import express from "express";
import path from "path";
import { createServer as createViteServer } from "vite";
import { GoogleGenAI } from "@google/genai";
import dotenv from "dotenv";
import { generateFullAsciiDoc } from "./src/data/textbookData";
import {
  getGitHubStatus,
  previewWorkspaceChanges,
  pushWorkspaceToGitHub,
} from "./githubSync";

dotenv.config();

async function startServer() {
  const app = express();
  const PORT = 3000;

  app.use(express.json());

  const requireLocalhostOnly = (
    req: express.Request,
    res: express.Response,
    next: express.NextFunction
  ) => {
    const remoteAddr = req.socket?.remoteAddress || "";
    const isLoopback =
      remoteAddr === "127.0.0.1" ||
      remoteAddr === "::1" ||
      remoteAddr === "::ffff:127.0.0.1";
    const hostHeader = req.headers.host || "";
    const isLocalHostHeader =
      hostHeader === `localhost:${PORT}` || hostHeader === `127.0.0.1:${PORT}`;
    const hasProxyHeaders = Boolean(
      req.headers["x-forwarded-for"] ||
        req.headers["x-forwarded-host"] ||
        req.headers["forwarded"]
    );
    if (!isLoopback || !isLocalHostHeader || hasProxyHeaders) {
      return res.status(403).json({ error: "Forbidden: localhost access only." });
    }
    return next();
  };

  app.get("/api/github/status", requireLocalhostOnly, async (_req, res) => {
    try {
      const status = await getGitHubStatus();
      return res.json(status);
    } catch (err: any) {
      return res.status(500).json({ error: err?.message || "Failed to check GitHub status." });
    }
  });

  app.get("/api/github/diff", requireLocalhostOnly, async (req, res) => {
    try {
      const branch = typeof req.query.branch === "string" ? req.query.branch : "main";
      const diff = await previewWorkspaceChanges(branch);
      return res.json(diff);
    } catch (err: any) {
      return res.status(400).json({ error: err?.message || "Failed to inspect workspace diff." });
    }
  });

  app.post("/api/github/push", requireLocalhostOnly, async (req, res) => {
    try {
      const { branch, message } = req.body || {};
      const result = await pushWorkspaceToGitHub(branch || "main", message || "");
      return res.json(result);
    } catch (err: any) {
      return res.status(400).json({ error: err?.message || "Failed to push to GitHub." });
    }
  });

  // Initialize Gemini AI Client lazily/safely
  const getGenAI = () => {
    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) {
      throw new Error("GEMINI_API_KEY environment variable is missing.");
    }
    return new GoogleGenAI({
      apiKey,
      httpOptions: {
        headers: {
          "User-Agent": "aistudio-build",
        },
      },
    });
  };

  // API Endpoint for Search & Inference Engine Iris Deduction & Proof Generation
  app.post("/api/gemini/deduce", async (req, res) => {
    try {
      const { conjecture, domain, proofType, rigorLevel, currentSteps } = req.body;

      if (!conjecture) {
        return res.status(400).json({ error: "Conjecture or statement is required." });
      }

      const ai = getGenAI();

      const systemInstruction = `
You are an inference engine specializing in the Counting-Iris Number System (Iris Number System / INS).
The Iris Number System is a constructive mathematical and physical framework unifying discrete topology, 6D Conformal Geometric Algebra (CGA) over canonical generators {e_1, e_2, e_3, e_4, e_⊙, e_∞}, Jaynesian logical (Maximum Entropy / MaxEnt) probability, Multiscale Resolution Analysis (MSRA / m-res) on discrete lattices G_N, complex and quaternion bivector subalgebras, the Unified Field Theory (Master Field Equation D F = J, Newton's laws of motion, gravitation as wave refraction, Maxwell's equations without "photons", conservation laws), and tautological proofs of classical conjectures (Goldbach, Riemann Hypothesis, Twin Primes, Collatz, Fermat).

Key Tautological Pillars:
1. Basis & 6D CGA Algebra: 4D basis {1, ι, ϖ, ϑ} with ι^2 = τ - 1 (τ = (1+√5)/2), embedded in 6D Conformal Geometric Algebra (CGA) with canonical generators {e_1, e_2, e_3, e_4, e_⊙, e_∞}, where e_1^2 = e_2^2 = e_3^2 = 1, e_4^2 = 0 (null causal time), and e_⊙^2 = e_∞^2 = 0 with e_⊙ · e_∞ = -1 (keep any internal diagonal basis strictly hidden from exposition). Quaternions H are embedded as bivectors (i = e23, j = e31, k = e12).
2. Primordial Postulate 0 & MSRA: Everything is an Operation of Measurement; terms that vanish physically under measurement are eliminated via Main Scale Projection (↓) onto bounded discrete grids G_N without unphysical infinite-divisibility limits.
3. Jaynesian MaxEnt: Logical probability distributions P(x) = (1/Z) exp(- sum λ_k A_k(x)) maximize discrete entropy S[P] = - sum P ln P under testable constraints, providing unbiased priors for prime density, statistical mechanics, and orbit dynamics.
4. Unified Field Theory & Tautological Deductions: Newton's laws, Maxwell's wave electrodynamics D F = J, gravitation as electromagnetic wave refraction, and conservation laws are integral parts of the mathematics system. Enforce finite-extent m-res fields, local direct-contact electromagnetic wave propagation at finite speed c on G_N, and finite interaction durations.

CRITICAL DIRECTIVE: Always use strictly and exclusively the Counting-Iris Number System framework. If external mathematics is ever required, do NOT proceed with the proof; instead, inform the user that external mathematics is required and request confirmation to proceed.

Generate a rigorous, step-by-step mathematical deduction or proof for the requested conjecture within the Counting-Iris Number System framework.

Return your response in structured JSON with the following schema:
{
  "title": "Title of the Theorem / Deduction",
  "domain": "${domain || 'Number Theory'}",
  "hypothesis": "Formal mathematical statement of assumptions",
  "conclusion": "Formal mathematical statement of conclusion",
  "rigorScore": 100,
  "summary": "High-level intuition and conceptual breakthrough of the proof",
  "steps": [
    {
      "stepNumber": 1,
      "statement": "Mathematical expression or proposition",
      "ruleUsed": "Axiom/Lemma name (e.g. 6D CGA Metric Signature, Primordial Postulate 0, Jaynesian MaxEnt, Main Scale Projection)",
      "justification": "Detailed explanation of why this step follows logically from previous steps or axioms",
      "status": "valid"
    }
  ],
  "potentialCounterexamples": ["Description of edge cases or non-trivial zero conditions if any"],
  "relatedLemmas": ["List of auxiliary lemmas derived during this deduction"]
}
`;

      const prompt = `
Generate a formal deduction proof for the following query:
Conjecture: "${conjecture}"
Domain: ${domain || "Number Theory"}
Proof Technique: ${proofType || "Constructive Spectral Induction"}
Rigor Level: ${rigorLevel || "Rigorous Formal Proof"}

${currentSteps && currentSteps.length > 0 ? `Existing partial proof steps:\n${JSON.stringify(currentSteps)}` : ""}

Ensure the steps use formal Iris Number System notation where applicable (using ι for Iris imaginary unit, ϖ for Phase spectrum, ϑ for Discrete measure, and ||x||_I for Iris norm) strictly within canonical 6D Conformal Geometric Algebra (CGA) and discrete m-res grids G_N.
`;

      const response = await ai.models.generateContent({
        model: "gemini-3.6-flash",
        contents: prompt,
        config: {
          systemInstruction,
          responseMimeType: "application/json",
          temperature: 0.2,
        },
      });

      const jsonText = response.text || "{}";
      const parsedData = JSON.parse(jsonText);

      return res.json({ success: true, proof: parsedData });
    } catch (err: any) {
      console.error("Gemini deduction error:", err);
      return res.status(500).json({
        error: err.message || "Failed to generate mathematical deduction via inference engine.",
      });
    }
  });

  // API Endpoint for Step Verification
  app.post("/api/gemini/verify-step", async (req, res) => {
    try {
      const { stepStatement, previousSteps, domain } = req.body;

      const ai = getGenAI();

      const prompt = `
In the Counting-Iris Number System (${domain || "Number Theory"}), strictly grounded in 6D Conformal Geometric Algebra (CGA) over canonical generators {e_1, e_2, e_3, e_4, e_⊙, e_∞}, Primordial Postulate 0, discrete m-res lattices G_N, Jaynesian MaxEnt inference, and the Unified Field Theory (D F = J, Newton's laws, Maxwell's wave equations, conservation laws), check the logical validity of the following proposed proof step:
Proposed Step: "${stepStatement}"
Previous Valid Steps: ${JSON.stringify(previousSteps || [])}

Return JSON format:
{
  "isValid": true/false,
  "confidence": 0.95,
  "explanation": "Detailed mathematical feedback on the validity or flaw in the step.",
  "suggestedCorrection": "Optional corrected statement if invalid"
}
`;

      const response = await ai.models.generateContent({
        model: "gemini-3.6-flash",
        contents: prompt,
        config: {
          responseMimeType: "application/json",
          temperature: 0.1,
        },
      });

      const parsed = JSON.parse(response.text || "{}");
      return res.json({ success: true, result: parsed });
    } catch (err: any) {
      console.error("Step verification error:", err);
      return res.status(500).json({ error: err.message || "Verification failed." });
    }
  });

  // API endpoint for dynamic synchronized AsciiDoc textbook download
  app.get(["/Iris_Number_System.adoc", "/public/Iris_Number_System.adoc"], (req, res) => {
    try {
      const adoc = generateFullAsciiDoc();
      res.setHeader("Content-Type", "text/plain; charset=utf-8");
      res.setHeader("Content-Disposition", 'inline; filename="Iris_Number_System.adoc"');
      return res.send(adoc);
    } catch (err: any) {
      console.error("Textbook adoc serving error:", err);
      return res.status(500).send("Error serving textbook adoc.");
    }
  });

  // Direct download endpoint for backup archive
  app.get(["/download-backup", "/api/download-backup"], (req, res) => {
    try {
      const backupPath = path.join(process.cwd(), "public", "iris_number_system_complete_backup.tar.gz");
      res.setHeader("Content-Type", "application/gzip");
      res.setHeader("Content-Disposition", 'attachment; filename="iris_number_system_complete_backup.tar.gz"');
      return res.sendFile(backupPath);
    } catch (err: any) {
      console.error("Backup serving error:", err);
      return res.status(500).send("Error serving backup archive.");
    }
  });

  // Vite middleware in development mode
  if (process.env.NODE_ENV !== "production") {
    const vite = await createViteServer({
      server: { middlewareMode: true, hmr: false },
      appType: "spa",
    });
    app.use(vite.middlewares);
  } else {
    const distPath = path.join(process.cwd(), "dist");
    app.use(express.static(distPath));
    app.get("*", (req, res) => {
      res.sendFile(path.join(distPath, "index.html"));
    });
  }

  app.listen(PORT, "0.0.0.0", () => {
    console.log(`Iris Server running on http://0.0.0.0:${PORT}`);
  });
}

startServer();
