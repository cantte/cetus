import { createDb } from "@cetus/db"
import * as schema from "@cetus/db/schema/auth"
import { env } from "@cetus/env/server"
import { betterAuth } from "better-auth"
import { drizzleAdapter } from "better-auth/adapters/drizzle"
import { jwt, admin } from "better-auth/plugins"
import { tanstackStartCookies } from "better-auth/tanstack-start"

export function createAuth() {
  const db = createDb()

  return betterAuth({
    baseURL: env.BETTER_AUTH_URL,
    database: drizzleAdapter(db, {
      provider: "pg",

      schema,
    }),
    emailAndPassword: {
      enabled: true,
    },
    session: {
      cookieCache: {
        enabled: true,
        // 5 minutes
        maxAge: 5 * 60,
      },
    },
    plugins: [
      admin(),
      jwt({
        jwks: {
          jwksPath: "/.well-known/jwks.json",
        },
        jwt: {
          definePayload: ({ user }) => ({
            ...user,
          }),
        },
      }),
      tanstackStartCookies(),
    ],
    secret: env.BETTER_AUTH_SECRET,
    trustedOrigins: [env.CORS_ORIGIN],
  })
}

export const auth = createAuth()
