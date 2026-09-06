'use client';

import { useState } from 'react';
import { FileDown, Loader2 } from 'lucide-react';
import { createClient } from '@/lib/supabase/client';
import { Button } from '@/components/ui/button';
import { downloadPedagogicalPdfForModule } from '@/lib/elearning/download-pedagogical-pdf';

interface PedagogicalPdfButtonProps {
  moduleId: string;
  moduleNumber?: number;
  variant?: 'default' | 'outline' | 'ghost';
  size?: 'default' | 'sm';
  className?: string;
  label?: string;
  fullWidth?: boolean;
}

export function PedagogicalPdfButton({
  moduleId,
  moduleNumber,
  variant = 'outline',
  size = 'sm',
  className,
  label = 'Télécharger la fiche pédagogique (PDF)',
  fullWidth,
}: PedagogicalPdfButtonProps) {
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleClick() {
    setBusy(true);
    setError(null);
    try {
      const supabase = createClient();
      await downloadPedagogicalPdfForModule(supabase, moduleId, { moduleNumber });
    } catch (err) {
      console.error(err);
      setError("Impossible de générer la fiche. Réessayez.");
    } finally {
      setBusy(false);
    }
  }

  return (
    <div
      className={
        fullWidth
          ? 'flex flex-col items-stretch gap-1 w-full min-w-0'
          : 'inline-flex flex-col items-stretch gap-1 min-w-0'
      }
    >
      <Button
        type="button"
        variant={variant}
        size={size}
        className={className}
        disabled={busy}
        onClick={handleClick}
      >
        {busy ? (
          <Loader2 className="w-3.5 h-3.5 mr-1 animate-spin" />
        ) : (
          <FileDown className="w-3.5 h-3.5 mr-1" />
        )}
        {busy ? 'Préparation du PDF…' : label}
      </Button>
      {error && <p className="text-xs text-red-600">{error}</p>}
    </div>
  );
}
