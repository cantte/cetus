CREATE TABLE "inventory_movements" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"tenant_id" uuid NOT NULL,
	"variant_id" uuid NOT NULL,
	"location_id" uuid NOT NULL,
	"type" "inventory_movement_type" NOT NULL,
	"quantity" numeric(18,6) NOT NULL,
	"previous_quantity" numeric(18,6) NOT NULL,
	"new_quantity" numeric(18,6) NOT NULL,
	"reason" text,
	"reference_type" text,
	"reference_id" uuid,
	"created_by" text,
	"metadata_json" jsonb DEFAULT '{}' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "inventory_movements_quantity_positive" CHECK ("quantity" > 0)
);

CREATE INDEX "inventory_movements_tenant_idx" ON "inventory_movements" ("tenant_id");
CREATE INDEX "inventory_movements_variant_idx" ON "inventory_movements" ("variant_id");
CREATE INDEX "inventory_movements_location_idx" ON "inventory_movements" ("location_id");
CREATE INDEX "inventory_movements_type_idx" ON "inventory_movements" ("type");
CREATE INDEX "inventory_movements_reference_idx" ON "inventory_movements" ("reference_type","reference_id");
CREATE INDEX "inventory_movements_created_at_idx" ON "inventory_movements" ("created_at");
ALTER TABLE "inventory_movements" ADD CONSTRAINT "inventory_movements_tenant_id_tenants_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "inventory_movements" ADD CONSTRAINT "inventory_movements_variant_id_product_variants_id_fkey" FOREIGN KEY ("variant_id") REFERENCES "product_variants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "inventory_movements" ADD CONSTRAINT "inventory_movements_location_id_inventory_locations_id_fkey" FOREIGN KEY ("location_id") REFERENCES "inventory_locations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
