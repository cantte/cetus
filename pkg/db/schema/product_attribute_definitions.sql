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

CREATE UNIQUE INDEX "product_attribute_definitions_tenant_category_code_idx" ON "product_attribute_definitions" ("tenant_id","category_id","code");
CREATE INDEX "product_attribute_definitions_tenant_idx" ON "product_attribute_definitions" ("tenant_id");
CREATE INDEX "product_attribute_definitions_category_idx" ON "product_attribute_definitions" ("category_id");
CREATE INDEX "product_attribute_definitions_code_idx" ON "product_attribute_definitions" ("code");
ALTER TABLE "product_attribute_definitions" ADD CONSTRAINT "product_attribute_definitions_tenant_id_tenants_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "product_attribute_definitions" ADD CONSTRAINT "product_attribute_definitions_category_id_categories_id_fkey" FOREIGN KEY ("category_id") REFERENCES "categories"("id") ON DELETE SET NULL ON UPDATE CASCADE;
