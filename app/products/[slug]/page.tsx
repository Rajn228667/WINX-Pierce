import { notFound } from 'next/navigation'
import { getProduct, products } from '@/lib/products'
import ProductDetail from '@/components/product-detail'

export function generateStaticParams() {
  return products.slice(0, 50).map((p) => ({ slug: p.slug }))
}

export async function generateMetadata({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params
  const product = getProduct(slug)
  if (!product) return { title: 'hikmart.kz' }
  return {
    title: `${product.model} — ${product.brand} | hikmart.kz`,
    description: `${product.brand} ${product.model}, артикул ${product.article}. Купить в Шымкенте с доставкой по Казахстану.`,
  }
}

export default async function ProductPage({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params
  const product = getProduct(slug)
  if (!product) notFound()
  return <ProductDetail product={product} />
}
