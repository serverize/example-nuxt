FROM node:alpine AS base
RUN apk add --no-cache libc6-compat


FROM base AS deps
WORKDIR /app
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* ./
RUN npm ci


FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
ENV NUXT_TELEMETRY_DISABLED=1
RUN npm run build


FROM base AS start
WORKDIR /app
COPY --from=deps /app/node_modules node_modules
COPY --from=builder /app/.output .output
ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV NUXT_TELEMETRY_DISABLED=1
ENV PORT=3000
USER node
EXPOSE 3000
CMD ["node", ".output/server/index.mjs"]