import { defineConfig } from 'vite'
import ViteRails from "vite-plugin-rails"

export default defineConfig({
  plugins: [
    ViteRails({
      envVars: {
        RAILS_ENV: process.env.RAILS_ENV || "development"
      },
      envOptions: { defineOn: "import.meta.env" },
      fullReload: {
        additionalPaths: [],
      },
    }),
  ],
  resolve: {
    alias: {
      '@images': '/app/frontend/images',
      'toastify-js': 'toastify-js/src/toastify.js'
    }
  },
  build: {
    outDir: 'vite',
    manifest: true,
    assetsDir: '',
  },
})

