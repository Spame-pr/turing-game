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
    this.systemPrompt = `${systemPrompt}. Your player name is ${this.playerId}.\n
    Do not reply to your own messages.\n
    Do not prepend your messages with your name.\n
    If you do not want to reply, put ${NO_REPLY_MARKER} in your response.\n
    Your messages must not be longer than ${MESSSAGE_LENGTH_LIMIT} characters.
    `;
  }

  getPlayerId(): string {
    return this.playerId;
  }

  async handleConversation(chatMessages: IChatMessage[], responseCallback: (message: string, delayMs: number) => any): Promise<string> {
    const handler = { done: false };
    const respond = (input: any) => {
      if (handler.done) return true;
      handler.done = true;

      console.error(`Agent ${this.playerId} responds!`);
      console.error(input);
      const { delay_ms = '2000', message } = JSON.parse(input);
      console.error({delay_ms, message});
      responseCallback(message, parseInt(delay_ms));
      return true;
    };

    const doNotRespond = () => {
      handler.done = true;
      console.error(`Agent ${this.playerId} decided to not respond!`);
      return true;
    };

const tools = [
  {
    name: 'keepSilent',
    description: 'Do not type anything to the chat',
    type: 'function',
    function: {
      function: doNotRespond as () => any,
      parameters: {},
    },
  },
  {
    name: 'respodToChat',
    description: 'Respond to chat',
    type: 'function',
    function: {
      function: respond as (args: any) => any,
      parameters: {
        type: 'object',
        properties: {
          message: { type: 'string' },
          delay_ms: { type: 'number' },
        },
      },
    },
  },
];

    let messages: (OpenAI.ChatCompletionUserMessageParam 
      | OpenAI.ChatCompletionAssistantMessageParam
      | OpenAI.ChatCompletionSystemMessageParam
    )[] = chatMessages.map((m) => (
        { role: m.playerId === this.playerId ? 'assistant' : 'user', content: m.message, name: m.playerId }
    ));
    messages = [ { role: 'system', content: this.systemPrompt }, ...messages];
    //console.error(messages)
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
    return "OK";
  }
}


