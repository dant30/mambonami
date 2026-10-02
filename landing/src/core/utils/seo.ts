// Must match the primary domain configured in Vercel, otherwise canonical/og:url point at a redirected host.
export const siteUrl = (import.meta.env.VITE_SITE_URL?.trim() || "https://www.mambonami.com").replace(/\/$/, "");
export const siteName = "MAMBONAMI";
export const defaultTitle = "MAMBONAMI | Farm-Fresh Produce Marketplace in Kenya";
export const defaultDescription =
  "MAMBONAMI connects Kenyan farmers with retailers, restaurants, hotels, and households for fresh produce, fair prices, transparent sourcing, M-Pesa escrow, and reliable delivery.";
// Falls back to a real shipped asset since no dedicated /og-image.jpg exists yet
export const defaultImage = `${siteUrl}/assets/images/hero-farm.jpg`;

type SeoOptions = {
  title?: string;
  description?: string;
  path?: string;
  image?: string;
  type?: "website" | "article" | "product";
  noIndex?: boolean;
};

export type SeoMetaTag = { title: string } | { name: string; content: string } | { property: string; content: string };
export type SeoLinkTag = { rel: string; href: string };

export function absoluteUrl(path = "/") {
  if (/^https?:\/\//i.test(path)) return path;
  return `${siteUrl}${path.startsWith("/") ? path : `/${path}`}`;
}

/** Appends the brand to page titles, keeping them within the ~60 character search snippet limit where possible. */
export function buildTitle(title?: string) {
  if (!title) return defaultTitle;
  const fullTitle = title.includes(siteName) ? title : `${title} | ${siteName}`;
  return fullTitle.length <= 65 ? fullTitle : `${fullTitle.slice(0, 62).trimEnd()}…`;
}

export function truncate(text: string, max = 160) {
  const clean = text.replace(/\s+/g, " ").trim();
  return clean.length <= max ? clean : `${clean.slice(0, max - 1).trimEnd()}…`;
}

export function seoMeta({
  title,
  description = defaultDescription,
  path = "/",
  image = defaultImage,
  type = "website",
  noIndex = false,
}: SeoOptions = {}): SeoMetaTag[] {
  const url = absoluteUrl(path);
  const fullTitle = buildTitle(title);
  const imageUrl = absoluteUrl(image);
  const summary = truncate(description);

  return [
    { title: fullTitle },
    { name: "description", content: summary },
    { name: "robots", content: noIndex ? "noindex, nofollow" : "index, follow, max-image-preview:large" },
    { name: "author", content: siteName },
    {
      name: "keywords",
      content:
        "MAMBONAMI, Kenya farm produce, fresh vegetables Kenya, direct farm marketplace, farmers marketplace Kenya, M-Pesa escrow, restaurant produce supply, wholesale produce Nairobi",
    },
    { property: "og:site_name", content: siteName },
    { property: "og:title", content: fullTitle },
    { property: "og:description", content: summary },
    { property: "og:type", content: type },
    { property: "og:url", content: url },
    { property: "og:image", content: imageUrl },
    { property: "og:image:alt", content: "Fresh Kenyan produce from MAMBONAMI partner farms" },
    { property: "og:locale", content: "en_KE" },
    { name: "twitter:card", content: "summary_large_image" },
    { name: "twitter:title", content: fullTitle },
    { name: "twitter:description", content: summary },
    { name: "twitter:image", content: imageUrl },
  ];
}

export function seoLinks(path = "/"): SeoLinkTag[] {
  return [{ rel: "canonical", href: absoluteUrl(path) }];
}

export interface ProductJsonLdInput {
  name: string;
  description?: string | null;
  image?: string | null;
  sku?: string | null;
  path: string;
  price: number | string;
  inStock: boolean;
  category?: string | null;
  sellerName?: string | null;
  rating?: number | null;
  reviewCount?: number | null;
}

export function buildProductJsonLd(input: ProductJsonLdInput) {
  const rating = input.rating != null && Number(input.reviewCount) > 0
    ? { aggregateRating: { "@type": "AggregateRating", ratingValue: Number(input.rating).toFixed(1), reviewCount: Number(input.reviewCount) } }
    : {};

  return {
    "@context": "https://schema.org",
    "@type": "Product",
    name: input.name,
    description: input.description ? truncate(input.description, 300) : undefined,
    image: input.image ? [absoluteUrl(input.image)] : [defaultImage],
    sku: input.sku || undefined,
    category: input.category || undefined,
    brand: { "@type": "Brand", name: input.sellerName || siteName },
    offers: {
      "@type": "Offer",
      url: absoluteUrl(input.path),
      priceCurrency: "KES",
      price: String(Number(input.price)),
      itemCondition: "https://schema.org/NewCondition",
      availability: input.inStock ? "https://schema.org/InStock" : "https://schema.org/OutOfStock",
      seller: { "@type": "Organization", name: siteName },
    },
    ...rating,
  };
}

export function buildBreadcrumbJsonLd(items: Array<{ name: string; path: string }>) {
  return {
    "@context": "https://schema.org",
    "@type": "BreadcrumbList",
    itemListElement: items.map((item, index) => ({ "@type": "ListItem", position: index + 1, name: item.name, item: absoluteUrl(item.path) })),
  };
}

export const organizationJsonLd = {
  "@context": "https://schema.org",
  "@type": "Organization",
  name: siteName,
  url: siteUrl,
  logo: `${siteUrl}/assets/icons/favicon.ico`,
  email: "hello@mambonami.com",
  telephone: "+254728102107",
  address: {
    "@type": "PostalAddress",
    addressLocality: "Nairobi",
    addressCountry: "KE",
  },
  sameAs: [],
};

export const websiteJsonLd = {
  "@context": "https://schema.org",
  "@type": "WebSite",
  name: siteName,
  url: siteUrl,
  description: defaultDescription,
  inLanguage: "en-KE",
};

export const marketplaceJsonLd = {
  "@context": "https://schema.org",
  "@type": "OnlineStore",
  name: siteName,
  url: siteUrl,
  description: defaultDescription,
  areaServed: {
    "@type": "Country",
    name: "Kenya",
  },
  paymentAccepted: "M-Pesa",
};
