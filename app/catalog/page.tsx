import { Suspense } from 'react'
import CatalogClient from '@/components/catalog-client'

export const metadata = {
  title: 'Каталог — hikmart.kz',
  description: 'Каталог систем безопасности: видеокамеры, регистраторы, домофоны, СКУД, сетевое оборудование Hikvision, HiWatch, Ezviz.',
}

export default function CatalogPage() {
  return (
    <Suspense fallback={<div className="mx-auto max-w-7xl px-4 py-16 md:px-6"><div className="skeleton h-96 rounded-xl" /></div>}>
      <CatalogClient />
    </Suspense>
  )
}
