FROM node:19.6

WORKDIR /app

COPY package*.json ./
RUN npm install
COPY index.js ./
CMD node index.js