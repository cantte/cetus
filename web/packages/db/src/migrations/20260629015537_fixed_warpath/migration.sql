CREATE TYPE "business_vertical_status" AS ENUM('active', 'inactive');--> statement-breakpoint
CREATE TYPE "catalog_template_status" AS ENUM('active', 'inactive');--> statement-breakpoint
CREATE TYPE "tenant_status" AS ENUM('active', 'inactive', 'suspended', 'archived');--> statement-breakpoint
CREATE TABLE "business_verticals" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"code" text NOT NULL,
	"name" text NOT NULL,
	"description" text,
	"status" "business_vertical_status" DEFAULT 'active'::"business_vertical_status" NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
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
--> statement-breakpoint
CREATE TABLE "tenant_catalog_settings" (
	"tenant_id" uuid PRIMARY KEY,
	"vertical_id" uuid,
	"catalog_template_id" uuid,
	"require_sku" boolean DEFAULT true NOT NULL,
	"require_product_image" boolean DEFAULT false NOT NULL,
	"allow_backorders" boolean DEFAULT false NOT NULL,
	"enable_lots" boolean DEFAULT false NOT NULL,
	"enable_expiration_dates" boolean DEFAULT false NOT NULL,
	"enable_serial_numbers" boolean DEFAULT false NOT NULL,
	"enable_compatibility" boolean DEFAULT false NOT NULL,
	"enable_compliance_review" boolean DEFAULT false NOT NULL,
	"default_reservation_ttl_minutes" integer DEFAULT 15 NOT NULL,
	"rules_json" jsonb DEFAULT '{}' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "tenants" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"name" text NOT NULL,
	"slug" text NOT NULL,
	"country" text DEFAULT 'CO' NOT NULL,
	"currency" text DEFAULT 'COP' NOT NULL,
	"timezone" text DEFAULT 'America/Bogota' NOT NULL,
	"status" "tenant_status" DEFAULT 'active'::"tenant_status" NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone
);
--> statement-breakpoint
CREATE UNIQUE INDEX "business_verticals_code_idx" ON "business_verticals" ("code");--> statement-breakpoint
CREATE INDEX "business_verticals_status_idx" ON "business_verticals" ("status");--> statement-breakpoint
CREATE INDEX "catalog_templates_vertical_id_idx" ON "catalog_templates" ("vertical_id");--> statement-breakpoint
CREATE INDEX "catalog_templates_vertical_default_idx" ON "catalog_templates" ("vertical_id","is_default");--> statement-breakpoint
CREATE UNIQUE INDEX "catalog_templates_vertical_name_idx" ON "catalog_templates" ("vertical_id","name","version");--> statement-breakpoint
CREATE INDEX "tenant_catalog_settings_vertical_id_idx" ON "tenant_catalog_settings" ("vertical_id");--> statement-breakpoint
CREATE INDEX "tenant_catalog_settings_template_id_idx" ON "tenant_catalog_settings" ("catalog_template_id");--> statement-breakpoint
CREATE UNIQUE INDEX "tenants_slug_idx" ON "tenants" ("slug");--> statement-breakpoint
CREATE INDEX "tenants_status_idx" ON "tenants" ("status");--> statement-breakpoint
ALTER TABLE "catalog_templates" ADD CONSTRAINT "catalog_templates_vertical_id_business_verticals_id_fkey" FOREIGN KEY ("vertical_id") REFERENCES "business_verticals"("id") ON DELETE RESTRICT ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "tenant_catalog_settings" ADD CONSTRAINT "tenant_catalog_settings_tenant_id_tenants_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "tenant_catalog_settings" ADD CONSTRAINT "tenant_catalog_settings_vertical_id_business_verticals_id_fkey" FOREIGN KEY ("vertical_id") REFERENCES "business_verticals"("id") ON DELETE RESTRICT ON UPDATE CASCADE;--> statement-breakpoint
ALTER TABLE "tenant_catalog_settings" ADD CONSTRAINT "tenant_catalog_settings_vwdmxEGjQBkX_fkey" FOREIGN KEY ("catalog_template_id") REFERENCES "catalog_templates"("id") ON DELETE SET NULL ON UPDATE CASCADE;