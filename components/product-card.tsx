'use client'

import Link from 'next/link'
import Image from 'next/image'
import { ShoppingCart, Check } from 'lucide-react'
import { useState } from 'react'
import { formatPrice, type Product } from '@/lib/products'
import { useAppStore } from '@/lib/store'
import { useT } from '@/lib/use-t'

export const categoryImages: Record<string, string> = {
  cameras: '/images/cat-cameras.png',
  recorders: '/images/cat-recorders.png',
  intercoms: '/images/cat-intercoms.png',
  alarm: '/images/cat-alarm.png',
  network: '/images/cat-network.png',
  access: '/images/cat-access.png',
  audio: '/images/cat-audio.png',
  auto: '/images/cat-auto.png',
  accessories: '/images/cat-accessories.png',
}

export default function ProductCard({ product }: { product: Product }) {
  const t = useT()
  const addToCart = useAppStore((s) => s.addToCart)
  const [added, setAdded] = useState(false)

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
    <article className="group flex flex-col overflow-hidden rounded-xl border border-border bg-card transition-shadow hover:shadow-lg hover:shadow-primary/5">
      <Link href={`/products/${product.slug}`} className="relative block aspect-square overflow-hidden bg-secondary">
        <Image
          src={categoryImages[product.category] || '/images/cat-accessories.png'}
          alt={product.model}
          fill
          className="object-cover transition-transform duration-500 group-hover:scale-105"
          sizes="(max-width: 768px) 50vw, 25vw"
        />
        <span className="absolute left-3 top-3 rounded-full bg-background/90 px-2.5 py-1 text-xs font-medium text-foreground backdrop-blur">
          {product.brand}
        </span>
      </Link>
      <div className="flex flex-1 flex-col gap-2 p-4">
        <p className="text-xs text-muted-foreground">
          {t('product.article')}: {product.article}
        </p>
        <Link href={`/products/${product.slug}`} className="line-clamp-2 min-h-[2.5rem] text-sm font-medium text-foreground hover:text-primary">
          {product.model}
        </Link>
        <p className="flex items-center gap-1.5 text-xs text-success">
          <span className="h-1.5 w-1.5 rounded-full bg-success" aria-hidden="true" />
          {t('catalog.instock')}: {product.stock}
        </p>
        <div className="mt-auto flex items-center justify-between gap-2 pt-2">
          <span className="text-base font-bold text-foreground">{formatPrice(product.price)}</span>
          <button
            type="button"
            onClick={handleAdd}
            aria-label={`${t('catalog.addtocart')}: ${product.model}`}
            className={`flex h-9 w-9 shrink-0 items-center justify-center rounded-lg transition-colors ${
              added ? 'bg-success text-success-foreground' : 'bg-primary text-primary-foreground hover:bg-primary/90'
            }`}
          >
            {added ? <Check className="h-4 w-4" aria-hidden="true" /> : <ShoppingCart className="h-4 w-4" aria-hidden="true" />}
          </button>
        </div>
      </div>
    </article>
  )
}
