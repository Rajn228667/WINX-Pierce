'use client'

import { useState } from 'react'
import { MapPin, Phone, MessageCircle, Check } from 'lucide-react'
import { useT } from '@/lib/use-t'

const PHONES = ['+7 708 001 12 12', '+7 708 001 12 13', '+7 777 187 17 17']
const WHATSAPP = 'https://wa.me/77080011212'

export default function ContactsClient() {
  const t = useT()
  const [sent, setSent] = useState(false)

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    setSent(true)
  }

  return (
    <div className="mx-auto max-w-7xl px-4 py-10 md:px-6 md:py-14">
      <h1 className="mb-8 font-sans text-3xl font-bold text-foreground md:text-4xl">{t('contacts.title')}</h1>

      <div className="grid gap-8 md:grid-cols-2">
        <div className="flex flex-col gap-6">
          <div className="rounded-2xl border border-border bg-card p-6 md:p-8">
            <h2 className="mb-4 flex items-center gap-2 font-sans text-lg font-semibold text-foreground">
              <MapPin className="h-5 w-5 text-primary" aria-hidden="true" />
              {t('contacts.address.label')}
            </h2>
            <p className="mb-3 text-foreground">{t('contacts.address')}</p>
            <p className="text-sm leading-relaxed text-muted-foreground text-pretty">{t('contacts.store.desc')}</p>
          </div>

          <div className="rounded-2xl border border-border bg-card p-6 md:p-8">
            <h2 className="mb-4 flex items-center gap-2 font-sans text-lg font-semibold text-foreground">
              <Phone className="h-5 w-5 text-primary" aria-hidden="true" />
              {t('footer.phones')}
            </h2>
            <ul className="mb-6 flex flex-col gap-2">
              {PHONES.map((phone) => (
                <li key={phone}>
                  <a href={`tel:${phone.replace(/[^\d+]/g, '')}`} className="text-lg font-medium text-foreground transition-colors hover:text-primary">
                    {phone}
                  </a>
                </li>
              ))}
            </ul>
            <div className="flex flex-wrap gap-3">
              <a
                href={`tel:${PHONES[0].replace(/[^\d+]/g, '')}`}
                className="btn-glow inline-flex items-center gap-2 rounded-lg bg-primary px-5 py-2.5 text-sm font-medium text-primary-foreground"
              >
                <Phone className="h-4 w-4" aria-hidden="true" />
                {t('contacts.call')}
              </a>
              <a
                href={WHATSAPP}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-2 rounded-lg border border-border bg-card px-5 py-2.5 text-sm font-medium text-foreground transition-colors hover:bg-secondary"
              >
                <MessageCircle className="h-4 w-4 text-success" aria-hidden="true" />
                {t('contacts.whatsapp')}
              </a>
            </div>
          </div>

          <div className="overflow-hidden rounded-2xl border border-border">
            <iframe
              src="https://www.openstreetmap.org/export/embed.html?bbox=69.575%2C42.310%2C69.615%2C42.330&layer=mapnik&marker=42.320%2C69.595"
              className="h-64 w-full border-0"
              loading="lazy"
              title={t('contacts.address.label')}
            />
          </div>
        </div>

        <div className="rounded-2xl border border-border bg-card p-6 md:p-8">
          <h2 className="mb-2 font-sans text-lg font-semibold text-foreground">{t('contacts.form.title')}</h2>
          <p className="mb-6 text-sm leading-relaxed text-muted-foreground text-pretty">{t('contacts.form.desc')}</p>

          {sent ? (
            <div className="flex flex-col items-center gap-3 py-14 text-center">
              <span className="flex h-12 w-12 items-center justify-center rounded-full bg-success/15 text-success">
                <Check className="h-6 w-6" aria-hidden="true" />
              </span>
              <p className="font-medium text-foreground">{t('contacts.form.send')} — OK</p>
            </div>
          ) : (
            <form onSubmit={handleSubmit} className="flex flex-col gap-4">
              <label className="flex flex-col gap-1.5">
                <span className="text-sm font-medium text-foreground">{t('contacts.form.name')}</span>
                <input
                  type="text"
                  name="name"
                  required
                  autoComplete="name"
                  className="rounded-lg border border-border bg-input px-4 py-2.5 text-sm text-foreground focus:outline-none focus:ring-2 focus:ring-ring"
                />
              </label>
              <label className="flex flex-col gap-1.5">
                <span className="text-sm font-medium text-foreground">{t('contacts.form.phone')}</span>
                <input
                  type="tel"
                  name="phone"
                  required
                  autoComplete="tel"
                  placeholder="+7 (___) ___-__-__"
                  className="rounded-lg border border-border bg-input px-4 py-2.5 text-sm text-foreground placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring"
                />
              </label>
              <label className="flex flex-col gap-1.5">
                <span className="text-sm font-medium text-foreground">{t('contacts.form.email')}</span>
                <input
                  type="email"
                  name="email"
                  autoComplete="email"
                  className="rounded-lg border border-border bg-input px-4 py-2.5 text-sm text-foreground focus:outline-none focus:ring-2 focus:ring-ring"
                />
              </label>
              <label className="flex flex-col gap-1.5">
                <span className="text-sm font-medium text-foreground">{t('contacts.form.topic')}</span>
                <textarea
                  name="topic"
                  rows={4}
                  required
                  className="resize-none rounded-lg border border-border bg-input px-4 py-2.5 text-sm text-foreground focus:outline-none focus:ring-2 focus:ring-ring"
                />
              </label>
              <button type="submit" className="btn-glow mt-2 rounded-lg bg-primary px-6 py-3 font-medium text-primary-foreground">
                {t('contacts.form.send')}
              </button>
            </form>
          )}
        </div>
      </div>
    </div>
  )
}
