/**
 * Enregistre une vidéo du parcours d'inscription MFK.
 *
 * Sécurité :
 * - refuse mfkigali.com (production) ;
 * - données fictives uniquement (domaine example.com) ;
 * - par défaut, POST /api/register est intercepté : aucun compte n'est écrit
 *   en base. Pour une vraie inscription, uniquement sur un serveur de test :
 *   VIDEO_LIVE_REGISTER=1 et VIDEO_BASE_URL pointant vers ce serveur.
 *
 * Prérequis : `npx playwright install chromium`
 * Lancement : `npm run video:inscription`
 * Le serveur local est démarré automatiquement s'il ne répond pas.
 */
import { spawn } from 'node:child_process'
import fs from 'node:fs/promises'
import path from 'node:path'
import { fileURLToPath } from 'node:url'
import { chromium } from 'playwright'

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..')
const VIDEO_PATH = path.join(ROOT, 'videos', 'inscription-mfk.webm')
const TMP_DIR = path.join(ROOT, 'videos', '.tmp')

const VIEWPORT = { width: 1280, height: 720 }
const SLOW_MO = 600
const STEP_PAUSE_MS = 2000

const PRODUCTION_HOSTS = new Set(['mfkigali.com', 'www.mfkigali.com'])

/** Compte fictif. example.com ne délivre pas de courrier (RFC 2606). */
const DEMO_ACCOUNT = {
  fullName: 'Camille Martin',
  email: 'camille.martin.demo@example.com',
  password: 'Demo-test-123',
  phone: '+250780000000',
  cefr: 'A1',
}

/** Clé anon publique des démos Supabase locales. Elle ne cible aucun projet. */
const LOCAL_DEMO_ANON_KEY =
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0'

function assertFakeAccount(account) {
  const reserved = account.email.endsWith('@example.com') || account.email.endsWith('@example.org')
  if (!reserved) {
    throw new Error(
      `Refus : l'adresse ${account.email} n'est pas fictive. Utilisez @example.com.`
    )
  }
}

function resolveTarget() {
  const baseUrl = (process.env.VIDEO_BASE_URL || 'http://127.0.0.1:3000').replace(/\/$/, '')
  let parsed
  try {
    parsed = new URL(baseUrl)
  } catch {
    throw new Error(`VIDEO_BASE_URL invalide : ${baseUrl}`)
  }

  const host = parsed.hostname.toLowerCase()
  if (PRODUCTION_HOSTS.has(host) || host.endsWith('.mfkigali.com')) {
    throw new Error(
      `Refus : ${baseUrl} est le site de production. Ce script ne doit jamais écrire dans la base de production.`
    )
  }

  const live = process.env.VIDEO_LIVE_REGISTER === '1'
  const local = host === 'localhost' || host === '127.0.0.1'
  const allowedTestHosts = (process.env.VIDEO_TEST_HOSTS || '')
    .split(',')
    .map((item) => item.trim().toLowerCase())
    .filter(Boolean)

  if (live && !local && !allowedTestHosts.includes(host)) {
    throw new Error(
      'Inscription réelle refusée. VIDEO_LIVE_REGISTER=1 est limité à localhost, 127.0.0.1 ou VIDEO_TEST_HOSTS (environnement de test, jamais la production).'
    )
  }

  return { baseUrl, live, local }
}

async function isServerUp(baseUrl) {
  try {
    const response = await fetch(baseUrl, { redirect: 'manual' })
    return response.status < 500
  } catch {
    return false
  }
}

async function waitForServer(baseUrl, timeoutMs) {
  const started = Date.now()
  while (Date.now() - started < timeoutMs) {
    if (await isServerUp(baseUrl)) return
    await new Promise((resolve) => setTimeout(resolve, 500))
  }
  throw new Error(`Le serveur de test ne répond pas sur ${baseUrl}.`)
}

function stopLocalServer(child) {
  if (!child?.pid) return
  try {
    process.kill(-child.pid, 'SIGTERM')
  } catch {
    child.kill('SIGTERM')
  }
}

function startLocalServer(baseUrl) {
  const port = new URL(baseUrl).port || '3000'
  const child = spawn('npx', ['next', 'dev', '-p', port, '-H', '127.0.0.1'], {
    cwd: ROOT,
    detached: true,
    env: {
      ...process.env,
      NODE_ENV: 'development',
      PORT: port,
      NEXT_PUBLIC_SITE_URL: baseUrl,
      // Ces valeurs locales empêchent Next de joindre un projet Supabase réel,
      // même si un .env.local de production est présent (process.env est prioritaire).
      NEXT_PUBLIC_SUPABASE_URL: 'http://127.0.0.1:54321',
      NEXT_PUBLIC_SUPABASE_ANON_KEY: LOCAL_DEMO_ANON_KEY,
      SUPABASE_SERVICE_ROLE_KEY: '',
    },
    stdio: ['ignore', 'pipe', 'pipe'],
  })

  child.stdout.on('data', (chunk) => process.stdout.write(chunk))
  child.stderr.on('data', (chunk) => process.stderr.write(chunk))
  return child
}

async function showBanner(page, text) {
  await page.evaluate((message) => {
    const id = 'mfk-video-banner'
    let banner = document.getElementById(id)
    if (!banner) {
      banner = document.createElement('div')
      banner.id = id
      banner.setAttribute('role', 'status')
      banner.style.cssText = [
        'position:fixed',
        'top:0',
        'left:0',
        'right:0',
        'z-index:2147483647',
        'background:#FDE047',
        'color:#1c1917',
        'font:700 22px/1.35 ui-sans-serif,system-ui,sans-serif',
        'text-align:center',
        'padding:16px 28px',
        'box-shadow:0 4px 14px rgba(0,0,0,.18)',
        'pointer-events:none',
      ].join(';')
      document.documentElement.appendChild(banner)
      document.body.style.paddingTop = '76px'
    }
    banner.textContent = message
  }, text)
}

async function highlight(locator) {
  await locator.scrollIntoViewIfNeeded()
  await locator.evaluate((element) => {
    element.style.outline = '4px solid #CA8A04'
    element.style.outlineOffset = '4px'
    element.style.boxShadow = '0 0 0 8px rgba(250, 204, 21, 0.55)'
    element.style.transition = 'box-shadow 150ms ease'
  })
}

async function step(page, label, action) {
  await showBanner(page, label)
  await action()
  await showBanner(page, label)
  await page.waitForTimeout(STEP_PAUSE_MS)
}

async function fillField(page, locator, value, label) {
  await step(page, label, async () => {
    await highlight(locator)
    await locator.click()
    await locator.fill('')
    await locator.pressSequentially(value, { delay: 35 })
  })
}

async function installDemoGuard(page, { live }) {
  await page.route('**/*', async (route) => {
    const requestUrl = route.request().url()
    let host = ''
    try {
      host = new URL(requestUrl).hostname.toLowerCase()
    } catch {
      await route.continue()
      return
    }

    if (PRODUCTION_HOSTS.has(host) || host.endsWith('.mfkigali.com')) {
      await route.abort('blockedbyclient')
      return
    }

    const isRegister = new URL(requestUrl).pathname === '/api/register'
    if (isRegister && route.request().method() === 'POST' && !live) {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          ok: true,
          emailConfirmationRequired: true,
          demo: true,
        }),
      })
      return
    }

    await route.continue()
  })
}

async function record(baseUrl, { live }) {
  assertFakeAccount(DEMO_ACCOUNT)
  await fs.mkdir(TMP_DIR, { recursive: true })

  const browser = await chromium.launch({
    headless: true,
    slowMo: SLOW_MO,
  })

  const context = await browser.newContext({
    viewport: VIEWPORT,
    locale: 'fr-FR',
    recordVideo: {
      dir: TMP_DIR,
      size: VIEWPORT,
    },
  })

  const page = await context.newPage()
  page.setDefaultTimeout(30_000)
  await installDemoGuard(page, { live })

  try {
    await page.goto(baseUrl, { waitUntil: 'domcontentloaded' })

    const learnFrench = page.getByTestId('learn-french')
    await step(page, 'Étape 1 : Cliquez sur J’apprends le français', async () => {
      await highlight(learnFrench)
      await learnFrench.click()
      await page.waitForURL('**/register')
    })

    const learnerRole = page.getByRole('button', { name: /Apprenant/ })
    await step(page, 'Étape 2 : Choisissez le rôle Apprenant', async () => {
      await highlight(learnerRole)
      await learnerRole.click()
    })

    const continueButton = page.getByRole('button', { name: 'Continuer' })
    await step(page, 'Étape 3 : Continuer vers le formulaire', async () => {
      await highlight(continueButton)
      await continueButton.click()
      await page.getByLabel(/Nom complet/).waitFor()
    })

    await fillField(
      page,
      page.getByLabel(/Nom complet/),
      DEMO_ACCOUNT.fullName,
      'Étape 4 : Remplissez le nom complet'
    )
    await fillField(
      page,
      page.getByLabel(/Adresse e-mail/),
      DEMO_ACCOUNT.email,
      'Étape 5 : Remplissez l’adresse e-mail'
    )
    await fillField(
      page,
      page.locator('#password'),
      DEMO_ACCOUNT.password,
      'Étape 6 : Choisissez un mot de passe fictif'
    )
    await fillField(
      page,
      page.locator('#confirm_password'),
      DEMO_ACCOUNT.password,
      'Étape 7 : Confirmez le mot de passe'
    )
    await fillField(
      page,
      page.getByLabel(/Téléphone/),
      DEMO_ACCOUNT.phone,
      'Étape 8 : Remplissez le téléphone'
    )

    const independent = page.getByRole('button', { name: /Indépendant/ })
    await step(page, 'Étape 9 : Choisissez le type d’apprenant', async () => {
      await highlight(independent)
      await independent.click()
    })

    const level = page.locator('#cefr_level')
    await step(page, 'Étape 10 : Choisissez le niveau CECRL', async () => {
      await highlight(level)
      await level.selectOption(DEMO_ACCOUNT.cefr)
    })

    const submit = page.getByRole('button', { name: 'Créer mon compte' })
    await step(page, 'Étape 11 : Validez l’inscription', async () => {
      await highlight(submit)
      await submit.click()
      await page.getByRole('heading', { name: 'Inscription envoyée' }).waitFor()
    })

    await step(page, 'Étape 12 : Inscription confirmée', async () => {
      await page.getByRole('heading', { name: 'Inscription envoyée' }).scrollIntoViewIfNeeded()
    })
  } finally {
    const video = page.video()
    await context.close()
    await browser.close()
    if (video) {
      const recorded = await video.path()
      await fs.mkdir(path.dirname(VIDEO_PATH), { recursive: true })
      await fs.copyFile(recorded, VIDEO_PATH)
      await fs.rm(TMP_DIR, { recursive: true, force: true })
    }
  }
}

async function main() {
  const target = resolveTarget()
  console.log(
    target.live
      ? `Mode test réel : inscription envoyée à ${target.baseUrl} (hôte autorisé, hors production).`
      : `Mode démo : ${target.baseUrl}. L'inscription est simulée, aucune base n'est contactée.`
  )

  let child = null
  const alreadyUp = await isServerUp(target.baseUrl)
  if (!alreadyUp) {
    if (!target.local) {
      throw new Error(
        `Aucun serveur sur ${target.baseUrl}. Démarrez l'environnement de test, puis relancez le script.`
      )
    }
    console.log('Démarrage du serveur local de démonstration (Supabase local fictif, pas la production)…')
    child = startLocalServer(target.baseUrl)
    try {
      await waitForServer(target.baseUrl, 90_000)
    } catch (error) {
      stopLocalServer(child)
      throw error
    }
  }

  try {
    await record(target.baseUrl, target)
    console.log(`Vidéo enregistrée : ${VIDEO_PATH}`)
    console.log(
      'Conversion MP4 : ffmpeg -i videos/inscription-mfk.webm -c:v libx264 -pix_fmt yuv420p -movflags +faststart videos/inscription-mfk.mp4'
    )
  } finally {
    stopLocalServer(child)
  }
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error)
  process.exit(1)
})
