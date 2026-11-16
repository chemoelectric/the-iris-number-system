import React, { useEffect, useState } from 'react';
import { X, GitBranch, UploadCloud, RefreshCw, CheckCircle2, AlertTriangle, ExternalLink } from 'lucide-react';

interface RemoteBranchInfo {
  name: string;
  sha: string;
}

interface GitHubStatusResponse {
  repo: string;
  repoUrl: string;
  hasToken: boolean;
  branches: RemoteBranchInfo[];
  remoteError?: string;
}

interface PushResult {
  success: boolean;
  upToDate: boolean;
  branch: string;
  commitSha?: string;
  commitUrl?: string;
  changedCount: number;
  changes: string[];
  message: string;
}

interface GitHubSyncModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export const GitHubSyncModal: React.FC<GitHubSyncModalProps> = ({ isOpen, onClose }) => {
  const [status, setStatus] = useState<GitHubStatusResponse | null>(null);
  const [loadingStatus, setLoadingStatus] = useState(false);
  const [branch, setBranch] = useState('main');
  const [commitMessage, setCommitMessage] = useState('Sync Iris workspace updates');
  const [diffChanges, setDiffChanges] = useState<string[] | null>(null);
  const [loadingDiff, setLoadingDiff] = useState(false);
  const [pushing, setPushing] = useState(false);
  const [pushResult, setPushResult] = useState<PushResult | null>(null);
  const [error, setError] = useState<string | null>(null);

  const fetchStatus = async () => {
    setLoadingStatus(true);
    setError(null);
    try {
      const res = await fetch('/api/github/status');
      const data = await res.json();
      if (!res.ok) {
        throw new Error(data?.error || 'Failed to check GitHub status.');
      }
      setStatus(data);
      if (data.branches?.length > 0 && !data.branches.some((b: RemoteBranchInfo) => b.name === branch)) {
        setBranch(data.branches[0].name);
      }
    } catch (err: any) {
      setError(err?.message || 'Could not reach backend GitHub status endpoint.');
    } finally {
      setLoadingStatus(false);
    }
  };

  useEffect(() => {
    if (isOpen) {
      setDiffChanges(null);
      setPushResult(null);
      fetchStatus();
    }
  }, [isOpen]);

  const handlePreviewDiff = async () => {
    setLoadingDiff(true);
    setError(null);
    setPushResult(null);
    try {
      const res = await fetch(`/api/github/diff?branch=${encodeURIComponent(branch)}`);
      const data = await res.json();
      if (!res.ok) {
        throw new Error(data?.error || 'Failed to inspect changes.');
      }
      setDiffChanges(data.changes || []);
    } catch (err: any) {
      setError(err?.message || 'Failed to inspect workspace changes.');
    } finally {
      setLoadingDiff(false);
    }
  };

  const handlePush = async () => {
    setPushing(true);
    setError(null);
    setPushResult(null);
    try {
      const res = await fetch('/api/github/push', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          branch,
          message: commitMessage,
        }),
      });
      const data = await res.json();
      if (!res.ok) {
        throw new Error(data?.error || 'Push failed.');
      }
      setPushResult(data);
      setDiffChanges(data.upToDate ? [] : null);
      fetchStatus();
    } catch (err: any) {
      setError(err?.message || 'Failed to push to GitHub.');
    } finally {
      setPushing(false);
    }
  };

  if (!isOpen) return null;

  const selectedBranchInfo = status?.branches.find((b) => b.name === branch);

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-3 sm:p-4 bg-black/80">
      <div className="bg-[#161616] max-w-xl w-full max-h-[90vh] overflow-y-auto p-5 sm:p-6 space-y-5 text-slate-100">
        {/* Header */}
        <div className="flex items-center justify-between pb-3 bg-[#161616]">
          <div className="flex items-center space-x-2.5">
            <GitBranch className="w-5 h-5 text-slate-200" />
            <div>
              <h3 className="text-base font-bold text-white">GitHub Repository Sync</h3>
              <p className="text-xs text-slate-400 font-mono">
                {status?.repo || 'chemoelectric/the-iris-number-system'}
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            aria-label="Close GitHub sync dialog"
            className="p-2 text-slate-300 hover:text-white bg-[#242424] hover:bg-[#303030]"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Server Token & Remote Status */}
        <div className="bg-[#121212] p-3.5 space-y-2 text-xs">
          <div className="flex items-center justify-between gap-2">
            <span className="text-slate-400">Server GITHUB_TOKEN:</span>
            {loadingStatus ? (
              <span className="font-mono text-slate-400">Checking...</span>
            ) : status?.hasToken ? (
              <span className="font-mono text-slate-100 font-semibold">Detected in server runtime</span>
            ) : (
              <span className="font-mono text-slate-300">Not detected in server runtime</span>
            )}
          </div>
          <div className="flex items-center justify-between gap-2">
            <span className="text-slate-400">Remote HEAD ({branch}):</span>
            <span className="font-mono text-slate-300">
              {selectedBranchInfo?.sha ? selectedBranchInfo.sha.slice(0, 10) : '—'}
            </span>
          </div>
          {status?.remoteError && (
            <div className="text-slate-300 pt-1 text-[11px] font-mono">
              Remote check: {status.remoteError}
            </div>
          )}
        </div>

        {/* Branch & Commit Message */}
        <div className="space-y-3">
          <div>
            <label className="block text-xs text-slate-400 mb-1">Target Branch</label>
            <div className="flex items-center gap-2">
              <select
                value={branch}
                onChange={(e) => {
                  setBranch(e.target.value);
                  setDiffChanges(null);
                }}
                className="flex-1 bg-[#222222] text-slate-100 text-xs font-mono px-3 py-2"
              >
                {(status?.branches?.length ? status.branches : [{ name: 'main', sha: '' }]).map((b) => (
                  <option key={b.name} value={b.name}>
                    {b.name}
                  </option>
                ))}
              </select>
              <button
                onClick={fetchStatus}
                disabled={loadingStatus}
                title="Refresh remote branches"
                className="px-3 py-2 bg-[#242424] hover:bg-[#303030] text-slate-200 text-xs flex items-center gap-1.5"
              >
                <RefreshCw className={`w-3.5 h-3.5 ${loadingStatus ? 'animate-spin' : ''}`} />
                <span className="hidden sm:inline">Refresh</span>
              </button>
            </div>
          </div>

          <div>
            <label className="block text-xs text-slate-400 mb-1">Commit Message</label>
            <input
              type="text"
              value={commitMessage}
              onChange={(e) => setCommitMessage(e.target.value)}
              placeholder="Describe changes to commit and push"
              className="w-full bg-[#222222] text-slate-100 text-xs px-3 py-2"
            />
          </div>
        </div>

        {/* Diff Preview */}
        {diffChanges !== null && (
          <div className="bg-[#121212] p-3 space-y-2">
            <div className="text-xs font-semibold text-slate-200">
              Pending Workspace Differences vs origin/{branch}: {diffChanges.length}
            </div>
            {diffChanges.length === 0 ? (
              <div className="text-xs text-slate-400 font-mono">
                Workspace matches origin/{branch}.
              </div>
            ) : (
              <div className="max-h-40 overflow-y-auto font-mono text-[11px] text-slate-300 space-y-0.5">
                {diffChanges.slice(0, 100).map((line, idx) => (
                  <div key={idx} className="truncate">
                    {line}
                  </div>
                ))}
                {diffChanges.length > 100 && (
                  <div className="text-slate-500">
                    ...and {diffChanges.length - 100} more file(s)
                  </div>
                )}
              </div>
            )}
          </div>
        )}

        {/* Error Message */}
        {error && (
          <div className="bg-[#242424] p-3 text-xs text-slate-200 flex items-start gap-2">
            <AlertTriangle className="w-4 h-4 shrink-0 mt-0.5" />
            <div className="font-mono whitespace-pre-wrap break-words">{error}</div>
          </div>
        )}

        {/* Success Message */}
        {pushResult && (
          <div className="bg-[#242424] p-3 text-xs text-slate-100 space-y-2">
            <div className="flex items-start gap-2">
              <CheckCircle2 className="w-4 h-4 shrink-0 mt-0.5" />
              <div>{pushResult.message}</div>
            </div>
            {pushResult.commitUrl && (
              <a
                href={pushResult.commitUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-1.5 text-xs font-mono text-slate-200 underline hover:text-white"
              >
                <span>View commit on GitHub</span>
                <ExternalLink className="w-3.5 h-3.5" />
              </a>
            )}
          </div>
        )}

        {/* Action Buttons */}
        <div className="flex flex-col-reverse sm:flex-row sm:items-center sm:justify-between gap-2 pt-2">
          <button
            onClick={handlePreviewDiff}
            disabled={loadingDiff || pushing}
            className="px-3.5 py-2 bg-[#242424] hover:bg-[#303030] text-slate-200 text-xs font-medium disabled:opacity-50"
          >
            {loadingDiff ? 'Checking Differences...' : 'Check Changes'}
          </button>

          <button
            onClick={handlePush}
            disabled={pushing || loadingStatus || !status?.hasToken}
            className="px-4 py-2 bg-[#333333] hover:bg-[#404040] text-white text-xs font-semibold flex items-center justify-center gap-2 disabled:opacity-50"
          >
            <UploadCloud className="w-4 h-4" />
            <span>{pushing ? 'Committing & Pushing...' : `Commit & Push to ${branch}`}</span>
          </button>
        </div>
      </div>
    </div>
  );
};
