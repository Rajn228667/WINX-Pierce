"use client"

import { useAppStore } from "./store"
import { dictionaries } from "./i18n"

export function useT() {
  const locale = useAppStore((s) => s.locale)
  return (key: string): string => dictionaries[locale][key] ?? dictionaries.ru[key] ?? key
}
