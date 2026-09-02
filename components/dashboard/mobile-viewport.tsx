'use client'

import { useEffect } from 'react'

/**
 * Keeps CSS viewport vars in sync with the visual viewport (mobile keyboard)
 * and scrolls focused fields into view so they are not hidden by the keyboard.
 */
export function MobileViewport() {
  useEffect(() => {
    const root = document.documentElement

    const sync = () => {
      const vv = window.visualViewport
      const height = vv?.height ?? window.innerHeight
      root.style.setProperty('--vvh', `${Math.round(height)}px`)
      const offsetTop = vv?.offsetTop ?? 0
      const keyboardInset = Math.max(0, window.innerHeight - height - offsetTop)
      root.style.setProperty('--kb-inset', `${Math.round(keyboardInset)}px`)
    }

    sync()
    window.visualViewport?.addEventListener('resize', sync)
    window.visualViewport?.addEventListener('scroll', sync)
    window.addEventListener('resize', sync)
    window.addEventListener('orientationchange', sync)

    const onFocusIn = (e: FocusEvent) => {
      const target = e.target
      if (!(target instanceof HTMLElement)) return
      if (
        target.tagName !== 'INPUT' &&
        target.tagName !== 'TEXTAREA' &&
        target.tagName !== 'SELECT' &&
        target.getAttribute('contenteditable') !== 'true'
      ) {
        return
      }
      window.setTimeout(() => {
        target.scrollIntoView({ block: 'center', inline: 'nearest', behavior: 'smooth' })
      }, 250)
    }

    document.addEventListener('focusin', onFocusIn)

    return () => {
      window.visualViewport?.removeEventListener('resize', sync)
      window.visualViewport?.removeEventListener('scroll', sync)
      window.removeEventListener('resize', sync)
      window.removeEventListener('orientationchange', sync)
      document.removeEventListener('focusin', onFocusIn)
    }
  }, [])

  return null
}
