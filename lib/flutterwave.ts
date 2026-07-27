const FLW_BASE = 'https://api.flutterwave.com/v3';

export { SCHOOL_ANNUAL_SUBSCRIPTION_RWF } from '@/lib/payments/constants';

export type FlutterwavePaymentInit = {
  tx_ref: string;
  amount: number;
  currency?: string;
  redirect_url: string;
  customer: {
    email: string;
    name: string;
    phonenumber?: string;
  };
  customizations?: {
    title?: string;
    description?: string;
    logo?: string;
  };
  meta?: Record<string, string | number | boolean | null>;
};

export type FlutterwaveVerifyResult = {
  id: number;
  tx_ref: string;
  flw_ref: string;
  amount: number;
  currency: string;
  charged_amount: number;
  status: string;
  payment_type?: string;
  customer?: {
    email?: string;
    name?: string;
    phone_number?: string;
  };
};

function getSecretKey(): string {
  const key = process.env.FLUTTERWAVE_SECRET_KEY;
  if (!key) {
    throw new Error('FLUTTERWAVE_SECRET_KEY is not configured');
  }
  return key;
}

export function getFlutterwaveSecretHash(): string | null {
  return process.env.FLUTTERWAVE_SECRET_HASH ?? null;
}

export function getAppBaseUrl(requestUrl?: string): string {
  if (process.env.NEXT_PUBLIC_APP_URL) {
    return process.env.NEXT_PUBLIC_APP_URL.replace(/\/$/, '');
  }
  if (process.env.VERCEL_URL) {
    return `https://${process.env.VERCEL_URL.replace(/\/$/, '')}`;
  }
  if (requestUrl) {
    try {
      return new URL(requestUrl).origin;
    } catch {
      // fall through
    }
  }
  return 'http://localhost:3000';
}

export function isModuleTxRef(txRef: string): boolean {
  return txRef.startsWith('module_');
}

export function isSchoolTxRef(txRef: string): boolean {
  return txRef.startsWith('school_');
}

export function makeModuleTxRef(moduleId: string): string {
  return `module_${moduleId}_${Date.now()}`;
}

export function makeSchoolTxRef(schoolId: string): string {
  return `school_${schoolId}_${Date.now()}`;
}

/**
 * Initiate Flutterwave Standard Checkout.
 * Returns the hosted checkout URL to redirect the customer to.
 */
export async function initiateFlutterwavePayment(
  payload: FlutterwavePaymentInit
): Promise<{ link: string }> {
  const res = await fetch(`${FLW_BASE}/payments`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${getSecretKey()}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      ...payload,
      currency: payload.currency ?? 'RWF',
    }),
  });

  const json = await res.json();

  if (!res.ok || json.status !== 'success' || !json.data?.link) {
    const message =
      json?.message ||
      json?.data?.message ||
      `Flutterwave payment initiation failed (${res.status})`;
    throw new Error(message);
  }

  return { link: json.data.link as string };
}

/**
 * Server-side transaction verification.
 * Always call this after a webhook or redirect before granting access.
 */
export async function verifyFlutterwaveTransaction(
  transactionId: string | number
): Promise<FlutterwaveVerifyResult> {
  const res = await fetch(`${FLW_BASE}/transactions/${transactionId}/verify`, {
    method: 'GET',
    headers: {
      Authorization: `Bearer ${getSecretKey()}`,
      'Content-Type': 'application/json',
    },
  });

  const json = await res.json();

  if (!res.ok || json.status !== 'success' || !json.data) {
    const message =
      json?.message || `Flutterwave verification failed (${res.status})`;
    throw new Error(message);
  }

  return json.data as FlutterwaveVerifyResult;
}

export function isWebhookSignatureValid(verifHash: string | null): boolean {
  const secret = getFlutterwaveSecretHash();
  if (!secret) return false;
  if (!verifHash) return false;
  return verifHash === secret;
}
