export const errorMessage = (message: string): string => {
  return JSON.stringify({ type: 'error', data: { message }});
};

export const userMessage = (type: string, content: any, sender: string | object | undefined = undefined) => {
  return JSON.stringify({
    type,
    content,
    sender
  })
};

export const sleep = (ms: number) => {
  return new Promise( resolve => setTimeout(resolve, ms) );
};


