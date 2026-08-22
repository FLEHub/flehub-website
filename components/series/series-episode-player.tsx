'use client'

import { useState } from 'react'
import { getYoutubeEmbedUrl, type SeriesEpisode, type SeriesType } from '@/lib/series'
import { Play } from 'lucide-react'

type Props = {
  seriesType: SeriesType
  episodes: SeriesEpisode[]
}

export function SeriesEpisodePlayer({ seriesType, episodes }: Props) {
  const [activeId, setActiveId] = useState<string | null>(
    episodes[0]?.id ?? null
  )
  const active = episodes.find((e) => e.id === activeId) ?? null

  if (episodes.length === 0) {
    return (
      <p className="text-sm text-gray-500 py-8 text-center">
        Aucun épisode publié pour le moment.
      </p>
    )
  }

  const embedUrl =
    seriesType === 'webseries' && active?.youtube_video_id
      ? getYoutubeEmbedUrl(active.youtube_video_id)
      : null

  return (
    <div className="space-y-6">
      {active && (
        <div className="rounded-xl border border-gray-100 bg-white overflow-hidden">
          {seriesType === 'webseries' && embedUrl ? (
            <div className="aspect-video bg-black">
              <iframe
                src={embedUrl}
                title={active.title}
                className="w-full h-full"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                allowFullScreen
              />
            </div>
          ) : seriesType === 'podcast' && active.audio_url ? (
            <div className="p-5 sm:p-6 space-y-3">
              <p className="text-sm font-medium text-gray-900">
                Épisode {active.episode_number} — {active.title}
              </p>
              <audio
                controls
                preload="metadata"
                src={active.audio_url}
                className="w-full"
              >
                Votre navigateur ne prend pas en charge la lecture audio.
              </audio>
            </div>
          ) : (
            <div className="p-8 text-center text-sm text-gray-500">
              Lecteur indisponible pour cet épisode.
            </div>
          )}
          {active.description && (
            <div className="px-5 py-4 border-t border-gray-100 text-sm text-gray-700 leading-relaxed whitespace-pre-wrap">
              {active.description}
            </div>
          )}
        </div>
      )}

      <div>
        <h2 className="text-lg font-semibold text-gray-900 mb-3">Épisodes</h2>
        <ul className="space-y-2">
          {episodes.map((ep) => {
            const isActive = ep.id === activeId
            return (
              <li key={ep.id}>
                <button
                  type="button"
                  onClick={() => setActiveId(ep.id)}
                  className={
                    isActive
                      ? 'w-full text-left flex items-start gap-3 rounded-lg border border-[#1E5FA8]/30 bg-[#E8F1FA]/50 px-4 py-3'
                      : 'w-full text-left flex items-start gap-3 rounded-lg border border-gray-100 bg-white px-4 py-3 hover:border-[#1E5FA8]/30 transition-colors'
                  }
                >
                  <span className="flex-shrink-0 w-9 h-9 rounded-md bg-[#E8F1FA] text-[#1E5FA8] flex items-center justify-center">
                    {isActive ? (
                      <Play className="w-4 h-4 fill-current" />
                    ) : (
                      <span className="text-xs font-bold">{ep.episode_number}</span>
                    )}
                  </span>
                  <span className="min-w-0 flex-1">
                    <span className="block text-sm font-medium text-gray-900">
                      Ép. {ep.episode_number} — {ep.title}
                    </span>
                    {ep.description && (
                      <span className="block text-xs text-gray-500 line-clamp-1 mt-0.5">
                        {ep.description}
                      </span>
                    )}
                  </span>
                </button>
              </li>
            )
          })}
        </ul>
      </div>
    </div>
  )
}
