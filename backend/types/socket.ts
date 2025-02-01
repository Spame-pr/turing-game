import { WebSocket } from 'ws';

export interface AuthenticatedWebSocket extends WebSocket {
  isAuthenticated?: boolean;
  isAlive?: boolean;
  playerId?: string;
}

