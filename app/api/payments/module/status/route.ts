import { NextRequest, NextResponse } from 'next/server';
import { fulfillVerifiedPayment } from '@/lib/payments/fulfill';
import { createClient } from '@/lib/supabase/server';

/**
 * Poll / optionally complete a module payment after Flutterwave redirect.
 * Query: tx_ref (required), transaction_id (optional — triggers server verify).
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

    const { data: learner } = await supabase
      .from('learners')
      .select('id')
      .eq('profile_id', user.id)
      .maybeSingle();

    if (!learner) {
      return NextResponse.json({ error: 'Learner profile not found' }, { status: 403 });
    }

    // If Flutterwave redirected with a transaction_id and payment is still pending,
    // verify + fulfill immediately (webhook may be delayed).
    if (transactionId) {
      const { data: pending } = await supabase
        .from('module_payments')
        .select('status')
        .eq('flutterwave_tx_ref', txRef)
        .eq('learner_id', learner.id)
        .maybeSingle();

      if (pending?.status === 'pending') {
        await fulfillVerifiedPayment({
          transactionId,
          expectedTxRef: txRef,
        });
      }
    }

    const { data: payment } = await supabase
      .from('module_payments')
      .select('id, module_id, status, amount_rwf, paid_at')
      .eq('flutterwave_tx_ref', txRef)
      .eq('learner_id', learner.id)
      .maybeSingle();

    if (!payment) {
      return NextResponse.json({ error: 'Payment not found' }, { status: 404 });
    }

    let enrolled = false;
    if (payment.status === 'successful') {
      const { data: enrollment } = await supabase
        .from('elearning_enrollments')
        .select('id')
        .eq('module_id', payment.module_id)
        .eq('learner_id', learner.id)
        .maybeSingle();
      enrolled = !!enrollment;
    }

    return NextResponse.json({
      status: payment.status,
      module_id: payment.module_id,
      enrolled,
      paid_at: payment.paid_at,
    });
  } catch (err) {
    console.error('[module payment status]', err);
    return NextResponse.json(
      { error: err instanceof Error ? err.message : 'Status check failed' },
      { status: 500 }
    );
  }
}
