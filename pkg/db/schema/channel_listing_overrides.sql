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

CREATE UNIQUE INDEX "channel_listing_overrides_channel_product_variant_idx" ON "channel_listing_overrides" ("sales_channel_id","product_id","variant_id");
CREATE INDEX "channel_listing_overrides_tenant_idx" ON "channel_listing_overrides" ("tenant_id");
CREATE INDEX "channel_listing_overrides_channel_idx" ON "channel_listing_overrides" ("sales_channel_id");
CREATE INDEX "channel_listing_overrides_product_idx" ON "channel_listing_overrides" ("product_id");
CREATE INDEX "channel_listing_overrides_variant_idx" ON "channel_listing_overrides" ("variant_id");
ALTER TABLE "channel_listing_overrides" ADD CONSTRAINT "channel_listing_overrides_tenant_id_tenants_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "channel_listing_overrides" ADD CONSTRAINT "channel_listing_overrides_Jo7RBdZ0WCOL_fkey" FOREIGN KEY ("sales_channel_id") REFERENCES "sales_channels"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "channel_listing_overrides" ADD CONSTRAINT "channel_listing_overrides_product_id_products_id_fkey" FOREIGN KEY ("product_id") REFERENCES "products"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "channel_listing_overrides" ADD CONSTRAINT "channel_listing_overrides_variant_id_product_variants_id_fkey" FOREIGN KEY ("variant_id") REFERENCES "product_variants"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "channel_listing_overrides" ADD CONSTRAINT "channel_listing_overrides_0Ku1JzKEs2Iw_fkey" FOREIGN KEY ("image_id_override") REFERENCES "product_images"("id") ON DELETE SET NULL ON UPDATE CASCADE;
