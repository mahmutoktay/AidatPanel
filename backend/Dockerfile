# Yerel E2E / docker compose için API imajı
FROM node:22-alpine

RUN apk add --no-cache openssl libc6-compat

WORKDIR /app

COPY package.json ./
RUN npm install

COPY prisma ./prisma
COPY index.js ./
COPY src ./src

RUN npx prisma generate

ENV NODE_ENV=development
ENV PORT=4200

EXPOSE 4200

# E2E: AIDATPANEL_E2E_RESET_LOG dizini compose ile bağlanır
CMD ["sh", "-c", "mkdir -p /data/e2e && npx prisma migrate deploy && node index.js"]
