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

CREATE UNIQUE INDEX "channel_connections_sales_channel_idx" ON "channel_connections" ("sales_channel_id");
CREATE INDEX "channel_connections_tenant_idx" ON "channel_connections" ("tenant_id");
CREATE INDEX "channel_connections_provider_idx" ON "channel_connections" ("provider");
CREATE INDEX "channel_connections_status_idx" ON "channel_connections" ("status");
CREATE INDEX "channel_connections_external_catalog_idx" ON "channel_connections" ("external_catalog_id");
ALTER TABLE "channel_connections" ADD CONSTRAINT "channel_connections_tenant_id_tenants_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "channel_connections" ADD CONSTRAINT "channel_connections_sales_channel_id_sales_channels_id_fkey" FOREIGN KEY ("sales_channel_id") REFERENCES "sales_channels"("id") ON DELETE CASCADE ON UPDATE CASCADE;
