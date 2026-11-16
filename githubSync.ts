import { execFile } from "child_process";
import fs from "fs/promises";
import path from "path";
import { promisify } from "util";

const execFileAsync = promisify(execFile);

export const GITHUB_REPO_SLUG = "chemoelectric/the-iris-number-system";
export const GITHUB_REPO_URL = `https://github.com/${GITHUB_REPO_SLUG}.git`;
const GIT_AUTHOR_NAME = "Barry Schwartz";
const GIT_AUTHOR_EMAIL = "150643+chemoelectric@users.noreply.github.com";

let syncInProgress = false;

function redactSecret(text: string, token?: string): string {
  if (!token) return text;
  const b64 = Buffer.from(`x-access-token:${token}`, "utf8").toString("base64");
  return text.split(token).join("[REDACTED]").split(b64).join("[REDACTED]");
}

async function runGit(
  args: string[],
  token?: string,
  timeoutMs = 60000
): Promise<{ stdout: string; stderr: string }> {
  try {
    const result = await execFileAsync("git", args, {
      cwd: process.cwd(),
      timeout: timeoutMs,
      maxBuffer: 10 * 1024 * 1024,
      env: {
        ...process.env,
        GIT_TERMINAL_PROMPT: "0",
      },
    });
    return {
      stdout: result.stdout || "",
      stderr: result.stderr || "",
    };
  } catch (err: any) {
    const rawMsg = [err?.stderr, err?.stdout, err?.message]
      .filter(Boolean)
      .join("\n")
      .trim();
    throw new Error(redactSecret(rawMsg || "Git command failed.", token));
  }
}

function validateBranch(branch: string): string {
  const clean = (branch || "main").trim();
  if (!/^[a-zA-Z0-9._/-]+$/.test(clean) || clean.includes("..")) {
    throw new Error("Invalid branch name.");
  }
  return clean;
}

export interface RemoteBranchInfo {
  name: string;
  sha: string;
}

export async function getGitHubStatus(): Promise<{
  repo: string;
  repoUrl: string;
  hasToken: boolean;
  branches: RemoteBranchInfo[];
  remoteError?: string;
}> {
  const token = (process.env.GITHUB_TOKEN || "").trim();
  const hasToken = token.length > 0;

  try {
    const { stdout } = await runGit(["ls-remote", "--heads", GITHUB_REPO_URL], token, 15000);
    const branches: RemoteBranchInfo[] = stdout
      .split("\n")
      .map((line) => line.trim())
      .filter(Boolean)
      .map((line) => {
        const [sha, ref] = line.split(/\s+/);
        return {
          name: (ref || "").replace(/^refs\/heads\//, ""),
          sha: sha || "",
        };
      })
      .filter((b) => b.name.length > 0);

    return {
      repo: GITHUB_REPO_SLUG,
      repoUrl: `https://github.com/${GITHUB_REPO_SLUG}`,
      hasToken,
      branches,
    };
  } catch (err: any) {
    return {
      repo: GITHUB_REPO_SLUG,
      repoUrl: `https://github.com/${GITHUB_REPO_SLUG}`,
      hasToken,
      branches: [{ name: "main", sha: "" }],
      remoteError: err?.message || "Could not query remote branches.",
    };
  }
}

async function prepareTempRepo(
  tmpDir: string,
  branch: string,
  token?: string
): Promise<string[]> {
  await fs.rm(tmpDir, { recursive: true, force: true });
  await fs.mkdir(tmpDir, { recursive: true });

  const gitDir = path.join(tmpDir, ".git");
  const workTree = process.cwd();

  await runGit(["-C", tmpDir, "init", "-b", branch], token);
  await runGit(["-C", tmpDir, "config", "core.filemode", "false"], token);

  // Exclude internal AI Studio scratch assets and git metadata at repo root
  const excludePath = path.join(gitDir, "info", "exclude");
  await fs.mkdir(path.dirname(excludePath), { recursive: true });
  await fs.writeFile(excludePath, "/assets/\n/.git/\n", "utf8");

  const authArgs: string[] = [];
  if (token) {
    const basicAuth = Buffer.from(`x-access-token:${token}`, "utf8").toString("base64");
    authArgs.push("-c", `http.https://github.com/.extraheader=AUTHORIZATION: basic ${basicAuth}`);
  }

  await runGit(
    [
      ...authArgs,
      "--git-dir",
      gitDir,
      "fetch",
      "--depth=1",
      GITHUB_REPO_URL,
      `refs/heads/${branch}:refs/remotes/origin/${branch}`,
    ],
    token,
    60000
  );

  // Align index and HEAD with remote branch without modifying workspace files
  await runGit(
    [
      "--git-dir",
      gitDir,
      "--work-tree",
      workTree,
      "reset",
      "--soft",
      `refs/remotes/origin/${branch}`,
    ],
    token
  );

  await runGit(["--git-dir", gitDir, "--work-tree", workTree, "add", "-A"], token);

  const { stdout: statusOut } = await runGit(
    ["--git-dir", gitDir, "--work-tree", workTree, "status", "--porcelain"],
    token
  );

  return statusOut
    .split("\n")
    .map((line) => line.trimEnd())
    .filter(Boolean);
}

export async function previewWorkspaceChanges(rawBranch: string): Promise<{
  branch: string;
  changes: string[];
}> {
  if (syncInProgress) {
    throw new Error("Another GitHub sync operation is currently in progress.");
  }

  const branch = validateBranch(rawBranch);
  const token = (process.env.GITHUB_TOKEN || "").trim();
  const tmpDir = path.join("/tmp", `iris-git-preview-${Date.now()}`);

  syncInProgress = true;
  try {
    const changes = await prepareTempRepo(tmpDir, branch, token || undefined);
    return { branch, changes };
  } finally {
    syncInProgress = false;
    await fs.rm(tmpDir, { recursive: true, force: true }).catch(() => {});
  }
}

export async function pushWorkspaceToGitHub(
  rawBranch: string,
  rawMessage: string
): Promise<{
  success: boolean;
  upToDate: boolean;
  branch: string;
  commitSha?: string;
  commitUrl?: string;
  changedCount: number;
  changes: string[];
  message: string;
}> {
  if (syncInProgress) {
    throw new Error("Another GitHub sync operation is currently in progress.");
  }

  const token = (process.env.GITHUB_TOKEN || "").trim();
  if (!token) {
    throw new Error(
      "GITHUB_TOKEN is not available in the server environment (process.env.GITHUB_TOKEN)."
    );
  }

  const branch = validateBranch(rawBranch);
  const commitMessage =
    (rawMessage || "").trim() ||
    `Sync workspace updates (${new Date().toISOString()})`;

  const tmpDir = path.join("/tmp", `iris-git-push-${Date.now()}`);
  const gitDir = path.join(tmpDir, ".git");
  const workTree = process.cwd();

  syncInProgress = true;
  try {
    const changes = await prepareTempRepo(tmpDir, branch, token);

    if (changes.length === 0) {
      return {
        success: true,
        upToDate: true,
        branch,
        changedCount: 0,
        changes: [],
        message: `Workspace already matches origin/${branch}. Nothing to commit.`,
      };
    }

    await runGit(
      [
        "--git-dir",
        gitDir,
        "--work-tree",
        workTree,
        "-c",
        `user.name=${GIT_AUTHOR_NAME}`,
        "-c",
        `user.email=${GIT_AUTHOR_EMAIL}`,
        "commit",
        "-m",
        commitMessage,
      ],
      token
    );

    const { stdout: shaOut } = await runGit(
      ["--git-dir", gitDir, "rev-parse", "HEAD"],
      token
    );
    const commitSha = shaOut.trim();

    const basicAuth = Buffer.from(`x-access-token:${token}`, "utf8").toString("base64");
    await runGit(
      [
        "-c",
        `http.https://github.com/.extraheader=AUTHORIZATION: basic ${basicAuth}`,
        "--git-dir",
        gitDir,
        "push",
        GITHUB_REPO_URL,
        `HEAD:refs/heads/${branch}`,
      ],
      token,
      90000
    );

    return {
      success: true,
      upToDate: false,
      branch,
      commitSha,
      commitUrl: `https://github.com/${GITHUB_REPO_SLUG}/commit/${commitSha}`,
      changedCount: changes.length,
      changes: changes.slice(0, 100),
      message: `Pushed ${changes.length} change(s) to ${branch} (${commitSha.slice(0, 7)}).`,
    };
  } finally {
    syncInProgress = false;
    await fs.rm(tmpDir, { recursive: true, force: true }).catch(() => {});
  }
}
