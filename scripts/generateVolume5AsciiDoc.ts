import fs from 'fs';
import path from 'path';
import { SPECTRAL_CIRCUITS_TEXTBOOK, generateFullAsciiDoc } from '../src/data/textbookData';

const adocContent = generateFullAsciiDoc(SPECTRAL_CIRCUITS_TEXTBOOK);

const publicDir = path.join(process.cwd(), 'public');
const fileName = SPECTRAL_CIRCUITS_TEXTBOOK.filename;
const filePath = path.join(publicDir, fileName);

fs.writeFileSync(filePath, adocContent, 'utf8');
console.log(`Successfully generated ${filePath}`);
