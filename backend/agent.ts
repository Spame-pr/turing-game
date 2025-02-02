import OpenAI from 'openai';
import { IChatMessage } from './types/message';

const OPENAI_API_KEY = process.env.OPENAI_API_KEY;
const MESSSAGE_LENGTH_LIMIT = 100;
const NO_REPLY_MARKER = "<NO_REPLY>"

export default class Agent {
  private client: OpenAI;
  private playerId: string;
  private systemPrompt: string;

  constructor(systemPrompt: string, playerId: string) {
    this.client  = new OpenAI({
      apiKey: OPENAI_API_KEY
    });
    this.playerId = playerId;
    this.systemPrompt = `${systemPrompt}.\n
    Your player name is ${this.playerId}.\n
    Do not reply to your own messages.\n
    Do not put your name at the beginning of your message.\n
    If you do not want to reply, put ${NO_REPLY_MARKER} in your response.\n
    Your messages must not be longer than ${MESSSAGE_LENGTH_LIMIT} characters.
    `;
    console.error(this.systemPrompt);
  }

  getPlayerId(): string {
    return this.playerId;
  }

  async handleConversation(chatMessages: IChatMessage[], responseCallback: (message: string, delayMs: number) => any): Promise<string> {
    let messages: (OpenAI.ChatCompletionUserMessageParam 
      | OpenAI.ChatCompletionAssistantMessageParam
      | OpenAI.ChatCompletionSystemMessageParam
    )[] = chatMessages.map((m) => (
        { role: m.playerId === this.playerId ? 'assistant' : 'user', content: m.message, name: m.playerId }
    ));
    messages = [ { role: 'system', content: this.systemPrompt }, ...messages];
    try {
      const chatCompletion = await this.client.chat.completions.create({
        messages,
        model: 'gpt-4o-mini',
      });
      console.error(JSON.stringify(chatCompletion));
      const response = chatCompletion.choices[0].message.content!;
      if (response.includes(NO_REPLY_MARKER)) {
        console.error(`Agent ${this.getPlayerId()} does not want to respond!`)
      } else {
        responseCallback(response, 3000);
      }
    } catch (err) {
      console.error('Something weird with openai, skip');
    }
    return "OK";
  }
}


