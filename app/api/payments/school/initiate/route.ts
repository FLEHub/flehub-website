import { NextRequest, NextResponse } from 'next/server';
import {
  getAppBaseUrl,
  initiateFlutterwavePayment,
  makeSchoolTxRef,
} from '@/lib/flutterwave';
import { SCHOOL_ANNUAL_SUBSCRIPTION_RWF } from '@/lib/payments/constants';
import { createClient } from '@/lib/supabase/server';

export async function POST(request: NextRequest) {
  try {
    const supabase = await createClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();

    if (!user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }

    const { data: school } = await supabase
      .from('schools')
      .select('id, school_name')
      .eq('profile_id', user.id)
      .maybeSingle();

    if (!school) {
      return NextResponse.json({ error: 'School profile not found' }, { status: 403 });
    }

    let amount = SCHOOL_ANNUAL_SUBSCRIPTION_RWF;
    try {
      const body = await request.json();
      if (body?.amount_rwf != null) {
        const parsed = Number(body.amount_rwf);
        if (Number.isFinite(parsed) && parsed > 0) {
          amount = parsed;
        }
      }
    } catch {
      // empty body is fine
    }

    const { data: profile } = await supabase
      .from('profiles')
      .select('full_name, email, phone')
      .eq('id', user.id)
      .maybeSingle();

    const txRef = makeSchoolTxRef(school.id);

    const { error: insertError } = await supabase.from('school_subscriptions').insert({
      school_id: school.id,
      amount_rwf: amount,
      status: 'pending',
      flutterwave_tx_ref: txRef,
    });

    if (insertError) {
      return NextResponse.json({ error: insertError.message }, { status: 500 });
    }

    const baseUrl = getAppBaseUrl(request.url);
    const redirectUrl = `${baseUrl}/dashboard/school/subscription?tx_ref=${encodeURIComponent(txRef)}`;

    const { link } = await initiateFlutterwavePayment({
      tx_ref: txRef,
      amount,
      currency: 'RWF',
      redirect_url: redirectUrl,
      customer: {
        email: profile?.email || user.email || 'school@flehub.rw',
        name: profile?.full_name || school.school_name || 'School',
        phonenumber: profile?.phone || undefined,
      },
      customizations: {
        title: 'FLEHub',
        description: `Abonnement annuel — ${school.school_name}`,
      },
      meta: {
        payment_type: 'school_subscription',
        school_id: school.id,
      },
    });

    return NextResponse.json({ checkout_url: link, tx_ref: txRef });
  } catch (err) {
    console.error('[school payment initiate]', err);
    return NextResponse.json(
      { error: err instanceof Error ? err.message : 'Payment initiation failed' },
      { status: 500 }
    );
  }
}
