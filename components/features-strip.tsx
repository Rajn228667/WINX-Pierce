'use client'

import { motion } from 'framer-motion'
import { Truck, Headset, Percent, ShieldCheck, Award } from 'lucide-react'
import { useT } from '@/lib/use-t'

const FEATURES = [
  { key: 'delivery', icon: Truck },
  { key: 'help', icon: Headset },
  { key: 'promo', icon: Percent },
  { key: 'warranty', icon: ShieldCheck },
  { key: 'best', icon: Award },
] as const

export default function FeaturesStrip() {
  const t = useT()

  return (
    <section className="border-y border-border bg-card" aria-label={t('features.delivery')}>
      <ul className="mx-auto grid max-w-7xl grid-cols-2 gap-6 px-4 py-10 md:grid-cols-5 md:px-6">
        {FEATURES.map((f, i) => (
          <motion.li
            key={f.key}
            initial={{ opacity: 0, y: 16 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.4, delay: i * 0.06 }}
            className="flex flex-col items-start gap-3"
          >
            <span className="flex h-11 w-11 items-center justify-center rounded-lg bg-primary/10 text-primary">
              <f.icon className="h-5 w-5" aria-hidden="true" />
            </span>
            <div>
              <h3 className="text-sm font-semibold text-foreground">{t(`features.${f.key}`)}</h3>
              <p className="mt-1 text-xs leading-relaxed text-muted-foreground">{t(`features.${f.key}.desc`)}</p>
            </div>
          </motion.li>
        ))}
      </ul>
    </section>
  )
}
