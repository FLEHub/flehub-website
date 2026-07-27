import { NextRequest, NextResponse } from 'next/server';
import { isWebhookSignatureValid } from '@/lib/flutterwave';
import { fulfillVerifiedPayment } from '@/lib/payments/fulfill';
import { createAdminClient } from '@/lib/supabase/admin';

/**
 * Flutterwave webhook — handles both module_ and school_ tx_ref prefixes.
 * Verifies verif-hash, then re-queries Flutterwave before fulfilling.
 */
export async function POST(request: NextRequest) {
  try {
    const verifHash = request.headers.get('verif-hash');
    if (!isWebhookSignatureValid(verifHash)) {
      return NextResponse.json({ error: 'Invalid signature' }, { status: 401 });
    }

    const payload = await request.json();
    const data = payload?.data ?? payload;
    const transactionId = data?.id;
    const txRef = data?.tx_ref as string | undefined;
    const status = data?.status as string | undefined;

    if (!transactionId) {
      return NextResponse.json({ error: 'Missing transaction id' }, { status: 400 });
    }

    // Mark failed early without full verify when Flutterwave reports failure.
    if (status && status !== 'successful' && txRef) {
      await markFailedIfPending(txRef, String(transactionId));
      return NextResponse.json({ received: true, fulfilled: false });
    }

    const result = await fulfillVerifiedPayment({
      transactionId,
      expectedTxRef: txRef,
    });

    if (!result.ok) {
      console.error('[payments webhook] fulfill failed:', result.reason);
      // Still return 200 so Flutterwave does not retry forever on business errors.
      return NextResponse.json({ received: true, fulfilled: false, reason: result.reason });
    }

    return NextResponse.json({
      received: true,
      fulfilled: true,
      type: result.type,
      alreadyProcessed: result.alreadyProcessed ?? false,
    });
  } catch (err) {
    console.error('[payments webhook]', err);
    return NextResponse.json(
      { error: err instanceof Error ? err.message : 'Webhook processing failed' },
      { status: 500 }
    );
  }
}

async function markFailedIfPending(txRef: string, transactionId: string) {
  try {
    const admin = createAdminClient();
    if (txRef.startsWith('module_')) {
      await admin
        .from('module_payments')
        .update({
          status: 'failed',
          flutterwave_transaction_id: transactionId,
        })
        .eq('flutterwave_tx_ref', txRef)
        .eq('status', 'pending');
    } else if (txRef.startsWith('school_')) {
      await admin
        .from('school_subscriptions')
        .update({
          status: 'failed',
          flutterwave_transaction_id: transactionId,
        })
        .eq('flutterwave_tx_ref', txRef)
        .eq('status', 'pending');
    }
  } catch (err) {
    console.error('[payments webhook] markFailedIfPending', err);
  }
}
