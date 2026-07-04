CREATE TABLE "channel_inventory_policies" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"tenant_id" uuid NOT NULL,
	"sales_channel_id" uuid NOT NULL,
	"location_id" uuid,
	"reservation_ttl_minutes" integer DEFAULT 15 NOT NULL,
	"allow_backorder" boolean DEFAULT false NOT NULL,
	"safety_stock" numeric(18,6) DEFAULT '0' NOT NULL,
	"stock_visibility" "stock_visibility" DEFAULT 'available_only'::"stock_visibility" NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "channel_inventory_policies_reservation_ttl_non_negative" CHECK ("reservation_ttl_minutes" >= 0),
	CONSTRAINT "channel_inventory_policies_safety_stock_non_negative" CHECK ("safety_stock" >= 0)
);

CREATE UNIQUE INDEX "channel_inventory_policies_channel_location_idx" ON "channel_inventory_policies" ("sales_channel_id","location_id");
CREATE INDEX "channel_inventory_policies_tenant_idx" ON "channel_inventory_policies" ("tenant_id");
CREATE INDEX "channel_inventory_policies_channel_idx" ON "channel_inventory_policies" ("sales_channel_id");
CREATE INDEX "channel_inventory_policies_location_idx" ON "channel_inventory_policies" ("location_id");
ALTER TABLE "channel_inventory_policies" ADD CONSTRAINT "channel_inventory_policies_tenant_id_tenants_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "channel_inventory_policies" ADD CONSTRAINT "channel_inventory_policies_a5IevPrxJppK_fkey" FOREIGN KEY ("sales_channel_id") REFERENCES "sales_channels"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "channel_inventory_policies" ADD CONSTRAINT "channel_inventory_policies_r9l4IBEGcHwP_fkey" FOREIGN KEY ("location_id") REFERENCES "inventory_locations"("id") ON DELETE SET NULL ON UPDATE CASCADE;
