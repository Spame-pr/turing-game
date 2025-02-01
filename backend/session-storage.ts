import Session from './session';

export default class SessionStorage {
  private sessions: Session[];

  constructor() {
    this.sessions = [];
  }

  async getSession(sessionId: string): Promise<Session> {
    let session = this.sessions.find((s) => s.getSessionId() === sessionId);
    if (!session) {
      session = new Session(sessionId);
      this.sessions.push(session);
    }
    return session;
  }
}
