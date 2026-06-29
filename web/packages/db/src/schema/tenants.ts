import { pgTable, text, timestamp, boolean, index, uuid } from "drizzle-orm/pg-core";

export const tenant = pgTable("tenants", {
  id: uuid().primaryKey(),
  name: text().notNull(),
  slug: text(),
});
