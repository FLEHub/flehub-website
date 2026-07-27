import { NextRequest, NextResponse } from 'next/server';
import { fulfillVerifiedPayment } from '@/lib/payments/fulfill';
import { createClient } from '@/lib/supabase/server';

/**
 * Poll / optionally complete a school subscription after Flutterwave redirect.
 */
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const txRef = searchParams.get('tx_ref');
    const transactionId = searchParams.get('transaction_id');

    if (!txRef) {
      return NextResponse.json({ error: 'tx_ref is required' }, { status: 400 });
    }

    const supabase = await createClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();

    if (!user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const { data: school } = await supabase
      .from('schools')
      .select('id')
      .eq('profile_id', user.id)
      .maybeSingle();

    if (!school) {
      return NextResponse.json({ error: 'School profile not found' }, { status: 403 });
    }

    if (transactionId) {
      const { data: pending } = await supabase
        .from('school_subscriptions')
        .select('status')
        .eq('flutterwave_tx_ref', txRef)
        .eq('school_id', school.id)
        .maybeSingle();

      if (pending?.status === 'pending') {
        await fulfillVerifiedPayment({
          transactionId,
          expectedTxRef: txRef,
        });
      }
    }

    const { data: sub } = await supabase
      .from('school_subscriptions')
      .select('id, status, period_start, period_end, paid_at, amount_rwf')
      .eq('flutterwave_tx_ref', txRef)
      .eq('school_id', school.id)
      .maybeSingle();

    if (!sub) {
      return NextResponse.json({ error: 'Subscription payment not found' }, { status: 404 });
    }

    return NextResponse.json({
      status: sub.status,
      period_start: sub.period_start,
      period_end: sub.period_end,
      paid_at: sub.paid_at,
      amount_rwf: sub.amount_rwf,
    });
  } catch (err) {
    console.error('[school payment status]', err);
    return NextResponse.json(
      { error: err instanceof Error ? err.message : 'Status check failed' },
      { status: 500 }
    );
  }
}
