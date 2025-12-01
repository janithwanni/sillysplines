import { defineConfig } from "vite";
import { svelte } from "@sveltejs/vite-plugin-svelte";

// https://vite.dev/config/
export default defineConfig({
  plugins: [svelte()],
  build: {
    outDir: "../inst/htmlwidgets/sillysplines",
    emptyOutDir: true,
    lib: {
      name: "sillysplines",
      entry: ["src/main.js"],
      formats: ["umd", "iife"],
      minify: false,
      fileName: (format, entryName) =>
        `sillysplines.min.${format == "umd" ? "umd.js" : "js"}`,
      cssFileName: "sillysplines.min",
    },
  },
});
