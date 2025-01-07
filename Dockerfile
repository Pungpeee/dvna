# Damn Vulnerable NodeJS Application
FROM node:carbon

WORKDIR /app

COPY . /app

RUN npm install

EXPOSE 3000

CMD ["bash", "start"]
