'use client';

import { useEffect } from 'react';
import { useParams, useRouter } from 'next/navigation';

/**
 * Ancienne page de revue des capsules — redirige vers Corrections (copies).
 * La validation de capsules vidéo a été retirée de l'UI.
 */
export default function CapsuleReviewsRedirectPage() {
  const params = useParams();
  const router = useRouter();
  const moduleId = typeof params.moduleId === 'string' ? params.moduleId : '';

  useEffect(() => {
    const query = moduleId ? `?module=${encodeURIComponent(moduleId)}` : '';
    router.replace(`/dashboard/teacher/corrections${query}`);
  }, [moduleId, router]);

  return null;
}
