CREATE TABLE "price_lists" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"tenant_id" uuid NOT NULL,
	"name" text NOT NULL,
	"currency" text DEFAULT 'COP' NOT NULL,
	"channel_type" "sales_channel_type",
	"is_default" boolean DEFAULT false NOT NULL,
	"priority" integer DEFAULT 0 NOT NULL,
	"status" "price_list_status" DEFAULT 'active'::"price_list_status" NOT NULL,
	"starts_at" timestamp with time zone,
	"ends_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE UNIQUE INDEX "price_lists_tenant_name_idx" ON "price_lists" ("tenant_id","name");
CREATE INDEX "price_lists_tenant_idx" ON "price_lists" ("tenant_id");
CREATE INDEX "price_lists_channel_type_idx" ON "price_lists" ("channel_type");
CREATE INDEX "price_lists_priority_idx" ON "price_lists" ("priority");
CREATE INDEX "price_lists_status_idx" ON "price_lists" ("status");
ALTER TABLE "price_lists" ADD CONSTRAINT "price_lists_tenant_id_tenants_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;
