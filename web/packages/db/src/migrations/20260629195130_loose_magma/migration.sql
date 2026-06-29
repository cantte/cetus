CREATE TYPE "attribute_applies_to" AS ENUM('product', 'variant', 'both');--> statement-breakpoint
CREATE TYPE "attribute_type" AS ENUM('string', 'number', 'boolean', 'enum', 'multi_enum', 'date', 'json');--> statement-breakpoint
CREATE TYPE "image_status" AS ENUM('active', 'inactive', 'processing', 'failed');--> statement-breakpoint
CREATE TYPE "image_type" AS ENUM('main', 'gallery', 'thumbnail', 'detail', 'lifestyle', 'packaging', 'variant');--> statement-breakpoint
CREATE TYPE "inventory_location_type" AS ENUM('warehouse', 'store', 'virtual', 'supplier', 'kitchen');--> statement-breakpoint
CREATE TYPE "inventory_movement_type" AS ENUM('stock_in', 'stock_out', 'adjustment', 'reservation', 'reservation_release', 'sale', 'return', 'transfer_in', 'transfer_out', 'damage', 'manual_correction');--> statement-breakpoint
CREATE TYPE "inventory_reservation_status" AS ENUM('active', 'confirmed', 'expired', 'released', 'cancelled');--> statement-breakpoint
CREATE TYPE "price_list_status" AS ENUM('active', 'inactive', 'archived');--> statement-breakpoint
CREATE TYPE "product_status" AS ENUM('draft', 'active', 'inactive', 'archived');--> statement-breakpoint
CREATE TYPE "product_visibility" AS ENUM('visible', 'hidden', 'internal_only');--> statement-breakpoint
CREATE TYPE "record_status" AS ENUM('active', 'inactive', 'archived');--> statement-breakpoint
CREATE TYPE "sales_channel_type" AS ENUM('web_store', 'whatsapp', 'messenger', 'instagram_dm', 'facebook_shop', 'marketplace', 'pos', 'manual', 'api');--> statement-breakpoint
CREATE TYPE "unit_type" AS ENUM('unit', 'weight', 'volume', 'length', 'package');--> statement-breakpoint
CREATE TYPE "variant_status" AS ENUM('active', 'inactive', 'archived');--> statement-breakpoint
CREATE TABLE "categories" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"tenant_id" uuid NOT NULL,
	"parent_id" uuid,
	"name" text NOT NULL,
	"slug" text NOT NULL,
	"description" text,
	"sort_order" integer DEFAULT 0 NOT NULL,
	"status" "record_status" DEFAULT 'active'::"record_status" NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone
);
--> statement-breakpoint
CREATE TABLE "inventory_locations" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"tenant_id" uuid NOT NULL,
	"name" text NOT NULL,
	"type" "inventory_location_type" DEFAULT 'warehouse'::"inventory_location_type" NOT NULL,
	"address" text,
	"city" text,
	"status" "record_status" DEFAULT 'active'::"record_status" NOT NULL,
	"is_default" boolean DEFAULT false NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "inventory_movements" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"tenant_id" uuid NOT NULL,
	"variant_id" uuid NOT NULL,
	"location_id" uuid NOT NULL,
	"type" "inventory_movement_type" NOT NULL,
	"quantity" numeric(18,6) NOT NULL,
	"previous_quantity" numeric(18,6) NOT NULL,
	"new_quantity" numeric(18,6) NOT NULL,
	"reason" text,
	"reference_type" text,
	"reference_id" uuid,
	"created_by" text,
	"metadata_json" jsonb DEFAULT '{}' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "inventory_movements_quantity_positive" CHECK ("quantity" > 0)
);
--> statement-breakpoint
CREATE TABLE "inventory_reservations" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"tenant_id" uuid NOT NULL,
	"customer_id" uuid,
	"conversation_id" uuid,
	"cart_id" uuid,
	"order_id" uuid,
	"variant_id" uuid NOT NULL,
	"location_id" uuid NOT NULL,
	"quantity" numeric(18,6) NOT NULL,
	"status" "inventory_reservation_status" DEFAULT 'active'::"inventory_reservation_status" NOT NULL,
	"expires_at" timestamp with time zone NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"confirmed_at" timestamp with time zone,
	"released_at" timestamp with time zone,
	CONSTRAINT "inventory_reservations_quantity_positive" CHECK ("quantity" > 0)
);
--> statement-breakpoint
CREATE TABLE "inventory_stocks" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"tenant_id" uuid NOT NULL,
	"variant_id" uuid NOT NULL,
	"location_id" uuid NOT NULL,
	"quantity_on_hand" numeric(18,6) DEFAULT '0' NOT NULL,
	"quantity_reserved" numeric(18,6) DEFAULT '0' NOT NULL,
	"quantity_available" numeric(18,6) DEFAULT '0' NOT NULL,
	"safety_stock" numeric(18,6) DEFAULT '0' NOT NULL,
	"reorder_point" numeric(18,6) DEFAULT '0' NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "inventory_stocks_on_hand_non_negative" CHECK ("quantity_on_hand" >= 0),
	CONSTRAINT "inventory_stocks_reserved_non_negative" CHECK ("quantity_reserved" >= 0),
	CONSTRAINT "inventory_stocks_available_non_negative" CHECK ("quantity_available" >= 0),
	CONSTRAINT "inventory_stocks_safety_stock_non_negative" CHECK ("safety_stock" >= 0),
	CONSTRAINT "inventory_stocks_reorder_point_non_negative" CHECK ("reorder_point" >= 0)
);
--> statement-breakpoint
CREATE TABLE "price_lists" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"tenant_id" uuid NOT NULL,
	"name" text NOT NULL,
	"currency" text DEFAULT 'COP' NOT NULL,
	"channel_type" "sales_channel_type",
	"is_default" boolean DEFAULT false NOT NULL,
	"priority" integer DEFAULT 0 NOT NULL,
	"status" "price_list_status" DEFAULT 'active'::"price_list_status" NOT NULL,
	"starts_at" timestamp with time zone,
	"ends_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "product_attribute_definitions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"tenant_id" uuid NOT NULL,
	"category_id" uuid,
	"code" text NOT NULL,
	"name" text NOT NULL,
	"type" "attribute_type" DEFAULT 'string'::"attribute_type" NOT NULL,
	"applies_to" "attribute_applies_to" DEFAULT 'both'::"attribute_applies_to" NOT NULL,
	"required" boolean DEFAULT false NOT NULL,
	"filterable" boolean DEFAULT false NOT NULL,
	"searchable" boolean DEFAULT false NOT NULL,
	"allowed_values_json" jsonb DEFAULT '[]' NOT NULL,
	"sort_order" integer DEFAULT 0 NOT NULL,
	"status" "record_status" DEFAULT 'active'::"record_status" NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "product_images" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"tenant_id" uuid NOT NULL,
	"product_id" uuid NOT NULL,
	"variant_id" uuid,
	"url" text NOT NULL,
	"storage_key" text,
	"alt_text" text,
	"title" text,
	"sort_order" integer DEFAULT 0 NOT NULL,
	"is_primary" boolean DEFAULT false NOT NULL,
	"image_type" "image_type" DEFAULT 'gallery'::"image_type" NOT NULL,
	"status" "image_status" DEFAULT 'active'::"image_status" NOT NULL,
	"metadata_json" jsonb DEFAULT '{}' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "product_variants" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"tenant_id" uuid NOT NULL,
	"product_id" uuid NOT NULL,
	"sku" text NOT NULL,
	"barcode" text,
	"name" text NOT NULL,
	"status" "variant_status" DEFAULT 'active'::"variant_status" NOT NULL,
	"attributes_json" jsonb DEFAULT '{}' NOT NULL,
	"unit_id" uuid,
	"unit_quantity" numeric(18,6) DEFAULT '1' NOT NULL,
	"weight" numeric(18,6),
	"dimensions_json" jsonb DEFAULT '{}' NOT NULL,
	"requires_shipping" boolean DEFAULT true NOT NULL,
	"primary_image_url" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone,
	CONSTRAINT "product_variants_unit_quantity_positive" CHECK ("unit_quantity" > 0)
);
--> statement-breakpoint
CREATE TABLE "products" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"tenant_id" uuid NOT NULL,
	"category_id" uuid,
	"name" text NOT NULL,
	"slug" text NOT NULL,
	"description" text,
	"short_description" text,
	"brand" text,
	"product_type" text,
	"status" "product_status" DEFAULT 'draft'::"product_status" NOT NULL,
	"visibility" "product_visibility" DEFAULT 'visible'::"product_visibility" NOT NULL,
	"has_variants" boolean DEFAULT false NOT NULL,
	"attributes_json" jsonb DEFAULT '{}' NOT NULL,
	"primary_image_url" text,
	"tax_category_code" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone
);
--> statement-breakpoint
CREATE TABLE "unit_definitions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"tenant_id" uuid NOT NULL,
	"code" text NOT NULL,
	"name" text NOT NULL,
	"type" "unit_type" DEFAULT 'unit'::"unit_type" NOT NULL,
	"base_unit_id" uuid,
	"conversion_factor" numeric(18,6),
	"status" "record_status" DEFAULT 'active'::"record_status" NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "variant_prices" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"tenant_id" uuid NOT NULL,
	"variant_id" uuid NOT NULL,
	"price_list_id" uuid NOT NULL,
	"regular_price" numeric(18,2) NOT NULL,
	"sale_price" numeric(18,2),
	"cost_price" numeric(18,2),
	"compare_at_price" numeric(18,2),
	"starts_at" timestamp with time zone,
	"ends_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "variant_prices_regular_price_non_negative" CHECK ("regular_price" >= 0),
	CONSTRAINT "variant_prices_sale_price_non_negative" CHECK ("sale_price" IS NULL OR "sale_price" >= 0),
	CONSTRAINT "variant_prices_cost_price_non_negative" CHECK ("cost_price" IS NULL OR "cost_price" >= 0)
);
--> statement-breakpoint
CREATE UNIQUE INDEX "categories_tenant_slug_idx" ON "categories" ("tenant_id","slug");--> statement-breakpoint
CREATE INDEX "categories_tenant_idx" ON "categories" ("tenant_id");--> statement-breakpoint
CREATE INDEX "categories_parent_idx" ON "categories" ("parent_id");--> statement-breakpoint
CREATE INDEX "categories_status_idx" ON "categories" ("status");--> statement-breakpoint
CREATE UNIQUE INDEX "inventory_locations_tenant_name_idx" ON "inventory_locations" ("tenant_id","name");--> statement-breakpoint
CREATE INDEX "inventory_locations_tenant_idx" ON "inventory_locations" ("tenant_id");--> statement-breakpoint
CREATE INDEX "inventory_locations_status_idx" ON "inventory_locations" ("status");--> statement-breakpoint
CREATE INDEX "inventory_movements_tenant_idx" ON "inventory_movements" ("tenant_id");--> statement-breakpoint
CREATE INDEX "inventory_movements_variant_idx" ON "inventory_movements" ("variant_id");--> statement-breakpoint
CREATE INDEX "inventory_movements_location_idx" ON "inventory_movements" ("location_id");--> statement-breakpoint
CREATE INDEX "inventory_movements_type_idx" ON "inventory_movements" ("type");--> statement-breakpoint
CREATE INDEX "inventory_movements_reference_idx" ON "inventory_movements" ("reference_type","reference_id");--> statement-breakpoint
CREATE INDEX "inventory_movements_created_at_idx" ON "inventory_movements" ("created_at");--> statement-breakpoint
CREATE INDEX "inventory_reservations_tenant_idx" ON "inventory_reservations" ("tenant_id");--> statement-breakpoint
CREATE INDEX "inventory_reservations_variant_idx" ON "inventory_reservations" ("variant_id");--> statement-breakpoint
CREATE INDEX "inventory_reservations_location_idx" ON "inventory_reservations" ("location_id");--> statement-breakpoint
CREATE INDEX "inventory_reservations_status_idx" ON "inventory_reservations" ("status");--> statement-breakpoint
CREATE INDEX "inventory_reservations_expires_at_idx" ON "inventory_reservations" ("expires_at");--> statement-breakpoint
CREATE INDEX "inventory_reservations_cart_idx" ON "inventory_reservations" ("cart_id");--> statement-breakpoint
CREATE INDEX "inventory_reservations_order_idx" ON "inventory_reservations" ("order_id");--> statement-breakpoint
CREATE UNIQUE INDEX "inventory_stocks_variant_location_idx" ON "inventory_stocks" ("variant_id","location_id");--> statement-breakpoint
CREATE INDEX "inventory_stocks_tenant_idx" ON "inventory_stocks" ("tenant_id");--> statement-breakpoint
CREATE INDEX "inventory_stocks_variant_idx" ON "inventory_stocks" ("variant_id");--> statement-breakpoint
CREATE INDEX "inventory_stocks_location_idx" ON "inventory_stocks" ("location_id");--> statement-breakpoint
CREATE UNIQUE INDEX "price_lists_tenant_name_idx" ON "price_lists" ("tenant_id","name");--> statement-breakpoint
CREATE INDEX "price_lists_tenant_idx" ON "price_lists" ("tenant_id");--> statement-breakpoint
CREATE INDEX "price_lists_channel_type_idx" ON "price_lists" ("channel_type");--> statement-breakpoint
CREATE INDEX "price_lists_priority_idx" ON "price_lists" ("priority");--> statement-breakpoint
CREATE INDEX "price_lists_status_idx" ON "price_lists" ("status");--> statement-breakpoint
CREATE UNIQUE INDEX "product_attribute_definitions_tenant_category_code_idx" ON "product_attribute_definitions" ("tenant_id","category_id","code");--> statement-breakpoint
CREATE INDEX "product_attribute_definitions_tenant_idx" ON "product_attribute_definitions" ("tenant_id");--> statement-breakpoint
CREATE INDEX "product_attribute_definitions_category_idx" ON "product_attribute_definitions" ("category_id");--> statement-breakpoint
CREATE INDEX "product_attribute_definitions_code_idx" ON "product_attribute_definitions" ("code");--> statement-breakpoint
CREATE INDEX "product_images_tenant_idx" ON "product_images" ("tenant_id");--> statement-breakpoint
CREATE INDEX "product_images_product_idx" ON "product_images" ("product_id");--> statement-breakpoint
CREATE INDEX "product_images_variant_idx" ON "product_images" ("variant_id");--> statement-breakpoint
CREATE INDEX "product_images_primary_idx" ON "product_images" ("product_id","variant_id","is_primary");--> statement-breakpoint
CREATE UNIQUE INDEX "product_variants_tenant_sku_idx" ON "product_variants" ("tenant_id","sku");--> statement-breakpoint
CREATE INDEX "product_variants_tenant_idx" ON "product_variants" ("tenant_id");--> statement-breakpoint
CREATE INDEX "product_variants_product_idx" ON "product_variants" ("product_id");--> statement-breakpoint
CREATE INDEX "product_variants_status_idx" ON "product_variants" ("status");--> statement-breakpoint
CREATE INDEX "product_variants_barcode_idx" ON "product_variants" ("barcode");--> statement-breakpoint
CREATE UNIQUE INDEX "products_tenant_slug_idx" ON "products" ("tenant_id","slug");--> statement-breakpoint
CREATE INDEX "products_tenant_idx" ON "products" ("tenant_id");--> statement-breakpoint
CREATE INDEX "products_category_idx" ON "products" ("category_id");--> statement-breakpoint
CREATE INDEX "products_status_idx" ON "products" ("status");--> statement-breakpoint
CREATE INDEX "products_visibility_idx" ON "products" ("visibility");--> statement-breakpoint
CREATE UNIQUE INDEX "unit_definitions_tenant_code_idx" ON "unit_definitions" ("tenant_id","code");--> statement-breakpoint
CREATE INDEX "unit_definitions_tenant_idx" ON "unit_definitions" ("tenant_id");--> statement-breakpoint
CREATE INDEX "unit_definitions_status_idx" ON "unit_definitions" ("status");--> statement-breakpoint
CREATE UNIQUE INDEX "variant_prices_variant_price_list_idx" ON "variant_prices" ("variant_id","price_list_id","starts_at");--> statement-breakpoint
CREATE INDEX "variant_prices_tenant_idx" ON "variant_prices" ("tenant_id");--> statement-breakpoint
CREATE INDEX "variant_prices_variant_idx" ON "variant_prices" ("variant_id");--> statement-breakpoint
CREATE INDEX "variant_prices_price_list_idx" ON "variant_prices" ("price_list_id");--> statement-breakpoint
ALTER TABLE "categories" ADD CONSTRAINT "categories_tenant_id_tenants_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "categories" ADD CONSTRAINT "categories_parent_id_categories_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "categories"("id") ON DELETE SET NULL ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "inventory_locations" ADD CONSTRAINT "inventory_locations_tenant_id_tenants_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "inventory_movements" ADD CONSTRAINT "inventory_movements_tenant_id_tenants_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "inventory_movements" ADD CONSTRAINT "inventory_movements_variant_id_product_variants_id_fkey" FOREIGN KEY ("variant_id") REFERENCES "product_variants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "inventory_movements" ADD CONSTRAINT "inventory_movements_location_id_inventory_locations_id_fkey" FOREIGN KEY ("location_id") REFERENCES "inventory_locations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "inventory_reservations" ADD CONSTRAINT "inventory_reservations_tenant_id_tenants_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "inventory_reservations" ADD CONSTRAINT "inventory_reservations_variant_id_product_variants_id_fkey" FOREIGN KEY ("variant_id") REFERENCES "product_variants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "inventory_reservations" ADD CONSTRAINT "inventory_reservations_location_id_inventory_locations_id_fkey" FOREIGN KEY ("location_id") REFERENCES "inventory_locations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "inventory_stocks" ADD CONSTRAINT "inventory_stocks_tenant_id_tenants_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "inventory_stocks" ADD CONSTRAINT "inventory_stocks_variant_id_product_variants_id_fkey" FOREIGN KEY ("variant_id") REFERENCES "product_variants"("id") ON DELETE CASCADE ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "inventory_stocks" ADD CONSTRAINT "inventory_stocks_location_id_inventory_locations_id_fkey" FOREIGN KEY ("location_id") REFERENCES "inventory_locations"("id") ON DELETE CASCADE ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "price_lists" ADD CONSTRAINT "price_lists_tenant_id_tenants_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "product_attribute_definitions" ADD CONSTRAINT "product_attribute_definitions_tenant_id_tenants_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "product_attribute_definitions" ADD CONSTRAINT "product_attribute_definitions_category_id_categories_id_fkey" FOREIGN KEY ("category_id") REFERENCES "categories"("id") ON DELETE SET NULL ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "product_images" ADD CONSTRAINT "product_images_tenant_id_tenants_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "product_images" ADD CONSTRAINT "product_images_product_id_products_id_fkey" FOREIGN KEY ("product_id") REFERENCES "products"("id") ON DELETE CASCADE ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "product_images" ADD CONSTRAINT "product_images_variant_id_product_variants_id_fkey" FOREIGN KEY ("variant_id") REFERENCES "product_variants"("id") ON DELETE CASCADE ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "product_variants" ADD CONSTRAINT "product_variants_tenant_id_tenants_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "product_variants" ADD CONSTRAINT "product_variants_product_id_products_id_fkey" FOREIGN KEY ("product_id") REFERENCES "products"("id") ON DELETE CASCADE ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "product_variants" ADD CONSTRAINT "product_variants_unit_id_unit_definitions_id_fkey" FOREIGN KEY ("unit_id") REFERENCES "unit_definitions"("id") ON DELETE SET NULL ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "products" ADD CONSTRAINT "products_tenant_id_tenants_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "products" ADD CONSTRAINT "products_category_id_categories_id_fkey" FOREIGN KEY ("category_id") REFERENCES "categories"("id") ON DELETE SET NULL ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "unit_definitions" ADD CONSTRAINT "unit_definitions_tenant_id_tenants_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "unit_definitions" ADD CONSTRAINT "unit_definitions_base_unit_id_unit_definitions_id_fkey" FOREIGN KEY ("base_unit_id") REFERENCES "unit_definitions"("id") ON DELETE SET NULL ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "variant_prices" ADD CONSTRAINT "variant_prices_tenant_id_tenants_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "variant_prices" ADD CONSTRAINT "variant_prices_variant_id_product_variants_id_fkey" FOREIGN KEY ("variant_id") REFERENCES "product_variants"("id") ON DELETE CASCADE ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "variant_prices" ADD CONSTRAINT "variant_prices_price_list_id_price_lists_id_fkey" FOREIGN KEY ("price_list_id") REFERENCES "price_lists"("id") ON DELETE CASCADE ON UPDATE CASCADE;