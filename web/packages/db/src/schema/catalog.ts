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
import type { AnyPgColumn } from "drizzle-orm/pg-core";

import { tenants } from "./tenants";

export const recordStatusEnum = pgEnum("record_status", ["active", "inactive", "archived"]);

export const productStatusEnum = pgEnum("product_status", [
  "draft",
  "active",
  "inactive",
  "archived",
]);

export const productVisibilityEnum = pgEnum("product_visibility", [
  "visible",
  "hidden",
  "internal_only",
]);

export const variantStatusEnum = pgEnum("variant_status", ["active", "inactive", "archived"]);

export const attributeTypeEnum = pgEnum("attribute_type", [
  "string",
  "number",
  "boolean",
  "enum",
  "multi_enum",
  "date",
  "json",
]);

export const attributeAppliesToEnum = pgEnum("attribute_applies_to", [
  "product",
  "variant",
  "both",
]);

export const unitTypeEnum = pgEnum("unit_type", ["unit", "weight", "volume", "length", "package"]);

export const imageTypeEnum = pgEnum("image_type", [
  "main",
  "gallery",
  "thumbnail",
  "detail",
  "lifestyle",
  "packaging",
  "variant",
]);

export const imageStatusEnum = pgEnum("image_status", [
  "active",
  "inactive",
  "processing",
  "failed",
]);

export const priceListStatusEnum = pgEnum("price_list_status", ["active", "inactive", "archived"]);

export const salesChannelTypeEnum = pgEnum("sales_channel_type", [
  "web_store",
  "whatsapp",
  "messenger",
  "instagram_dm",
  "facebook_shop",
  "marketplace",
  "pos",
  "manual",
  "api",
]);

export const inventoryLocationTypeEnum = pgEnum("inventory_location_type", [
  "warehouse",
  "store",
  "virtual",
  "supplier",
  "kitchen",
]);

export const inventoryMovementTypeEnum = pgEnum("inventory_movement_type", [
  "stock_in",
  "stock_out",
  "adjustment",
  "reservation",
  "reservation_release",
  "sale",
  "return",
  "transfer_in",
  "transfer_out",
  "damage",
  "manual_correction",
]);

export const inventoryReservationStatusEnum = pgEnum("inventory_reservation_status", [
  "active",
  "confirmed",
  "expired",
  "released",
  "cancelled",
]);

export type ProductAttributesJson = Record<string, unknown>;

export type VariantAttributesJson = Record<string, unknown>;

export type ProductImageMetadataJson = {
  width?: number;
  height?: number;
  sizeBytes?: number;
  format?: string;
  dominantColor?: string;
};

export type ProductDimensionsJson = {
  width?: number;
  height?: number;
  length?: number;
  unit?: "cm" | "m" | "in";
};

export type MovementMetadataJson = {
  notes?: string;
  source?: string;
  previousData?: Record<string, unknown>;
  newData?: Record<string, unknown>;
};

export const unitDefinitions = snakeCase.table(
  "unit_definitions",
  {
    id: uuid().defaultRandom().primaryKey(),

    tenantId: uuid()
      .notNull()
      .references(() => tenants.id, {
        onDelete: "cascade",
        onUpdate: "cascade",
      }),

    code: text().notNull(),
    name: text().notNull(),

    type: unitTypeEnum().default("unit").notNull(),

    baseUnitId: uuid().references((): AnyPgColumn => unitDefinitions.id, {
      onDelete: "set null",
      onUpdate: "cascade",
    }),

    conversionFactor: numeric({
      precision: 18,
      scale: 6,
    }),

    status: recordStatusEnum().default("active").notNull(),

    createdAt: timestamp({ withTimezone: true }).defaultNow().notNull(),
    updatedAt: timestamp({ withTimezone: true })
      .defaultNow()
      .$onUpdate(() => /* @__PURE__ */ new Date())
      .notNull(),
  },
  (table) => [
    uniqueIndex("unit_definitions_tenant_code_idx").on(table.tenantId, table.code),
    index("unit_definitions_tenant_idx").on(table.tenantId),
    index("unit_definitions_status_idx").on(table.status),
  ],
);

export const categories = snakeCase.table(
  "categories",
  {
    id: uuid().defaultRandom().primaryKey(),

    tenantId: uuid()
      .notNull()
      .references(() => tenants.id, {
        onDelete: "cascade",
        onUpdate: "cascade",
      }),

    parentId: uuid().references((): AnyPgColumn => categories.id, {
      onDelete: "set null",
      onUpdate: "cascade",
    }),

    name: text().notNull(),
    slug: text().notNull(),
    description: text(),

    sortOrder: integer().default(0).notNull(),

    status: recordStatusEnum().default("active").notNull(),

    createdAt: timestamp({ withTimezone: true }).defaultNow().notNull(),
    updatedAt: timestamp({ withTimezone: true })
      .defaultNow()
      .$onUpdate(() => /* @__PURE__ */ new Date())
      .notNull(),
    deletedAt: timestamp({ withTimezone: true }),
  },
  (table) => [
    uniqueIndex("categories_tenant_slug_idx").on(table.tenantId, table.slug),
    index("categories_tenant_idx").on(table.tenantId),
    index("categories_parent_idx").on(table.parentId),
    index("categories_status_idx").on(table.status),
  ],
);

export const productAttributeDefinitions = snakeCase.table(
  "product_attribute_definitions",
  {
    id: uuid().defaultRandom().primaryKey(),

    tenantId: uuid()
      .notNull()
      .references(() => tenants.id, {
        onDelete: "cascade",
        onUpdate: "cascade",
      }),

    categoryId: uuid().references(() => categories.id, {
      onDelete: "set null",
      onUpdate: "cascade",
    }),

    code: text().notNull(),
    name: text().notNull(),

    type: attributeTypeEnum().default("string").notNull(),
    appliesTo: attributeAppliesToEnum("applies_to").default("both").notNull(),

    required: boolean().default(false).notNull(),
    filterable: boolean().default(false).notNull(),
    searchable: boolean().default(false).notNull(),

    allowedValuesJson: jsonb()
      .$type<string[]>()
      .default(sql`'[]'::jsonb`)
      .notNull(),

    sortOrder: integer().default(0).notNull(),

    status: recordStatusEnum().default("active").notNull(),

    createdAt: timestamp({ withTimezone: true }).defaultNow().notNull(),
    updatedAt: timestamp({ withTimezone: true })
      .defaultNow()
      .$onUpdate(() => /* @__PURE__ */ new Date())
      .notNull(),
  },
  (table) => [
    uniqueIndex("product_attribute_definitions_tenant_category_code_idx").on(
      table.tenantId,
      table.categoryId,
      table.code,
    ),
    index("product_attribute_definitions_tenant_idx").on(table.tenantId),
    index("product_attribute_definitions_category_idx").on(table.categoryId),
    index("product_attribute_definitions_code_idx").on(table.code),
  ],
);

export const products = snakeCase.table(
  "products",
  {
    id: uuid().defaultRandom().primaryKey(),

    tenantId: uuid()
      .notNull()
      .references(() => tenants.id, {
        onDelete: "cascade",
        onUpdate: "cascade",
      }),

    categoryId: uuid().references(() => categories.id, {
      onDelete: "set null",
      onUpdate: "cascade",
    }),

    name: text().notNull(),
    slug: text().notNull(),

    description: text(),
    shortDescription: text(),

    brand: text(),
    productType: text(),

    status: productStatusEnum().default("draft").notNull(),
    visibility: productVisibilityEnum().default("visible").notNull(),

    hasVariants: boolean().default(false).notNull(),

    attributesJson: jsonb()
      .$type<ProductAttributesJson>()
      .default(sql`'{}'::jsonb`)
      .notNull(),

    primaryImageUrl: text(),
    taxCategoryCode: text(),

    createdAt: timestamp({ withTimezone: true }).defaultNow().notNull(),
    updatedAt: timestamp({ withTimezone: true })
      .defaultNow()
      .$onUpdate(() => /* @__PURE__ */ new Date())
      .notNull(),
    deletedAt: timestamp({ withTimezone: true }),
  },
  (table) => [
    uniqueIndex("products_tenant_slug_idx").on(table.tenantId, table.slug),
    index("products_tenant_idx").on(table.tenantId),
    index("products_category_idx").on(table.categoryId),
    index("products_status_idx").on(table.status),
    index("products_visibility_idx").on(table.visibility),
  ],
);

export const productVariants = snakeCase.table(
  "product_variants",
  {
    id: uuid().defaultRandom().primaryKey(),

    tenantId: uuid()
      .notNull()
      .references(() => tenants.id, {
        onDelete: "cascade",
        onUpdate: "cascade",
      }),

    productId: uuid()
      .notNull()
      .references(() => products.id, {
        onDelete: "cascade",
        onUpdate: "cascade",
      }),

    sku: text().notNull(),
    barcode: text(),

    name: text().notNull(),

    status: variantStatusEnum().default("active").notNull(),

    attributesJson: jsonb()
      .$type<VariantAttributesJson>()
      .default(sql`'{}'::jsonb`)
      .notNull(),

    unitId: uuid().references(() => unitDefinitions.id, {
      onDelete: "set null",
      onUpdate: "cascade",
    }),

    unitQuantity: numeric({
      precision: 18,
      scale: 6,
    })
      .default("1")
      .notNull(),

    weight: numeric({
      precision: 18,
      scale: 6,
    }),

    dimensionsJson: jsonb()
      .$type<ProductDimensionsJson>()
      .default(sql`'{}'::jsonb`)
      .notNull(),

    requiresShipping: boolean().default(true).notNull(),

    primaryImageUrl: text(),

    createdAt: timestamp({ withTimezone: true }).defaultNow().notNull(),
    updatedAt: timestamp({ withTimezone: true })
      .defaultNow()
      .$onUpdate(() => /* @__PURE__ */ new Date())
      .notNull(),
    deletedAt: timestamp({ withTimezone: true }),
  },
  (table) => [
    uniqueIndex("product_variants_tenant_sku_idx").on(table.tenantId, table.sku),
    index("product_variants_tenant_idx").on(table.tenantId),
    index("product_variants_product_idx").on(table.productId),
    index("product_variants_status_idx").on(table.status),
    index("product_variants_barcode_idx").on(table.barcode),
    check("product_variants_unit_quantity_positive", sql`${table.unitQuantity} > 0`),
  ],
);

export const productImages = snakeCase.table(
  "product_images",
  {
    id: uuid().defaultRandom().primaryKey(),

    tenantId: uuid()
      .notNull()
      .references(() => tenants.id, {
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

    url: text().notNull(),
    storageKey: text(),

    altText: text(),
    title: text(),

    sortOrder: integer().default(0).notNull(),
    isPrimary: boolean().default(false).notNull(),

    imageType: imageTypeEnum().default("gallery").notNull(),
    status: imageStatusEnum().default("active").notNull(),

    metadataJson: jsonb()
      .$type<ProductImageMetadataJson>()
      .default(sql`'{}'::jsonb`)
      .notNull(),

    createdAt: timestamp({ withTimezone: true }).defaultNow().notNull(),
    updatedAt: timestamp({ withTimezone: true })
      .defaultNow()
      .$onUpdate(() => /* @__PURE__ */ new Date())
      .notNull(),
  },
  (table) => [
    index("product_images_tenant_idx").on(table.tenantId),
    index("product_images_product_idx").on(table.productId),
    index("product_images_variant_idx").on(table.variantId),
    index("product_images_primary_idx").on(table.productId, table.variantId, table.isPrimary),
  ],
);

export const priceLists = snakeCase.table(
  "price_lists",
  {
    id: uuid().defaultRandom().primaryKey(),

    tenantId: uuid()
      .notNull()
      .references(() => tenants.id, {
        onDelete: "cascade",
        onUpdate: "cascade",
      }),

    name: text().notNull(),

    currency: text().default("COP").notNull(),

    channelType: salesChannelTypeEnum(),

    isDefault: boolean().notNull().default(false),

    priority: integer().notNull().default(0),

    status: priceListStatusEnum().default("active").notNull(),

    startsAt: timestamp({ withTimezone: true }),
    endsAt: timestamp({ withTimezone: true }),

    createdAt: timestamp({ withTimezone: true }).defaultNow().notNull(),
    updatedAt: timestamp({ withTimezone: true })
      .defaultNow()
      .$onUpdate(() => /* @__PURE__ */ new Date())
      .notNull(),
  },
  (table) => [
    uniqueIndex("price_lists_tenant_name_idx").on(table.tenantId, table.name),
    index("price_lists_tenant_idx").on(table.tenantId),
    index("price_lists_channel_type_idx").on(table.channelType),
    index("price_lists_priority_idx").on(table.priority),
    index("price_lists_status_idx").on(table.status),
  ],
);

export const variantPrices = snakeCase.table(
  "variant_prices",
  {
    id: uuid().defaultRandom().primaryKey(),

    tenantId: uuid()
      .notNull()
      .references(() => tenants.id, {
        onDelete: "cascade",
        onUpdate: "cascade",
      }),

    variantId: uuid()
      .notNull()
      .references(() => productVariants.id, {
        onDelete: "cascade",
        onUpdate: "cascade",
      }),

    priceListId: uuid()
      .notNull()
      .references(() => priceLists.id, {
        onDelete: "cascade",
        onUpdate: "cascade",
      }),

    regularPrice: numeric({
      precision: 18,
      scale: 2,
    }).notNull(),

    salePrice: numeric({
      precision: 18,
      scale: 2,
    }),

    costPrice: numeric({
      precision: 18,
      scale: 2,
    }),

    compareAtPrice: numeric({
      precision: 18,
      scale: 2,
    }),

    startsAt: timestamp({ withTimezone: true }),
    endsAt: timestamp({ withTimezone: true }),

    createdAt: timestamp({ withTimezone: true }).defaultNow().notNull(),
    updatedAt: timestamp({ withTimezone: true })
      .defaultNow()
      .$onUpdate(() => /* @__PURE__ */ new Date())
      .notNull(),
  },
  (table) => [
    uniqueIndex("variant_prices_variant_price_list_idx").on(
      table.variantId,
      table.priceListId,
      table.startsAt,
    ),
    index("variant_prices_tenant_idx").on(table.tenantId),
    index("variant_prices_variant_idx").on(table.variantId),
    index("variant_prices_price_list_idx").on(table.priceListId),
    check("variant_prices_regular_price_non_negative", sql`${table.regularPrice} >= 0`),
    check(
      "variant_prices_sale_price_non_negative",
      sql`${table.salePrice} IS NULL OR ${table.salePrice} >= 0`,
    ),
    check(
      "variant_prices_cost_price_non_negative",
      sql`${table.costPrice} IS NULL OR ${table.costPrice} >= 0`,
    ),
  ],
);

export const inventoryLocations = snakeCase.table(
  "inventory_locations",
  {
    id: uuid().defaultRandom().primaryKey(),

    tenantId: uuid()
      .notNull()
      .references(() => tenants.id, {
        onDelete: "cascade",
        onUpdate: "cascade",
      }),

    name: text().notNull(),

    type: inventoryLocationTypeEnum().default("warehouse").notNull(),

    address: text(),
    city: text(),

    status: recordStatusEnum().default("active").notNull(),
    isDefault: boolean().default(false).notNull(),

    createdAt: timestamp({ withTimezone: true }).defaultNow().notNull(),
    updatedAt: timestamp({ withTimezone: true })
      .defaultNow()
      .$onUpdate(() => /* @__PURE__ */ new Date())
      .notNull(),
  },
  (table) => [
    uniqueIndex("inventory_locations_tenant_name_idx").on(table.tenantId, table.name),
    index("inventory_locations_tenant_idx").on(table.tenantId),
    index("inventory_locations_status_idx").on(table.status),
  ],
);

export const inventoryStocks = snakeCase.table(
  "inventory_stocks",
  {
    id: uuid().defaultRandom().primaryKey(),

    tenantId: uuid()
      .notNull()
      .references(() => tenants.id, {
        onDelete: "cascade",
        onUpdate: "cascade",
      }),

    variantId: uuid()
      .notNull()
      .references(() => productVariants.id, {
        onDelete: "cascade",
        onUpdate: "cascade",
      }),

    locationId: uuid()
      .notNull()
      .references(() => inventoryLocations.id, {
        onDelete: "cascade",
        onUpdate: "cascade",
      }),

    quantityOnHand: numeric({
      precision: 18,
      scale: 6,
    })
      .default("0")
      .notNull(),

    quantityReserved: numeric({
      precision: 18,
      scale: 6,
    })
      .default("0")
      .notNull(),

    quantityAvailable: numeric({
      precision: 18,
      scale: 6,
    })
      .default("0")
      .notNull(),

    safetyStock: numeric({
      precision: 18,
      scale: 6,
    })
      .default("0")
      .notNull(),

    reorderPoint: numeric({
      precision: 18,
      scale: 6,
    })
      .default("0")
      .notNull(),

    updatedAt: timestamp({ withTimezone: true })
      .defaultNow()
      .$onUpdate(() => /* @__PURE__ */ new Date())
      .notNull(),
  },
  (table) => [
    uniqueIndex("inventory_stocks_variant_location_idx").on(table.variantId, table.locationId),
    index("inventory_stocks_tenant_idx").on(table.tenantId),
    index("inventory_stocks_variant_idx").on(table.variantId),
    index("inventory_stocks_location_idx").on(table.locationId),

    check("inventory_stocks_on_hand_non_negative", sql`${table.quantityOnHand} >= 0`),
    check("inventory_stocks_reserved_non_negative", sql`${table.quantityReserved} >= 0`),
    check("inventory_stocks_available_non_negative", sql`${table.quantityAvailable} >= 0`),
    check("inventory_stocks_safety_stock_non_negative", sql`${table.safetyStock} >= 0`),
    check("inventory_stocks_reorder_point_non_negative", sql`${table.reorderPoint} >= 0`),
  ],
);

export const inventoryMovements = snakeCase.table(
  "inventory_movements",
  {
    id: uuid().defaultRandom().primaryKey(),

    tenantId: uuid()
      .notNull()
      .references(() => tenants.id, {
        onDelete: "cascade",
        onUpdate: "cascade",
      }),

    variantId: uuid()
      .notNull()
      .references(() => productVariants.id, {
        onDelete: "restrict",
        onUpdate: "cascade",
      }),

    locationId: uuid()
      .notNull()
      .references(() => inventoryLocations.id, {
        onDelete: "restrict",
        onUpdate: "cascade",
      }),

    type: inventoryMovementTypeEnum().notNull(),

    quantity: numeric({
      precision: 18,
      scale: 6,
    }).notNull(),

    previousQuantity: numeric({
      precision: 18,
      scale: 6,
    }).notNull(),

    newQuantity: numeric({
      precision: 18,
      scale: 6,
    }).notNull(),

    reason: text(),

    referenceType: text(),
    referenceId: uuid(),

    createdBy: text(),

    metadataJson: jsonb()
      .$type<MovementMetadataJson>()
      .default(sql`'{}'::jsonb`)
      .notNull(),

    createdAt: timestamp({ withTimezone: true }).defaultNow().notNull(),
  },
  (table) => [
    index("inventory_movements_tenant_idx").on(table.tenantId),
    index("inventory_movements_variant_idx").on(table.variantId),
    index("inventory_movements_location_idx").on(table.locationId),
    index("inventory_movements_type_idx").on(table.type),
    index("inventory_movements_reference_idx").on(table.referenceType, table.referenceId),
    index("inventory_movements_created_at_idx").on(table.createdAt),
    check("inventory_movements_quantity_positive", sql`${table.quantity} > 0`),
  ],
);

export const inventoryReservations = snakeCase.table(
  "inventory_reservations",
  {
    id: uuid().defaultRandom().primaryKey(),

    tenantId: uuid()
      .notNull()
      .references(() => tenants.id, {
        onDelete: "cascade",
        onUpdate: "cascade",
      }),

    customerId: uuid(),
    conversationId: uuid(),
    cartId: uuid(),
    orderId: uuid(),

    variantId: uuid()
      .notNull()
      .references(() => productVariants.id, {
        onDelete: "restrict",
        onUpdate: "cascade",
      }),

    locationId: uuid()
      .notNull()
      .references(() => inventoryLocations.id, {
        onDelete: "restrict",
        onUpdate: "cascade",
      }),

    quantity: numeric({
      precision: 18,
      scale: 6,
    }).notNull(),

    status: inventoryReservationStatusEnum().default("active").notNull(),

    expiresAt: timestamp({ withTimezone: true }).notNull(),

    createdAt: timestamp({ withTimezone: true }).defaultNow().notNull(),
    confirmedAt: timestamp({ withTimezone: true }),
    releasedAt: timestamp({ withTimezone: true }),
  },
  (table) => [
    index("inventory_reservations_tenant_idx").on(table.tenantId),
    index("inventory_reservations_variant_idx").on(table.variantId),
    index("inventory_reservations_location_idx").on(table.locationId),
    index("inventory_reservations_status_idx").on(table.status),
    index("inventory_reservations_expires_at_idx").on(table.expiresAt),
    index("inventory_reservations_cart_idx").on(table.cartId),
    index("inventory_reservations_order_idx").on(table.orderId),
    check("inventory_reservations_quantity_positive", sql`${table.quantity} > 0`),
  ],
);
