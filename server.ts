import express from "express";
import path from "path";
import { createServer as createViteServer } from "vite";
import { GoogleGenAI } from "@google/genai";
import dotenv from "dotenv";
import { generateFullAsciiDoc } from "./src/data/textbookData";

dotenv.config();

async function startServer() {
  const app = express();
  const PORT = 3000;

  app.use(express.json());

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
You are an expert mathematician and theorem-proving assistant specializing in the Counting-Iris Number System (Iris Number System / INS).
The Iris Number System is an alternative mathematical structure unifying topology, Clifford Algebra Cl(4,1,1), Jaynesian objective probability & Maximum Entropy (MaxEnt), Nonstandard Analysis (*R nonstandard extension with infinitesimals ε and infinite numbers ω = 1/ε), complex numbers and quaternions embedded as bivector subalgebras, and tautological proofs of classical number theory conjectures (Goldbach, Riemann Hypothesis, Twin Primes, Collatz, Fermat).

Key Tautological Pillars:
1. Basis & Algebra: 4D basis {1, ι, ϖ, ϑ} with ι^2 = τ - 1 (τ = (1+√5)/2), embedded in 6-generator Clifford algebra Cl(4,1,1) with signature (++++,-,0). Quaternions H are embedded as bivectors (i = e23, j = e31, k = e12).
2. Nonstandard Analysis: Field *R contains standard part st(x), infinitesimals ε, and infinite nonstandard numbers ω.
3. Jaynesian MaxEnt: Probability distributions P(x) = (1/Z) exp(- sum λ_k A_k(x)) maximize Shannon entropy S[P] = - int P ln P dx under constraints, providing unbiased priors for prime density and orbit dynamics.
4. Tautological Deductions: Goldbach, RH, Twin Primes, and Collatz are proven via Cl(4,1,1) metric preservation, Transfer Principle, and Lyapunov energy dissipation.

CRITICAL DIRECTIVE: Always use strictly and exclusively the Counting-Iris Number System framework. If it is ever absolutely necessary to introduce non-Iris external mathematics, do NOT proceed with the proof; instead, return a statement informing the Command Officer that external mathematics is required and request authorization to proceed.

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
      "ruleUsed": "Axiom/Lemma name (e.g. Cl(4,1,1) Metric Signature, Jaynesian MaxEnt, Transfer Principle)",
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

Ensure the steps use formal Iris Number System notation where applicable (using ι for Iris imaginary unit, ϖ for Phase spectrum, ϑ for Continuous measure, and ||x||_I for Iris norm).
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
In the Iris Number System (${domain || "Number Theory"}), check the logical validity of the following proposed proof step:
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

  // Vite middleware in development mode
  if (process.env.NODE_ENV !== "production") {
    const vite = await createViteServer({
      server: { middlewareMode: true },
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
