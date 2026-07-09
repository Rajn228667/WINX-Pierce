"use client"

import { useState, useRef, useEffect } from "react"
import Link from "next/link"
import { usePathname } from "next/navigation"
import { motion, AnimatePresence } from "framer-motion"
import { Search, ShoppingCart, User, Menu, X, Phone, ShieldCheck } from "lucide-react"
import { useAppStore } from "@/lib/store"
import { useT } from "@/lib/use-t"
import { locales } from "@/lib/i18n"
import { searchProducts, formatPrice } from "@/lib/products"

export function Header() {
  const t = useT()
  const pathname = usePathname()
  const { locale, setLocale, cart, setAuthOpen } = useAppStore()
  const [mobileOpen, setMobileOpen] = useState(false)
  const [query, setQuery] = useState("")
  const [searchFocused, setSearchFocused] = useState(false)
  const searchRef = useRef<HTMLDivElement>(null)

  const cartCount = cart.reduce((n, c) => n + c.qty, 0)
  const results = query.length >= 2 ? searchProducts(query).slice(0, 6) : []

  useEffect(() => {
    setMobileOpen(false)
    setQuery("")
  }, [pathname])

  useEffect(() => {
    function onClick(e: MouseEvent) {
      if (searchRef.current && !searchRef.current.contains(e.target as Node)) setSearchFocused(false)
    }
    document.addEventListener("mousedown", onClick)
    return () => document.removeEventListener("mousedown", onClick)
  }, [])

  const nav = [
    { href: "/", label: t("nav.home") },
    { href: "/catalog", label: t("nav.catalog") },
    { href: "/brands", label: t("nav.brands") },
    { href: "/contacts", label: t("nav.contacts") },
  ]

  return (
    <header className="sticky top-0 z-50 border-b border-border bg-background/80 backdrop-blur-xl">
      {/* Top strip */}
      <div className="hidden md:flex items-center justify-between px-4 lg:px-8 py-1.5 text-xs text-muted-foreground border-b border-border/50">
        <p>{t("site.disclaimer")}</p>
        <div className="flex items-center gap-4">
          <a href="tel:+77080011212" className="flex items-center gap-1 hover:text-foreground transition-colors">
            <Phone className="w-3 h-3" aria-hidden="true" />
            +7 708 001 12 12
          </a>
          <span>
            {t("site.store")} · {t("site.consult")}
          </span>
        </div>
      </div>

      <div className="flex items-center gap-4 px-4 lg:px-8 h-16">
        {/* Logo — same as original site */}
        <Link href="/" className="flex items-center gap-2 shrink-0" aria-label="hikmart.kz">
          <div className="w-9 h-9 rounded-lg bg-primary flex items-center justify-center">
            <ShieldCheck className="w-5 h-5 text-primary-foreground" aria-hidden="true" />
          </div>
          <div className="leading-tight">
            <span className="font-bold text-lg tracking-tight">hikmart.kz</span>
            <span className="hidden lg:block text-[10px] text-muted-foreground">{t("site.tagline")}</span>
          </div>
        </Link>

        {/* Nav */}
        <nav className="hidden md:flex items-center gap-1 ml-4" aria-label="Main">
          {nav.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className={`px-3 py-2 rounded-lg text-sm font-medium transition-colors ${
                pathname === item.href ? "text-foreground bg-muted" : "text-muted-foreground hover:text-foreground hover:bg-muted/50"
              }`}
            >
              {item.label}
            </Link>
          ))}
        </nav>

        {/* Search */}
        <div ref={searchRef} className="relative flex-1 max-w-md ml-auto hidden sm:block">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" aria-hidden="true" />
            <input
              type="search"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              onFocus={() => setSearchFocused(true)}
              placeholder={t("catalog.search")}
              className="w-full h-10 pl-9 pr-4 rounded-xl bg-input border border-border text-sm placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring/50 transition-shadow"
              aria-label={t("catalog.search")}
            />
          </div>
          <AnimatePresence>
            {searchFocused && results.length > 0 && (
              <motion.ul
                initial={{ opacity: 0, y: -6 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -6 }}
                transition={{ duration: 0.15 }}
                className="absolute top-12 inset-x-0 bg-card border border-border rounded-xl shadow-2xl overflow-hidden"
              >
                {results.map((p) => (
                  <li key={p.slug}>
                    <Link
                      href={`/products/${p.slug}`}
                      className="flex items-center justify-between gap-2 px-4 py-2.5 hover:bg-muted transition-colors"
                      onClick={() => setSearchFocused(false)}
                    >
                      <div className="min-w-0">
                        <p className="text-sm font-medium truncate">{p.model}</p>
                        <p className="text-xs text-muted-foreground">
                          {p.brand} · {p.article}
                        </p>
                      </div>
                      <span className="text-sm font-semibold text-primary whitespace-nowrap">{formatPrice(p.price)}</span>
                    </Link>
                  </li>
                ))}
              </motion.ul>
            )}
          </AnimatePresence>
        </div>

        {/* Language switcher */}
        <div className="hidden sm:flex items-center rounded-lg bg-muted p-0.5" role="group" aria-label="Language">
          {locales.map((l) => (
            <button
              key={l.code}
              onClick={() => setLocale(l.code)}
              className={`px-2.5 py-1 rounded-md text-xs font-semibold transition-all ${
                locale === l.code ? "bg-primary text-primary-foreground shadow" : "text-muted-foreground hover:text-foreground"
              }`}
            >
              {l.label}
            </button>
          ))}
        </div>

        {/* Auth */}
        <button
          onClick={() => setAuthOpen(true)}
          className="hidden sm:flex items-center justify-center w-10 h-10 rounded-xl bg-muted hover:bg-border transition-colors"
          aria-label={t("nav.login")}
        >
          <User className="w-4.5 h-4.5" aria-hidden="true" />
        </button>

        {/* Cart */}
        <Link
          href="/cart"
          className="relative flex items-center justify-center w-10 h-10 rounded-xl bg-muted hover:bg-border transition-colors"
          aria-label={t("nav.cart")}
        >
          <ShoppingCart className="w-4.5 h-4.5" aria-hidden="true" />
          {cartCount > 0 && (
            <motion.span
              key={cartCount}
              initial={{ scale: 0.5 }}
              animate={{ scale: 1 }}
              className="absolute -top-1 -right-1 min-w-5 h-5 px-1 rounded-full bg-primary text-primary-foreground text-[10px] font-bold flex items-center justify-center"
            >
              {cartCount}
            </motion.span>
          )}
        </Link>

        {/* Mobile menu button */}
        <button
          onClick={() => setMobileOpen(!mobileOpen)}
          className="md:hidden flex items-center justify-center w-10 h-10 rounded-xl bg-muted"
          aria-label="Menu"
          aria-expanded={mobileOpen}
        >
          {mobileOpen ? <X className="w-5 h-5" aria-hidden="true" /> : <Menu className="w-5 h-5" aria-hidden="true" />}
        </button>
      </div>

      {/* Mobile menu */}
      <AnimatePresence>
        {mobileOpen && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: "auto", opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            className="md:hidden overflow-hidden border-t border-border bg-background"
          >
            <nav className="flex flex-col p-4 gap-1" aria-label="Mobile">
              {nav.map((item) => (
                <Link
                  key={item.href}
                  href={item.href}
                  className="px-4 py-3 rounded-lg text-sm font-medium hover:bg-muted transition-colors"
                >
                  {item.label}
                </Link>
              ))}
              <div className="flex items-center gap-2 px-4 py-3">
                {locales.map((l) => (
                  <button
                    key={l.code}
                    onClick={() => setLocale(l.code)}
                    className={`px-3 py-1.5 rounded-lg text-xs font-semibold ${
                      locale === l.code ? "bg-primary text-primary-foreground" : "bg-muted text-muted-foreground"
                    }`}
                  >
                    {l.label}
                  </button>
                ))}
              </div>
              <button
                onClick={() => {
                  setAuthOpen(true)
                  setMobileOpen(false)
                }}
                className="flex items-center gap-2 px-4 py-3 rounded-lg text-sm font-medium hover:bg-muted transition-colors text-left"
              >
                <User className="w-4 h-4" aria-hidden="true" />
                {t("nav.login")}
              </button>
            </nav>
          </motion.div>
        )}
      </AnimatePresence>
    </header>
  )
}
