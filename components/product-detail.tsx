'use client'

import Link from 'next/link'
import Image from 'next/image'
import { useState } from 'react'
import { ArrowLeft, ShoppingCart, Check, Truck, ShieldCheck } from 'lucide-react'
import { formatPrice, products, type Product } from '@/lib/products'
import ProductCard, { categoryImages } from '@/components/product-card'
import { useAppStore } from '@/lib/store'
import { useT } from '@/lib/use-t'

function buildSpecs(product: Product, t: (k: string) => string): [string, string][] {
  return [
    [t('product.brand'), product.brand],
    [t('product.article'), product.article],
    [t('product.category'), t(`cat.${product.category}`)],
    [t('product.availability'), `${t('catalog.instock')}: ${product.stock}`],
    [t('product.warranty'), '12 мес.'],
  ]
}

export default function ProductDetail({ product }: { product: Product }) {
  const t = useT()
  const addToCart = useAppStore((s) => s.addToCart)
  const [added, setAdded] = useState(false)

  const related = products
    .filter((p) => p.category === product.category && p.slug !== product.slug)
    .slice(0, 4)

  const handleAdd = () => {
    addToCart({
      slug: product.slug,
      model: product.model,
      brand: product.brand,
      article: product.article,
      price: product.price,
    })
    setAdded(true)
    setTimeout(() => setAdded(false), 1500)
  }

  return (
    <div className="mx-auto max-w-7xl px-4 py-10 md:px-6 md:py-14">
      <Link href="/catalog" className="mb-8 inline-flex items-center gap-2 text-sm text-muted-foreground transition-colors hover:text-foreground">
        <ArrowLeft className="h-4 w-4" aria-hidden="true" />
        {t('product.back')}
      </Link>

      <div className="grid gap-10 md:grid-cols-2">
        <div className="relative aspect-square overflow-hidden rounded-2xl border border-border bg-card">
          <Image
            src={categoryImages[product.category] || '/images/cat-accessories.png'}
            alt={product.model}
            fill
            className="object-cover"
            sizes="(max-width: 768px) 100vw, 50vw"
            priority
          />
          <span className="absolute left-4 top-4 rounded-full bg-background/90 px-3 py-1.5 text-sm font-medium text-foreground backdrop-blur">
            {product.brand}
          </span>
        </div>

        <div className="flex flex-col">
          <p className="mb-2 text-sm text-muted-foreground">
            {t('product.article')}: {product.article}
          </p>
          <h1 className="mb-4 font-sans text-2xl font-bold text-foreground md:text-3xl text-balance">{product.model}</h1>

          <p className="mb-2 flex items-center gap-2 text-sm text-success">
            <span className="h-2 w-2 rounded-full bg-success" aria-hidden="true" />
            {t('catalog.instock')}: {product.stock}
          </p>

          <p className="mb-6 font-sans text-3xl font-bold text-foreground md:text-4xl">{formatPrice(product.price)}</p>

          <button
            type="button"
            onClick={handleAdd}
            className={`btn-glow mb-8 flex w-full items-center justify-center gap-2 rounded-lg px-6 py-3.5 font-medium transition-colors md:w-auto md:min-w-[240px] ${
              added ? 'bg-success text-success-foreground' : 'bg-primary text-primary-foreground hover:bg-primary/90'
            }`}
          >
            {added ? <Check className="h-5 w-5" aria-hidden="true" /> : <ShoppingCart className="h-5 w-5" aria-hidden="true" />}
            {t('catalog.addtocart')}
          </button>

          <div className="mb-8 grid grid-cols-2 gap-3">
            <div className="flex items-center gap-3 rounded-lg border border-border bg-card p-4">
              <Truck className="h-5 w-5 shrink-0 text-primary" aria-hidden="true" />
              <span className="text-sm text-muted-foreground">{t('product.delivery')}</span>
            </div>
            <div className="flex items-center gap-3 rounded-lg border border-border bg-card p-4">
              <ShieldCheck className="h-5 w-5 shrink-0 text-primary" aria-hidden="true" />
              <span className="text-sm text-muted-foreground">{t('product.warranty')}</span>
            </div>
          </div>

          <section aria-labelledby="specs-title">
            <h2 id="specs-title" className="mb-4 font-sans text-lg font-semibold text-foreground">
              {t('product.specs')}
            </h2>
            <dl className="divide-y divide-border rounded-xl border border-border bg-card">
              {buildSpecs(product, t).map(([label, value]) => (
                <div key={label} className="flex items-center justify-between gap-4 px-5 py-3.5">
                  <dt className="text-sm text-muted-foreground">{label}</dt>
                  <dd className="text-right text-sm font-medium text-foreground">{value}</dd>
                </div>
              ))}
            </dl>
          </section>

          <p className="mt-6 text-xs text-muted-foreground">{t('site.disclaimer')}</p>
        </div>
      </div>

      {related.length > 0 && (
        <section className="mt-16" aria-labelledby="related-title">
          <h2 id="related-title" className="mb-6 font-sans text-xl font-bold text-foreground md:text-2xl">
            {t('product.related')}
          </h2>
          <div className="grid grid-cols-2 gap-4 md:grid-cols-4">
            {related.map((p) => (
              <ProductCard key={p.slug} product={p} />
            ))}
          </div>
        </section>
      )}
    </div>
  )
}
