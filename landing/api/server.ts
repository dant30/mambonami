import { IncomingMessage, ServerResponse } from 'http';
import { fileURLToPath, pathToFileURL } from 'url';
import path from 'path';
import { pipeline } from 'stream/promises';
import { Readable } from 'stream';

const SSR_BUNDLE_PATH = path.join(process.cwd(), 'dist', 'server', 'server.js');

let serverEntryPromise: Promise<any> | null = null;

async function getSsrServer() {
  if (!serverEntryPromise) {
    serverEntryPromise = import(pathToFileURL(SSR_BUNDLE_PATH).href).then(
      (module) => module.default ?? module,
    );
  }
  return serverEntryPromise;
}

function createWebRequest(req: IncomingMessage) {
  const protocol = (req.socket as any).encrypted ? 'https' : 'http';
  const host = req.headers.host ?? 'localhost';
  const url = new URL(req.url ?? '/', `${protocol}://${host}`);

  const headers = new Headers();
  for (const [key, value] of Object.entries(req.headers)) {
    if (Array.isArray(value)) {
      value.forEach((v) => headers.append(key, v));
    } else if (value != null) {
      headers.set(key, value);
    }
  }

  const body = req.method === 'GET' || req.method === 'HEAD' ? undefined : req;
  return new Request(url.toString(), {
    method: req.method,
    headers,
    body,
  });
}

async function sendWebResponse(res: ServerResponse, webResponse: Response) {
  res.statusCode = webResponse.status;
  for (const [key, value] of webResponse.headers) {
    if (value !== undefined) {
      res.setHeader(key, value);
    }
  }

  if (!webResponse.body) {
    res.end();
    return;
  }

  const bodyStream = Readable.fromWeb(webResponse.body as any);
  await pipeline(bodyStream, res);
}

export default async function handler(req: IncomingMessage, res: ServerResponse) {
  try {
    const ssrServer = await getSsrServer();
    if (!ssrServer || typeof ssrServer.fetch !== 'function') {
      throw new Error('SSR server bundle does not expose a fetch handler');
    }

    const webRequest = createWebRequest(req);
    const webResponse = await ssrServer.fetch(webRequest, {}, {});
    await sendWebResponse(res, webResponse);
  } catch (error) {
    console.error(error);
    res.statusCode = 500;
    res.setHeader('content-type', 'text/plain; charset=utf-8');
    res.end('Internal Server Error');
  }
}
