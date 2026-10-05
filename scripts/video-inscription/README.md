# Vidéo d'inscription MFK

Le script Playwright ouvre l'accueil, clique sur le bouton blanc **J’apprends le français**, passe par « Créer un compte gratuit », remplit le formulaire apprenant avec des données fictives, valide l'inscription et filme la page « Inscription envoyée ».

## Lancer l'enregistrement

```bash
npx playwright install chromium
npm run video:inscription
```

La vidéo est écrite dans `videos/inscription-mfk.webm` (1280×720).

Par défaut, le script démarre `next dev` sur `http://127.0.0.1:3000` s'il n'y a pas déjà un serveur, avec une URL Supabase locale fictive (`127.0.0.1:54321`). L'appel `POST /api/register` est intercepté dans le navigateur : **aucun compte n'est créé**, ni en production ni ailleurs.

Les données saisies sont fictives (`camille.martin.demo@example.com`). Le script refuse de tourner contre `mfkigali.com`.

## Inscription sur un environnement de test

Uniquement si le serveur pointe vers une **base de test** (jamais la production) :

```bash
VIDEO_BASE_URL=http://127.0.0.1:3000 VIDEO_LIVE_REGISTER=1 npm run video:inscription
```

Pour un hôte de test qui n'est pas localhost, ajoutez-le explicitement :

```bash
VIDEO_BASE_URL=https://staging.exemple.test VIDEO_TEST_HOSTS=staging.exemple.test VIDEO_LIVE_REGISTER=1 npm run video:inscription
```

## Convertir en MP4 avec ffmpeg

Le fichier Playwright est un WebM (VP8/VP9). Pour un MP4 lisible partout :

```bash
ffmpeg -i videos/inscription-mfk.webm -c:v libx264 -pix_fmt yuv420p -movflags +faststart videos/inscription-mfk.mp4
```

- `-c:v libx264` encode la vidéo en H.264.
- `-pix_fmt yuv420p` rend le fichier compatible avec la plupart des lecteurs.
- `-movflags +faststart` place les métadonnées en tête du fichier pour une lecture progressive.

S'il y a une piste audio à conserver, ajoutez `-c:a aac`. Cette capture n'a pas de son.
