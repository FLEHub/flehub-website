import { Suspense } from 'react';
import { Skeleton } from '@/components/ui/skeleton';
import TeacherCorrectionsClient from './corrections-client';

function CorrectionsFallback() {
  return (
    <div className="p-6 space-y-6 max-w-7xl mx-auto">
      <div className="space-y-2">
        <Skeleton className="h-8 w-48" />
        <Skeleton className="h-4 w-72" />
      </div>
      <Skeleton className="h-10 w-80" />
      <div className="space-y-3">
        {Array.from({ length: 4 }).map((_, i) => (
          <Skeleton key={i} className="h-20 w-full rounded-xl" />
        ))}
      </div>
    </div>
  );
}

export default function TeacherCorrectionsPage() {
  return (
    <Suspense fallback={<CorrectionsFallback />}>
      <TeacherCorrectionsClient />
    </Suspense>
  );
}
