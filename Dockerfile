# Damn Vulnerable NodeJS Application
FROM node:23.3.0-alpine

WORKDIR /app

COPY . /app

RUN npm install

EXPOSE 3000

CMD ["bash", "start"]
