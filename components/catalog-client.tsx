'use client'

import { useMemo, useState, useEffect } from 'react'
import { useSearchParams, useRouter, usePathname } from 'next/navigation'
import { Search, X, SlidersHorizontal } from 'lucide-react'
import { products, categories, type Category } from '@/lib/products'
import ProductCard from '@/components/product-card'
import { useT } from '@/lib/use-t'

type SortKey = 'priceAsc' | 'priceDesc' | 'name'

const PAGE_SIZE = 24

export default function CatalogClient() {
  const t = useT()
  const router = useRouter()
  const pathname = usePathname()
  const searchParams = useSearchParams()

  const initialCategory = searchParams.get('category') as Category | null
  const initialBrand = searchParams.get('brand')
  const initialQuery = searchParams.get('q') ?? ''

  const [category, setCategory] = useState<Category | 'all'>(initialCategory ?? 'all')
  const [brand, setBrand] = useState<string>(initialBrand ?? 'all')
  const [query, setQuery] = useState(initialQuery)
  const [sort, setSort] = useState<SortKey>('name')
  const [visible, setVisible] = useState(PAGE_SIZE)

  // Sync state from URL when params change (e.g. header search / footer links)
  useEffect(() => {
    setCategory((searchParams.get('category') as Category | null) ?? 'all')
    setBrand(searchParams.get('brand') ?? 'all')
    setQuery(searchParams.get('q') ?? '')
    setVisible(PAGE_SIZE)
  }, [searchParams])

  const availableBrands = useMemo(() => {
    const set = new Set(products.map((p) => p.brand))
    return [...set].sort()
  }, [])

  const filtered = useMemo(() => {
    let list = products
    if (category !== 'all') list = list.filter((p) => p.category === category)
    if (brand !== 'all') list = list.filter((p) => p.brand === brand)
    const q = query.trim().toLowerCase()
    if (q) {
      list = list.filter(
        (p) =>
          p.model.toLowerCase().includes(q) ||
          p.brand.toLowerCase().includes(q) ||
          p.article.includes(q),
      )
    }
    const sorted = [...list]
    if (sort === 'priceAsc') sorted.sort((a, b) => a.price - b.price)
    else if (sort === 'priceDesc') sorted.sort((a, b) => b.price - a.price)
    else sorted.sort((a, b) => a.model.localeCompare(b.model))
    return sorted
  }, [category, brand, query, sort])

  const updateUrl = (cat: Category | 'all', br: string) => {
    const params = new URLSearchParams()
    if (cat !== 'all') params.set('category', cat)
    if (br !== 'all') params.set('brand', br)
    router.replace(`${pathname}${params.size ? `?${params}` : ''}`, { scroll: false })
  }

  return (
    <div className="mx-auto max-w-7xl px-4 py-10 md:px-6 md:py-14">
      <header className="mb-8">
        <h1 className="font-sans text-3xl font-bold text-foreground md:text-4xl text-balance">{t('catalog.title')}</h1>
        <p className="mt-2 max-w-2xl text-muted-foreground text-pretty">{t('catalog.subtitle')}</p>
      </header>

      {/* Category chips */}
      <div className="mb-6 flex flex-wrap gap-2" role="group" aria-label={t('catalog.all')}>
        <button
          type="button"
          onClick={() => { setCategory('all'); setVisible(PAGE_SIZE); updateUrl('all', brand) }}
          className={`rounded-full px-4 py-2 text-sm font-medium transition-colors ${
            category === 'all' ? 'bg-primary text-primary-foreground' : 'border border-border bg-card text-muted-foreground hover:text-foreground'
          }`}
        >
          {t('catalog.all')}
        </button>
        {categories.map((c) => (
          <button
            key={c.id}
            type="button"
            onClick={() => { setCategory(c.id); setVisible(PAGE_SIZE); updateUrl(c.id, brand) }}
            className={`rounded-full px-4 py-2 text-sm font-medium transition-colors ${
              category === c.id ? 'bg-primary text-primary-foreground' : 'border border-border bg-card text-muted-foreground hover:text-foreground'
            }`}
          >
            {t(`cat.${c.id}`)}
          </button>
        ))}
      </div>

      {/* Search / brand / sort row */}
      <div className="mb-8 flex flex-col gap-3 md:flex-row md:items-center">
        <div className="relative flex-1">
          <Search className="pointer-events-none absolute left-3.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" aria-hidden="true" />
          <input
            type="search"
            value={query}
            onChange={(e) => { setQuery(e.target.value); setVisible(PAGE_SIZE) }}
            placeholder={t('catalog.search')}
            aria-label={t('catalog.search')}
            className="w-full rounded-lg border border-border bg-input py-2.5 pl-10 pr-10 text-sm text-foreground placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring"
          />
          {query && (
            <button
              type="button"
              onClick={() => setQuery('')}
              aria-label="Clear"
              className="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"
            >
              <X className="h-4 w-4" aria-hidden="true" />
            </button>
          )}
        </div>

        <div className="flex gap-3">
          <label className="flex items-center gap-2 text-sm text-muted-foreground">
            <span className="sr-only">{t('product.brand')}</span>
            <select
              value={brand}
              onChange={(e) => { setBrand(e.target.value); setVisible(PAGE_SIZE); updateUrl(category, e.target.value) }}
              className="rounded-lg border border-border bg-input px-3 py-2.5 text-sm text-foreground focus:outline-none focus:ring-2 focus:ring-ring"
            >
              <option value="all">{t('product.brand')}: {t('catalog.all')}</option>
              {availableBrands.map((b) => (
                <option key={b} value={b}>{b}</option>
              ))}
            </select>
          </label>

          <label className="flex items-center gap-2 text-sm text-muted-foreground">
            <SlidersHorizontal className="h-4 w-4" aria-hidden="true" />
            <span className="sr-only">{t('catalog.sort')}</span>
            <select
              value={sort}
              onChange={(e) => setSort(e.target.value as SortKey)}
              className="rounded-lg border border-border bg-input px-3 py-2.5 text-sm text-foreground focus:outline-none focus:ring-2 focus:ring-ring"
            >
              <option value="name">{t('catalog.sort.name')}</option>
              <option value="priceAsc">{t('catalog.sort.priceAsc')}</option>
              <option value="priceDesc">{t('catalog.sort.priceDesc')}</option>
            </select>
          </label>
        </div>
      </div>

      <p className="mb-6 text-sm text-muted-foreground" aria-live="polite">
        {t('catalog.found')}: <span className="font-semibold text-foreground">{filtered.length}</span>
      </p>

      {filtered.length === 0 ? (
        <div className="flex flex-col items-center gap-3 rounded-xl border border-border bg-card py-20 text-center">
          <Search className="h-8 w-8 text-muted-foreground" aria-hidden="true" />
          <p className="text-lg font-medium text-foreground">{t('catalog.empty')}</p>
        </div>
      ) : (
        <>
          <div className="grid grid-cols-2 gap-4 md:grid-cols-3 lg:grid-cols-4">
            {filtered.slice(0, visible).map((p) => (
              <ProductCard key={p.slug} product={p} />
            ))}
          </div>
          {visible < filtered.length && (
            <div className="mt-10 flex justify-center">
              <button
                type="button"
                onClick={() => setVisible((v) => v + PAGE_SIZE)}
                className="btn-glow rounded-lg border border-border bg-card px-8 py-3 text-sm font-medium text-foreground"
              >
                {t('brands.all')} ({filtered.length - visible})
              </button>
            </div>
          )}
        </>
      )}
    </div>
  )
}
