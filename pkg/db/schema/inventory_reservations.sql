CREATE TABLE "inventory_reservations" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"tenant_id" uuid NOT NULL,
	"customer_id" uuid,
	"conversation_id" uuid,
	"cart_id" uuid,
	"order_id" uuid,
	"variant_id" uuid NOT NULL,
	"location_id" uuid NOT NULL,
	"quantity" numeric(18,6) NOT NULL,
	"status" "inventory_reservation_status" DEFAULT 'active'::"inventory_reservation_status" NOT NULL,
	"expires_at" timestamp with time zone NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"confirmed_at" timestamp with time zone,
	"released_at" timestamp with time zone,
	CONSTRAINT "inventory_reservations_quantity_positive" CHECK ("quantity" > 0)
);

CREATE INDEX "inventory_reservations_tenant_idx" ON "inventory_reservations" ("tenant_id");
CREATE INDEX "inventory_reservations_variant_idx" ON "inventory_reservations" ("variant_id");
CREATE INDEX "inventory_reservations_location_idx" ON "inventory_reservations" ("location_id");
CREATE INDEX "inventory_reservations_status_idx" ON "inventory_reservations" ("status");
CREATE INDEX "inventory_reservations_expires_at_idx" ON "inventory_reservations" ("expires_at");
CREATE INDEX "inventory_reservations_cart_idx" ON "inventory_reservations" ("cart_id");
CREATE INDEX "inventory_reservations_order_idx" ON "inventory_reservations" ("order_id");
ALTER TABLE "inventory_reservations" ADD CONSTRAINT "inventory_reservations_tenant_id_tenants_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "inventory_reservations" ADD CONSTRAINT "inventory_reservations_variant_id_product_variants_id_fkey" FOREIGN KEY ("variant_id") REFERENCES "product_variants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "inventory_reservations" ADD CONSTRAINT "inventory_reservations_location_id_inventory_locations_id_fkey" FOREIGN KEY ("location_id") REFERENCES "inventory_locations"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
