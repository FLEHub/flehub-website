'use client'

import { useState } from 'react'
import {
  GalleryLightbox,
  type LightboxPhoto,
} from '@/components/galleries/gallery-lightbox'

type Props = {
  photos: LightboxPhoto[]
}

export function GalleryPhotoGrid({ photos }: Props) {
  const [openIndex, setOpenIndex] = useState<number | null>(null)

  if (photos.length === 0) {
    return (
      <p className="text-sm text-gray-500 py-8 text-center">
        Aucune photo dans cette galerie.
      </p>
    )
  }

  return (
    <>
      <div className="grid grid-cols-2 sm:grid-cols-3 gap-3 sm:gap-4">
        {photos.map((photo, index) => (
          <button
            key={photo.id}
            type="button"
            onClick={() => setOpenIndex(index)}
            className="group relative aspect-square overflow-hidden rounded-lg bg-[#E6F5EE] focus:outline-none focus-visible:ring-2 focus-visible:ring-[#00A550] focus-visible:ring-offset-2"
          >
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              src={photo.photo_url}
              alt={photo.caption || ''}
              className="w-full h-full object-cover transition-transform duration-300 group-hover:scale-[1.03]"
            />
            {photo.caption && (
              <span className="absolute inset-x-0 bottom-0 bg-gradient-to-t from-black/60 to-transparent px-2.5 py-2 text-left text-xs text-white line-clamp-2 opacity-0 group-hover:opacity-100 transition-opacity">
                {photo.caption}
              </span>
            )}
          </button>
        ))}
      </div>

      <GalleryLightbox
        photos={photos}
        openIndex={openIndex}
        onClose={() => setOpenIndex(null)}
        onNavigate={setOpenIndex}
      />
    </>
  )
}
