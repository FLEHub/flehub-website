'use client'

import { useEffect } from 'react'
import Link from 'next/link'
import { Clock } from 'lucide-react'
import { createClient } from '@/lib/supabase/client'
import { BrandLogo } from '@/components/brand-logo'
import { BrandMark } from '@/components/brand-mark'

export default function EmailConfirmedPage() {
  useEffect(() => {
    const supabase = createClient()
    void supabase.auth.getSession().finally(() => {
      void supabase.auth.signOut()
    })
  }, [])

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 px-4">
      <div className="max-w-md w-full bg-white rounded-2xl shadow-sm border border-gray-100 p-8 text-center">
        <Link href="/" className="mb-6 inline-flex items-center justify-center gap-2 bg-transparent">
          <BrandLogo size={40} />
          <BrandMark size="md" />
        </Link>
        <div className="w-16 h-16 bg-amber-50 rounded-full flex items-center justify-center mx-auto mb-5">
          <Clock className="w-9 h-9 text-amber-500" />
        </div>
        <h1 className="text-2xl font-bold text-gray-900 mb-3">E-mail confirmé</h1>
        <p className="text-gray-500 text-sm leading-relaxed mb-6">
          Votre email est confirmé. Votre compte est en cours de validation par notre équipe,
          vous recevrez un email dès son activation.
        </p>
        <Link
          href="/login"
          className="block w-full py-3 bg-flehub-green text-white font-semibold rounded-xl hover:bg-flehub-green-dark transition-colors text-sm"
        >
          Aller à la page de connexion
        </Link>
      </div>
    </div>
  )
}
