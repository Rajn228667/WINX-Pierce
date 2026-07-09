'use client'

import Link from 'next/link'
import { brands } from '@/lib/products'
import { useT } from '@/lib/use-t'

export default function BrandsStrip() {
  const t = useT()
  const doubled = [...brands, ...brands]

  return (
    <section className="overflow-hidden py-12 md:py-16" aria-labelledby="brands-title">
      <div className="mx-auto mb-8 max-w-7xl px-4 md:px-6">
        <h2 id="brands-title" className="font-sans text-2xl font-bold text-foreground md:text-3xl text-balance">
          {t('brands.title')}
        </h2>
        <p className="mt-2 max-w-xl text-muted-foreground text-pretty">{t('brands.subtitle')}</p>
      </div>
      <div className="relative">
        <div className="pointer-events-none absolute inset-y-0 left-0 z-10 w-24 bg-gradient-to-r from-background to-transparent" aria-hidden="true" />
        <div className="pointer-events-none absolute inset-y-0 right-0 z-10 w-24 bg-gradient-to-l from-background to-transparent" aria-hidden="true" />
        <div className="flex w-max animate-marquee gap-4">
          {doubled.map((b, i) => (
            <Link
              key={`${b.name}-${i}`}
              href={`/catalog?brand=${encodeURIComponent(b.name)}`}
              className="flex min-w-[200px] flex-col rounded-xl border border-border bg-card px-6 py-5 transition-colors hover:border-primary/40"
            >
              <span className="font-sans text-lg font-bold text-foreground">{b.name}</span>
              <span className="mt-1 text-xs text-muted-foreground">
                {b.count} {t('brands.positions')}
              </span>
            </Link>
          ))}
        </div>
      </div>
    </section>
  )
}
