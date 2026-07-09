import productsData from "./products-data.json"

export type Category =
  | "cameras"
  | "recorders"
  | "intercoms"
  | "alarm"
  | "network"
  | "auto"
  | "access"
  | "audio"
  | "accessories"

export interface Product {
  slug: string
  brand: string
  article: string
  model: string
  price: number
  stock: string
  category: Category
  image: string
}

export const products: Product[] = productsData as Product[]

const brandCounts: Record<string, number> = {}
for (const p of products) {
  brandCounts[p.brand] = (brandCounts[p.brand] || 0) + 1
}

export const brands: { name: string; count: number; url: string }[] = [
  { name: "Hikvision", count: brandCounts["Hikvision"] || 0, url: "https://www.hikvision.com" },
  { name: "HiWatch", count: brandCounts["HiWatch"] || 0, url: "https://hi.watch" },
  { name: "Ezviz", count: brandCounts["Ezviz"] || 0, url: "https://www.ezviz.com" },
]

export const categories: { id: Category; icon: string }[] = [
  { id: "cameras", icon: "camera" },
  { id: "recorders", icon: "hard-drive" },
  { id: "intercoms", icon: "phone" },
  { id: "alarm", icon: "bell" },
  { id: "network", icon: "network" },
  { id: "access", icon: "key" },
  { id: "audio", icon: "volume" },
  { id: "auto", icon: "car" },
  { id: "accessories", icon: "package" },
]

export function formatPrice(price: number): string {
  return price.toLocaleString("ru-RU").replace(/,/g, " ") + " KZT"
}

export function getProduct(slug: string): Product | undefined {
  return products.find((p) => p.slug === slug)
}

export function searchProducts(query: string): Product[] {
  const q = query.trim().toLowerCase()
  if (!q) return []
  return products.filter(
    (p) =>
      p.model.toLowerCase().includes(q) ||
      p.brand.toLowerCase().includes(q) ||
      p.article.includes(q) ||
      p.category.includes(q),
  )
}
