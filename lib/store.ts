"use client"

import { create } from "zustand"
import { persist } from "zustand/middleware"
import type { Locale } from "./i18n"

export interface CartItem {
  slug: string
  model: string
  brand: string
  article: string
  price: number
  qty: number
}

interface AppState {
  locale: Locale
  setLocale: (l: Locale) => void
  cart: CartItem[]
  addToCart: (item: Omit<CartItem, "qty">) => void
  removeFromCart: (slug: string) => void
  setQty: (slug: string, qty: number) => void
  clearCart: () => void
  authOpen: boolean
  setAuthOpen: (open: boolean) => void
}

export const useAppStore = create<AppState>()(
  persist(
    (set) => ({
      locale: "ru",
      setLocale: (locale) => set({ locale }),
      cart: [],
      addToCart: (item) =>
        set((s) => {
          const existing = s.cart.find((c) => c.slug === item.slug)
          if (existing) {
            return {
              cart: s.cart.map((c) => (c.slug === item.slug ? { ...c, qty: c.qty + 1 } : c)),
            }
          }
          return { cart: [...s.cart, { ...item, qty: 1 }] }
        }),
      removeFromCart: (slug) => set((s) => ({ cart: s.cart.filter((c) => c.slug !== slug) })),
      setQty: (slug, qty) =>
        set((s) => ({
          cart: qty <= 0 ? s.cart.filter((c) => c.slug !== slug) : s.cart.map((c) => (c.slug === slug ? { ...c, qty } : c)),
        })),
      clearCart: () => set({ cart: [] }),
      authOpen: false,
      setAuthOpen: (authOpen) => set({ authOpen }),
    }),
    { name: "hikmart-store", partialize: (s) => ({ locale: s.locale, cart: s.cart }) },
  ),
)
