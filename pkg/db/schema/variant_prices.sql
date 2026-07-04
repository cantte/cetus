CREATE TABLE "variant_prices" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"tenant_id" uuid NOT NULL,
	"variant_id" uuid NOT NULL,
	"price_list_id" uuid NOT NULL,
	"regular_price" numeric(18,2) NOT NULL,
	"sale_price" numeric(18,2),
	"cost_price" numeric(18,2),
	"compare_at_price" numeric(18,2),
	"starts_at" timestamp with time zone,
	"ends_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "variant_prices_regular_price_non_negative" CHECK ("regular_price" >= 0),
	CONSTRAINT "variant_prices_sale_price_non_negative" CHECK ("sale_price" IS NULL OR "sale_price" >= 0),
	CONSTRAINT "variant_prices_cost_price_non_negative" CHECK ("cost_price" IS NULL OR "cost_price" >= 0)
);

CREATE UNIQUE INDEX "variant_prices_variant_price_list_idx" ON "variant_prices" ("variant_id","price_list_id","starts_at");
CREATE INDEX "variant_prices_tenant_idx" ON "variant_prices" ("tenant_id");
CREATE INDEX "variant_prices_variant_idx" ON "variant_prices" ("variant_id");
CREATE INDEX "variant_prices_price_list_idx" ON "variant_prices" ("price_list_id");
ALTER TABLE "variant_prices" ADD CONSTRAINT "variant_prices_tenant_id_tenants_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "variant_prices" ADD CONSTRAINT "variant_prices_variant_id_product_variants_id_fkey" FOREIGN KEY ("variant_id") REFERENCES "product_variants"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "variant_prices" ADD CONSTRAINT "variant_prices_price_list_id_price_lists_id_fkey" FOREIGN KEY ("price_list_id") REFERENCES "price_lists"("id") ON DELETE CASCADE ON UPDATE CASCADE;
