import { defineConfig } from "vite";
import { svelte } from "@sveltejs/vite-plugin-svelte";

// https://vite.dev/config/
export default defineConfig({
  plugins: [svelte()],
  build: {
    outDir: "../inst/htmlwidgets/sillysplines",
    lib: {
      name: "sillysplines",
      entry: ["src/App.svelte"],
      fileName: "sillysplines.min",
      cssFileName: "sillysplines.min",
    },
  },
});
