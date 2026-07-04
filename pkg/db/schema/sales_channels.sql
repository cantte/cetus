CREATE TABLE "sales_channels" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"tenant_id" uuid NOT NULL,
	"type" "sales_channel_type" NOT NULL,
	"name" text,
	"status" "channel_status" DEFAULT 'active'::"channel_status" NOT NULL,
	"capabilities_json" jsonb DEFAULT '{}' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone
);

CREATE UNIQUE INDEX "sales_channels_tenant_type_idx" ON "sales_channels" ("tenant_id","type");
CREATE INDEX "sales_channels_tenant_idx" ON "sales_channels" ("tenant_id");
CREATE INDEX "sales_channels_type_idx" ON "sales_channels" ("type");
CREATE INDEX "sales_channels_status_idx" ON "sales_channels" ("status");
ALTER TABLE "sales_channels" ADD CONSTRAINT "sales_channels_tenant_id_tenants_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;
