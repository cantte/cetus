CREATE TABLE "inventory_stocks" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"tenant_id" uuid NOT NULL,
	"variant_id" uuid NOT NULL,
	"location_id" uuid NOT NULL,
	"quantity_on_hand" numeric(18,6) DEFAULT '0' NOT NULL,
	"quantity_reserved" numeric(18,6) DEFAULT '0' NOT NULL,
	"quantity_available" numeric(18,6) DEFAULT '0' NOT NULL,
	"safety_stock" numeric(18,6) DEFAULT '0' NOT NULL,
	"reorder_point" numeric(18,6) DEFAULT '0' NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "inventory_stocks_on_hand_non_negative" CHECK ("quantity_on_hand" >= 0),
	CONSTRAINT "inventory_stocks_reserved_non_negative" CHECK ("quantity_reserved" >= 0),
	CONSTRAINT "inventory_stocks_available_non_negative" CHECK ("quantity_available" >= 0),
	CONSTRAINT "inventory_stocks_safety_stock_non_negative" CHECK ("safety_stock" >= 0),
	CONSTRAINT "inventory_stocks_reorder_point_non_negative" CHECK ("reorder_point" >= 0)
);

CREATE UNIQUE INDEX "inventory_stocks_variant_location_idx" ON "inventory_stocks" ("variant_id","location_id");
CREATE INDEX "inventory_stocks_tenant_idx" ON "inventory_stocks" ("tenant_id");
CREATE INDEX "inventory_stocks_variant_idx" ON "inventory_stocks" ("variant_id");
CREATE INDEX "inventory_stocks_location_idx" ON "inventory_stocks" ("location_id");
ALTER TABLE "inventory_stocks" ADD CONSTRAINT "inventory_stocks_tenant_id_tenants_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "inventory_stocks" ADD CONSTRAINT "inventory_stocks_variant_id_product_variants_id_fkey" FOREIGN KEY ("variant_id") REFERENCES "product_variants"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "inventory_stocks" ADD CONSTRAINT "inventory_stocks_location_id_inventory_locations_id_fkey" FOREIGN KEY ("location_id") REFERENCES "inventory_locations"("id") ON DELETE CASCADE ON UPDATE CASCADE;
