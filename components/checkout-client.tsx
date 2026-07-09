'use client'

import Link from 'next/link'
import { useEffect, useState } from 'react'
import { ArrowLeft, Banknote, CreditCard, Smartphone, Info, Check } from 'lucide-react'
import { formatPrice } from '@/lib/products'
import { useAppStore } from '@/lib/store'
import { useT } from '@/lib/use-t'

type PaymentMethod = 'cash' | 'card' | 'kaspi'

export default function CheckoutClient() {
  const t = useT()
  const cart = useAppStore((s) => s.cart)
  const clearCart = useAppStore((s) => s.clearCart)
  const [mounted, setMounted] = useState(false)
  const [payment, setPayment] = useState<PaymentMethod>('cash')
  const [submitted, setSubmitted] = useState(false)

  useEffect(() => setMounted(true), [])

  const total = cart.reduce((sum, item) => sum + item.price * item.qty, 0)

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    // Payment foundation: order data is assembled here; the payment
    // provider integration (Kaspi / card acquiring) plugs in at this point.
    setSubmitted(true)
    clearCart()
  }

  if (!mounted) {
    return (
      <div className="mx-auto max-w-3xl px-4 py-14 md:px-6">
        <div className="skeleton h-96 rounded-xl" />
      </div>
    )
  }

  if (submitted) {
    return (
      <div className="mx-auto max-w-3xl px-4 py-20 md:px-6">
        <div className="flex flex-col items-center gap-4 rounded-2xl border border-border bg-card py-16 text-center">
          <span className="flex h-14 w-14 items-center justify-center rounded-full bg-success/15 text-success">
            <Check className="h-7 w-7" aria-hidden="true" />
          </span>
          <h1 className="font-sans text-2xl font-bold text-foreground">{t('checkout.title')}</h1>
          <p className="max-w-md text-sm leading-relaxed text-muted-foreground text-pretty">{t('checkout.soon')}</p>
          <Link
            href="/catalog"
            className="mt-2 inline-flex items-center gap-2 rounded-lg bg-primary px-6 py-3 text-sm font-medium text-primary-foreground transition-colors hover:bg-primary/90"
          >
            {t('cart.empty.cta')}
          </Link>
        </div>
      </div>
    )
  }

  return (
    <div className="mx-auto max-w-3xl px-4 py-10 md:px-6 md:py-14">
      <Link href="/cart" className="mb-8 inline-flex items-center gap-2 text-sm text-muted-foreground transition-colors hover:text-foreground">
        <ArrowLeft className="h-4 w-4" aria-hidden="true" />
        {t('cart.title')}
      </Link>

      <h1 className="mb-2 font-sans text-3xl font-bold text-foreground md:text-4xl">{t('checkout.title')}</h1>

      <div className="mb-8 flex items-start gap-3 rounded-xl border border-primary/30 bg-primary/5 p-4">
        <Info className="mt-0.5 h-5 w-5 shrink-0 text-primary" aria-hidden="true" />
        <p className="text-sm leading-relaxed text-muted-foreground text-pretty">{t('checkout.soon')}</p>
      </div>

      <form onSubmit={handleSubmit} className="flex flex-col gap-5">
        <div className="grid gap-5 md:grid-cols-2">
          <label className="flex flex-col gap-1.5">
            <span className="text-sm font-medium text-foreground">{t('checkout.name')}</span>
            <input
              type="text"
              name="name"
              required
              autoComplete="name"
              className="rounded-lg border border-border bg-input px-4 py-2.5 text-sm text-foreground focus:outline-none focus:ring-2 focus:ring-ring"
            />
          </label>
          <label className="flex flex-col gap-1.5">
            <span className="text-sm font-medium text-foreground">{t('checkout.phone')}</span>
            <input
              type="tel"
              name="phone"
              required
              autoComplete="tel"
              placeholder="+7 (___) ___-__-__"
              className="rounded-lg border border-border bg-input px-4 py-2.5 text-sm text-foreground placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring"
            />
          </label>
        </div>
        <label className="flex flex-col gap-1.5">
          <span className="text-sm font-medium text-foreground">{t('checkout.email')}</span>
          <input
            type="email"
            name="email"
            autoComplete="email"
            className="rounded-lg border border-border bg-input px-4 py-2.5 text-sm text-foreground focus:outline-none focus:ring-2 focus:ring-ring"
          />
        </label>
        <label className="flex flex-col gap-1.5">
          <span className="text-sm font-medium text-foreground">{t('checkout.address')}</span>
          <input
            type="text"
            name="address"
            autoComplete="street-address"
            className="rounded-lg border border-border bg-input px-4 py-2.5 text-sm text-foreground focus:outline-none focus:ring-2 focus:ring-ring"
          />
        </label>
        <label className="flex flex-col gap-1.5">
          <span className="text-sm font-medium text-foreground">{t('checkout.comment')}</span>
          <textarea
            name="comment"
            rows={3}
            className="resize-none rounded-lg border border-border bg-input px-4 py-2.5 text-sm text-foreground focus:outline-none focus:ring-2 focus:ring-ring"
          />
        </label>

        <fieldset>
          <legend className="mb-3 text-sm font-medium text-foreground">{t('checkout.payment')}</legend>
          <div className="grid gap-3 md:grid-cols-3">
            {(
              [
                { id: 'cash', icon: Banknote, label: t('checkout.payment.cash'), disabled: false },
                { id: 'card', icon: CreditCard, label: t('checkout.payment.card'), disabled: true },
                { id: 'kaspi', icon: Smartphone, label: t('checkout.payment.kaspi'), disabled: true },
              ] as const
            ).map((m) => (
              <label
                key={m.id}
                className={`flex cursor-pointer items-center gap-3 rounded-xl border p-4 transition-colors ${
                  payment === m.id ? 'border-primary bg-primary/5' : 'border-border bg-card'
                } ${m.disabled ? 'cursor-not-allowed opacity-50' : 'hover:border-primary/40'}`}
              >
                <input
                  type="radio"
                  name="payment"
                  value={m.id}
                  checked={payment === m.id}
                  disabled={m.disabled}
                  onChange={() => setPayment(m.id)}
                  className="sr-only"
                />
                <m.icon className="h-5 w-5 shrink-0 text-primary" aria-hidden="true" />
                <span className="text-sm text-foreground">{m.label}</span>
              </label>
            ))}
          </div>
        </fieldset>

        <div className="mt-2 flex flex-col gap-4 rounded-xl border border-border bg-card p-5 md:flex-row md:items-center md:justify-between">
          <p className="text-muted-foreground">
            {t('cart.total')}: <span className="font-sans text-2xl font-bold text-foreground">{formatPrice(total)}</span>
          </p>
          <button
            type="submit"
            disabled={cart.length === 0}
            className="btn-glow rounded-lg bg-primary px-8 py-3.5 font-medium text-primary-foreground disabled:cursor-not-allowed disabled:opacity-50"
          >
            {t('checkout.submit')}
          </button>
        </div>
      </form>
    </div>
  )
}
