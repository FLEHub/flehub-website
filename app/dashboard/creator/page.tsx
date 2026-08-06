import { redirect } from 'next/navigation'
import Link from 'next/link'
import { createClient } from '@/lib/supabase/server'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Clapperboard, Mic, ArrowRight, Plus } from 'lucide-react'

export const dynamic = 'force-dynamic'

export default async function CreatorDashboardPage() {
  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) redirect('/login')

  const { data: profile } = await supabase
    .from('profiles')
    .select('full_name, role, status')
    .eq('id', user.id)
    .maybeSingle()

  if (!profile || profile.role !== 'creator') {
    redirect('/dashboard')
  }
  if (profile.status === 'suspended' || profile.status === 'rejected') {
    redirect('/login?reason=account_inactive')
  }

  const firstName = profile.full_name?.split(' ')[0] || 'créateur'

  return (
    <div className="p-6 max-w-3xl mx-auto space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Espace créateur</h1>
        <p className="text-sm text-gray-500 mt-1">
          Web-séries et podcasts — portail MFK
        </p>
      </div>

      <Card className="border-0 shadow-sm">
        <CardHeader className="pb-3">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-[#E6F5EE] flex items-center justify-center">
              <Clapperboard className="w-5 h-5 text-[#00A550]" />
            </div>
            <CardTitle className="text-lg">Bienvenue, {firstName}</CardTitle>
          </div>
        </CardHeader>
        <CardContent className="space-y-4">
          <p className="text-sm text-gray-600 leading-relaxed">
            Créez des web-séries YouTube ou des podcasts audio, gérez les
            épisodes, et publiez-les sur le portail MFK.
          </p>
          <div className="flex flex-wrap gap-3">
            <Button asChild className="bg-[#00A550] hover:bg-[#008040]">
              <Link href="/dashboard/creator/series">
                Gérer mes séries
                <ArrowRight className="w-4 h-4 ml-2" />
              </Link>
            </Button>
            <Button asChild variant="outline">
              <Link href="/dashboard/creator/series/new">
                <Plus className="w-4 h-4 mr-2" />
                Nouvelle série
              </Link>
            </Button>
          </div>
          <div className="flex flex-wrap gap-4 pt-2 text-xs text-gray-500">
            <span className="inline-flex items-center gap-1.5">
              <Clapperboard className="w-3.5 h-3.5" />
              Web-séries
            </span>
            <span className="inline-flex items-center gap-1.5">
              <Mic className="w-3.5 h-3.5" />
              Podcasts
            </span>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
