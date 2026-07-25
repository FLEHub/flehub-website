'use client';

import { useEffect } from 'react';
import { useParams, useRouter } from 'next/navigation';

export default function CapsuleReviewsRedirectPage() {
  const params = useParams();
  const router = useRouter();
  const moduleId = typeof params.moduleId === 'string' ? params.moduleId : '';

  useEffect(() => {
    const query = moduleId ? `?module=${encodeURIComponent(moduleId)}&tab=capsules` : '?tab=capsules';
    router.replace(`/dashboard/teacher/corrections${query}`);
  }, [moduleId, router]);

  return null;
}
