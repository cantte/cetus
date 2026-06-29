import { sql } from "drizzle-orm";
import {
  index,
  pgEnum,
  text,
  timestamp,
  uniqueIndex,
  uuid,
  snakeCase,
  integer,
  jsonb,
  boolean,
} from "drizzle-orm/pg-core";

export const tenantStatusEnum = pgEnum("tenant_status", [
  "active",
  "inactive",
  "suspended",
  "archived",
]);

export const businessVerticalStatusEnum = pgEnum("business_vertical_status", [
  "active",
  "inactive",
]);

export const catalogTemplateStatusEnum = pgEnum("catalog_template_status", [
  "active",
  "inactive",
]);

export type DefaultCategoryTemplate = {
  name: string;
  slug?: string;
  description?: string;
  parent?: string | null;
  sortOrder?: number;
};

export type DefaultAttributeTemplate = {
  code: string;
  name: string;
  type:
    | "string"
    | "number"
    | "boolean"
    | "enum"
    | "multi_enum"
    | "date"
    | "json";
  appliesTo: "product" | "variant" | "both";
  required?: boolean;
  filterable?: boolean;
  searchable?: boolean;
  allowedValues?: string[];
  categoryCode?: string;
  sortOrder?: number;
};

export type DefaultUnitTemplate = {
  code: string;
  name: string;
  type: "unit" | "weight" | "volume" | "length" | "package";
  baseUnitCode?: string;
  conversionFactor?: number;
};

export type DefaultBotFlowTemplate = {
  intent: string;
  questions: {
    key: string;
    message: string;
    attributeCode?: string;
    required?: boolean;
  }[];
};

export type CatalogTemplateMetadata = {
  recommendedFor?: string[];
  notes?: string;
};

export type TenantCatalogRules = {
  productCodeStrategy?: "manual" | "auto";
  skuStrategy?: "manual" | "auto";
  defaultProductVisibility?: "visible" | "hidden" | "internal_only";
  defaultProductStatus?: "draft" | "active";
};

export const tenants = snakeCase.table(
  "tenants",
  {
    id: uuid().defaultRandom().primaryKey(),

    name: text().notNull(),
    slug: text().notNull(),

    country: text().default("CO").notNull(),
    currency: text().default("COP").notNull(),
    timezone: text().default("America/Bogota").notNull(),

    status: tenantStatusEnum().default("active").notNull(),
    createdAt: timestamp({ withTimezone: true }).defaultNow().notNull(),
    updatedAt: timestamp({ withTimezone: true })
      .defaultNow()
      .$onUpdate(() => /* @__PURE__ */ new Date())
      .notNull(),
    deletedAt: timestamp({ withTimezone: true }),
  },
  (table) => [
    uniqueIndex("tenants_slug_idx").on(table.slug),
    index("tenants_status_idx").on(table.status),
  ]
);

export const businessVerticals = snakeCase.table(
  "business_verticals",
  {
    id: uuid().defaultRandom().primaryKey(),

    code: text().notNull(),
    name: text().notNull(),
    description: text(),

    status: businessVerticalStatusEnum("status").default("active").notNull(),

    createdAt: timestamp({ withTimezone: true }).defaultNow().notNull(),
    updatedAt: timestamp({ withTimezone: true })
      .defaultNow()
      .$onUpdate(() => /* @__PURE__ */ new Date())
      .notNull(),
  },
  (table) => [
    uniqueIndex("business_verticals_code_idx").on(table.code),
    index("business_verticals_status_idx").on(table.status),
  ]
);

export const catalogTemplates = snakeCase.table(
  "catalog_templates",
  {
    id: uuid().defaultRandom().primaryKey(),
    verticalId: uuid()
      .notNull()
      .references(() => businessVerticals.id, {
        onDelete: "restrict",
        onUpdate: "cascade",
      }),

    name: text().notNull(),
    description: text(),

    version: integer("version").default(1).notNull(),

    defaultCategoriesJson: jsonb()
      .$type<DefaultCategoryTemplate[]>()
      .default(sql`'[]'::jsonb`)
      .notNull(),

    defaultAttributesJson: jsonb()
      .$type<DefaultAttributeTemplate[]>()
      .default(sql`'[]'::jsonb`)
      .notNull(),

    defaultUnitsJson: jsonb()
      .$type<DefaultUnitTemplate[]>()
      .default(sql`'[]'::jsonb`)
      .notNull(),

    defaultBotFlowsJson: jsonb()
      .$type<DefaultBotFlowTemplate[]>()
      .default(sql`'[]'::jsonb`)
      .notNull(),

    metadataJson: jsonb()
      .$type<CatalogTemplateMetadata>()
      .default(sql`'{}'::jsonb`)
      .notNull(),

    isDefault: boolean().default(false).notNull(),

    status: catalogTemplateStatusEnum("status").default("active").notNull(),

    createdAt: timestamp({ withTimezone: true }).defaultNow().notNull(),
    updatedAt: timestamp({ withTimezone: true })
      .defaultNow()
      .$onUpdate(() => /* @__PURE__ */ new Date())
      .notNull(),
  },
  (table) => [
    index("catalog_templates_vertical_id_idx").on(table.verticalId),
    index("catalog_templates_vertical_default_idx").on(
      table.verticalId,
      table.isDefault
    ),
    uniqueIndex("catalog_templates_vertical_name_idx").on(
      table.verticalId,
      table.name,
      table.version
    ),
  ]
);

export const tenantCatalogSettings = snakeCase.table(
  "tenant_catalog_settings",
  {
    tenantId: uuid()
      .primaryKey()
      .references(() => tenants.id, {
        onDelete: "cascade",
        onUpdate: "cascade",
      }),
    verticalId: uuid().references(() => businessVerticals.id, {
      onDelete: "restrict",
      onUpdate: "cascade",
    }),

    catalogTemplateId: uuid().references(() => catalogTemplates.id, {
      onDelete: "set null",
      onUpdate: "cascade",
    }),

    requireSku: boolean().default(true).notNull(),
    requireProductImage: boolean().default(false).notNull(),

    allowBackorders: boolean().default(false).notNull(),

    enableLots: boolean().default(false).notNull(),
    enableExpirationDates: boolean().default(false).notNull(),
    enableSerialNumbers: boolean().default(false).notNull(),
    enableCompatibility: boolean().default(false).notNull(),
    enableComplianceReview: boolean().default(false).notNull(),

    defaultReservationTtlMinutes: integer().default(15).notNull(),

    rulesJson: jsonb()
      .$type<TenantCatalogRules>()
      .default(sql`'{}'::jsonb`)
      .notNull(),

    createdAt: timestamp({ withTimezone: true }).defaultNow().notNull(),
    updatedAt: timestamp({ withTimezone: true })
      .defaultNow()
      .$onUpdate(() => /* @__PURE__ */ new Date())
      .notNull(),
  },
  (table) => [
    index("tenant_catalog_settings_vertical_id_idx").on(table.verticalId),
    index("tenant_catalog_settings_template_id_idx").on(
      table.catalogTemplateId
    ),
  ]
);
