'use client'

import { useCallback, useEffect, useState } from 'react'
import { CheckCircle2, Clock, RefreshCw, XCircle } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Textarea } from '@/components/ui/textarea'
import { Badge } from '@/components/ui/badge'
import { Card, CardContent } from '@/components/ui/card'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'

type PendingAccount = {
  id: string
  full_name: string
  email: string
  phone: string | null
  role: string
  created_at: string
  email_confirmed_at: string | null
  role_details: string | null
}

const ROLE_LABEL: Record<string, string> = {
  learner: 'Apprenant',
  teacher: 'Enseignant',
  school: 'École',
  journalist: 'Journaliste',
  creator: 'Créateur',
  admin: 'Admin',
}

function formatDate(value: string | null): string {
  if (!value) return '—'
  return new Date(value).toLocaleString('fr-FR', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  })
}

export function AccountValidations() {
  const [accounts, setAccounts] = useState<PendingAccount[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [notice, setNotice] = useState<string | null>(null)
  const [actionId, setActionId] = useState<string | null>(null)
  const [rejectTarget, setRejectTarget] = useState<PendingAccount | null>(null)
  const [reason, setReason] = useState('')

  const load = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const res = await fetch('/api/admin/validations', { cache: 'no-store' })
      const data = await res.json()
      if (!res.ok) {
        setError(typeof data.error === 'string' ? data.error : 'Chargement impossible.')
        setAccounts([])
        return
      }
      setAccounts(Array.isArray(data.accounts) ? data.accounts : [])
    } catch {
      setError('Une erreur réseau est survenue.')
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    void load()
  }, [load])

  const runAction = async (
    account: PendingAccount,
    action: 'validate' | 'reject',
    rejectionReason?: string
  ) => {
    setActionId(account.id + action)
    setError(null)
    setNotice(null)
    try {
      const res = await fetch('/api/admin/validations', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          userId: account.id,
          action,
          rejectionReason: rejectionReason || undefined,
        }),
      })
      const data = await res.json()
      if (!res.ok) {
        setError(typeof data.error === 'string' ? data.error : "L'action a échoué.")
        return
      }
      setAccounts((prev) => prev.filter((row) => row.id !== account.id))
      if (data.emailSent) {
        setNotice(
          action === 'validate'
            ? `Compte de ${account.full_name || account.email} activé. Un e-mail de confirmation a été envoyé.`
            : `Inscription de ${account.full_name || account.email} refusée. Un e-mail a été envoyé.`
        )
      } else {
        setNotice(
          action === 'validate'
            ? `Compte activé. L'e-mail n'a pas été envoyé${data.emailError ? ` : ${data.emailError}` : '.'}`
            : `Inscription refusée. L'e-mail n'a pas été envoyé${data.emailError ? ` : ${data.emailError}` : '.'}`
        )
      }
      setRejectTarget(null)
      setReason('')
    } catch {
      setError('Une erreur réseau est survenue.')
    } finally {
      setActionId(null)
    }
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between gap-3">
        <p className="text-sm text-gray-500">
          {loading ? 'Chargement…' : `${accounts.length} compte${accounts.length > 1 ? 's' : ''} en attente`}
        </p>
        <Button variant="outline" size="sm" onClick={() => void load()} disabled={loading}>
          <RefreshCw className={`w-3.5 h-3.5 mr-1.5 ${loading ? 'animate-spin' : ''}`} />
          Actualiser
        </Button>
      </div>

      {error && (
        <div className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          {error}
        </div>
      )}
      {notice && (
        <div className="rounded-xl border border-green-200 bg-green-50 px-4 py-3 text-sm text-green-800">
          {notice}
        </div>
      )}

      <Card className="border-0 shadow-sm">
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="pl-4">Nom</TableHead>
                <TableHead>E-mail</TableHead>
                <TableHead>Rôle</TableHead>
                <TableHead>Inscription</TableHead>
                <TableHead>E-mail confirmé</TableHead>
                <TableHead>Détails</TableHead>
                <TableHead className="pr-4 text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {loading ? (
                <TableRow>
                  <TableCell colSpan={7} className="py-12 text-center text-sm text-gray-500">
                    Chargement des comptes…
                  </TableCell>
                </TableRow>
              ) : accounts.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={7} className="py-12 text-center text-sm text-gray-500">
                    <Clock className="mx-auto mb-2 h-5 w-5 text-gray-400" />
                    Aucun compte en attente de validation.
                  </TableCell>
                </TableRow>
              ) : (
                accounts.map((account) => {
                  const busy = actionId?.startsWith(account.id) ?? false
                  return (
                    <TableRow key={account.id}>
                      <TableCell className="pl-4 py-3">
                        <p className="text-sm font-medium text-gray-900">
                          {account.full_name || 'Sans nom'}
                        </p>
                        {account.phone && (
                          <p className="text-xs text-gray-500">{account.phone}</p>
                        )}
                      </TableCell>
                      <TableCell className="text-sm text-gray-700">{account.email}</TableCell>
                      <TableCell>
                        <Badge variant="secondary" className="font-medium">
                          {ROLE_LABEL[account.role] ?? account.role}
                        </Badge>
                      </TableCell>
                      <TableCell className="text-xs text-gray-500">
                        {formatDate(account.created_at)}
                      </TableCell>
                      <TableCell className="text-xs text-gray-500">
                        {formatDate(account.email_confirmed_at)}
                      </TableCell>
                      <TableCell className="max-w-[220px] text-xs text-gray-600">
                        {account.role_details || '—'}
                      </TableCell>
                      <TableCell className="pr-4 text-right">
                        <div className="flex justify-end gap-1.5">
                          <Button
                            size="sm"
                            disabled={busy}
                            onClick={() => void runAction(account, 'validate')}
                            className="h-8 bg-[#1E5FA8] hover:bg-[#164A82] text-white"
                          >
                            <CheckCircle2 className="w-3.5 h-3.5 mr-1" />
                            Valider
                          </Button>
                          <Button
                            size="sm"
                            variant="outline"
                            disabled={busy}
                            onClick={() => {
                              setRejectTarget(account)
                              setReason('')
                            }}
                            className="h-8 text-red-600 border-red-200 hover:bg-red-50"
                          >
                            <XCircle className="w-3.5 h-3.5 mr-1" />
                            Refuser
                          </Button>
                        </div>
                      </TableCell>
                    </TableRow>
                  )
                })
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      <Dialog open={Boolean(rejectTarget)} onOpenChange={(open) => !open && setRejectTarget(null)}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Refuser l&apos;inscription</DialogTitle>
            <DialogDescription>
              {rejectTarget
                ? `${rejectTarget.full_name || rejectTarget.email} recevra un e-mail de refus.`
                : ''}
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-2">
            <label htmlFor="rejection-reason" className="text-sm font-medium text-gray-700">
              Motif (optionnel)
            </label>
            <Textarea
              id="rejection-reason"
              value={reason}
              maxLength={500}
              onChange={(event) => setReason(event.target.value)}
              placeholder="Expliquez brièvement la décision, si vous le souhaitez."
            />
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setRejectTarget(null)}>
              Annuler
            </Button>
            <Button
              disabled={!rejectTarget || actionId !== null}
              onClick={() => rejectTarget && void runAction(rejectTarget, 'reject', reason)}
              className="bg-red-600 hover:bg-red-700 text-white"
            >
              Confirmer le refus
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}
