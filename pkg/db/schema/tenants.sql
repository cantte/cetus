CREATE TABLE "tenants" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"name" text NOT NULL,
	"slug" text NOT NULL,
	"country" text DEFAULT 'CO' NOT NULL,
	"currency" text DEFAULT 'COP' NOT NULL,
	"timezone" text DEFAULT 'America/Bogota' NOT NULL,
	"status" "tenant_status" DEFAULT 'active'::"tenant_status" NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone
);

CREATE UNIQUE INDEX "tenants_slug_idx" ON "tenants" ("slug");
CREATE INDEX "tenants_status_idx" ON "tenants" ("status");
