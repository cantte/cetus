CREATE TABLE "products" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"tenant_id" uuid NOT NULL,
	"category_id" uuid,
	"name" text NOT NULL,
	"slug" text NOT NULL,
	"description" text,
	"short_description" text,
	"brand" text,
	"product_type" "product_type",
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

CREATE UNIQUE INDEX "products_tenant_slug_idx" ON "products" ("tenant_id","slug");
CREATE INDEX "products_tenant_idx" ON "products" ("tenant_id");
CREATE INDEX "products_category_idx" ON "products" ("category_id");
CREATE INDEX "products_status_idx" ON "products" ("status");
CREATE INDEX "products_visibility_idx" ON "products" ("visibility");
ALTER TABLE "products" ADD CONSTRAINT "products_tenant_id_tenants_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "products" ADD CONSTRAINT "products_category_id_categories_id_fkey" FOREIGN KEY ("category_id") REFERENCES "categories"("id") ON DELETE SET NULL ON UPDATE CASCADE;
