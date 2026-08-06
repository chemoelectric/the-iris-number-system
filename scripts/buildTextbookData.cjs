const fs = require("fs");

function parseAdocFile(filePath, id, defaultTitle, defaultSubtitle, author, description) {
  let adocContent = fs.readFileSync(filePath, "utf8");
  adocContent = adocContent
    .replace(/=\s*\\downarrow/g, "= \\downarrow")
    .replace(/=\s*↓/g, "= ↓");

  const chapterBlocks = adocContent.split(/^= /m);
  const chapters = [];

  for (let i = 1; i < chapterBlocks.length; i++) {
    const block = chapterBlocks[i];
    const lines = block.split("\n");
    const chapTitle = lines[0].trim();
    
    if (chapTitle.toLowerCase().includes("index of formal statements")) continue;
    if (chapTitle.includes("The Iris Number System:")) continue; // Skip book title line if split matched header
    
    const chapId = "chap-" + chapTitle.toLowerCase().replace(/[^a-z0-9]+/g, "-");
    const sectionBlocks = ("\n" + lines.slice(1).join("\n")).split(/\n(?=={2,3} )/);
    
    const sections = [];
    let chapSummary = "";
    
    sectionBlocks.forEach((secBlock) => {
      const secLines = secBlock.trim().split("\n");
      if (secLines[0].startsWith("==")) {
        const secHeader = secLines[0].replace(/^={2,3}\s*/, "").trim();
        const secId = "sec-" + secHeader.toLowerCase().replace(/[^a-z0-9]+/g, "-");
        const secContent = secLines.join("\n").trim();
        sections.push({
          id: secId,
          title: secHeader,
          contentAsciiDoc: secContent
        });
      } else {
        if (secBlock.trim()) {
          chapSummary = secBlock.trim();
        }
      }
    });

    if (sections.length === 0) {
      sections.push({
        id: chapId + "-sec-1",
        title: chapTitle,
        contentAsciiDoc: lines.slice(1).join("\n").trim()
      });
    }

    chapters.push({
      id: chapId,
      title: chapTitle,
      summary: chapSummary,
      sections: sections
    });
  }

  return {
    id,
    title: defaultTitle,
    subtitle: defaultSubtitle,
    author,
    version: "2.1.0",
    lastUpdated: "2026-08-01",
    description,
    chapters
  };
}

const vol1 = parseAdocFile(
  fs.existsSync("public/Iris_Number_System-01-Volume_I_Fundamentals.adoc")
    ? "public/Iris_Number_System-01-Volume_I_Fundamentals.adoc"
    : "public/Iris_Number_System.adoc",
  "textbook-iris-number-system",
  "The Iris Number System",
  "Fundamentals",
  "Frédéric Blondel Custer",
  "A Rigorous Constructive Foundation for Mathematics and Physics"
);

const vol2 = parseAdocFile(
  fs.existsSync("public/Iris_Number_System-02-Volume_II_Number_Theory_etc.adoc")
    ? "public/Iris_Number_System-02-Volume_II_Number_Theory_etc.adoc"
    : "public/Iris_Number_System_Applications_to_Number_Theory.adoc",
  "textbook-iris-number-theory",
  "The Iris Number System",
  "Applications to Number Theory, Analysis, Probability Theory, Statistics",
  "Frédéric Blondel Custer",
  "A Rigorous Application of the Counting-Iris Number System to Classical Problems in Number Theory, Analysis, Probability Theory, and Statistics"
);

const vol3 = parseAdocFile(
  fs.existsSync("public/Iris_Number_System-03-Volume_III_Geometry_Algebra_etc.adoc")
    ? "public/Iris_Number_System-03-Volume_III_Geometry_Algebra_etc.adoc"
    : "public/Iris_Number_System_Geometry_Algebra_etc.adoc",
  "textbook-iris-geometry-algebra",
  "The Iris Number System",
  "Applications to Geometry, Algebra, Representations, Topology, Lattices, Categories, Combinatorics",
  "Frédéric Blondel Custer",
  "A Rigorous Foundation for Geometry, Algebra, Representations, Topology, Lattices, Categories, and Combinatorics in the Iris Number System"
);

const vol4 = parseAdocFile(
  "public/Iris_Number_System-04-Volume_IV_Physics_etc.adoc",
  "textbook-iris-physics-chemistry-etc",
  "The Iris Number System",
  "Applications to Physics, Chemistry, Astronomy, Engineering, Communications, Computing, Time-Binding",
  "Frédéric Blondel Custer",
  "A Rigorous Application of the Counting-Iris Number System and the Master Field Equation to Physics, Chemistry, Astronomy, Engineering, Communications, Computing, and Time-Binding"
);

vol1.filename = "Iris_Number_System-01-Volume_I_Fundamentals.adoc";
vol2.filename = "Iris_Number_System-02-Volume_II_Number_Theory_etc.adoc";
vol3.filename = "Iris_Number_System-03-Volume_III_Geometry_Algebra_etc.adoc";
vol4.filename = "Iris_Number_System-04-Volume_IV_Physics_etc.adoc";

function generateFormalIndexChapterObj(chapters) {
  const entries = [];
  chapters.filter((c) => c.id !== "chap-index").forEach((chap) => {
    chap.sections.forEach((sec) => {
      const lines = sec.contentAsciiDoc.split("\n");
      for (let i = 0; i < lines.length; i++) {
        const line = lines[i].trim();
        if (line.match(/^\[(POSTULATE|THEOREM|DEFINITION|AXIOM|LEMMA|COROLLARY)\]$/i)) {
          const type = line.replace(/[\[\]]/g, "").toUpperCase();
          let anchorId = "";
          if (i > 0 && lines[i - 1].trim().match(/^\[#([a-zA-Z0-9_-]+)\]$/)) {
            anchorId = lines[i - 1].trim().match(/^\[#([a-zA-Z0-9_-]+)\]$/)[1];
          }
          let title = `${type}`;
          if (i + 1 < lines.length && lines[i + 1].trim().startsWith(".")) {
            title = lines[i + 1].trim().substring(1).trim();
          }
          if (!anchorId) {
            anchorId = `${type.toLowerCase()}-${title.toLowerCase().replace(/[^a-z0-9]+/g, "-")}`;
          }
          entries.push({
            type,
            title,
            anchorId,
            chapterTitle: chap.title,
            sectionTitle: sec.title,
          });
        }
      }
    });
  });

  const postulates = entries.filter((e) => e.type === "POSTULATE");
  const theorems = entries.filter((e) => e.type === "THEOREM");
  const definitions = entries.filter((e) => e.type === "DEFINITION");
  const others = entries.filter((e) => !["POSTULATE", "THEOREM", "DEFINITION"].includes(e.type));

  let indexAdoc = "== Index of Formal Statements\n\n";
  indexAdoc += "This index lists all formal Postulates, Theorems, and Definitions established across the textbook.\n\n";

  if (postulates.length > 0) {
    indexAdoc += "=== Postulates\n\n";
    postulates.forEach((e) => {
      indexAdoc += `* xref:${e.anchorId}[**${e.title}**]  -- Chapter: *${e.chapterTitle}* | Section: *${e.sectionTitle}*\n`;
    });
    indexAdoc += "\n";
  }

  if (theorems.length > 0) {
    indexAdoc += "=== Theorems\n\n";
    theorems.forEach((e) => {
      indexAdoc += `* xref:${e.anchorId}[**${e.title}**]  -- Chapter: *${e.chapterTitle}* | Section: *${e.sectionTitle}*\n`;
    });
    indexAdoc += "\n";
  }

  if (definitions.length > 0) {
    indexAdoc += "=== Definitions\n\n";
    definitions.forEach((e) => {
      indexAdoc += `* xref:${e.anchorId}[**${e.title}**]  -- Chapter: *${e.chapterTitle}* | Section: *${e.sectionTitle}*\n`;
    });
    indexAdoc += "\n";
  }

  if (others.length > 0) {
    indexAdoc += "=== Other Formal Statements\n\n";
    others.forEach((e) => {
      indexAdoc += `* xref:${e.anchorId}[**${e.title}**]  -- Chapter: *${e.chapterTitle}* | Section: *${e.sectionTitle}*\n`;
    });
    indexAdoc += "\n";
  }

  return {
    id: "chap-index",
    title: "Index of Formal Statements",
    summary: "Index of all formal Postulates, Theorems, and Definitions in the Iris Number System.",
    sections: [
      {
        id: "sec-index-formal-statements",
        title: "Index of Formal Statements",
        contentAsciiDoc: indexAdoc,
      },
    ],
  };
}

vol1.chapters.push(generateFormalIndexChapterObj(vol1.chapters));
vol2.chapters.push(generateFormalIndexChapterObj(vol2.chapters));
vol3.chapters.push(generateFormalIndexChapterObj(vol3.chapters));
vol4.chapters.push(generateFormalIndexChapterObj(vol4.chapters));

const fileHeader = `import { TextbookChapter, Textbook } from "../types";

export function generateFormalIndexChapter(chapters: TextbookChapter[]): TextbookChapter {
  interface FormalEntry {
    type: string;
    title: string;
    anchorId: string;
    chapterTitle: string;
    sectionTitle: string;
  }

  const entries: FormalEntry[] = [];

  chapters.filter((c) => c.id !== "chap-index").forEach((chap) => {
    chap.sections.forEach((sec) => {
      const lines = sec.contentAsciiDoc.split("\\n");
      for (let i = 0; i < lines.length; i++) {
        const line = lines[i].trim();
        if (line.match(/^\\[(POSTULATE|THEOREM|DEFINITION|AXIOM|LEMMA|COROLLARY)\\]$/i)) {
          const type = line.replace(/[\\[\\]]/g, "").toUpperCase();
          let anchorId = "";
          if (i > 0 && lines[i - 1].trim().match(/^\\[#([a-zA-Z0-9_-]+)\\]$/)) {
            anchorId = lines[i - 1].trim().match(/^\\[#([a-zA-Z0-9_-]+)\\]$/)![1];
          }
          let title = \`\${type}\`;
          if (i + 1 < lines.length && lines[i + 1].trim().startsWith(".")) {
            title = lines[i + 1].trim().substring(1).trim();
          }
          if (!anchorId) {
            anchorId = \`\${type.toLowerCase()}-\${title.toLowerCase().replace(/[^a-z0-9]+/g, "-")}\`;
          }
          entries.push({
            type,
            title,
            anchorId,
            chapterTitle: chap.title,
            sectionTitle: sec.title,
          });
        }
      }
    });
  });

  const postulates = entries.filter((e) => e.type === "POSTULATE");
  const theorems = entries.filter((e) => e.type === "THEOREM");
  const definitions = entries.filter((e) => e.type === "DEFINITION");
  const others = entries.filter((e) => !["POSTULATE", "THEOREM", "DEFINITION"].includes(e.type));

  let indexAdoc = "== Index of Formal Statements\\n\\n";
  indexAdoc += "This index lists all formal Postulates, Theorems, and Definitions established across the textbook.\\n\\n";

  if (postulates.length > 0) {
    indexAdoc += "=== Postulates\\n\\n";
    postulates.forEach((e) => {
      indexAdoc += \`* xref:\${e.anchorId}[**\${e.title}**]  -- Chapter: *\${e.chapterTitle}* | Section: *\${e.sectionTitle}*\\n\`;
    });
    indexAdoc += "\\n";
  }

  if (theorems.length > 0) {
    indexAdoc += "=== Theorems\\n\\n";
    theorems.forEach((e) => {
      indexAdoc += \`* xref:\${e.anchorId}[**\${e.title}**]  -- Chapter: *\${e.chapterTitle}* | Section: *\${e.sectionTitle}*\\n\`;
    });
    indexAdoc += "\\n";
  }

  if (definitions.length > 0) {
    indexAdoc += "=== Definitions\\n\\n";
    definitions.forEach((e) => {
      indexAdoc += \`* xref:\${e.anchorId}[**\${e.title}**]  -- Chapter: *\${e.chapterTitle}* | Section: *\${e.sectionTitle}*\\n\`;
    });
    indexAdoc += "\\n";
  }

  if (others.length > 0) {
    indexAdoc += "=== Other Formal Statements\\n\\n";
    others.forEach((e) => {
      indexAdoc += \`* xref:\${e.anchorId}[**\${e.title}**]  -- Chapter: *\${e.chapterTitle}* | Section: *\${e.sectionTitle}*\\n\`;
    });
    indexAdoc += "\\n";
  }

  return {
    id: "chap-index",
    title: "Index of Formal Statements",
    summary: "Index of all formal Postulates, Theorems, and Definitions in the Iris Number System.",
    sections: [
      {
        id: "sec-index-formal-statements",
        title: "Index of Formal Statements",
        contentAsciiDoc: indexAdoc,
      },
    ],
  };
}

export function getCompleteChapters(chapters: TextbookChapter[]): TextbookChapter[] {
  const baseChapters = chapters.filter((c) => c.id !== "chap-index");
  const indexChap = generateFormalIndexChapter(baseChapters);
  return [...baseChapters, indexChap];
}
`;

const exportStr = `
export const INITIAL_TEXTBOOK: Textbook = ${JSON.stringify(vol1, null, 2)};

export const NUMBER_THEORY_TEXTBOOK: Textbook = ${JSON.stringify(vol2, null, 2)};

export const GEOMETRY_ALGEBRA_TEXTBOOK: Textbook = ${JSON.stringify(vol3, null, 2)};

export const PHYSICS_CHEMISTRY_TEXTBOOK: Textbook = ${JSON.stringify(vol4, null, 2)};

export const TEXTBOOK_VOLUMES: Textbook[] = [INITIAL_TEXTBOOK, NUMBER_THEORY_TEXTBOOK, GEOMETRY_ALGEBRA_TEXTBOOK, PHYSICS_CHEMISTRY_TEXTBOOK];

export function generateFullAsciiDoc(textbook = INITIAL_TEXTBOOK): string {
  const chapters = getCompleteChapters(textbook.chapters);
  let adoc = \`= \${textbook.title}: \${textbook.subtitle || "Fundamentals"}\\n\`;
  adoc += \`:subtitle: \${textbook.subtitle || "Fundamentals"}\\n\`;
  adoc += \`:author: \${textbook.author}\\n\`;
  adoc += \`:doctype: book\\n\`;
  adoc += \`:toc: left\\n\`;
  adoc += \`:toc-title: Table of Contents\\n\`;
  adoc += \`:stem: latexmath\\n\`;
  adoc += \`:sectnums!:\\n\\n\`;
  adoc += \`\${textbook.description}\\n\\n\`;

  chapters.forEach((chap) => {
    adoc += \`= \${chap.title}\\n\\n\`;
    if (chap.summary) {
      adoc += \`\${chap.summary}\\n\\n\`;
    }
    chap.sections.forEach((sec) => {
      adoc += \`\${sec.contentAsciiDoc.trim()}\\n\\n\`;
    });
  });

  return adoc;
}
`;

fs.writeFileSync("src/data/textbookData.ts", fileHeader + exportStr, "utf8");
console.log("Re-generated src/data/textbookData.ts successfully!");
