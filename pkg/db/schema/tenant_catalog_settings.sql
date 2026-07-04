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

CREATE INDEX "tenant_catalog_settings_vertical_id_idx" ON "tenant_catalog_settings" ("vertical_id");
CREATE INDEX "tenant_catalog_settings_template_id_idx" ON "tenant_catalog_settings" ("catalog_template_id");
ALTER TABLE "tenant_catalog_settings" ADD CONSTRAINT "tenant_catalog_settings_tenant_id_tenants_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "tenant_catalog_settings" ADD CONSTRAINT "tenant_catalog_settings_vertical_id_business_verticals_id_fkey" FOREIGN KEY ("vertical_id") REFERENCES "business_verticals"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "tenant_catalog_settings" ADD CONSTRAINT "tenant_catalog_settings_vwdmxEGjQBkX_fkey" FOREIGN KEY ("catalog_template_id") REFERENCES "catalog_templates"("id") ON DELETE SET NULL ON UPDATE CASCADE;
