CREATE TABLE "catalog_templates" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"vertical_id" uuid NOT NULL,
	"name" text NOT NULL,
	"description" text,
	"version" integer DEFAULT 1 NOT NULL,
	"default_categories_json" jsonb DEFAULT '[]' NOT NULL,
	"default_attributes_json" jsonb DEFAULT '[]' NOT NULL,
	"default_units_json" jsonb DEFAULT '[]' NOT NULL,
	"default_bot_flows_json" jsonb DEFAULT '[]' NOT NULL,
	"metadata_json" jsonb DEFAULT '{}' NOT NULL,
	"is_default" boolean DEFAULT false NOT NULL,
	"status" "catalog_template_status" DEFAULT 'active'::"catalog_template_status" NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE INDEX "catalog_templates_vertical_id_idx" ON "catalog_templates" ("vertical_id");
CREATE INDEX "catalog_templates_vertical_default_idx" ON "catalog_templates" ("vertical_id","is_default");
CREATE UNIQUE INDEX "catalog_templates_vertical_name_idx" ON "catalog_templates" ("vertical_id","name","version");
ALTER TABLE "catalog_templates" ADD CONSTRAINT "catalog_templates_vertical_id_business_verticals_id_fkey" FOREIGN KEY ("vertical_id") REFERENCES "business_verticals"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
