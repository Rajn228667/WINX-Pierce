"use client"

import Link from "next/link"
import { Phone, MessageCircle, MapPin, ShieldCheck } from "lucide-react"
import { useT } from "@/lib/use-t"
import { categories } from "@/lib/products"

export function Footer() {
  const t = useT()

  return (
    <footer className="border-t border-border bg-card mt-20">
      <div className="max-w-7xl mx-auto px-4 lg:px-8 py-12 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-10">
        {/* Brand */}
        <div>
          <div className="flex items-center gap-2 mb-4">
            <div className="w-9 h-9 rounded-lg bg-primary flex items-center justify-center">
              <ShieldCheck className="w-5 h-5 text-primary-foreground" aria-hidden="true" />
            </div>
            <span className="font-bold text-lg">hikmart.kz</span>
          </div>
          <p className="text-sm text-muted-foreground leading-relaxed mb-4">{t("site.tagline")}</p>
          <p className="flex items-start gap-2 text-sm text-muted-foreground">
            <MapPin className="w-4 h-4 mt-0.5 shrink-0" aria-hidden="true" />
            {t("contacts.address")}
          </p>
        </div>

        {/* Catalog */}
        <div>
          <h3 className="font-semibold mb-4 text-sm uppercase tracking-wider text-muted-foreground">{t("footer.categories")}</h3>
          <ul className="flex flex-col gap-2">
            {categories.slice(0, 6).map((c) => (
              <li key={c.id}>
                <Link href={`/catalog?category=${c.id}`} className="text-sm text-muted-foreground hover:text-foreground transition-colors">
                  {t(`cat.${c.id}`)}
                </Link>
              </li>
            ))}
          </ul>
        </div>

        {/* Info */}
        <div>
          <h3 className="font-semibold mb-4 text-sm uppercase tracking-wider text-muted-foreground">{t("footer.info")}</h3>
          <ul className="flex flex-col gap-2">
            <li>
              <Link href="/privacy" className="text-sm text-muted-foreground hover:text-foreground transition-colors">
                {t("footer.privacy")}
              </Link>
            </li>
            <li>
              <a
                href="https://policies.google.com/terms"
                target="_blank"
                rel="noopener noreferrer"
                className="text-sm text-muted-foreground hover:text-foreground transition-colors"
              >
                {t("footer.terms")}
              </a>
            </li>
            <li>
              <Link href="/contacts" className="text-sm text-muted-foreground hover:text-foreground transition-colors">
                {t("nav.contacts")}
              </Link>
            </li>
            <li>
              <Link href="/brands" className="text-sm text-muted-foreground hover:text-foreground transition-colors">
                {t("nav.brands")}
              </Link>
            </li>
          </ul>
        </div>

        {/* Phones */}
        <div>
          <h3 className="font-semibold mb-4 text-sm uppercase tracking-wider text-muted-foreground">{t("footer.phones")}</h3>
          <ul className="flex flex-col gap-3">
            <li>
              <a href="tel:+77080011212" className="flex items-center gap-2 text-sm text-muted-foreground hover:text-foreground transition-colors">
                <Phone className="w-4 h-4" aria-hidden="true" />
                +7 708 001 12 12
              </a>
            </li>
            <li>
              <a href="tel:+77080011213" className="flex items-center gap-2 text-sm text-muted-foreground hover:text-foreground transition-colors">
                <Phone className="w-4 h-4" aria-hidden="true" />
                +7 708 001 12 13
              </a>
            </li>
            <li>
              <a href="tel:+77771871717" className="flex items-center gap-2 text-sm text-muted-foreground hover:text-foreground transition-colors">
                <Phone className="w-4 h-4" aria-hidden="true" />
                +7 777 187 17 17
              </a>
            </li>
            <li>
              <a
                href="https://wa.me/77080011212"
                target="_blank"
                rel="noopener noreferrer"
                className="btn-glow inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-success/15 text-success text-sm font-semibold border border-success/30"
              >
                <MessageCircle className="w-4 h-4" aria-hidden="true" />
                WhatsApp
              </a>
            </li>
          </ul>
        </div>
      </div>

      <div className="border-t border-border">
        <div className="max-w-7xl mx-auto px-4 lg:px-8 py-5 flex flex-col sm:flex-row items-center justify-between gap-3">
          <p className="text-xs text-muted-foreground">
            © {new Date().getFullYear()} hikmart.kz · {t("footer.rights")}
          </p>
          <p className="text-xs text-muted-foreground">{t("footer.madeby")}</p>
        </div>
      </div>
    </footer>
  )
}
