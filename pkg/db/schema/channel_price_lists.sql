CREATE TABLE "channel_price_lists" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"tenant_id" uuid NOT NULL,
	"sales_channel_id" uuid NOT NULL,
	"price_list_id" uuid NOT NULL,
	"priority" integer DEFAULT 0 NOT NULL,
	"starts_at" timestamp with time zone,
	"ends_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE UNIQUE INDEX "channel_price_lists_channel_price_list_idx" ON "channel_price_lists" ("sales_channel_id","price_list_id");
CREATE INDEX "channel_price_lists_tenant_idx" ON "channel_price_lists" ("tenant_id");
CREATE INDEX "channel_price_lists_channel_idx" ON "channel_price_lists" ("sales_channel_id");
CREATE INDEX "channel_price_lists_price_list_idx" ON "channel_price_lists" ("price_list_id");
CREATE INDEX "channel_price_lists_priority_idx" ON "channel_price_lists" ("priority");
ALTER TABLE "channel_price_lists" ADD CONSTRAINT "channel_price_lists_tenant_id_tenants_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "channel_price_lists" ADD CONSTRAINT "channel_price_lists_sales_channel_id_sales_channels_id_fkey" FOREIGN KEY ("sales_channel_id") REFERENCES "sales_channels"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "channel_price_lists" ADD CONSTRAINT "channel_price_lists_price_list_id_price_lists_id_fkey" FOREIGN KEY ("price_list_id") REFERENCES "price_lists"("id") ON DELETE CASCADE ON UPDATE CASCADE;
