CREATE TYPE "channel_provider" AS ENUM('internal', 'meta', 'google', 'shopify', 'woocommerce', 'custom');--> statement-breakpoint
CREATE TYPE "channel_publication_status" AS ENUM('draft', 'pending_sync', 'published', 'unpublished', 'rejected', 'failed', 'archived');--> statement-breakpoint
CREATE TYPE "channel_status" AS ENUM('active', 'inactive', 'disconnected', 'failed', 'archived');--> statement-breakpoint
CREATE TYPE "channel_sync_status" AS ENUM('pending', 'synced', 'failed', 'disabled');--> statement-breakpoint
CREATE TYPE "stock_visibility" AS ENUM('hidden', 'available_only', 'exact_quantity', 'low_stock_only', 'range');--> statement-breakpoint
CREATE TABLE "channel_connections" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"tenant_id" uuid NOT NULL,
	"sales_channel_id" uuid NOT NULL,
	"provider" "channel_provider" DEFAULT 'internal'::"channel_provider" NOT NULL,
	"external_business_id" text,
	"external_waba_id" text,
	"external_phone_number_id" text,
	"external_page_id" text,
	"external_catalog_id" text,
	"credentials_secret_ref" text,
	"webhook_verify_token" text,
	"settings_json" jsonb DEFAULT '{}' NOT NULL,
	"status" "channel_status" DEFAULT 'active'::"channel_status" NOT NULL,
	"last_connected_at" timestamp with time zone,
	"last_error" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "channel_inventory_policies" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"tenant_id" uuid NOT NULL,
	"sales_channel_id" uuid NOT NULL,
	"location_id" uuid,
	"reservation_ttl_minutes" integer DEFAULT 15 NOT NULL,
	"allow_backorder" boolean DEFAULT false NOT NULL,
	"safety_stock" numeric(18,6) DEFAULT '0' NOT NULL,
	"stock_visibility" "stock_visibility" DEFAULT 'available_only'::"stock_visibility" NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "channel_inventory_policies_reservation_ttl_non_negative" CHECK ("reservation_ttl_minutes" >= 0),
	CONSTRAINT "channel_inventory_policies_safety_stock_non_negative" CHECK ("safety_stock" >= 0)
);
--> statement-breakpoint
CREATE TABLE "channel_listing_overrides" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"tenant_id" uuid NOT NULL,
	"sales_channel_id" uuid NOT NULL,
	"product_id" uuid NOT NULL,
	"variant_id" uuid,
	"title_override" text,
	"description_override" text,
	"image_id_override" uuid,
	"price_override" numeric(18,2),
	"metadata_json" jsonb DEFAULT '{}' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "channel_listing_overrides_price_non_negative" CHECK ("price_override" IS NULL OR "price_override" >= 0)
);
--> statement-breakpoint
CREATE TABLE "channel_price_lists" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"tenant_id" uuid NOT NULL,
	"sales_channel_id" uuid NOT NULL,
	"price_list_id" uuid NOT NULL,
	"priority" integer DEFAULT 0 NOT NULL,
	"starts_at" timestamp with time zone,
	"ends_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "channel_publications" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"tenant_id" uuid NOT NULL,
	"sales_channel_id" uuid NOT NULL,
	"product_id" uuid NOT NULL,
	"variant_id" uuid,
	"status" "channel_publication_status" DEFAULT 'draft'::"channel_publication_status" NOT NULL,
	"sync_status" "channel_sync_status" DEFAULT 'pending'::"channel_sync_status" NOT NULL,
	"external_catalog_id" text,
	"external_product_id" text,
	"external_variant_id" text,
	"external_retailer_id" text,
	"external_listing_id" text,
	"external_url" text,
	"sync_error" text,
	"last_synced_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "sales_channels" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"tenant_id" uuid NOT NULL,
	"type" "sales_channel_type" NOT NULL,
	"name" text,
	"status" "channel_status" DEFAULT 'active'::"channel_status" NOT NULL,
	"capabilities_json" jsonb DEFAULT '{}' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone
);
--> statement-breakpoint
CREATE UNIQUE INDEX "channel_connections_sales_channel_idx" ON "channel_connections" ("sales_channel_id");--> statement-breakpoint
CREATE INDEX "channel_connections_tenant_idx" ON "channel_connections" ("tenant_id");--> statement-breakpoint
CREATE INDEX "channel_connections_provider_idx" ON "channel_connections" ("provider");--> statement-breakpoint
CREATE INDEX "channel_connections_status_idx" ON "channel_connections" ("status");--> statement-breakpoint
CREATE INDEX "channel_connections_external_catalog_idx" ON "channel_connections" ("external_catalog_id");--> statement-breakpoint
CREATE UNIQUE INDEX "channel_inventory_policies_channel_location_idx" ON "channel_inventory_policies" ("sales_channel_id","location_id");--> statement-breakpoint
CREATE INDEX "channel_inventory_policies_tenant_idx" ON "channel_inventory_policies" ("tenant_id");--> statement-breakpoint
CREATE INDEX "channel_inventory_policies_channel_idx" ON "channel_inventory_policies" ("sales_channel_id");--> statement-breakpoint
CREATE INDEX "channel_inventory_policies_location_idx" ON "channel_inventory_policies" ("location_id");--> statement-breakpoint
CREATE UNIQUE INDEX "channel_listing_overrides_channel_product_variant_idx" ON "channel_listing_overrides" ("sales_channel_id","product_id","variant_id");--> statement-breakpoint
CREATE INDEX "channel_listing_overrides_tenant_idx" ON "channel_listing_overrides" ("tenant_id");--> statement-breakpoint
CREATE INDEX "channel_listing_overrides_channel_idx" ON "channel_listing_overrides" ("sales_channel_id");--> statement-breakpoint
CREATE INDEX "channel_listing_overrides_product_idx" ON "channel_listing_overrides" ("product_id");--> statement-breakpoint
CREATE INDEX "channel_listing_overrides_variant_idx" ON "channel_listing_overrides" ("variant_id");--> statement-breakpoint
CREATE UNIQUE INDEX "channel_price_lists_channel_price_list_idx" ON "channel_price_lists" ("sales_channel_id","price_list_id");--> statement-breakpoint
CREATE INDEX "channel_price_lists_tenant_idx" ON "channel_price_lists" ("tenant_id");--> statement-breakpoint
CREATE INDEX "channel_price_lists_channel_idx" ON "channel_price_lists" ("sales_channel_id");--> statement-breakpoint
CREATE INDEX "channel_price_lists_price_list_idx" ON "channel_price_lists" ("price_list_id");--> statement-breakpoint
CREATE INDEX "channel_price_lists_priority_idx" ON "channel_price_lists" ("priority");--> statement-breakpoint
CREATE UNIQUE INDEX "channel_publications_channel_product_variant_idx" ON "channel_publications" ("sales_channel_id","product_id","variant_id");--> statement-breakpoint
CREATE INDEX "channel_publications_tenant_idx" ON "channel_publications" ("tenant_id");--> statement-breakpoint
CREATE INDEX "channel_publications_channel_idx" ON "channel_publications" ("sales_channel_id");--> statement-breakpoint
CREATE INDEX "channel_publications_product_idx" ON "channel_publications" ("product_id");--> statement-breakpoint
CREATE INDEX "channel_publications_variant_idx" ON "channel_publications" ("variant_id");--> statement-breakpoint
CREATE INDEX "channel_publications_status_idx" ON "channel_publications" ("status");--> statement-breakpoint
CREATE INDEX "channel_publications_sync_status_idx" ON "channel_publications" ("sync_status");--> statement-breakpoint
CREATE INDEX "channel_publications_external_product_idx" ON "channel_publications" ("external_product_id");--> statement-breakpoint
CREATE INDEX "channel_publications_external_retailer_idx" ON "channel_publications" ("external_retailer_id");--> statement-breakpoint
CREATE UNIQUE INDEX "sales_channels_tenant_type_idx" ON "sales_channels" ("tenant_id","type");--> statement-breakpoint
CREATE INDEX "sales_channels_tenant_idx" ON "sales_channels" ("tenant_id");--> statement-breakpoint
CREATE INDEX "sales_channels_type_idx" ON "sales_channels" ("type");--> statement-breakpoint
CREATE INDEX "sales_channels_status_idx" ON "sales_channels" ("status");--> statement-breakpoint
ALTER TABLE "channel_connections" ADD CONSTRAINT "channel_connections_tenant_id_tenants_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "channel_connections" ADD CONSTRAINT "channel_connections_sales_channel_id_sales_channels_id_fkey" FOREIGN KEY ("sales_channel_id") REFERENCES "sales_channels"("id") ON DELETE CASCADE ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "channel_inventory_policies" ADD CONSTRAINT "channel_inventory_policies_tenant_id_tenants_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "channel_inventory_policies" ADD CONSTRAINT "channel_inventory_policies_a5IevPrxJppK_fkey" FOREIGN KEY ("sales_channel_id") REFERENCES "sales_channels"("id") ON DELETE CASCADE ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "channel_inventory_policies" ADD CONSTRAINT "channel_inventory_policies_r9l4IBEGcHwP_fkey" FOREIGN KEY ("location_id") REFERENCES "inventory_locations"("id") ON DELETE SET NULL ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "channel_listing_overrides" ADD CONSTRAINT "channel_listing_overrides_tenant_id_tenants_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "channel_listing_overrides" ADD CONSTRAINT "channel_listing_overrides_Jo7RBdZ0WCOL_fkey" FOREIGN KEY ("sales_channel_id") REFERENCES "sales_channels"("id") ON DELETE CASCADE ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "channel_listing_overrides" ADD CONSTRAINT "channel_listing_overrides_product_id_products_id_fkey" FOREIGN KEY ("product_id") REFERENCES "products"("id") ON DELETE CASCADE ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "channel_listing_overrides" ADD CONSTRAINT "channel_listing_overrides_variant_id_product_variants_id_fkey" FOREIGN KEY ("variant_id") REFERENCES "product_variants"("id") ON DELETE CASCADE ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "channel_listing_overrides" ADD CONSTRAINT "channel_listing_overrides_0Ku1JzKEs2Iw_fkey" FOREIGN KEY ("image_id_override") REFERENCES "product_images"("id") ON DELETE SET NULL ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "channel_price_lists" ADD CONSTRAINT "channel_price_lists_tenant_id_tenants_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "channel_price_lists" ADD CONSTRAINT "channel_price_lists_sales_channel_id_sales_channels_id_fkey" FOREIGN KEY ("sales_channel_id") REFERENCES "sales_channels"("id") ON DELETE CASCADE ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "channel_price_lists" ADD CONSTRAINT "channel_price_lists_price_list_id_price_lists_id_fkey" FOREIGN KEY ("price_list_id") REFERENCES "price_lists"("id") ON DELETE CASCADE ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "channel_publications" ADD CONSTRAINT "channel_publications_tenant_id_tenants_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "channel_publications" ADD CONSTRAINT "channel_publications_sales_channel_id_sales_channels_id_fkey" FOREIGN KEY ("sales_channel_id") REFERENCES "sales_channels"("id") ON DELETE CASCADE ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "channel_publications" ADD CONSTRAINT "channel_publications_product_id_products_id_fkey" FOREIGN KEY ("product_id") REFERENCES "products"("id") ON DELETE CASCADE ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "channel_publications" ADD CONSTRAINT "channel_publications_variant_id_product_variants_id_fkey" FOREIGN KEY ("variant_id") REFERENCES "product_variants"("id") ON DELETE CASCADE ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "sales_channels" ADD CONSTRAINT "sales_channels_tenant_id_tenants_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;