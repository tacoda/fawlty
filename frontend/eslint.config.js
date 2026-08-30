import js from "@eslint/js";
import svelte from "eslint-plugin-svelte";
import globals from "globals";

// Narrow on purpose, same reasoning as backend/.rubocop.yml: every rule here
// is one the charter already asks for, so a finding is worth acting on.
export default [
  { ignores: ["dist/**", "node_modules/**"] },

  js.configs.recommended,
  ...svelte.configs["flat/recommended"],

  {
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: "module",
      globals: { ...globals.browser }
    },
    rules: {
      // The commit gate blocks these at commit time. This catches them sooner.
      "no-console": "error",
      "no-debugger": "error",
      "no-unused-vars": ["error", { argsIgnorePattern: "^_" }],
      eqeqeq: ["error", "smart"]
    }
  },

  // Build config runs in Node, not the browser.
  {
    files: ["*.config.js"],
    languageOptions: { globals: { ...globals.node } }
  }
];
