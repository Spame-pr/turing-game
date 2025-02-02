FROM node:20-alpine

RUN mkdir app
WORKDIR app

ADD . .
RUN npm install
RUN npm run build

EXPOSE 8080

CMD ["node","./dist/index.js"]

