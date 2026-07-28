'use client';

import { useEffect } from 'react';
import { useParams, useRouter } from 'next/navigation';

/**
 * Capsule vidéo retirée du parcours apprenant.
 * Conservée en redirection pour ne pas casser d'anciens liens.
 * Données elearning_capsules / storage inchangées.
 */
export default function LearnerCapsulePage() {
  const params = useParams();
  const router = useRouter();
  const moduleId = typeof params.moduleId === 'string' ? params.moduleId : '';

  useEffect(() => {
    if (moduleId) {
      router.replace(`/dashboard/learner/elearning/${moduleId}`);
    } else {
      router.replace('/dashboard/learner/elearning');
    }
  }, [moduleId, router]);

  return null;
}
