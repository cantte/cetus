import { defineRelations } from "drizzle-orm";

import * as schema from "./schema";

export const relations = defineRelations(schema, (r) => ({
  account: {
    user: r.one.user({
      from: r.account.userId,
      to: r.user.id,
    }),
  },

  user: {
    account: r.many.account(),
    session: r.many.session(),
  },

  session: {
    user: r.one.user({
      from: r.session.userId,
      to: r.user.id,
    }),
  },

  tenants: {
    catalogSettings: r.one.tenantCatalogSettings(),
  },

  businessVerticals: {
    catalogTemplates: r.many.catalogTemplates(),
    tenantCatalogSettings: r.many.tenantCatalogSettings(),
  },

  catalogTemplates: {
    vertical: r.one.businessVerticals({
      from: r.catalogTemplates.verticalId,
      to: r.businessVerticals.id,
    }),
    tenantCatalogSettings: r.many.tenantCatalogSettings(),
  },

  tenantCatalogSettings: {
    tenant: r.one.tenants({
      from: r.tenantCatalogSettings.tenantId,
      to: r.tenants.id,
    }),

    vertical: r.one.businessVerticals({
      from: r.tenantCatalogSettings.verticalId,
      to: r.businessVerticals.id,
    }),

    catalogTemplate: r.one.catalogTemplates({
      from: r.tenantCatalogSettings.catalogTemplateId,
      to: r.catalogTemplates.id,
    }),
  },
}));
