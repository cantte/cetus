CREATE TABLE "business_verticals" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	"code" text NOT NULL,
	"name" text NOT NULL,
	"description" text,
	"status" "business_vertical_status" DEFAULT 'active'::"business_vertical_status" NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);

CREATE UNIQUE INDEX "business_verticals_code_idx" ON "business_verticals" ("code");
CREATE INDEX "business_verticals_status_idx" ON "business_verticals" ("status");
