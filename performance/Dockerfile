FROM node:18

WORKDIR /perf

COPY package.json package.json
COPY package-lock.json package-lock.json
RUN npm install

COPY . .

CMD ["sh", "./run.sh"]