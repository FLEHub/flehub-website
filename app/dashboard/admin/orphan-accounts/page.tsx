'use client'

import { useCallback, useEffect, useState } from 'react'
import {
  AlertTriangle,
  RefreshCw,
  UserPlus,
  UserX,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import type { AppRole } from '@/lib/ensure-profile'
import type { OrphanAuthAccount } from '@/lib/find-auth-user'

const ROLE_OPTIONS: { value: AppRole; label: string }[] = [
  { value: 'learner', label: 'Apprenant' },
  { value: 'teacher', label: 'Enseignant' },
  { value: 'school', label: 'École' },
  { value: 'admin', label: 'Admin' },
  { value: 'journalist', label: 'Journaliste' },
  { value: 'creator', label: 'Créateur' },
]

function defaultRole(account: OrphanAuthAccount): AppRole {
  const meta = (account.meta_role ?? '').toLowerCase()
  return ROLE_OPTIONS.some((r) => r.value === meta) ? (meta as AppRole) : 'learner'
}

function formatDate(value: string | null) {
  if (!value) return '—'
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) return '—'
  return date.toLocaleString('fr-FR', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  })
}

export default function AdminOrphanAccountsPage() {
  const [accounts, setAccounts] = useState<OrphanAuthAccount[]>([])
  const [roles, setRoles] = useState<Record<string, AppRole>>({})
  const [loading, setLoading] = useState(true)
  const [actionId, setActionId] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [success, setSuccess] = useState<string | null>(null)

  const fetchAccounts = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const res = await fetch('/api/admin/orphan-accounts', { cache: 'no-store' })
      const json = await res.json().catch(() => ({}))
      if (!res.ok) {
        throw new Error(
          typeof json?.error === 'string' ? json.error : 'Impossible de charger les comptes.'
        )
      }
      const list = (json.accounts ?? []) as OrphanAuthAccount[]
      setAccounts(list)
      setRoles((prev) => {
        const next = { ...prev }
        for (const account of list) {
          if (!next[account.id]) next[account.id] = defaultRole(account)
        }
        return next
      })
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Impossible de charger les comptes.')
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    fetchAccounts()
  }, [fetchAccounts])

  const createProfile = async (account: OrphanAuthAccount) => {
    setActionId(account.id)
    setError(null)
    setSuccess(null)
    try {
      const res = await fetch('/api/admin/orphan-accounts', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          userId: account.id,
          role: roles[account.id] ?? defaultRole(account),
          full_name: account.full_name,
          phone: account.phone,
        }),
      })
      const json = await res.json().catch(() => ({}))
      if (!res.ok) {
        throw new Error(
          typeof json?.error === 'string' ? json.error : 'La création du profil a échoué.'
        )
      }
      setAccounts((prev) => prev.filter((item) => item.id !== account.id))
      setSuccess(`Profil créé pour ${account.email ?? account.id}.`)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'La création du profil a échoué.')
    } finally {
      setActionId(null)
    }
  }

  return (
    <div className="p-6 space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Comptes sans profil</h1>
          <p className="text-sm text-gray-500 mt-1">
            Comptes Auth existants (souvent e-mail déjà confirmé) auxquels il manque la ligne
            correspondante dans <span className="font-medium text-gray-700">profiles</span>.
          </p>
        </div>
        <Button
          variant="outline"
          size="sm"
          onClick={fetchAccounts}
          disabled={loading}
          className="self-start sm:self-auto flex items-center gap-2"
        >
          <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
          Actualiser
        </Button>
      </div>

      {error && (
        <div className="rounded-lg bg-red-50 border border-red-200 px-4 py-3 text-sm text-red-700">
          {error}
        </div>
      )}
      {success && (
        <div className="rounded-lg bg-[#E8F1FA] border border-green-200 px-4 py-3 text-sm text-[#164A82]">
          {success}
        </div>
      )}

      <Card className="border-0 shadow-sm">
        <CardHeader className="pb-3">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-lg bg-orange-50 flex items-center justify-center">
              <AlertTriangle className="w-4 h-4 text-orange-600" />
            </div>
            <CardTitle className="text-base font-semibold">
              {accounts.length} compte{accounts.length === 1 ? '' : 's'} à réparer
            </CardTitle>
          </div>
        </CardHeader>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow className="border-gray-100">
                <TableHead className="text-xs text-gray-500 font-medium pl-6">E-mail</TableHead>
                <TableHead className="text-xs text-gray-500 font-medium">Nom (métadonnées)</TableHead>
                <TableHead className="text-xs text-gray-500 font-medium">Créé le</TableHead>
                <TableHead className="text-xs text-gray-500 font-medium">E-mail confirmé</TableHead>
                <TableHead className="text-xs text-gray-500 font-medium">Rôle à créer</TableHead>
                <TableHead className="text-xs text-gray-500 font-medium pr-6 text-right">
                  Action
                </TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {loading ? (
                Array.from({ length: 4 }).map((_, i) => (
                  <TableRow key={i} className="border-gray-50">
                    {Array.from({ length: 6 }).map((_, j) => (
                      <TableCell key={j} className="py-3">
                        <div className="h-4 rounded bg-gray-100 animate-pulse w-3/4" />
                      </TableCell>
                    ))}
                  </TableRow>
                ))
              ) : accounts.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={6} className="text-center py-16 text-gray-500">
                    <div className="flex flex-col items-center gap-2">
                      <UserX className="w-8 h-8 text-gray-300" />
                      <p className="text-sm">Aucun compte Auth orphelin pour le moment.</p>
                    </div>
                  </TableCell>
                </TableRow>
              ) : (
                accounts.map((account) => (
                  <TableRow key={account.id} className="border-gray-50 hover:bg-gray-50/70">
                    <TableCell className="pl-6 py-3">
                      <div className="text-sm font-medium text-gray-900 truncate max-w-[220px]">
                        {account.email ?? '—'}
                      </div>
                      <div className="text-[11px] text-gray-400 font-mono truncate max-w-[220px]">
                        {account.id}
                      </div>
                    </TableCell>
                    <TableCell className="text-sm text-gray-600 py-3">
                      {account.full_name ?? '—'}
                    </TableCell>
                    <TableCell className="text-xs text-gray-500 py-3">
                      {formatDate(account.created_at)}
                    </TableCell>
                    <TableCell className="py-3">
                      {account.email_confirmed_at ? (
                        <span className="text-xs px-2 py-0.5 rounded-full font-medium bg-[#E8F1FA] text-[#1E5FA8]">
                          Oui
                        </span>
                      ) : (
                        <span className="text-xs px-2 py-0.5 rounded-full font-medium bg-yellow-50 text-yellow-700">
                          Non
                        </span>
                      )}
                    </TableCell>
                    <TableCell className="py-3">
                      <select
                        value={roles[account.id] ?? defaultRole(account)}
                        onChange={(e) =>
                          setRoles((prev) => ({
                            ...prev,
                            [account.id]: e.target.value as AppRole,
                          }))
                        }
                        className="h-8 px-2 rounded-lg border border-gray-200 text-xs text-gray-800 bg-white"
                      >
                        {ROLE_OPTIONS.map((opt) => (
                          <option key={opt.value} value={opt.value}>
                            {opt.label}
                          </option>
                        ))}
                      </select>
                    </TableCell>
                    <TableCell className="py-3 pr-6 text-right">
                      <Button
                        size="sm"
                        disabled={actionId === account.id}
                        onClick={() => createProfile(account)}
                        className="h-8 px-3 text-xs bg-[#1E5FA8] hover:bg-[#164A82] text-white"
                      >
                        <UserPlus className="w-3.5 h-3.5 mr-1.5" />
                        {actionId === account.id ? 'Création…' : 'Créer le profil'}
                      </Button>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  )
}
