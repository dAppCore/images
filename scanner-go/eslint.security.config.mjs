// /etc/scanner/eslint.security.config.mjs
// Bundled ESLint security ruleset for core-scanner.
//
// Usage (scan an arbitrary project without its own eslint config):
//   eslint --config /etc/scanner/eslint.security.config.mjs --no-eslintrc .
//
// Covers:
//   eslint-plugin-security      — Node.js security anti-patterns
//   eslint-plugin-no-secrets    — hardcoded credentials / tokens
//   eslint-plugin-n             — Node.js best-practice rules
//   @microsoft/eslint-plugin-sdl — Microsoft SDL security rules

import security from "eslint-plugin-security";
import noSecrets from "eslint-plugin-no-secrets";
import nodePlugin from "eslint-plugin-n";
import sdl from "@microsoft/eslint-plugin-sdl";

export default [
  {
    plugins: {
      security,
      "no-secrets": noSecrets,
      n: nodePlugin,
      sdl,
    },
    rules: {
      // eslint-plugin-security — all rules at warn level; escalate to error in CI
      "security/detect-buffer-noassert": "warn",
      "security/detect-child-process": "warn",
      "security/detect-disable-mustache-escape": "error",
      "security/detect-eval-with-expression": "error",
      "security/detect-new-buffer": "warn",
      "security/detect-no-csrf-before-method-override": "error",
      "security/detect-non-literal-fs-filename": "warn",
      "security/detect-non-literal-regexp": "warn",
      "security/detect-non-literal-require": "warn",
      "security/detect-object-injection": "warn",
      "security/detect-possible-timing-attacks": "warn",
      "security/detect-pseudoRandomBytes": "error",
      "security/detect-unsafe-regex": "error",

      // eslint-plugin-no-secrets — catch hardcoded creds/tokens
      "no-secrets/no-secrets": ["error", { tolerance: 4.2 }],

      // eslint-plugin-n — Node.js hygiene
      "n/no-deprecated-api": "error",
      "n/no-extraneous-require": "warn",
      "n/no-missing-require": "warn",
      "n/no-process-exit": "warn",
      "n/no-unpublished-require": "warn",

      // @microsoft/eslint-plugin-sdl — SDL security rules
      "sdl/no-inner-html": "error",
      "sdl/no-unsafe-alloc": "error",
      "sdl/no-postmessage-star-origin": "error",
      "sdl/no-html-method": "error",
      "sdl/no-cookies": "warn",
      "sdl/no-document-domain": "error",
      "sdl/no-document-write": "error",
    },
  },
];
