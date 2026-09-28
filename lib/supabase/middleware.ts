import { createServerClient } from '@supabase/ssr';
import { NextResponse, type NextRequest } from 'next/server';
import { ACCOUNT_STATUS, isActiveAccountStatus } from '@/lib/account-status';
import { promoteProfileAfterEmailConfirmation } from '@/lib/ensure-profile';
import { createAdminClient } from '@/lib/supabase/admin';

function redirectWithCookies(url: URL, sessionResponse: NextResponse) {
  const redirectResponse = NextResponse.redirect(url);
  sessionResponse.cookies.getAll().forEach((cookie) => {
    redirectResponse.cookies.set(cookie);
  });
  return redirectResponse;
}

export async function updateSession(request: NextRequest) {
  let supabaseResponse = NextResponse.next({ request });

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll();
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) =>
            request.cookies.set(name, value)
          );
          supabaseResponse = NextResponse.next({ request });
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options)
          );
        },
      },
    }
  );

  const {
    data: { user },
  } = await supabase.auth.getUser();

  const { pathname } = request.nextUrl;
  const needsAccount =
    pathname.startsWith('/dashboard') || pathname.startsWith('/admin');

  if (user && (needsAccount || pathname === '/login' || pathname === '/register')) {
    const { data: profile } = await supabase
      .from('profiles')
      .select('role, status')
      .eq('id', user.id)
      .maybeSingle();

    let status = profile?.status ?? null;
    if (user.email_confirmed_at && status === ACCOUNT_STATUS.PENDING_EMAIL) {
      try {
        const admin = createAdminClient();
        const promoted = await promoteProfileAfterEmailConfirmation(
          admin,
          user.id,
          user.email_confirmed_at
        );
        if (promoted) status = ACCOUNT_STATUS.PENDING_ADMIN;
      } catch (err) {
        console.error('[middleware] promote after email confirmation', err);
      }
    }

    const active = Boolean(profile && isActiveAccountStatus(status));

    if (!active) {
      await supabase.auth.signOut();
      if (pathname === '/login' || pathname === '/register' || pathname.startsWith('/auth')) {
        return supabaseResponse;
      }
      const url = request.nextUrl.clone();
      url.pathname = '/login';
      url.search = '';
      url.searchParams.set('reason', status || 'inactive');
      return redirectWithCookies(url, supabaseResponse);
    }

    if (pathname.startsWith('/admin') && profile?.role !== 'admin') {
      const url = request.nextUrl.clone();
      url.pathname = '/dashboard';
      url.search = '';
      return redirectWithCookies(url, supabaseResponse);
    }

    if (pathname === '/login' || pathname === '/register') {
      const url = request.nextUrl.clone();
      url.pathname = '/dashboard';
      url.search = '';
      return redirectWithCookies(url, supabaseResponse);
    }
  }

  if (!user && needsAccount) {
    const url = request.nextUrl.clone();
    url.pathname = '/login';
    url.search = '';
    return NextResponse.redirect(url);
  }

  return supabaseResponse;
}
