import Hero from '@/components/hero'
import PromoSlider from '@/components/promo-slider'
import FeaturesStrip from '@/components/features-strip'
import CategoriesGrid from '@/components/categories-grid'
import PopularProducts from '@/components/popular-products'
import BrandsStrip from '@/components/brands-strip'

export default function HomePage() {
  return (
    <>
      <Hero />
      <PromoSlider />
      <FeaturesStrip />
      <CategoriesGrid />
      <PopularProducts />
      <BrandsStrip />
    </>
  )
}
