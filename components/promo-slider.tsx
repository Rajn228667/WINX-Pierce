'use client'

import { useCallback, useEffect, useState } from 'react'
import Link from 'next/link'
import Image from 'next/image'
import { AnimatePresence, motion } from 'framer-motion'
import { ArrowRight, ChevronLeft, ChevronRight } from 'lucide-react'
import { useT } from '@/lib/use-t'

const SLIDES = [
  { key: 'slide1', image: '/images/slide-hikvision-door.png', href: '/catalog?category=intercoms' },
  { key: 'slide2', image: '/images/slide-ezviz-camera.png', href: '/catalog?category=cameras' },
  { key: 'slide3', image: '/images/slide-wifi-business.png', href: '/catalog?category=network' },
  { key: 'slide4', image: '/images/slide-barrier.png', href: '/catalog?category=access' },
] as const

const INTERVAL = 5000

export default function PromoSlider() {
  const t = useT()
  const [index, setIndex] = useState(0)
  const [paused, setPaused] = useState(false)

  const next = useCallback(() => setIndex((i) => (i + 1) % SLIDES.length), [])
  const prev = useCallback(() => setIndex((i) => (i - 1 + SLIDES.length) % SLIDES.length), [])

  useEffect(() => {
    if (paused) return
    const id = setInterval(next, INTERVAL)
    return () => clearInterval(id)
  }, [paused, next, index])

  const slide = SLIDES[index]

  return (
    <section
      aria-label={t('slider.aria')}
      className="mx-auto max-w-7xl px-4 py-8 md:px-6"
      onMouseEnter={() => setPaused(true)}
      onMouseLeave={() => setPaused(false)}
    >
      <div className="relative h-[320px] overflow-hidden rounded-2xl border border-border bg-card md:h-[420px]">
        <AnimatePresence mode="wait">
          <motion.div
            key={slide.key}
            initial={{ opacity: 0, scale: 1.03 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.6 }}
            className="absolute inset-0"
          >
            <Image
              src={slide.image || "/placeholder.svg"}
              alt={t(`slider.${slide.key}.title`)}
              fill
              className="object-cover"
              priority={index === 0}
              sizes="(max-width: 768px) 100vw, 1280px"
            />
            <div className="absolute inset-0 bg-gradient-to-r from-background/95 via-background/60 to-transparent" />
            <div className="absolute inset-0 flex flex-col justify-center px-8 md:px-14">
              <p className="mb-2 text-sm font-medium uppercase tracking-widest text-primary">
                {t(`slider.${slide.key}.tag`)}
              </p>
              <h2 className="mb-3 max-w-lg font-sans text-2xl font-bold text-foreground text-balance md:text-4xl">
                {t(`slider.${slide.key}.title`)}
              </h2>
              <p className="mb-6 max-w-md text-sm leading-relaxed text-muted-foreground md:text-base">
                {t(`slider.${slide.key}.desc`)}
              </p>
              <Link
                href={slide.href}
                className="inline-flex w-fit items-center gap-2 rounded-lg bg-primary px-5 py-2.5 text-sm font-medium text-primary-foreground transition-colors hover:bg-primary/90"
              >
                {t('slider.cta')}
                <ArrowRight className="h-4 w-4" aria-hidden="true" />
              </Link>
            </div>
          </motion.div>
        </AnimatePresence>

        <div className="absolute bottom-5 right-5 z-10 flex items-center gap-2">
          <button
            type="button"
            onClick={prev}
            aria-label={t('slider.prev')}
            className="flex h-9 w-9 items-center justify-center rounded-full border border-border bg-background/80 text-foreground backdrop-blur transition-colors hover:bg-secondary"
          >
            <ChevronLeft className="h-4 w-4" aria-hidden="true" />
          </button>
          <button
            type="button"
            onClick={next}
            aria-label={t('slider.next')}
            className="flex h-9 w-9 items-center justify-center rounded-full border border-border bg-background/80 text-foreground backdrop-blur transition-colors hover:bg-secondary"
          >
            <ChevronRight className="h-4 w-4" aria-hidden="true" />
          </button>
        </div>

        <div className="absolute bottom-6 left-8 z-10 flex gap-2 md:left-14" role="tablist" aria-label={t('slider.dots')}>
          {SLIDES.map((s, i) => (
            <button
              key={s.key}
              type="button"
              role="tab"
              aria-selected={i === index}
              aria-label={`${t('slider.goto')} ${i + 1}`}
              onClick={() => setIndex(i)}
              className={`h-1.5 rounded-full transition-all ${i === index ? 'w-8 bg-primary' : 'w-4 bg-border hover:bg-muted-foreground'}`}
            />
          ))}
        </div>
      </div>
    </section>
  )
}
