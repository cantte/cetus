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

  categories: {
    tenant: r.one.tenants({
      from: r.categories.tenantId,
      to: r.tenants.id,
    }),

    parent: r.one.categories({
      from: r.categories.parentId,
      to: r.categories.id,
    }),

    children: r.many.categories(),

    products: r.many.products(),
    attributeDefinitions: r.many.productAttributeDefinitions(),
  },

  products: {
    tenant: r.one.tenants({
      from: r.products.tenantId,
      to: r.tenants.id,
    }),

    category: r.one.categories({
      from: r.products.categoryId,
      to: r.categories.id,
    }),

    variants: r.many.productVariants(),
    images: r.many.productImages(),
  },

  productVariants: {
    tenant: r.one.tenants({
      from: r.productVariants.tenantId,
      to: r.tenants.id,
    }),

    product: r.one.products({
      from: r.productVariants.productId,
      to: r.products.id,
    }),

    unit: r.one.unitDefinitions({
      from: r.productVariants.unitId,
      to: r.unitDefinitions.id,
    }),

    images: r.many.productImages(),
    prices: r.many.variantPrices(),
    stocks: r.many.inventoryStocks(),
    movements: r.many.inventoryMovements(),
    reservations: r.many.inventoryReservations(),
  },

  productImages: {
    tenant: r.one.tenants({
      from: r.productImages.tenantId,
      to: r.tenants.id,
    }),

    product: r.one.products({
      from: r.productImages.productId,
      to: r.products.id,
    }),

    variant: r.one.productVariants({
      from: r.productImages.variantId,
      to: r.productVariants.id,
    }),
  },

  productAttributeDefinitions: {
    tenant: r.one.tenants({
      from: r.productAttributeDefinitions.tenantId,
      to: r.tenants.id,
    }),

    category: r.one.categories({
      from: r.productAttributeDefinitions.categoryId,
      to: r.categories.id,
    }),
  },

  unitDefinitions: {
    tenant: r.one.tenants({
      from: r.unitDefinitions.tenantId,
      to: r.tenants.id,
    }),

    baseUnit: r.one.unitDefinitions({
      from: r.unitDefinitions.baseUnitId,
      to: r.unitDefinitions.id,
    }),

    variants: r.many.productVariants(),
  },

  priceLists: {
    tenant: r.one.tenants({
      from: r.priceLists.tenantId,
      to: r.tenants.id,
    }),

    prices: r.many.variantPrices(),
  },

  variantPrices: {
    tenant: r.one.tenants({
      from: r.variantPrices.tenantId,
      to: r.tenants.id,
    }),

    variant: r.one.productVariants({
      from: r.variantPrices.variantId,
      to: r.productVariants.id,
    }),

    priceList: r.one.priceLists({
      from: r.variantPrices.priceListId,
      to: r.priceLists.id,
    }),
  },

  inventoryLocations: {
    tenant: r.one.tenants({
      from: r.inventoryLocations.tenantId,
      to: r.tenants.id,
    }),

    stocks: r.many.inventoryStocks(),
    movements: r.many.inventoryMovements(),
    reservations: r.many.inventoryReservations(),
  },

  inventoryStocks: {
    tenant: r.one.tenants({
      from: r.inventoryStocks.tenantId,
      to: r.tenants.id,
    }),

    variant: r.one.productVariants({
      from: r.inventoryStocks.variantId,
      to: r.productVariants.id,
    }),

    location: r.one.inventoryLocations({
      from: r.inventoryStocks.locationId,
      to: r.inventoryLocations.id,
    }),
  },

  inventoryMovements: {
    tenant: r.one.tenants({
      from: r.inventoryMovements.tenantId,
      to: r.tenants.id,
    }),

    variant: r.one.productVariants({
      from: r.inventoryMovements.variantId,
      to: r.productVariants.id,
    }),

    location: r.one.inventoryLocations({
      from: r.inventoryMovements.locationId,
      to: r.inventoryLocations.id,
    }),
  },

  inventoryReservations: {
    tenant: r.one.tenants({
      from: r.inventoryReservations.tenantId,
      to: r.tenants.id,
    }),

    variant: r.one.productVariants({
      from: r.inventoryReservations.variantId,
      to: r.productVariants.id,
    }),

    location: r.one.inventoryLocations({
      from: r.inventoryReservations.locationId,
      to: r.inventoryLocations.id,
    }),
  },
}));
