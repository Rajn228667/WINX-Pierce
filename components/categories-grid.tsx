'use client'

import Link from 'next/link'
import Image from 'next/image'
import { motion } from 'framer-motion'
import { ArrowUpRight } from 'lucide-react'
import { categories, products } from '@/lib/products'
import { categoryImages } from '@/components/product-card'
import { useT } from '@/lib/use-t'

export default function CategoriesGrid() {
  const t = useT()

  return (
    <section className="mx-auto max-w-7xl px-4 py-12 md:px-6 md:py-16" aria-labelledby="categories-title">
      <div className="mb-8 flex items-end justify-between">
        <div>
          <h2 id="categories-title" className="font-sans text-2xl font-bold text-foreground md:text-3xl text-balance">
            {t('catalog.title')}
          </h2>
          <p className="mt-2 max-w-xl text-muted-foreground text-pretty">{t('catalog.subtitle')}</p>
        </div>
        <Link href="/catalog" className="hidden items-center gap-1 text-sm font-medium text-primary hover:underline md:inline-flex">
          {t('brands.all')}
          <ArrowUpRight className="h-4 w-4" aria-hidden="true" />
        </Link>
      </div>

      <div className="grid grid-cols-2 gap-4 md:grid-cols-3 lg:grid-cols-3">
        {categories.map((cat, i) => {
          const count = products.filter((p) => p.category === cat.id).length
          return (
            <motion.div
              key={cat.id}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: '-40px' }}
              transition={{ duration: 0.4, delay: i * 0.05 }}
            >
              <Link
                href={`/catalog?category=${cat.id}`}
                className="group relative flex h-full flex-col overflow-hidden rounded-xl border border-border bg-card transition-colors hover:border-primary/40"
              >
                <div className="relative aspect-[16/10] overflow-hidden">
                  <Image
                    src={categoryImages[cat.id] || "/placeholder.svg"}
                    alt={t(`cat.${cat.id}`)}
                    fill
                    className="object-cover transition-transform duration-500 group-hover:scale-105"
                    sizes="(max-width: 768px) 50vw, 33vw"
                  />
                  <div className="absolute inset-0 bg-gradient-to-t from-card via-card/20 to-transparent" />
                </div>
                <div className="flex flex-1 flex-col p-4 md:p-5">
                  <h3 className="mb-1 flex items-center justify-between font-sans text-base font-semibold text-foreground md:text-lg">
                    {t(`cat.${cat.id}`)}
                    <ArrowUpRight className="h-4 w-4 text-muted-foreground transition-colors group-hover:text-primary" aria-hidden="true" />
                  </h3>
                  <p className="text-sm leading-relaxed text-muted-foreground">{t(`cat.${cat.id}.desc`)}</p>
                  {count > 0 && (
                    <p className="mt-2 text-xs font-medium text-primary">
                      {count} {t('brands.positions')}
                    </p>
                  )}
                </div>
              </Link>
            </motion.div>
          )
        })}
      </div>
    </section>
  )
}
