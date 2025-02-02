import dotenv from 'dotenv';

dotenv.config();

import { WebSocketServer, WebSocket } from 'ws';
import { IncomingMessage } from 'http';
import Agent from './agent';
import { IChatMessage } from './types/message';
import SessionStorage from './session-storage';
import Session from './session';
import { parse } from 'url';
import { AuthenticatedWebSocket } from './types/socket';
import { userMessage, errorMessage } from './utils';

const BOT_PLAYER_ID = "BOT";
const mainConversation: IChatMessage[] = [];

interface IPlayerMessage {
  type: string;
  content: any;
};

class WSServer {
  private wss: WebSocketServer;
  private clients: Set<AuthenticatedWebSocket>;
  private sessionStorage: SessionStorage;

  constructor(port: number) {
    this.wss = new WebSocketServer({
      port,
    });
    this.clients = new Set();
    this.initialize();
    this.sessionStorage = SessionStorage.getInstance();
  }

  private async initialize(): Promise<void> {
    this.wss.on('connection', async (ws: AuthenticatedWebSocket, request: IncomingMessage) => {
      const { query } = parse(request.url || '', true);
      const sessionId = query.sessionId as string;

      if (!sessionId) {
        ws.send(errorMessage('No session id provided!'));
	ws.close();
	return;
      }

      let session: Session | null = null; 
      try {
        session = await this.sessionStorage.getSession(sessionId);
        session.joinSession(ws);
      } catch (err) {
        ws.send(errorMessage('Cannot join session!'));
	ws.close();
	return;
      }

      this.clients.add(ws);

      // Handle incoming messages
      ws.on('message', async (rawMessage: string) => {
        const message = JSON.parse(rawMessage.toString()) as IPlayerMessage;
        if (message.type === 'chat') {
          session.addMessageToConversation({ playerId: ws.playerId!, message: message.content });
	} else if (message.type === 'get_topic') {
          session.notifyTopic();
	} else if (message.type === 'start_session') {
          try {
            session.startSession();
	  } catch (err) {
            ws.send(errorMessage('Cannot start session!'));
	  }
	}
      });

      // Handle client disconnection
      ws.on('close', () => {
        console.log(`Client ${ws} disconnected`);
      });

      // Handle errors
      ws.on('error', (error: Error) => {
        console.error(`WebSocket error for ${ws}:`, error);
      });
    });

    console.log('WebSocket server started');
  }
}

const server = new WSServer(8080);
