CREATE TABLE "unit_definitions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"tenant_id" uuid NOT NULL,
	"code" text NOT NULL,
	"name" text NOT NULL,
	"type" "unit_type" DEFAULT 'unit'::"unit_type" NOT NULL,
	"base_unit_id" uuid,
	"conversion_factor" numeric(18,6),
	"status" "record_status" DEFAULT 'active'::"record_status" NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE UNIQUE INDEX "unit_definitions_tenant_code_idx" ON "unit_definitions" ("tenant_id","code");
CREATE INDEX "unit_definitions_tenant_idx" ON "unit_definitions" ("tenant_id");
CREATE INDEX "unit_definitions_status_idx" ON "unit_definitions" ("status");
ALTER TABLE "unit_definitions" ADD CONSTRAINT "unit_definitions_tenant_id_tenants_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "unit_definitions" ADD CONSTRAINT "unit_definitions_base_unit_id_unit_definitions_id_fkey" FOREIGN KEY ("base_unit_id") REFERENCES "unit_definitions"("id") ON DELETE SET NULL ON UPDATE CASCADE;
