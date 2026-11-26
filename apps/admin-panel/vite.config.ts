import fs from 'node:fs'
import path from 'node:path'
import react from '@vitejs/plugin-react'
import { defineConfig, type Plugin } from 'vite'

const rootAssetsDir = path.resolve(__dirname, '../../assets')

function sharedAssetsPlugin(): Plugin {
  return {
    name: 'kisan-setu-shared-assets',
    configureServer(server) {
      server.middlewares.use('/assets', (req, res, next) => {
        const reqPath = (req.url || '/').split('?')[0]
        const filePath = path.join(rootAssetsDir, reqPath)
        if (filePath.startsWith(rootAssetsDir) && fs.existsSync(filePath) && fs.statSync(filePath).isFile()) {
          fs.createReadStream(filePath).pipe(res)
          return
        }
        next()
      })
    },
    closeBundle() {
      const distAssetsDir = path.resolve(__dirname, 'dist/assets-shared')
      if (fs.existsSync(rootAssetsDir)) {
        fs.cpSync(rootAssetsDir, distAssetsDir, { recursive: true })
      }
    },
  }
}

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), sharedAssetsPlugin()],
  server: {
    fs: {
      allow: [path.resolve(__dirname, '../..')],
    },
  },
})
