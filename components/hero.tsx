'use client'

import { useEffect, useRef } from 'react'
import Link from 'next/link'
import dynamic from 'next/dynamic'
import { motion } from 'framer-motion'
import { ArrowRight, ShieldCheck, Truck, BadgeCheck } from 'lucide-react'
import { useT } from '@/lib/use-t'

const Camera3D = dynamic(() => import('@/components/camera-3d'), { ssr: false })

export default function Hero() {
  const t = useT()
  const scrollProgress = useRef(0)
  const sectionRef = useRef<HTMLElement>(null)

  useEffect(() => {
    const onScroll = () => {
      const max = Math.max(document.documentElement.scrollHeight - window.innerHeight, 1)
      scrollProgress.current = window.scrollY / max
    }
    onScroll()
    window.addEventListener('scroll', onScroll, { passive: true })
    return () => window.removeEventListener('scroll', onScroll)
  }, [])

  return (
    <section ref={sectionRef} className="relative overflow-hidden bg-background">
      <div className="pointer-events-none absolute inset-0" aria-hidden="true">
        <div className="absolute -right-40 top-0 h-[600px] w-[600px] rounded-full bg-primary/5 blur-3xl" />
        <div className="absolute -left-40 bottom-0 h-[400px] w-[400px] rounded-full bg-primary/5 blur-3xl" />
      </div>

      <div className="mx-auto flex max-w-7xl flex-col items-center gap-8 px-4 pb-16 pt-12 md:flex-row md:gap-4 md:px-6 md:pb-24 md:pt-20">
        <div className="z-10 flex-1">
          <motion.p
            initial={{ opacity: 0, y: 16 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
            className="mb-4 inline-flex items-center gap-2 rounded-full border border-border bg-card px-4 py-1.5 text-sm text-muted-foreground"
          >
            <span className="h-2 w-2 rounded-full bg-primary" aria-hidden="true" />
            {t('hero.badge')}
          </motion.p>

          <motion.h1
            initial={{ opacity: 0, y: 24 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.1 }}
            className="mb-6 font-sans text-4xl font-bold leading-tight tracking-tight text-foreground text-balance md:text-6xl"
          >
            {t('hero.title1')} <span className="text-primary">{t('hero.title2')}</span>
          </motion.h1>

          <motion.p
            initial={{ opacity: 0, y: 24 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.2 }}
            className="mb-8 max-w-xl text-lg leading-relaxed text-muted-foreground text-pretty"
          >
            {t('hero.subtitle')}
          </motion.p>

          <motion.div
            initial={{ opacity: 0, y: 24 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.3 }}
            className="flex flex-wrap items-center gap-4"
          >
            <Link
              href="/catalog"
              className="inline-flex items-center gap-2 rounded-lg bg-primary px-6 py-3 font-medium text-primary-foreground transition-colors hover:bg-primary/90"
            >
              {t('hero.cta')}
              <ArrowRight className="h-4 w-4" aria-hidden="true" />
            </Link>
            <Link
              href="/contacts"
              className="inline-flex items-center gap-2 rounded-lg border border-border bg-card px-6 py-3 font-medium text-foreground transition-colors hover:bg-secondary"
            >
              {t('hero.cta2')}
            </Link>
          </motion.div>

          <motion.ul
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 0.6, delay: 0.5 }}
            className="mt-10 flex flex-wrap gap-6 text-sm text-muted-foreground"
          >
            <li className="flex items-center gap-2">
              <ShieldCheck className="h-5 w-5 text-primary" aria-hidden="true" />
              {t('hero.feat1')}
            </li>
            <li className="flex items-center gap-2">
              <Truck className="h-5 w-5 text-primary" aria-hidden="true" />
              {t('hero.feat2')}
            </li>
            <li className="flex items-center gap-2">
              <BadgeCheck className="h-5 w-5 text-primary" aria-hidden="true" />
              {t('hero.feat3')}
            </li>
          </motion.ul>
        </div>

        <div className="relative h-[360px] w-full flex-1 md:h-[520px]">
          <Camera3D scrollProgress={scrollProgress} />
        </div>
      </div>
    </section>
  )
}
