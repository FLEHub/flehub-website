'use client'

import { useCallback, useEffect, useState } from 'react'
import { ChevronLeft, ChevronRight, X } from 'lucide-react'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogTitle,
} from '@/components/ui/dialog'

export type LightboxPhoto = {
  id: string
  photo_url: string
  caption: string | null
}

type Props = {
  photos: LightboxPhoto[]
  openIndex: number | null
  onClose: () => void
  onNavigate: (index: number) => void
}

export function GalleryLightbox({
  photos,
  openIndex,
  onClose,
  onNavigate,
}: Props) {
  const open = openIndex !== null && openIndex >= 0 && openIndex < photos.length
  const photo = open && openIndex !== null ? photos[openIndex] : null

  const goPrev = useCallback(() => {
    if (openIndex === null || photos.length === 0) return
    onNavigate((openIndex - 1 + photos.length) % photos.length)
  }, [openIndex, photos.length, onNavigate])

  const goNext = useCallback(() => {
    if (openIndex === null || photos.length === 0) return
    onNavigate((openIndex + 1) % photos.length)
  }, [openIndex, photos.length, onNavigate])

  useEffect(() => {
    if (!open) return
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'ArrowLeft') goPrev()
      if (e.key === 'ArrowRight') goNext()
    }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [open, goPrev, goNext])

  return (
    <Dialog
      open={open}
      onOpenChange={(next) => {
        if (!next) onClose()
      }}
    >
      <DialogContent className="max-w-5xl w-[min(96vw,56rem)] p-0 border-0 bg-black/95 text-white overflow-hidden gap-0 [&>button]:hidden">
        <DialogTitle className="sr-only">Visionneuse photo</DialogTitle>
        <DialogDescription className="sr-only">
          Affiche la photo en grand avec légende et navigation
        </DialogDescription>

        <div className="relative flex flex-col">
          <button
            type="button"
            onClick={onClose}
            className="absolute top-3 right-3 z-10 inline-flex items-center justify-center w-9 h-9 rounded-full bg-black/50 text-white hover:bg-black/70 transition-colors"
            aria-label="Fermer"
          >
            <X className="w-5 h-5" />
          </button>

          {photos.length > 1 && (
            <>
              <button
                type="button"
                onClick={goPrev}
                className="absolute left-2 sm:left-3 top-1/2 -translate-y-1/2 z-10 inline-flex items-center justify-center w-10 h-10 rounded-full bg-black/50 text-white hover:bg-black/70 transition-colors"
                aria-label="Photo précédente"
              >
                <ChevronLeft className="w-6 h-6" />
              </button>
              <button
                type="button"
                onClick={goNext}
                className="absolute right-2 sm:right-3 top-1/2 -translate-y-1/2 z-10 inline-flex items-center justify-center w-10 h-10 rounded-full bg-black/50 text-white hover:bg-black/70 transition-colors"
                aria-label="Photo suivante"
              >
                <ChevronRight className="w-6 h-6" />
              </button>
            </>
          )}

          <div className="flex items-center justify-center min-h-[50vh] max-h-[78vh] px-4 pt-10 pb-4">
            {photo && (
              // eslint-disable-next-line @next/next/no-img-element
              <img
                src={photo.photo_url}
                alt={photo.caption || ''}
                className="max-h-[70vh] max-w-full object-contain"
              />
            )}
          </div>

          <div className="px-5 pb-5 pt-1 text-center space-y-1">
            {photo?.caption && (
              <p className="text-sm sm:text-base text-gray-100 leading-relaxed">
                {photo.caption}
              </p>
            )}
            {openIndex !== null && photos.length > 0 && (
              <p className="text-xs text-gray-400">
                {openIndex + 1} / {photos.length}
              </p>
            )}
          </div>
        </div>
      </DialogContent>
    </Dialog>
  )
}
