export const siteUrl = "https://mambonami.com";
export const siteName = "MAMBONAMI";
export const defaultTitle = "MAMBONAMI | Farm-Fresh Produce Marketplace in Kenya";
export const defaultDescription =
  "MAMBONAMI connects Kenyan farmers with retailers, restaurants, hotels, and households for fresh produce, fair prices, transparent sourcing, M-Pesa escrow, and reliable delivery.";
export const defaultImage = `${siteUrl}/og-image.jpg`;

type SeoOptions = {
  title?: string;
  description?: string;
  path?: string;
  image?: string;
  type?: "website" | "article";
  noIndex?: boolean;
};

export function absoluteUrl(path = "/") {
  return `${siteUrl}${path.startsWith("/") ? path : `/${path}`}`;
}

export function seoMeta({
  title = defaultTitle,
  description = defaultDescription,
  path = "/",
  image = defaultImage,
  type = "website",
  noIndex = false,
}: SeoOptions = {}) {
  const url = absoluteUrl(path);

  return [
    { title },
    { name: "description", content: description },
    { name: "robots", content: noIndex ? "noindex, nofollow" : "index, follow" },
    { name: "author", content: siteName },
    {
      name: "keywords",
      content:
        "MAMBONAMI, Kenya farm produce, fresh vegetables Kenya, direct farm marketplace, farmers marketplace Kenya, M-Pesa escrow, restaurant produce supply, wholesale produce Nairobi",
    },
    { property: "og:site_name", content: siteName },
    { property: "og:title", content: title },
    { property: "og:description", content: description },
    { property: "og:type", content: type },
    { property: "og:url", content: url },
    { property: "og:image", content: image },
    { property: "og:image:alt", content: "Fresh Kenyan produce from MAMBONAMI partner farms" },
    { property: "og:locale", content: "en_KE" },
    { name: "twitter:card", content: "summary_large_image" },
    { name: "twitter:title", content: title },
    { name: "twitter:description", content: description },
    { name: "twitter:image", content: image },
  ];
}

export function seoLinks(path = "/") {
  return [{ rel: "canonical", href: absoluteUrl(path) }];
}

export const organizationJsonLd = {
  "@context": "https://schema.org",
  "@type": "Organization",
  name: siteName,
  url: siteUrl,
  logo: `${siteUrl}/favicon.ico`,
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
