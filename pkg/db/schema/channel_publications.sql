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

CREATE UNIQUE INDEX "channel_publications_channel_product_variant_idx" ON "channel_publications" ("sales_channel_id","product_id","variant_id");
CREATE INDEX "channel_publications_tenant_idx" ON "channel_publications" ("tenant_id");
CREATE INDEX "channel_publications_channel_idx" ON "channel_publications" ("sales_channel_id");
CREATE INDEX "channel_publications_product_idx" ON "channel_publications" ("product_id");
CREATE INDEX "channel_publications_variant_idx" ON "channel_publications" ("variant_id");
CREATE INDEX "channel_publications_status_idx" ON "channel_publications" ("status");
CREATE INDEX "channel_publications_sync_status_idx" ON "channel_publications" ("sync_status");
CREATE INDEX "channel_publications_external_product_idx" ON "channel_publications" ("external_product_id");
CREATE INDEX "channel_publications_external_retailer_idx" ON "channel_publications" ("external_retailer_id");
ALTER TABLE "channel_publications" ADD CONSTRAINT "channel_publications_tenant_id_tenants_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "channel_publications" ADD CONSTRAINT "channel_publications_sales_channel_id_sales_channels_id_fkey" FOREIGN KEY ("sales_channel_id") REFERENCES "sales_channels"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "channel_publications" ADD CONSTRAINT "channel_publications_product_id_products_id_fkey" FOREIGN KEY ("product_id") REFERENCES "products"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "channel_publications" ADD CONSTRAINT "channel_publications_variant_id_product_variants_id_fkey" FOREIGN KEY ("variant_id") REFERENCES "product_variants"("id") ON DELETE CASCADE ON UPDATE CASCADE;
