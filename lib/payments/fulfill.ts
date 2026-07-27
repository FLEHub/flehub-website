import { createAdminClient } from '@/lib/supabase/admin';
import {
  isModuleTxRef,
  isSchoolTxRef,
  verifyFlutterwaveTransaction,
  type FlutterwaveVerifyResult,
} from '@/lib/flutterwave';

const ONE_YEAR_MS = 365 * 24 * 60 * 60 * 1000;

export type FulfillResult =
  | { ok: true; type: 'module' | 'school'; alreadyProcessed?: boolean }
  | { ok: false; reason: string };

/**
 * Verify a Flutterwave transaction and fulfill the corresponding payment
 * (module enrollment or school subscription). Idempotent.
 */
export async function fulfillVerifiedPayment(opts: {
  transactionId: string | number;
  expectedTxRef?: string;
  expectedAmountRwf?: number;
}): Promise<FulfillResult> {
  const verified = await verifyFlutterwaveTransaction(opts.transactionId);

  if (verified.status !== 'successful') {
    return { ok: false, reason: `Transaction status is ${verified.status}` };
  }

  if (opts.expectedTxRef && verified.tx_ref !== opts.expectedTxRef) {
    return { ok: false, reason: 'tx_ref mismatch' };
  }

  if (
    opts.expectedAmountRwf != null &&
    Number(verified.amount) < Number(opts.expectedAmountRwf)
  ) {
    return { ok: false, reason: 'amount mismatch' };
  }

  if (verified.currency && verified.currency !== 'RWF') {
    return { ok: false, reason: `Unexpected currency ${verified.currency}` };
  }

  if (isModuleTxRef(verified.tx_ref)) {
    return fulfillModulePayment(verified);
  }

  if (isSchoolTxRef(verified.tx_ref)) {
    return fulfillSchoolSubscription(verified);
  }

  return { ok: false, reason: `Unknown tx_ref prefix: ${verified.tx_ref}` };
}

async function fulfillModulePayment(
  verified: FlutterwaveVerifyResult
): Promise<FulfillResult> {
  const admin = createAdminClient();

  const { data: payment, error } = await admin
    .from('module_payments')
    .select('id, module_id, learner_id, amount_rwf, status')
    .eq('flutterwave_tx_ref', verified.tx_ref)
    .maybeSingle();

  if (error || !payment) {
    return { ok: false, reason: 'module_payments row not found' };
  }

  if (Number(verified.amount) < Number(payment.amount_rwf)) {
    return { ok: false, reason: 'verified amount below expected' };
  }

  if (payment.status === 'successful') {
    // Ensure enrollment exists even if a previous run partially completed.
    await admin.from('elearning_enrollments').upsert(
      {
        module_id: payment.module_id,
        learner_id: payment.learner_id,
      },
      { onConflict: 'module_id,learner_id', ignoreDuplicates: true }
    );
    return { ok: true, type: 'module', alreadyProcessed: true };
  }

  const now = new Date().toISOString();

  const { error: updateError } = await admin
    .from('module_payments')
    .update({
      status: 'successful',
      flutterwave_transaction_id: String(verified.id),
      paid_at: now,
    })
    .eq('id', payment.id)
    .eq('status', 'pending');

  if (updateError) {
    return { ok: false, reason: updateError.message };
  }

  const { error: enrollError } = await admin
    .from('elearning_enrollments')
    .upsert(
      {
        module_id: payment.module_id,
        learner_id: payment.learner_id,
      },
      { onConflict: 'module_id,learner_id', ignoreDuplicates: true }
    );

  if (enrollError) {
    return { ok: false, reason: enrollError.message };
  }

  return { ok: true, type: 'module' };
}

async function fulfillSchoolSubscription(
  verified: FlutterwaveVerifyResult
): Promise<FulfillResult> {
  const admin = createAdminClient();

  const { data: sub, error } = await admin
    .from('school_subscriptions')
    .select('id, school_id, amount_rwf, status, period_end')
    .eq('flutterwave_tx_ref', verified.tx_ref)
    .maybeSingle();

  if (error || !sub) {
    return { ok: false, reason: 'school_subscriptions row not found' };
  }

  if (Number(verified.amount) < Number(sub.amount_rwf)) {
    return { ok: false, reason: 'verified amount below expected' };
  }

  if (sub.status === 'active') {
    return { ok: true, type: 'school', alreadyProcessed: true };
  }

  const now = new Date();
  // If renewing while still active, extend from current period_end.
  const { data: latestActive } = await admin
    .from('school_subscriptions')
    .select('period_end')
    .eq('school_id', sub.school_id)
    .eq('status', 'active')
    .order('period_end', { ascending: false })
    .limit(1)
    .maybeSingle();

  const base =
    latestActive?.period_end && new Date(latestActive.period_end) > now
      ? new Date(latestActive.period_end)
      : now;

  const periodStart = now.toISOString();
  const periodEnd = new Date(base.getTime() + ONE_YEAR_MS).toISOString();

  // Expire other active subscriptions for this school (keep history).
  await admin
    .from('school_subscriptions')
    .update({ status: 'expired' })
    .eq('school_id', sub.school_id)
    .eq('status', 'active')
    .neq('id', sub.id);

  const { error: updateError } = await admin
    .from('school_subscriptions')
    .update({
      status: 'active',
      period_start: periodStart,
      period_end: periodEnd,
      flutterwave_transaction_id: String(verified.id),
      paid_at: periodStart,
    })
    .eq('id', sub.id);

  if (updateError) {
    return { ok: false, reason: updateError.message };
  }

  return { ok: true, type: 'school' };
}
