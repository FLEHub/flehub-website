'use client';

import { useState } from 'react';
import { toast } from 'sonner';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { SCHOOL_STATUS_LABELS, SCHOOL_TYPE_LABELS } from '@/lib/school/constants';

type Props = {
  school: any;
};

export function SettingsForm({ school }: Props) {
  const [form, setForm] = useState({
    name: school.display_name ?? '',
    address: school.address ?? '',
    district: school.district ?? '',
    type: school.type ?? 'both',
    director_name: school.director_name ?? '',
    email: school.email ?? '',
    phone: school.phone ?? '',
  });
  const [logoPreview, setLogoPreview] = useState(school.logo_signed_url ?? '');
  const [signaturePreview, setSignaturePreview] = useState(school.signature_signed_url ?? '');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);

  function update(field: string, value: string) {
    setForm((current) => ({ ...current, [field]: value }));
  }

  async function saveProfile(event: React.FormEvent) {
    event.preventDefault();
    setLoading(true);
    const res = await fetch('/api/school/profile', {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(form),
    });
    const payload = await res.json().catch(() => ({}));
    setLoading(false);
    if (!res.ok) {
      toast.error(payload.error ?? 'Mise à jour impossible.');
      return;
    }
    toast.success('Profil école mis à jour.');
  }

  async function uploadAsset(kind: 'logo' | 'signature', file?: File) {
    if (!file) return;
    const body = new FormData();
    body.append('kind', kind);
    body.append('file', file);
    const res = await fetch('/api/school/assets', { method: 'POST', body });
    const payload = await res.json().catch(() => ({}));
    if (!res.ok) {
      toast.error(payload.error ?? 'Téléversement impossible.');
      return;
    }
    if (kind === 'logo') setLogoPreview(payload.signedUrl);
    if (kind === 'signature') setSignaturePreview(payload.signedUrl);
    toast.success(kind === 'logo' ? 'Logo mis à jour.' : 'Signature mise à jour.');
  }

  async function changePassword(event: React.FormEvent) {
    event.preventDefault();
    const res = await fetch('/api/school/password', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ password }),
    });
    const payload = await res.json().catch(() => ({}));
    if (!res.ok) {
      toast.error(payload.error ?? 'Changement impossible.');
      return;
    }
    setPassword('');
    toast.success('Mot de passe mis à jour.');
  }

  return (
    <div className="grid gap-6 lg:grid-cols-[1fr_420px]">
      <div className="space-y-6">
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <CardTitle className="text-base">Profil institutionnel</CardTitle>
              <Badge className="bg-[#E8F8F0] text-[#00A550]">
                {SCHOOL_STATUS_LABELS[school.status] ?? school.status}
              </Badge>
            </div>
          </CardHeader>
          <CardContent>
            <form onSubmit={saveProfile} className="grid gap-4 sm:grid-cols-2">
              <div className="sm:col-span-2">
                <Label>Nom de l&apos;école</Label>
                <Input value={form.name} onChange={(e) => update('name', e.target.value)} required />
              </div>
              <div>
                <Label>Type</Label>
                <select className="h-10 w-full rounded-md border px-3 text-sm" value={form.type} onChange={(e) => update('type', e.target.value)}>
                  {Object.entries(SCHOOL_TYPE_LABELS).map(([value, label]) => (
                    <option key={value} value={value}>{label}</option>
                  ))}
                </select>
              </div>
              <div>
                <Label>District</Label>
                <Input value={form.district} onChange={(e) => update('district', e.target.value)} required />
              </div>
              <div className="sm:col-span-2">
                <Label>Adresse</Label>
                <Input value={form.address} onChange={(e) => update('address', e.target.value)} required />
              </div>
              <div>
                <Label>Directeur</Label>
                <Input value={form.director_name} onChange={(e) => update('director_name', e.target.value)} required />
              </div>
              <div>
                <Label>Téléphone</Label>
                <Input value={form.phone} onChange={(e) => update('phone', e.target.value)} required />
              </div>
              <div className="sm:col-span-2">
                <Label>E-mail officiel</Label>
                <Input type="email" value={form.email} onChange={(e) => update('email', e.target.value)} required />
              </div>
              <div className="sm:col-span-2">
                <Button disabled={loading} className="bg-[#00A550] text-white hover:bg-[#007A3D]">
                  {loading ? 'Enregistrement...' : 'Enregistrer le profil'}
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-base">Logo et signature</CardTitle>
          </CardHeader>
          <CardContent className="grid gap-4 sm:grid-cols-2">
            <div>
              <Label>Logo école (PNG/JPG)</Label>
              <Input type="file" accept="image/png,image/jpeg" onChange={(e) => uploadAsset('logo', e.target.files?.[0])} />
            </div>
            <div>
              <Label>Signature du directeur (PNG)</Label>
              <Input type="file" accept="image/png" onChange={(e) => uploadAsset('signature', e.target.files?.[0])} />
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-base">Changer le mot de passe</CardTitle>
          </CardHeader>
          <CardContent>
            <form onSubmit={changePassword} className="flex flex-col gap-3 sm:flex-row">
              <Input
                type="password"
                placeholder="Nouveau mot de passe"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                minLength={8}
                required
              />
              <Button className="bg-[#00A550] text-white hover:bg-[#007A3D]">Mettre à jour</Button>
            </form>
          </CardContent>
        </Card>
      </div>

      <Card className="h-fit">
        <CardHeader>
          <CardTitle className="text-base">Aperçu certificat</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="rounded-3xl border bg-white p-5 text-center">
            <div className="flex items-start justify-between">
              <div className="rounded-xl border px-3 py-2 font-bold text-[#00A550]">FLEHub</div>
              <div className="h-16 w-20 overflow-hidden rounded-xl border bg-[#F5F5F5]">
                {logoPreview ? <img src={logoPreview} alt="Logo école" className="h-full w-full object-contain" /> : null}
              </div>
            </div>
            <p className="mt-8 text-xs uppercase tracking-wider text-gray-500">Certificat de réussite</p>
            <p className="mt-2 text-xl font-bold text-gray-900">Nom de l&apos;élève</p>
            <p className="text-sm text-gray-600">Niveau A2</p>
            <div className="mt-8 flex items-end justify-between text-left">
              <div>
                <div className="h-14 w-36">
                  {signaturePreview ? <img src={signaturePreview} alt="Signature" className="h-full object-contain" /> : null}
                </div>
                <div className="border-t pt-1 text-xs font-semibold">{form.director_name || 'Directeur'}</div>
              </div>
              <div className="h-16 w-16 rounded-lg bg-[#F5F5F5] text-xs text-gray-400 flex items-center justify-center">QR</div>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
