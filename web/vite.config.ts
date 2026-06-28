import ultracite from "ultracite/oxfmt"
import { defineConfig } from "vite-plus"

export default defineConfig({
  fmt: {
    ignorePatterns: [
      "node_modules/**",
      "**/node_modules/**",
      "apps/web/dist/**",
      "apps/web/.vinxi/**",
      "apps/web/.tanstack/**",
      "apps/web/src/routeTree.gen.ts",
      "packages/db/dist/**",
      "*.gen.ts",
      "*.md",
      "**/migrations/**",
      ".agents/**",
      ".claude/**",
    ],
    extends: [ultracite],
    arrowParens: "always",
    bracketSameLine: false,
    bracketSpacing: true,
    endOfLine: "lf",
    experimentalSortImports: {
      ignoreCase: true,
      newlinesBetween: true,
      order: "asc",
    },
    experimentalSortPackageJson: true,
    jsxSingleQuote: false,
    printWidth: 80,
    quoteProps: "as-needed",
    semi: false,
    singleQuote: false,
    sortTailwindcss: {
      functions: ["clsx", "cn"],
      preserveWhitespace: true,
      stylesheet: "./apps/web/src/index.css",
    },
    tabWidth: 2,
    trailingComma: "es5",
    useTabs: false,
  },
  lint: {
    ignorePatterns: [
      "node_modules/**",
      "**/node_modules/**",
      "apps/web/dist/**",
      "apps/web/.vinxi/**",
      "apps/web/.tanstack/**",
      "apps/web/src/routeTree.gen.ts",
      "packages/db/dist/**",
      "*.gen.ts",
      "*.md",
      "**/migrations/**",
      ".agents/**",
      ".claude/**",
    ],
    options: {
      typeAware: false,
      typeCheck: false,
    },
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
      "typescript/consistent-type-definitions": ["error", "type"],
      "sort-keys": "off",
    },
  },
  staged: {
    "*.{js,ts,jsx,tsx,vue,svelte,json,jsonc,css,md}": "vp check --fix",
  },
})
