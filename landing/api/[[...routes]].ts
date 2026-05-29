import { IncomingMessage, ServerResponse } from 'http';

let server: any = null;

export default async function handler(req: IncomingMessage, res: ServerResponse) {
  if (!server) {
    try {
      const { default: nitroServer } = await import('../../../dist/server/index.mjs');
      server = nitroServer;
    } catch (e) {
      console.error('Failed to load Nitro server:', e);
      res.statusCode = 500;
      res.end('Internal Server Error');
      return;
    }
  }

  // Route to Nitro server
  return server.handler(req, res);
}
