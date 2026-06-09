export const AUTH_RATE_LIMIT_MESSAGE =
  'Trop de tentatives, veuillez réessayer dans quelques minutes';

type AuthLikeError = {
  status?: number | string;
  code?: string;
  message?: string;
};

export function isAuthRateLimitError(error: AuthLikeError | null | undefined) {
  if (!error) return false;

  const status = Number(error.status);
  const code = error.code?.toLowerCase() ?? '';
  const message = error.message?.toLowerCase() ?? '';

  return (
    status === 429 ||
    code.includes('rate_limit') ||
    code.includes('too_many_requests') ||
    message.includes('rate limit') ||
    message.includes('too many requests') ||
    message.includes('over email send rate')
  );
}
