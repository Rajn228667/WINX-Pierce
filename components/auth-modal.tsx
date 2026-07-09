"use client"

import { useState } from "react"
import { motion, AnimatePresence } from "framer-motion"
import { X, Mail, Lock, User, Phone, ShieldCheck } from "lucide-react"
import { useAppStore } from "@/lib/store"
import { useT } from "@/lib/use-t"

export function AuthModal() {
  const t = useT()
  const { authOpen, setAuthOpen } = useAppStore()
  const [mode, setMode] = useState<"login" | "register">("login")

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    // Foundation only: backend auth will be connected later
    setAuthOpen(false)
  }

  return (
    <AnimatePresence>
      {authOpen && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-background/80 backdrop-blur-sm"
          onClick={() => setAuthOpen(false)}
          role="dialog"
          aria-modal="true"
          aria-label={mode === "login" ? t("auth.title") : t("auth.register")}
        >
          <motion.div
            initial={{ scale: 0.94, y: 16, opacity: 0 }}
            animate={{ scale: 1, y: 0, opacity: 1 }}
            exit={{ scale: 0.94, y: 16, opacity: 0 }}
            transition={{ type: "spring", stiffness: 300, damping: 26 }}
            className="relative w-full max-w-md bg-card border border-border rounded-2xl p-8 shadow-2xl"
            onClick={(e) => e.stopPropagation()}
          >
            <button
              onClick={() => setAuthOpen(false)}
              className="absolute top-4 right-4 w-9 h-9 rounded-lg bg-muted hover:bg-border flex items-center justify-center transition-colors"
              aria-label="Close"
            >
              <X className="w-4 h-4" aria-hidden="true" />
            </button>

            <div className="flex items-center gap-2 mb-6">
              <div className="w-10 h-10 rounded-xl bg-primary flex items-center justify-center">
                <ShieldCheck className="w-5 h-5 text-primary-foreground" aria-hidden="true" />
              </div>
              <div>
                <h2 className="font-bold text-lg">{mode === "login" ? t("auth.title") : t("auth.register")}</h2>
                <p className="text-xs text-muted-foreground">hikmart.kz</p>
              </div>
            </div>

            <form onSubmit={handleSubmit} className="flex flex-col gap-4">
              {mode === "register" && (
                <>
                  <Field icon={<User className="w-4 h-4" aria-hidden="true" />} type="text" placeholder={t("auth.name")} required />
                  <Field icon={<Phone className="w-4 h-4" aria-hidden="true" />} type="tel" placeholder={t("auth.phone")} required />
                </>
              )}
              <Field icon={<Mail className="w-4 h-4" aria-hidden="true" />} type="email" placeholder={t("auth.email")} required />
              <Field icon={<Lock className="w-4 h-4" aria-hidden="true" />} type="password" placeholder={t("auth.password")} required />
              {mode === "register" && (
                <Field icon={<Lock className="w-4 h-4" aria-hidden="true" />} type="password" placeholder={t("auth.password2")} required />
              )}

              <button
                type="submit"
                className="btn-glow h-12 rounded-xl bg-primary text-primary-foreground font-semibold text-sm mt-2"
              >
                {mode === "login" ? t("auth.login") : t("auth.signup")}
              </button>
            </form>

            <p className="text-center text-sm text-muted-foreground mt-5">
              {mode === "login" ? t("auth.noAccount") : t("auth.haveAccount")}{" "}
              <button
                onClick={() => setMode(mode === "login" ? "register" : "login")}
                className="text-primary font-semibold hover:underline"
              >
                {mode === "login" ? t("auth.register") : t("auth.login")}
              </button>
            </p>

            <p className="text-[11px] text-muted-foreground/70 text-center mt-5 leading-relaxed">
              {t("auth.recaptcha")}{" "}
              <a href="https://policies.google.com/privacy" target="_blank" rel="noopener noreferrer" className="underline">
                Privacy
              </a>{" "}
              ·{" "}
              <a href="https://policies.google.com/terms" target="_blank" rel="noopener noreferrer" className="underline">
                Terms
              </a>
            </p>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  )
}

function Field({
  icon,
  ...props
}: { icon: React.ReactNode } & React.InputHTMLAttributes<HTMLInputElement>) {
  return (
    <div className="relative">
      <span className="absolute left-3.5 top-1/2 -translate-y-1/2 text-muted-foreground">{icon}</span>
      <input
        {...props}
        className="w-full h-12 pl-10 pr-4 rounded-xl bg-input border border-border text-sm placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring/50 transition-shadow"
      />
    </div>
  )
}
