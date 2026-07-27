import { NextRequest, NextResponse } from 'next/server';
import {
  getAppBaseUrl,
  initiateFlutterwavePayment,
  makeModuleTxRef,
} from '@/lib/flutterwave';
import { createClient } from '@/lib/supabase/server';

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const moduleId = body?.moduleId as string | undefined;

    if (!moduleId) {
      return NextResponse.json({ error: 'moduleId is required' }, { status: 400 });
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

    const { data: mod } = await supabase
      .from('elearning_modules')
      .select('id, title, price_rwf, published')
      .eq('id', moduleId)
      .eq('published', true)
      .maybeSingle();

    if (!mod) {
      return NextResponse.json({ error: 'Module not found' }, { status: 404 });
    }

    const price = Number(mod.price_rwf ?? 0);
    if (price <= 0) {
      return NextResponse.json(
        { error: 'This module is free — use direct enrollment' },
        { status: 400 }
      );
    }

    const { data: existingEnrollment } = await supabase
      .from('elearning_enrollments')
      .select('id')
      .eq('module_id', moduleId)
      .eq('learner_id', learner.id)
      .maybeSingle();

    if (existingEnrollment) {
      return NextResponse.json({ error: 'Already enrolled' }, { status: 409 });
    }

    const { data: profile } = await supabase
      .from('profiles')
      .select('full_name, email, phone')
      .eq('id', user.id)
      .maybeSingle();

    const txRef = makeModuleTxRef(moduleId);

    const { error: insertError } = await supabase.from('module_payments').insert({
      module_id: moduleId,
      learner_id: learner.id,
      amount_rwf: price,
      status: 'pending',
      flutterwave_tx_ref: txRef,
    });

    if (insertError) {
      return NextResponse.json({ error: insertError.message }, { status: 500 });
    }

    const baseUrl = getAppBaseUrl(request.url);
    const redirectUrl = `${baseUrl}/dashboard/learner/elearning/payment-callback?tx_ref=${encodeURIComponent(txRef)}`;

    const { link } = await initiateFlutterwavePayment({
      tx_ref: txRef,
      amount: price,
      currency: 'RWF',
      redirect_url: redirectUrl,
      customer: {
        email: profile?.email || user.email || 'learner@flehub.rw',
        name: profile?.full_name || 'Learner',
        phonenumber: profile?.phone || undefined,
      },
      customizations: {
        title: 'FLEHub',
        description: `Module: ${mod.title}`,
      },
      meta: {
        payment_type: 'module',
        module_id: moduleId,
        learner_id: learner.id,
      },
    });

    return NextResponse.json({ checkout_url: link, tx_ref: txRef });
  } catch (err) {
    console.error('[module payment initiate]', err);
    return NextResponse.json(
      { error: err instanceof Error ? err.message : 'Payment initiation failed' },
      { status: 500 }
    );
  }
}
