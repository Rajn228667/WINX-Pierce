'use client'

import Link from 'next/link'
import { motion } from 'framer-motion'
import { ArrowUpRight } from 'lucide-react'
import { brands, products } from '@/lib/products'
import { useT } from '@/lib/use-t'

export default function BrandsClient() {
  const t = useT()

  return (
    <div className="mx-auto max-w-7xl px-4 py-10 md:px-6 md:py-14">
      <header className="mb-10">
        <h1 className="font-sans text-3xl font-bold text-foreground md:text-4xl text-balance">{t('brands.title')}</h1>
        <p className="mt-2 max-w-xl text-muted-foreground text-pretty">{t('brands.subtitle')}</p>
      </header>

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {brands.map((b, i) => {
          const inCatalog = products.filter((p) => p.brand === b.name).length
          return (
            <motion.div
              key={b.name}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: '-40px' }}
              transition={{ duration: 0.4, delay: (i % 3) * 0.06 }}
            >
              <Link
                href={inCatalog > 0 ? `/catalog?brand=${encodeURIComponent(b.name)}` : '/catalog'}
                className="group flex h-full flex-col rounded-xl border border-border bg-card p-6 transition-colors hover:border-primary/40"
              >
                <div className="mb-3 flex items-center justify-between">
                  <h2 className="font-sans text-xl font-bold text-foreground">{b.name}</h2>
                  <ArrowUpRight className="h-5 w-5 text-muted-foreground transition-colors group-hover:text-primary" aria-hidden="true" />
                </div>
                <p className="text-sm text-muted-foreground">
                  {b.count} {t('brands.positions')}
                </p>
              </Link>
            </motion.div>
          )
        })}
      </div>
    </div>
  )
}
