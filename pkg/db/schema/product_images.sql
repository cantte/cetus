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

CREATE INDEX "product_images_tenant_idx" ON "product_images" ("tenant_id");
CREATE INDEX "product_images_product_idx" ON "product_images" ("product_id");
CREATE INDEX "product_images_variant_idx" ON "product_images" ("variant_id");
CREATE INDEX "product_images_primary_idx" ON "product_images" ("product_id","variant_id","is_primary");
ALTER TABLE "product_images" ADD CONSTRAINT "product_images_tenant_id_tenants_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "product_images" ADD CONSTRAINT "product_images_product_id_products_id_fkey" FOREIGN KEY ("product_id") REFERENCES "products"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "product_images" ADD CONSTRAINT "product_images_variant_id_product_variants_id_fkey" FOREIGN KEY ("variant_id") REFERENCES "product_variants"("id") ON DELETE CASCADE ON UPDATE CASCADE;
