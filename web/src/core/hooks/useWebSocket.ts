import { useEffect, useRef, useState } from 'react';
export const useWebSocket = (url: string) => {
  const [lastMessage, setLastMessage] = useState<any>(null);
  const ws = useRef<WebSocket | null>(null);
  useEffect(() => {
    ws.current = new WebSocket(url);
    ws.current.onmessage = (event) => setLastMessage(JSON.parse(event.data));
    return () => ws.current?.close();
  }, [url]);
  const send = (data: any) => ws.current?.send(JSON.stringify(data));
  return { lastMessage, send };
};
