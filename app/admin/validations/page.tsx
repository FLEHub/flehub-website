import Link from 'next/link'
import { redirect } from 'next/navigation'
import { requireActiveAdmin } from '@/lib/require-admin'
import { AccountValidations } from '@/components/admin/account-validations'

export const dynamic = 'force-dynamic'

export default async function AdminValidationsPage() {
  const admin = await requireActiveAdmin()
  if (!admin) redirect('/login')

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="border-b border-gray-200 bg-white">
        <div className="mx-auto flex max-w-6xl items-center justify-between gap-4 px-4 py-4 sm:px-6">
          <div>
            <p className="text-xs font-semibold uppercase tracking-wide text-[#1E5FA8]">
              Administration MFK
            </p>
            <h1 className="text-xl font-bold text-gray-900">Validation des comptes</h1>
          </div>
          <Link
            href="/dashboard/admin"
            className="text-sm font-medium text-[#1E5FA8] hover:underline"
          >
            Retour au tableau de bord
          </Link>
        </div>
      </header>
      <main className="mx-auto max-w-6xl px-4 py-6 sm:px-6">
        <p className="mb-5 max-w-3xl text-sm text-gray-500">
          Comptes dont l&apos;e-mail est confirmé, en attente d&apos;une décision. La liste est
          triée par date de confirmation, les plus anciens en premier.
        </p>
        <AccountValidations />
      </main>
    </div>
  )
}
