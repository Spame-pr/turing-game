import Session from './session';

export default class SessionStorage {
  private sessions: Session[];
  private static instance: SessionStorage | undefined;

  constructor() {
    this.sessions = [];
  }

  static getInstance(): SessionStorage {
    if (!SessionStorage.instance) {
      SessionStorage.instance = new SessionStorage();
    }
    return SessionStorage.instance;
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
