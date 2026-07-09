import type { Metadata, Viewport } from "next"
import { Inter, JetBrains_Mono } from "next/font/google"
import "./globals.css"
import { Header } from "@/components/header"
import { Footer } from "@/components/footer"
import { AuthModal } from "@/components/auth-modal"

const inter = Inter({ subsets: ["latin", "cyrillic"], variable: "--font-inter" })
const jetbrains = JetBrains_Mono({ subsets: ["latin", "cyrillic"], variable: "--font-jetbrains" })

export const metadata: Metadata = {
  title: "hikmart.kz — Комплексные системы безопасности",
  description:
    "Видеонаблюдение Hikvision, HiWatch, Ezviz, контроль доступа, сетевое оборудование в Шымкенте и по Казахстану. HiWatch Магазин — консультация менеджера по оборудованию.",
  keywords: ["hikvision", "hiwatch", "ezviz", "видеонаблюдение", "Шымкент", "Казахстан", "системы безопасности"],
}

export const viewport: Viewport = {
  themeColor: "#0b0d10",
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ru" className={`bg-background ${inter.variable} ${jetbrains.variable}`}>
      <body className="min-h-screen flex flex-col font-sans">
        <Header />
        <main className="flex-1">{children}</main>
        <Footer />
        <AuthModal />
      </body>
    </html>
  )
}
