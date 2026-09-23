import { publicSiteUrl } from '@/lib/site-url'

type AccountEmail =
  | { kind: 'activated'; to: string; fullName: string }
  | { kind: 'rejected'; to: string; fullName: string; reason?: string | null }

export type SendAccountEmailResult = {
  sent: boolean
  error?: string
}

function escapeHtml(value: string): string {
  return value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
}

function greeting(fullName: string): string {
  const name = fullName.trim()
  return name ? `Bonjour ${escapeHtml(name)},` : 'Bonjour,'
}

function messageFor(email: AccountEmail): { subject: string; html: string; text: string } {
  const loginUrl = `${publicSiteUrl()}/login`

  if (email.kind === 'activated') {
    const text =
      'Votre compte MFK est activé, vous pouvez vous connecter.\n' + loginUrl
    return {
      subject: 'Votre compte MFK est activé',
      text,
      html: layout(
        'Votre compte est activé',
        `${greeting(email.fullName)}
        <p style="margin:0 0 16px;font-size:15px;line-height:1.6;color:#4b5563;">
          Votre compte MFK est activé, vous pouvez vous connecter.
        </p>
        <p style="margin:0 0 8px;text-align:center;">
          <a href="${loginUrl}" style="display:inline-block;background:#1E5FA8;color:#ffffff;text-decoration:none;font-weight:700;font-size:15px;padding:12px 22px;border-radius:12px;">
            Se connecter
          </a>
        </p>`
      ),
    }
  }

  const reason = email.reason?.trim()
  const reasonHtml = reason
    ? `<p style="margin:0 0 16px;font-size:15px;line-height:1.6;color:#4b5563;"><strong>Motif :</strong> ${escapeHtml(reason)}</p>`
    : ''
  const reasonText = reason ? `\nMotif : ${reason}` : ''

  return {
    subject: "Votre inscription MFK n'a pas été acceptée",
    text: `Votre inscription à MFK n'a pas été acceptée.${reasonText}`,
    html: layout(
      'Inscription non acceptée',
      `${greeting(email.fullName)}
      <p style="margin:0 0 16px;font-size:15px;line-height:1.6;color:#4b5563;">
        Votre inscription à MFK n'a pas été acceptée.
      </p>
      ${reasonHtml}`
    ),
  }
}

function layout(title: string, body: string): string {
  return `<!DOCTYPE html>
<html lang="fr">
  <body style="margin:0;padding:0;background:#f4f7fb;font-family:Arial,Helvetica,sans-serif;color:#1f2937;">
    <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background:#f4f7fb;padding:32px 16px;">
      <tr>
        <td align="center">
          <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="max-width:520px;background:#ffffff;border-radius:16px;overflow:hidden;border:1px solid #e5e7eb;">
            <tr>
              <td style="background:#1E5FA8;padding:28px 32px;text-align:center;">
                <p style="margin:0;font-size:28px;font-weight:800;letter-spacing:0.04em;color:#ffffff;">MFK</p>
                <p style="margin:6px 0 0;font-size:13px;color:#dbeafe;">Maison de la Francophonie Kigali</p>
              </td>
            </tr>
            <tr>
              <td style="padding:32px;">
                <h1 style="margin:0 0 12px;font-size:22px;line-height:1.3;color:#111827;">${escapeHtml(title)}</h1>
                ${body}
              </td>
            </tr>
            <tr>
              <td style="padding:16px 32px 24px;border-top:1px solid #f3f4f6;">
                <p style="margin:0;font-size:12px;line-height:1.5;color:#9ca3af;text-align:center;">
                  Maison de la Francophonie Kigali · <a href="https://mfkigali.com" style="color:#1E5FA8;text-decoration:none;">mfkigali.com</a>
                </p>
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
  </body>
</html>`
}

/**
 * Sends the activation or refusal email.
 * Uses Resend when RESEND_API_KEY is set (ACCOUNT_EMAIL_FROM optional).
 */
export async function sendAccountEmail(email: AccountEmail): Promise<SendAccountEmailResult> {
  const apiKey = process.env.RESEND_API_KEY?.trim()
  const from = process.env.ACCOUNT_EMAIL_FROM?.trim() || 'MFK <noreply@mfkigali.com>'
  const message = messageFor(email)

  if (!apiKey) {
    console.error('[account-email] RESEND_API_KEY missing, email not sent', {
      kind: email.kind,
      to: email.to,
    })
    return { sent: false, error: 'Service e-mail non configuré (RESEND_API_KEY).' }
  }

  try {
    const res = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from,
        to: [email.to],
        subject: message.subject,
        html: message.html,
        text: message.text,
      }),
    })

    if (!res.ok) {
      const detail = await res.text()
      console.error('[account-email] resend failed', res.status, detail)
      return { sent: false, error: "L'e-mail n'a pas pu être envoyé." }
    }

    return { sent: true }
  } catch (err) {
    console.error('[account-email] resend request failed', err)
    return { sent: false, error: "L'e-mail n'a pas pu être envoyé." }
  }
}
