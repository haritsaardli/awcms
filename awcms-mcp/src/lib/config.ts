import dotenv from "dotenv";
import path from "path";
import fs from "fs";
import { fileURLToPath } from "url";

// Helper to get directory names
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Project Root is 3 levels up from src/lib (awcms-mcp/src/lib -> awcms-mcp/src -> awcms-mcp -> awcms-dev)
export const PROJECT_ROOT = path.resolve(__dirname, "../../../");

// Load Environment Variables with priority:
// 1. awcms-mcp/.env
// 2. awcms/.env
export function loadConfig() {
  const localEnvPath = path.resolve(PROJECT_ROOT, "awcms-mcp/.env");
  const repoEnvPath = path.resolve(PROJECT_ROOT, "awcms/.env");

  let envVars = { ...process.env };

  if (fs.existsSync(localEnvPath)) {
    console.error(`[Config] Loading from local: ${localEnvPath}`);
    const parsed = dotenv.parse(fs.readFileSync(localEnvPath));
    envVars = { ...envVars, ...parsed };
  } else if (fs.existsSync(repoEnvPath)) {
    console.error(`[Config] Loading from repository: ${repoEnvPath}`);
    const parsed = dotenv.parse(fs.readFileSync(repoEnvPath));
    envVars = { ...envVars, ...parsed };
  } else {
    console.error("[Config] Warning: No .env file found.");
  }

  return envVars;
}

export const env = loadConfig();
