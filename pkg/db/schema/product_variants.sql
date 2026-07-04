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

CREATE UNIQUE INDEX "product_variants_tenant_sku_idx" ON "product_variants" ("tenant_id","sku");
CREATE INDEX "product_variants_tenant_idx" ON "product_variants" ("tenant_id");
CREATE INDEX "product_variants_product_idx" ON "product_variants" ("product_id");
CREATE INDEX "product_variants_status_idx" ON "product_variants" ("status");
CREATE INDEX "product_variants_barcode_idx" ON "product_variants" ("barcode");
ALTER TABLE "product_variants" ADD CONSTRAINT "product_variants_tenant_id_tenants_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "product_variants" ADD CONSTRAINT "product_variants_product_id_products_id_fkey" FOREIGN KEY ("product_id") REFERENCES "products"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "product_variants" ADD CONSTRAINT "product_variants_unit_id_unit_definitions_id_fkey" FOREIGN KEY ("unit_id") REFERENCES "unit_definitions"("id") ON DELETE SET NULL ON UPDATE CASCADE;
