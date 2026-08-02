import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Newspaper } from 'lucide-react'

export const dynamic = 'force-dynamic'

export default async function JournalistDashboardPage() {
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

  if (!profile || profile.role !== 'journalist') {
    redirect('/dashboard')
  }
  if (profile.status === 'suspended' || profile.status === 'rejected') {
    redirect('/login?reason=account_inactive')
  }

  const firstName = profile.full_name?.split(' ')[0] || 'journaliste'

  return (
    <div className="p-6 max-w-3xl mx-auto space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Espace journaliste</h1>
        <p className="text-sm text-gray-500 mt-1">Portail actualités MFK</p>
      </div>

      <Card className="border-0 shadow-sm">
        <CardHeader className="pb-3">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-[#E6F5EE] flex items-center justify-center">
              <Newspaper className="w-5 h-5 text-[#00A550]" />
            </div>
            <CardTitle className="text-lg">Bienvenue, {firstName}</CardTitle>
          </div>
        </CardHeader>
        <CardContent>
          <p className="text-sm text-gray-600 leading-relaxed">
            Bienvenue, vos articles apparaîtront ici. L&apos;éditeur d&apos;articles sera
            disponible prochainement.
          </p>
        </CardContent>
      </Card>
    </div>
  )
}
