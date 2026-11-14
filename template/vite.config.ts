// Vite config for craft-vite running in Docker (no DDEV variables).
import tailwindcss from "@tailwindcss/vite";
import path from "path";
import { defineConfig } from "vite";

export default defineConfig(({ command }) => ({
  base: command === "serve" ? "" : "/dist/",
  publicDir: path.resolve(import.meta.dirname, "src/public"),
  build: {
    manifest: true,
    outDir: path.resolve(import.meta.dirname, "web/dist/"),
    rollupOptions: {
      input: { entrypoint: path.resolve(import.meta.dirname, "src/entrypoint.ts") },
    },
    emptyOutDir: true,
  },
  server: {
    host: "0.0.0.0",
    port: 5173,
    strictPort: true,
    // Asset URLs must point at the port published on the host.
    origin: process.env.VITE_DEV_SERVER_PUBLIC ?? "http://localhost:5173",
    cors: { origin: /^https?:\/\/localhost(:\d+)?$/ },
  },
  plugins: [tailwindcss()],
}));
