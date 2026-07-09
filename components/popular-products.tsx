'use client'

import Link from 'next/link'
import { motion } from 'framer-motion'
import { ArrowUpRight } from 'lucide-react'
import { products } from '@/lib/products'
import ProductCard from '@/components/product-card'
import { useT } from '@/lib/use-t'

export default function PopularProducts() {
  const t = useT()
  // Spread picks across categories for variety
  const picks = [
    ...products.filter((p) => p.category === 'cameras').slice(0, 3),
    ...products.filter((p) => p.category === 'recorders').slice(0, 2),
    ...products.filter((p) => p.category === 'intercoms').slice(0, 1),
    ...products.filter((p) => p.category === 'network').slice(0, 1),
    ...products.filter((p) => p.category === 'alarm').slice(0, 1),
  ].slice(0, 8)

  return (
    <section className="mx-auto max-w-7xl px-4 py-12 md:px-6 md:py-16" aria-labelledby="popular-title">
      <div className="mb-8 flex items-end justify-between">
        <div>
          <h2 id="popular-title" className="font-sans text-2xl font-bold text-foreground md:text-3xl text-balance">
            {t('popular.title')}
          </h2>
          <p className="mt-2 max-w-xl text-muted-foreground text-pretty">{t('popular.subtitle')}</p>
        </div>
        <Link href="/catalog" className="hidden items-center gap-1 text-sm font-medium text-primary hover:underline md:inline-flex">
          {t('brands.all')}
          <ArrowUpRight className="h-4 w-4" aria-hidden="true" />
        </Link>
      </div>

      <div className="grid grid-cols-2 gap-4 md:grid-cols-4">
        {picks.map((p, i) => (
          <motion.div
            key={p.slug}
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: '-40px' }}
            transition={{ duration: 0.4, delay: (i % 4) * 0.06 }}
          >
            <ProductCard product={p} />
          </motion.div>
        ))}
      </div>
    </section>
  )
}
