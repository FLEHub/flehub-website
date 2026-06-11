import { NextRequest, NextResponse } from 'next/server';
import { checkRateLimit, getClientIp } from '@/lib/rate-limit';
import { registerUser } from '@/lib/register/register-user';
import type { RegisterPayload } from '@/lib/register/validation';

const RATE_LIMIT = 5;
const RATE_WINDOW_MS = 15 * 60 * 1000;

export async function POST(request: NextRequest) {
  const ip = getClientIp(request);
  const rateLimitKey = `register:${ip}`;
  const { allowed, retryAfterSeconds } = checkRateLimit(
    rateLimitKey,
    RATE_LIMIT,
    RATE_WINDOW_MS
  );

  if (!allowed) {
    const minutes = Math.max(1, Math.ceil(retryAfterSeconds / 60));
    return NextResponse.json(
      {
        error: `Trop de tentatives d'inscription depuis votre connexion. Veuillez réessayer dans environ ${minutes} minute${minutes > 1 ? 's' : ''}.`,
        code: 'rate_limit_exceeded',
      },
      {
        status: 429,
        headers: { 'Retry-After': String(retryAfterSeconds) },
      }
    );
  }

  let body: RegisterPayload;

  try {
    body = await request.json();
  } catch {
    return NextResponse.json(
      { error: 'Requête invalide. Veuillez réessayer.' },
      { status: 400 }
    );
  }

  try {
    const result = await registerUser(body);

    if (!result.ok) {
      return NextResponse.json(
        { error: result.error },
        { status: result.status ?? 400 }
      );
    }

    return NextResponse.json({
      success: true,
      role: body.role,
      pending: body.role !== 'learner',
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    return NextResponse.json(
      {
        error:
          message.includes('service role') || message.includes('Supabase')
            ? "Configuration serveur incomplète. Veuillez contacter l'administrateur."
            : "Une erreur inattendue est survenue. Veuillez réessayer.",
      },
      { status: 500 }
    );
  }
}
