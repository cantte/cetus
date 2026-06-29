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
  numeric,
  check,
} from "drizzle-orm/pg-core";

import {
  inventoryLocations,
  priceLists,
  productImages,
  products,
  productVariants,
  salesChannelTypeEnum,
} from "./catalog";
import { tenants } from "./tenants";

export const channelStatusEnum = pgEnum("channel_status", [
  "active",
  "inactive",
  "disconnected",
  "failed",
  "archived",
]);

export const channelProviderEnum = pgEnum("channel_provider", [
  "internal",
  "meta",
  "google",
  "shopify",
  "woocommerce",
  "custom",
]);

export const channelPublicationStatusEnum = pgEnum(
  "channel_publication_status",
  [
    "draft",
    "pending_sync",
    "published",
    "unpublished",
    "rejected",
    "failed",
    "archived",
  ]
);

export const channelSyncStatusEnum = pgEnum("channel_sync_status", [
  "pending",
  "synced",
  "failed",
  "disabled",
]);

export const stockVisibilityEnum = pgEnum("stock_visibility", [
  "hidden",
  "available_only",
  "exact_quantity",
  "low_stock_only",
  "range",
]);

export type ChannelCapabilitiesJson = {
  canPublishCatalog?: boolean;
  canReceiveMessages?: boolean;
  canSendMessages?: boolean;
  canCreateOrders?: boolean;
  supportsProductMessages?: boolean;
  supportsPriceSync?: boolean;
  supportsInventorySync?: boolean;
  supportsCheckout?: boolean;
};

export type ChannelConnectionSettingsJson = Record<string, unknown>;

export type ChannelListingMetadataJson = Record<string, unknown>;

export const salesChannels = snakeCase.table(
  "sales_channels",
  {
    id: uuid().defaultRandom().primaryKey(),

    tenantId: uuid()
      .notNull()
      .references(() => tenants.id, {
        onDelete: "cascade",
        onUpdate: "cascade",
      }),

    type: salesChannelTypeEnum().notNull(),

    name: text(),

    status: channelStatusEnum().default("active").notNull(),

    capabilitiesJson: jsonb()
      .$type<ChannelCapabilitiesJson>()
      .default(sql`'{}'::jsonb`)
      .notNull(),

    createdAt: timestamp({ withTimezone: true }).defaultNow().notNull(),
    updatedAt: timestamp({ withTimezone: true })
      .defaultNow()
      .$onUpdate(() => /* @__PURE__ */ new Date())
      .notNull(),
    deletedAt: timestamp({ withTimezone: true }),
  },
  (table) => [
    uniqueIndex("sales_channels_tenant_type_idx").on(
      table.tenantId,
      table.type
    ),
    index("sales_channels_tenant_idx").on(table.tenantId),
    index("sales_channels_type_idx").on(table.type),
    index("sales_channels_status_idx").on(table.status),
  ]
);

export const channelConnections = snakeCase.table(
  "channel_connections",
  {
    id: uuid().defaultRandom().primaryKey(),

    tenantId: uuid()
      .notNull()
      .references(() => tenants.id, {
        onDelete: "cascade",
        onUpdate: "cascade",
      }),

    salesChannelId: uuid()
      .notNull()
      .references(() => salesChannels.id, {
        onDelete: "cascade",
        onUpdate: "cascade",
      }),

    provider: channelProviderEnum().default("internal").notNull(),

    externalBusinessId: text(),
    externalWabaId: text(),
    externalPhoneNumberId: text(),
    externalPageId: text(),
    externalCatalogId: text(),

    credentialsSecretRef: text(),
    webhookVerifyToken: text(),

    settingsJson: jsonb()
      .$type<ChannelConnectionSettingsJson>()
      .default(sql`'{}'::jsonb`)
      .notNull(),

    status: channelStatusEnum().default("active").notNull(),

    lastConnectedAt: timestamp({ withTimezone: true }),
    lastError: text(),

    createdAt: timestamp({ withTimezone: true }).defaultNow().notNull(),
    updatedAt: timestamp({ withTimezone: true })
      .defaultNow()
      .$onUpdate(() => /* @__PURE__ */ new Date())
      .notNull(),
  },
  (table) => [
    uniqueIndex("channel_connections_sales_channel_idx").on(
      table.salesChannelId
    ),
    index("channel_connections_tenant_idx").on(table.tenantId),
    index("channel_connections_provider_idx").on(table.provider),
    index("channel_connections_status_idx").on(table.status),
    index("channel_connections_external_catalog_idx").on(
      table.externalCatalogId
    ),
  ]
);

export const channelPublications = snakeCase.table(
  "channel_publications",
  {
    id: uuid().defaultRandom().primaryKey(),

    tenantId: uuid()
      .notNull()
      .references(() => tenants.id, {
        onDelete: "cascade",
        onUpdate: "cascade",
      }),

    salesChannelId: uuid()
      .notNull()
      .references(() => salesChannels.id, {
        onDelete: "cascade",
        onUpdate: "cascade",
      }),

    productId: uuid()
      .notNull()
      .references(() => products.id, {
        onDelete: "cascade",
        onUpdate: "cascade",
      }),

    variantId: uuid().references(() => productVariants.id, {
      onDelete: "cascade",
      onUpdate: "cascade",
    }),

    status: channelPublicationStatusEnum().default("draft").notNull(),
    syncStatus: channelSyncStatusEnum().default("pending").notNull(),

    externalCatalogId: text(),
    externalProductId: text(),
    externalVariantId: text(),
    externalRetailerId: text(),
    externalListingId: text(),
    externalUrl: text(),

    syncError: text(),
    lastSyncedAt: timestamp({ withTimezone: true }),

    createdAt: timestamp({ withTimezone: true }).defaultNow().notNull(),
    updatedAt: timestamp({ withTimezone: true })
      .defaultNow()
      .$onUpdate(() => /* @__PURE__ */ new Date())
      .notNull(),
  },
  (table) => [
    uniqueIndex("channel_publications_channel_product_variant_idx").on(
      table.salesChannelId,
      table.productId,
      table.variantId
    ),
    index("channel_publications_tenant_idx").on(table.tenantId),
    index("channel_publications_channel_idx").on(table.salesChannelId),
    index("channel_publications_product_idx").on(table.productId),
    index("channel_publications_variant_idx").on(table.variantId),
    index("channel_publications_status_idx").on(table.status),
    index("channel_publications_sync_status_idx").on(table.syncStatus),
    index("channel_publications_external_product_idx").on(
      table.externalProductId
    ),
    index("channel_publications_external_retailer_idx").on(
      table.externalRetailerId
    ),
  ]
);

export const channelListingOverrides = snakeCase.table(
  "channel_listing_overrides",
  {
    id: uuid().defaultRandom().primaryKey(),

    tenantId: uuid()
      .notNull()
      .references(() => tenants.id, {
        onDelete: "cascade",
        onUpdate: "cascade",
      }),

    salesChannelId: uuid()
      .notNull()
      .references(() => salesChannels.id, {
        onDelete: "cascade",
        onUpdate: "cascade",
      }),

    productId: uuid()
      .notNull()
      .references(() => products.id, {
        onDelete: "cascade",
        onUpdate: "cascade",
      }),

    variantId: uuid().references(() => productVariants.id, {
      onDelete: "cascade",
      onUpdate: "cascade",
    }),

    titleOverride: text(),
    descriptionOverride: text(),

    imageIdOverride: uuid().references(() => productImages.id, {
      onDelete: "set null",
      onUpdate: "cascade",
    }),

    priceOverride: numeric({
      precision: 18,
      scale: 2,
    }),

    metadataJson: jsonb()
      .$type<ChannelListingMetadataJson>()
      .default(sql`'{}'::jsonb`)
      .notNull(),

    createdAt: timestamp({ withTimezone: true }).defaultNow().notNull(),
    updatedAt: timestamp({ withTimezone: true })
      .defaultNow()
      .$onUpdate(() => /* @__PURE__ */ new Date())
      .notNull(),
  },
  (table) => [
    uniqueIndex("channel_listing_overrides_channel_product_variant_idx").on(
      table.salesChannelId,
      table.productId,
      table.variantId
    ),
    index("channel_listing_overrides_tenant_idx").on(table.tenantId),
    index("channel_listing_overrides_channel_idx").on(table.salesChannelId),
    index("channel_listing_overrides_product_idx").on(table.productId),
    index("channel_listing_overrides_variant_idx").on(table.variantId),
    check(
      "channel_listing_overrides_price_non_negative",
      sql`${table.priceOverride} IS NULL OR ${table.priceOverride} >= 0`
    ),
  ]
);

export const channelInventoryPolicies = snakeCase.table(
  "channel_inventory_policies",
  {
    id: uuid().defaultRandom().primaryKey(),

    tenantId: uuid()
      .notNull()
      .references(() => tenants.id, {
        onDelete: "cascade",
        onUpdate: "cascade",
      }),

    salesChannelId: uuid()
      .notNull()
      .references(() => salesChannels.id, {
        onDelete: "cascade",
        onUpdate: "cascade",
      }),

    locationId: uuid().references(() => inventoryLocations.id, {
      onDelete: "set null",
      onUpdate: "cascade",
    }),

    reservationTtlMinutes: integer().default(15).notNull(),
    allowBackorder: boolean().default(false).notNull(),

    safetyStock: numeric("safety_stock", {
      precision: 18,
      scale: 6,
    })
      .default("0")
      .notNull(),

    stockVisibility: stockVisibilityEnum().default("available_only").notNull(),

    createdAt: timestamp({ withTimezone: true }).defaultNow().notNull(),
    updatedAt: timestamp({ withTimezone: true })
      .defaultNow()
      .$onUpdate(() => /* @__PURE__ */ new Date())
      .notNull(),
  },
  (table) => [
    uniqueIndex("channel_inventory_policies_channel_location_idx").on(
      table.salesChannelId,
      table.locationId
    ),
    index("channel_inventory_policies_tenant_idx").on(table.tenantId),
    index("channel_inventory_policies_channel_idx").on(table.salesChannelId),
    index("channel_inventory_policies_location_idx").on(table.locationId),
    check(
      "channel_inventory_policies_reservation_ttl_non_negative",
      sql`${table.reservationTtlMinutes} >= 0`
    ),
    check(
      "channel_inventory_policies_safety_stock_non_negative",
      sql`${table.safetyStock} >= 0`
    ),
  ]
);

export const channelPriceLists = snakeCase.table(
  "channel_price_lists",
  {
    id: uuid().defaultRandom().primaryKey(),

    tenantId: uuid()
      .notNull()
      .references(() => tenants.id, {
        onDelete: "cascade",
        onUpdate: "cascade",
      }),

    salesChannelId: uuid()
      .notNull()
      .references(() => salesChannels.id, {
        onDelete: "cascade",
        onUpdate: "cascade",
      }),

    priceListId: uuid()
      .notNull()
      .references(() => priceLists.id, {
        onDelete: "cascade",
        onUpdate: "cascade",
      }),

    priority: integer().default(0).notNull(),

    startsAt: timestamp({ withTimezone: true }),
    endsAt: timestamp({ withTimezone: true }),

    createdAt: timestamp({ withTimezone: true }).defaultNow().notNull(),
    updatedAt: timestamp({ withTimezone: true })
      .defaultNow()
      .$onUpdate(() => /* @__PURE__ */ new Date())
      .notNull(),
  },
  (table) => [
    uniqueIndex("channel_price_lists_channel_price_list_idx").on(
      table.salesChannelId,
      table.priceListId
    ),
    index("channel_price_lists_tenant_idx").on(table.tenantId),
    index("channel_price_lists_channel_idx").on(table.salesChannelId),
    index("channel_price_lists_price_list_idx").on(table.priceListId),
    index("channel_price_lists_priority_idx").on(table.priority),
  ]
);
