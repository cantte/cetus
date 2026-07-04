CREATE TABLE "inventory_locations" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"tenant_id" uuid NOT NULL,
	"name" text NOT NULL,
	"type" "inventory_location_type" DEFAULT 'warehouse'::"inventory_location_type" NOT NULL,
	"address" text,
	"city" text,
	"status" "record_status" DEFAULT 'active'::"record_status" NOT NULL,
	"is_default" boolean DEFAULT false NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE UNIQUE INDEX "inventory_locations_tenant_name_idx" ON "inventory_locations" ("tenant_id","name");
CREATE INDEX "inventory_locations_tenant_idx" ON "inventory_locations" ("tenant_id");
CREATE INDEX "inventory_locations_status_idx" ON "inventory_locations" ("status");
ALTER TABLE "inventory_locations" ADD CONSTRAINT "inventory_locations_tenant_id_tenants_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;
