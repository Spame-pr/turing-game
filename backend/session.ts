import { IChatMessage } from './types/message';

export default class Session {
  private sessionId: string;
  private conversation: IChatMessage[]; 

  constructor(sessionId: string) {
    this.sessionId = sessionId;
    this.conversation = []; 
  }

  getSessionId() {
    return this.sessionId;
  }
  async addMessageToConversation(message: IChatMessage) {
    this.conversation.push(message);
  }

  async getConversation(): Promise<IChatMessage[]> {
    return this.conversation;
  }
}
