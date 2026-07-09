'use client'

import Link from 'next/link'
import Image from 'next/image'
import { useEffect, useState } from 'react'
import { Minus, Plus, Trash2, ShoppingCart, ArrowRight } from 'lucide-react'
import { formatPrice, getProduct } from '@/lib/products'
import { categoryImages } from '@/components/product-card'
import { useAppStore } from '@/lib/store'
import { useT } from '@/lib/use-t'

export default function CartClient() {
  const t = useT()
  const cart = useAppStore((s) => s.cart)
  const setQty = useAppStore((s) => s.setQty)
  const removeFromCart = useAppStore((s) => s.removeFromCart)
  const [mounted, setMounted] = useState(false)

  useEffect(() => setMounted(true), [])

  const total = cart.reduce((sum, item) => sum + item.price * item.qty, 0)

  if (!mounted) {
    return (
      <div className="mx-auto max-w-4xl px-4 py-14 md:px-6">
        <div className="skeleton h-64 rounded-xl" />
      </div>
    )
  }

  return (
    <div className="mx-auto max-w-4xl px-4 py-10 md:px-6 md:py-14">
      <h1 className="mb-8 font-sans text-3xl font-bold text-foreground md:text-4xl">{t('cart.title')}</h1>

      {cart.length === 0 ? (
        <div className="flex flex-col items-center gap-4 rounded-2xl border border-border bg-card py-20 text-center">
          <ShoppingCart className="h-10 w-10 text-muted-foreground" aria-hidden="true" />
          <p className="text-lg font-medium text-foreground">{t('cart.empty')}</p>
          <Link
            href="/catalog"
            className="inline-flex items-center gap-2 rounded-lg bg-primary px-6 py-3 text-sm font-medium text-primary-foreground transition-colors hover:bg-primary/90"
          >
            {t('cart.empty.cta')}
            <ArrowRight className="h-4 w-4" aria-hidden="true" />
          </Link>
        </div>
      ) : (
        <>
          <ul className="divide-y divide-border rounded-2xl border border-border bg-card">
            {cart.map((item) => {
              const product = getProduct(item.slug)
              const image = product ? categoryImages[product.category] : '/images/cat-accessories.png'
              return (
                <li key={item.slug} className="flex items-center gap-4 p-4 md:p-5">
                  <Link href={`/products/${item.slug}`} className="relative h-20 w-20 shrink-0 overflow-hidden rounded-lg bg-secondary">
                    <Image src={image || "/placeholder.svg"} alt={item.model} fill className="object-cover" sizes="80px" />
                  </Link>
                  <div className="min-w-0 flex-1">
                    <Link href={`/products/${item.slug}`} className="line-clamp-2 text-sm font-medium text-foreground hover:text-primary">
                      {item.model}
                    </Link>
                    <p className="mt-1 text-xs text-muted-foreground">
                      {item.brand} · {t('product.article')}: {item.article}
                    </p>
                    <p className="mt-1 text-sm font-semibold text-foreground md:hidden">{formatPrice(item.price * item.qty)}</p>
                  </div>
                  <div className="flex items-center gap-2" role="group" aria-label={`${t('cart.qty')}: ${item.model}`}>
                    <button
                      type="button"
                      onClick={() => setQty(item.slug, item.qty - 1)}
                      aria-label={`${t('cart.qty')} -`}
                      className="flex h-8 w-8 items-center justify-center rounded-md border border-border text-foreground transition-colors hover:bg-secondary"
                    >
                      <Minus className="h-3.5 w-3.5" aria-hidden="true" />
                    </button>
                    <span className="w-8 text-center text-sm font-medium text-foreground">{item.qty}</span>
                    <button
                      type="button"
                      onClick={() => setQty(item.slug, item.qty + 1)}
                      aria-label={`${t('cart.qty')} +`}
                      className="flex h-8 w-8 items-center justify-center rounded-md border border-border text-foreground transition-colors hover:bg-secondary"
                    >
                      <Plus className="h-3.5 w-3.5" aria-hidden="true" />
                    </button>
                  </div>
                  <p className="hidden w-32 text-right text-sm font-semibold text-foreground md:block">
                    {formatPrice(item.price * item.qty)}
                  </p>
                  <button
                    type="button"
                    onClick={() => removeFromCart(item.slug)}
                    aria-label={`${t('cart.remove')}: ${item.model}`}
                    className="flex h-8 w-8 shrink-0 items-center justify-center rounded-md text-muted-foreground transition-colors hover:bg-destructive/10 hover:text-destructive"
                  >
                    <Trash2 className="h-4 w-4" aria-hidden="true" />
                  </button>
                </li>
              )
            })}
          </ul>

          <div className="mt-6 flex flex-col items-end gap-4">
            <p className="text-lg text-muted-foreground">
              {t('cart.total')}: <span className="font-sans text-2xl font-bold text-foreground">{formatPrice(total)}</span>
            </p>
            <Link
              href="/checkout"
              className="btn-glow inline-flex items-center gap-2 rounded-lg bg-primary px-8 py-3.5 font-medium text-primary-foreground"
            >
              {t('cart.checkout')}
              <ArrowRight className="h-4 w-4" aria-hidden="true" />
            </Link>
            <p className="text-xs text-muted-foreground">{t('site.disclaimer')}</p>
          </div>
        </>
      )}
    </div>
  )
}
