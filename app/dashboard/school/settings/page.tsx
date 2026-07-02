'use client'

import { useState, useEffect, useCallback, useRef } from 'react'
import { createClient } from '@/lib/supabase/client'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import {
  Settings,
  Upload,
  CheckCircle2,
  RefreshCw,
  AlertTriangle,
  X,
  User,
  ImageIcon,
  GraduationCap,
} from 'lucide-react'

interface SchoolSettings {
  id: string | null
  school_id: string
  examiner_name: string
  examiner_signature_path: string | null
  school_logo_path: string | null
}

export default function SchoolSettingsPage() {
  const supabase = createClient()

  const [schoolId, setSchoolId] = useState<string | null>(null)
  const [settings, setSettings] = useState<SchoolSettings | null>(null)
  const [examinerName, setExaminerName] = useState('')
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [success, setSuccess] = useState(false)
  const [uploadingKey, setUploadingKey] = useState<string | null>(null)

  const sigInputRef = useRef<HTMLInputElement>(null)
  const logoInputRef = useRef<HTMLInputElement>(null)

  const [signatureUrl, setSignatureUrl] = useState<string | null>(null)
  const [logoUrl, setLogoUrl] = useState<string | null>(null)

  const getSchoolId = useCallback(async () => {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return null
    const { data } = await supabase.from('schools').select('id').eq('profile_id', user.id).maybeSingle()
    return data?.id ?? null
  }, [supabase])

  const loadSettings = useCallback(async (sid: string) => {
    const { data } = await supabase.from('school_settings').select('*').eq('school_id', sid).maybeSingle()
    if (data) {
      setSettings(data)
      setExaminerName(data.examiner_name ?? '')
      if (data.examiner_signature_path) {
        const { data: urlData } = await supabase.storage.from('school-assets').createSignedUrl(data.examiner_signature_path, 3600)
        setSignatureUrl(urlData?.signedUrl ?? null)
      }
      if (data.school_logo_path) {
        const { data: urlData } = await supabase.storage.from('school-assets').createSignedUrl(data.school_logo_path, 3600)
        setLogoUrl(urlData?.signedUrl ?? null)
      }
    }
  }, [supabase])

  const loadAll = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const sid = schoolId ?? await getSchoolId()
      if (!sid) { setLoading(false); return }
      if (!schoolId) setSchoolId(sid)
      await loadSettings(sid)
    } catch { setError('Failed to load settings. Please refresh.') }
    finally { setLoading(false) }
  }, [schoolId, getSchoolId, loadSettings])

  useEffect(() => { loadAll() }, [loadAll])

  const handleSaveName = async () => {
    if (!schoolId) return
    setSaving(true)
    setError(null)
    setSuccess(false)
    try {
      if (settings?.id) {
        const { error: err } = await supabase.from('school_settings').update({ examiner_name: examinerName.trim(), updated_at: new Date().toISOString() }).eq('id', settings.id)
        if (err) throw err
      } else {
        const { error: err } = await supabase.from('school_settings').insert({ school_id: schoolId, examiner_name: examinerName.trim() })
        if (err) throw err
      }
      setSuccess(true)
      setTimeout(() => setSuccess(false), 3000)
      await loadSettings(schoolId)
    } catch (err) {
      setError((err as Error).message)
    } finally {
      setSaving(false)
    }
  }

  const uploadAsset = async (file: File, assetKey: 'signature' | 'logo') => {
    if (!schoolId) return
    setUploadingKey(assetKey)
    setError(null)
    try {
      const ext = file.name.split('.').pop()?.toLowerCase() ?? 'png'
      const path = `${schoolId}/${assetKey}.${ext}`
      const { error: upErr } = await supabase.storage.from('school-assets').upload(path, file, { upsert: true })
      if (upErr) throw upErr

      const fieldName = assetKey === 'signature' ? 'examiner_signature_path' : 'school_logo_path'
      if (settings?.id) {
        const { error: err } = await supabase.from('school_settings').update({ [fieldName]: path, updated_at: new Date().toISOString() }).eq('id', settings.id)
        if (err) throw err
      } else {
        const { error: err } = await supabase.from('school_settings').insert({ school_id: schoolId, [fieldName]: path })
        if (err) throw err
      }

      // get preview URL
      const { data: urlData } = await supabase.storage.from('school-assets').createSignedUrl(path, 3600)
      if (assetKey === 'signature') setSignatureUrl(urlData?.signedUrl ?? null)
      else setLogoUrl(urlData?.signedUrl ?? null)

      await loadSettings(schoolId)
    } catch (err) {
      setError((err as Error).message)
    } finally {
      setUploadingKey(null)
    }
  }

  return (
    <div className="p-6 space-y-6 max-w-2xl mx-auto">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">School Settings</h1>
        <p className="text-sm text-gray-500 mt-1">Manage your examiner details and branding assets.</p>
      </div>

      {error && (
        <div className="flex items-center gap-2 rounded-lg bg-red-50 border border-red-200 px-4 py-3 text-sm text-red-700">
          <AlertTriangle className="w-4 h-4 flex-shrink-0" />
          <span className="flex-1">{error}</span>
          <button onClick={() => setError(null)}><X className="w-4 h-4 text-red-400 hover:text-red-600" /></button>
        </div>
      )}

      {success && (
        <div className="flex items-center gap-2 rounded-lg bg-[#E6F5EE] border border-green-200 px-4 py-3 text-sm text-[#00A550]">
          <CheckCircle2 className="w-4 h-4 flex-shrink-0" />
          Settings saved successfully.
        </div>
      )}

      {/* Examiner Details */}
      <Card className="border-0 shadow-sm">
        <CardHeader className="pb-3">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-lg bg-[#E6F5EE] flex items-center justify-center">
              <User className="w-4 h-4 text-[#00A550]" />
            </div>
            <CardTitle className="text-base font-semibold">Examiner Details</CardTitle>
          </div>
        </CardHeader>
        <CardContent className="space-y-4">
          {loading ? (
            <div className="h-10 bg-gray-100 rounded animate-pulse" />
          ) : (
            <>
              <div className="space-y-1.5">
                <Label htmlFor="examiner-name">Examiner Full Name</Label>
                <Input
                  id="examiner-name"
                  placeholder="e.g., UWIMANA Marie Claire"
                  value={examinerName}
                  onChange={(e) => setExaminerName(e.target.value)}
                  className="border-gray-200 focus:border-[#00A550] max-w-sm"
                />
                <p className="text-xs text-gray-400">This name appears on issued certificates.</p>
              </div>
              <Button onClick={handleSaveName} disabled={saving || !examinerName.trim()}
                className="bg-[#00A550] hover:bg-[#008040] text-white">
                {saving ? <RefreshCw className="w-3.5 h-3.5 animate-spin mr-1.5" /> : <Settings className="w-3.5 h-3.5 mr-1.5" />}
                {saving ? 'Saving…' : 'Save Name'}
              </Button>
            </>
          )}
        </CardContent>
      </Card>

      {/* Examiner Signature */}
      <Card className="border-0 shadow-sm">
        <CardHeader className="pb-3">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-lg bg-blue-50 flex items-center justify-center">
              <ImageIcon className="w-4 h-4 text-blue-600" />
            </div>
            <CardTitle className="text-base font-semibold">Examiner Signature</CardTitle>
          </div>
        </CardHeader>
        <CardContent className="space-y-4">
          <p className="text-sm text-gray-500">Upload a PNG image of the examiner's signature. Used on certificates.</p>
          {signatureUrl && (
            <div className="border border-gray-200 rounded-lg p-4 bg-gray-50 w-fit">
              <img src={signatureUrl} alt="Examiner signature" className="h-16 object-contain" />
            </div>
          )}
          <div>
            <input ref={sigInputRef} type="file" accept="image/png" className="hidden"
              onChange={(e) => { const f = e.target.files?.[0]; if (f) uploadAsset(f, 'signature') }} />
            <Button variant="outline" onClick={() => sigInputRef.current?.click()}
              disabled={uploadingKey === 'signature'}
              className="border-gray-200 hover:border-[#00A550] hover:text-[#00A550]">
              {uploadingKey === 'signature'
                ? <RefreshCw className="w-3.5 h-3.5 animate-spin mr-1.5" />
                : <Upload className="w-3.5 h-3.5 mr-1.5" />}
              {uploadingKey === 'signature' ? 'Uploading…' : signatureUrl ? 'Replace Signature' : 'Upload PNG'}
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* School Logo */}
      <Card className="border-0 shadow-sm">
        <CardHeader className="pb-3">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-lg bg-amber-50 flex items-center justify-center">
              <GraduationCap className="w-4 h-4 text-amber-600" />
            </div>
            <CardTitle className="text-base font-semibold">School Logo</CardTitle>
          </div>
        </CardHeader>
        <CardContent className="space-y-4">
          <p className="text-sm text-gray-500">Upload your school logo (PNG or JPG). Displayed on certificates and documents.</p>
          {logoUrl && (
            <div className="border border-gray-200 rounded-lg p-4 bg-gray-50 w-fit">
              <img src={logoUrl} alt="School logo" className="h-20 object-contain" />
            </div>
          )}
          <div>
            <input ref={logoInputRef} type="file" accept="image/png,image/jpeg,image/jpg" className="hidden"
              onChange={(e) => { const f = e.target.files?.[0]; if (f) uploadAsset(f, 'logo') }} />
            <Button variant="outline" onClick={() => logoInputRef.current?.click()}
              disabled={uploadingKey === 'logo'}
              className="border-gray-200 hover:border-[#00A550] hover:text-[#00A550]">
              {uploadingKey === 'logo'
                ? <RefreshCw className="w-3.5 h-3.5 animate-spin mr-1.5" />
                : <Upload className="w-3.5 h-3.5 mr-1.5" />}
              {uploadingKey === 'logo' ? 'Uploading…' : logoUrl ? 'Replace Logo' : 'Upload PNG/JPG'}
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
