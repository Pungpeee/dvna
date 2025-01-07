# Damn Vulnerable NodeJS Application
FROM node:23.3.0-alpine

WORKDIR /app

COPY . .

RUN chmod +x /app/entrypoint.sh \
	&& npm install

EXPOSE 3000

CMD ["bash", "/app/entrypoint.sh"]
