'use client';

import Link from 'next/link';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { CheckCircle2, PenLine } from 'lucide-react';

export default function LearnerTcfEeConfirmationPage() {
  return (
    <div className="p-6 max-w-xl mx-auto">
      <Card>
        <CardContent className="flex flex-col items-center justify-center py-16 text-center space-y-4">
          <div className="p-3 rounded-lg bg-blue-50">
            <PenLine className="w-6 h-6 text-blue-700" />
          </div>
          <div className="inline-flex items-center gap-2 rounded-lg bg-flehub-green-light px-3 py-1.5 text-sm font-medium text-flehub-green">
            <CheckCircle2 className="w-4 h-4" />
            Copie envoyée
          </div>
          <h1 className="text-2xl font-bold text-gray-900">
            Votre copie a été envoyée
          </h1>
          <p className="text-sm text-gray-500 max-w-sm">
            Vous recevrez votre correction bientôt. Merci d’avoir terminé les 3
            tâches d’expression écrite.
          </p>
          <Button
            asChild
            className="mt-2 bg-flehub-green hover:bg-flehub-green/90 text-white"
          >
            <Link href="/dashboard/learner/preparation">
              Retour à Préparation
            </Link>
          </Button>
        </CardContent>
      </Card>
    </div>
  );
}
