'use client'

import { useState, useRef, useTransition } from 'react'
import Image from 'next/image'
import { createClient } from '@/lib/supabase/client'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import {
  Upload,
  CheckCircle2,
  AlertCircle,
  ImageIcon,
  Building2,
  Mail,
  Phone,
  PenLine,
} from 'lucide-react'

interface OrgSettings {
  id: string
  org_name: string
  contact_email: string | null
  contact_phone: string | null
  logo_url: string | null
  signature_url: string | null
  updated_at: string
}

interface Props {
  initialSettings: OrgSettings | null
}

type UploadField = 'logo_url' | 'signature_url'

type Toast = { type: 'success' | 'error'; message: string } | null

function ImageUploadCard({
  label,
  description,
  current,
  accept,
  onUpload,
  uploading,
  icon: Icon,
}: {
  label: string
  description: string
  current: string | null
  accept: string
  onUpload: (file: File) => Promise<void>
  uploading: boolean
  icon: React.ElementType
}) {
  const inputRef = useRef<HTMLInputElement>(null)
  const [dragOver, setDragOver] = useState(false)

  const handleFile = async (file: File) => {
    if (!file) return
    await onUpload(file)
  }

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-2">
        <Icon className="w-4 h-4 text-[#00A550]" />
        <Label className="text-sm font-semibold text-gray-800">{label}</Label>
      </div>
      <p className="text-xs text-gray-500 -mt-1">{description}</p>

      {current && (
        <div className="relative w-full h-28 rounded-xl border border-gray-200 overflow-hidden bg-gray-50">
          <Image src={current} alt={label} fill className="object-contain p-2" unoptimized />
        </div>
      )}

      <div
        onDragOver={(e) => { e.preventDefault(); setDragOver(true) }}
        onDragLeave={() => setDragOver(false)}
        onDrop={(e) => {
          e.preventDefault()
          setDragOver(false)
          const file = e.dataTransfer.files[0]
          if (file) handleFile(file)
        }}
        onClick={() => inputRef.current?.click()}
        className={`flex flex-col items-center justify-center gap-2 h-24 rounded-xl border-2 border-dashed cursor-pointer transition-colors ${
          dragOver
            ? 'border-[#00A550] bg-[#E6F5EE]'
            : 'border-gray-200 hover:border-[#00A550] hover:bg-[#E6F5EE]/40 bg-gray-50/60'
        }`}
      >
        <Upload className={`w-5 h-5 ${dragOver ? 'text-[#00A550]' : 'text-gray-400'}`} />
        <span className="text-xs text-gray-500">
          {uploading ? 'Uploading…' : 'Click or drag to upload'}
        </span>
      </div>
      <input
        ref={inputRef}
        type="file"
        accept={accept}
        className="hidden"
        onChange={(e) => {
          const file = e.target.files?.[0]
          if (file) handleFile(file)
          e.target.value = ''
        }}
      />
    </div>
  )
}

export function AdminSettingsForm({ initialSettings }: Props) {
  const supabase = createClient()
  const [settings, setSettings] = useState<OrgSettings>(
    initialSettings ?? {
      id: '',
      org_name: 'FLEHub',
      contact_email: null,
      contact_phone: null,
      logo_url: null,
      signature_url: null,
      updated_at: new Date().toISOString(),
    }
  )
  const [uploadingField, setUploadingField] = useState<UploadField | null>(null)
  const [toast, setToast] = useState<Toast>(null)
  const [isPending, startTransition] = useTransition()

  const showToast = (type: 'success' | 'error', message: string) => {
    setToast({ type, message })
    setTimeout(() => setToast(null), 4000)
  }

  const uploadImage = async (file: File, field: UploadField) => {
    setUploadingField(field)
    try {
      const ext = file.name.split('.').pop()
      const path = `${field}/${Date.now()}.${ext}`
      const { error: uploadError } = await supabase.storage
        .from('admin-assets')
        .upload(path, file, { upsert: true })

      if (uploadError) throw uploadError

      const { data: urlData } = supabase.storage
        .from('admin-assets')
        .getPublicUrl(path)

      const publicUrl = urlData.publicUrl

      const { error: dbError } = await supabase
        .from('org_settings')
        .update({ [field]: publicUrl, updated_at: new Date().toISOString() })
        .eq('id', settings.id)

      if (dbError) throw dbError

      setSettings((prev) => ({ ...prev, [field]: publicUrl }))
      showToast('success', `${field === 'logo_url' ? 'Logo' : 'Signature'} updated successfully.`)
    } catch (err) {
      showToast('error', `Upload failed: ${(err as Error).message}`)
    } finally {
      setUploadingField(null)
    }
  }

  const handleSave = () => {
    startTransition(async () => {
      const { error } = await supabase
        .from('org_settings')
        .update({
          org_name: settings.org_name,
          contact_email: settings.contact_email,
          contact_phone: settings.contact_phone,
          updated_at: new Date().toISOString(),
        })
        .eq('id', settings.id)

      if (error) {
        showToast('error', `Save failed: ${error.message}`)
      } else {
        showToast('success', 'Organization settings saved successfully.')
      }
    })
  }

  return (
    <div className="space-y-6">
      {/* Toast */}
      {toast && (
        <div
          className={`flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium shadow-sm border transition-all ${
            toast.type === 'success'
              ? 'bg-[#E6F5EE] text-[#00A550] border-green-200'
              : 'bg-red-50 text-red-700 border-red-200'
          }`}
        >
          {toast.type === 'success' ? (
            <CheckCircle2 className="w-4 h-4 flex-shrink-0" />
          ) : (
            <AlertCircle className="w-4 h-4 flex-shrink-0" />
          )}
          {toast.message}
        </div>
      )}

      {/* Organization Info */}
      <Card className="border-0 shadow-sm">
        <CardHeader className="pb-4">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-lg bg-[#E6F5EE] flex items-center justify-center">
              <Building2 className="w-4 h-4 text-[#00A550]" />
            </div>
            <CardTitle className="text-base font-semibold">Organization Information</CardTitle>
          </div>
        </CardHeader>
        <CardContent className="space-y-5">
          <div className="space-y-1.5">
            <Label htmlFor="org_name" className="text-sm font-medium text-gray-700">
              Organization Name
            </Label>
            <Input
              id="org_name"
              value={settings.org_name}
              onChange={(e) => setSettings((p) => ({ ...p, org_name: e.target.value }))}
              placeholder="FLEHub"
              className="border-gray-200 focus:border-[#00A550] focus:ring-[#00A550]/20"
            />
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div className="space-y-1.5">
              <Label htmlFor="contact_email" className="text-sm font-medium text-gray-700 flex items-center gap-1.5">
                <Mail className="w-3.5 h-3.5 text-gray-400" />
                Contact Email
              </Label>
              <Input
                id="contact_email"
                type="email"
                value={settings.contact_email ?? ''}
                onChange={(e) => setSettings((p) => ({ ...p, contact_email: e.target.value || null }))}
                placeholder="admin@flehub.com"
                className="border-gray-200 focus:border-[#00A550] focus:ring-[#00A550]/20"
              />
            </div>

            <div className="space-y-1.5">
              <Label htmlFor="contact_phone" className="text-sm font-medium text-gray-700 flex items-center gap-1.5">
                <Phone className="w-3.5 h-3.5 text-gray-400" />
                Contact Phone
              </Label>
              <Input
                id="contact_phone"
                type="tel"
                value={settings.contact_phone ?? ''}
                onChange={(e) => setSettings((p) => ({ ...p, contact_phone: e.target.value || null }))}
                placeholder="+250 7XX XXX XXX"
                className="border-gray-200 focus:border-[#00A550] focus:ring-[#00A550]/20"
              />
            </div>
          </div>

          <div className="flex justify-end pt-2">
            <Button
              onClick={handleSave}
              disabled={isPending}
              className="bg-[#00A550] hover:bg-[#008040] text-white px-6 font-medium transition-colors"
            >
              {isPending ? 'Saving…' : 'Save Changes'}
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* Branding Assets */}
      <Card className="border-0 shadow-sm">
        <CardHeader className="pb-4">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-lg bg-[#E6F5EE] flex items-center justify-center">
              <ImageIcon className="w-4 h-4 text-[#00A550]" />
            </div>
            <div>
              <CardTitle className="text-base font-semibold">Certificate Assets</CardTitle>
              <p className="text-xs text-gray-500 mt-0.5">
                These images will appear on all generated certificates.
              </p>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-8">
            <ImageUploadCard
              label="Official Logo"
              description="PNG or JPG — displayed at the top of certificates."
              current={settings.logo_url}
              accept="image/png,image/jpeg,image/jpg"
              uploading={uploadingField === 'logo_url'}
              onUpload={(file) => uploadImage(file, 'logo_url')}
              icon={ImageIcon}
            />
            <ImageUploadCard
              label="Admin Signature"
              description="PNG — placed at the bottom of certificates."
              current={settings.signature_url}
              accept="image/png"
              uploading={uploadingField === 'signature_url'}
              onUpload={(file) => uploadImage(file, 'signature_url')}
              icon={PenLine}
            />
          </div>
        </CardContent>
      </Card>

      {/* Last updated */}
      {settings.updated_at && (
        <p className="text-xs text-gray-400 text-right">
          Last updated:{' '}
          {new Date(settings.updated_at).toLocaleDateString('en-RW', {
            day: 'numeric',
            month: 'long',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
          })}
        </p>
      )}
    </div>
  )
}
