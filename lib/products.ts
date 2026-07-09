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
}

export const products: Product[] = productsData as Product[]

export const brands: { name: string; count: number; url: string }[] = [
  { name: "Hikvision", count: 680, url: "https://www.hikvision.com" },
  { name: "HiWatch", count: 142, url: "https://hi.watch" },
  { name: "Ruijie | Reyee", count: 128, url: "https://www.ruijienetworks.com" },
  { name: "Ezviz", count: 109, url: "https://www.ezviz.com" },
  { name: "Volta", count: 87, url: "https://volta.kz" },
  { name: "Huawei", count: 87, url: "https://e.huawei.com" },
  { name: "HiLook", count: 36, url: "https://www.hilook.com" },
  { name: "Сибирский Арсенал", count: 20, url: "https://www.arsenalnpo.ru" },
  { name: "Uniview", count: 5, url: "https://www.uniview.com" },
  { name: "Hikmicro", count: 4, url: "https://www.hikmicrotech.com" },
  { name: "Seagate", count: 3, url: "https://www.seagate.com" },
  { name: "Ruijie", count: 1, url: "https://www.ruijienetworks.com" },
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
