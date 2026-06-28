import { defineConfig } from "oxlint"
import core from "ultracite/oxlint/core"
import react from "ultracite/oxlint/react"
import tanstack from "ultracite/oxlint/tanstack"
import vitest from "ultracite/oxlint/vitest"

export default defineConfig({
  extends: [core, vitest, tanstack, react],
  ignorePatterns: [
    ...(core.ignorePatterns ?? []),
    "*.gen.ts",
    "*.md",
    "**/migrations/**",
    ".agents/**",
    ".claude/**",
  ],
  rules: {
    "func-style": "off",
    "max-statements": [
      "warn",
      {
        max: 20,
      },
    ],
    "no-use-before-define": [
      "warn",
      {
        classes: true,
        functions: false,
        variables: true,
      },
    ],
    "no-inline-comments": [
      "warn",
      {
        ignorePattern: "@__PURE__",
      },
    ],
    "typescript/consistent-type-definitions": ["error", "type"],
    "sort-keys": "off",
  },
})
