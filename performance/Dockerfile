FROM node:20

COPY package.json package.json
COPY package-lock.json package-lock.json
RUN npm install

COPY . .

CMD ["sh", "/run.sh"]