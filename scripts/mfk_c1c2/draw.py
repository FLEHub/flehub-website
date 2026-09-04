#!/usr/bin/env python3
"""SVG originaux C1–C2 — même style géométrique que B2, accents par module."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2] / "public" / "elearning"

SETS = {
    "mfk-c1-m1": ("#3A5F7A", [
        "urbanisme-colline", "densite-jardins", "mixite-rive", "friche-figuier",
        "logement-partage", "cle-pavillon", "cour-fermee", "lit-commun",
        "mobilite-douce", "trottoir-herbe", "camion-pente", "relais-lanterne",
        "ville-fantastique", "plan-2040", "tour-ombre", "riviere-inventee",
        "recommandation-banc", "motion-colline", "carte-rukiri", "assemblee-demain",
        "compte-rendu", "deux-documents", "micro-lila", "cahier-racines",
        "parking-refuse", "saule-abri", "escalier-pente", "toit-partage",
        "horizon-ocre", "coeur-seuil",
    ]),
    "mfk-c1-m2": ("#7A4A2A", [
        "faim-emotion", "bol-felicie", "carte-mentale", "plaisir-minuscule",
        "ration-chiffre", "graphique-sante", "rapport-etude", "balance-sel",
        "jardinier-rive", "colere-marche", "file-herbes", "prix-juste",
        "application-fil", "conseil-achat", "etiquette-lampe", "panier-nuance",
        "debat-pub", "slogan-doux", "micro-gout", "affiche-gout",
        "recueil-plaisirs", "feuille-goutee", "banc-figuier", "the-saule",
        "statistique-cour", "nuage-faim", "soleil-marche", "main-terre",
        "radio-ration", "coeur-table",
    ]),
    "mfk-c1-m3": ("#5A3A6A", [
        "cahier-dons", "parcours-infirmerie", "attente-longue", "consentement-clair",
        "enquete-herbes", "decouverte-filtre", "miniconference", "graphique-peur",
        "formation-longue", "journal-intime", "garde-nuit", "blouse-inventee",
        "therapie-rive", "debat-naturel", "infusion-solange", "cabinet-ombre",
        "podcast-parcours", "studio-sante", "oreille-doute", "voix-hawa",
        "progres-crainte", "loupe-science", "main-soin", "banc-attente",
        "radio-don", "feuille-loi-inventee", "soleil-guerir", "nuage-fatigue",
        "porte-infirmerie", "coeur-soin",
    ]),
    "mfk-c1-m4": ("#6A2A4A", [
        "image-de-soi", "miroir-cour", "fil-portrait", "regard-croise",
        "visible-invisible", "rampe-herbes", "manifeste-seuil", "chaise-acces",
        "langage-corps", "geste-silence", "idiome-main", "epaule-dite",
        "oeuvre-animee", "audioguide-rose", "toile-ocre", "atelier-corps",
        "tendance-commentee", "blog-invente", "micro-corps", "balance-norme",
        "slam-banc", "voix-lea", "tambour-sami", "ombre-danse",
        "cadre-portrait", "soleil-peau", "nuage-regard", "feuille-manifeste",
        "radio-geste", "coeur-visible",
    ]),
    "mfk-c1-m5": ("#2A4A5A", [
        "chant-cour", "verlan-doux", "clip-invente", "message-chanson",
        "biographie-engagee", "discours-solange", "necrologie-douce", "portrait-voix",
        "terre-accueil", "poeme-rive", "chronique-humor", "valise-ouverte",
        "ages-vie", "deux-generations", "registre-soutenu", "banc-anciens",
        "comparaison-ages", "sketch-sami", "micro-monde", "cahier-combats",
        "feminisme-cour", "main-egale", "affiche-accueil", "lampe-veille",
        "radio-ages", "soleil-lutte", "nuage-frontiere", "feuille-poeme",
        "groupe-voix", "coeur-monde",
    ]),
    "mfk-c1-m6": ("#3A5A3A", [
        "revue-presse", "organisation-atelier", "bienveillance-poste", "horloge-poste",
        "accroche-offre", "entretien-joel", "cv-croise", "porte-essai",
        "conflit-atelier", "discours-rapporte", "crise-travail", "table-froide",
        "eldorado-invente", "temoignage-expat", "habitude-pro", "valise-contrat",
        "analyse-travail", "cahier-temoins", "micro-emploi", "balance-salaire",
        "motion-bureau", "tampon-offre", "equipe-rive", "casque-joel",
        "radio-travail", "soleil-poste", "nuage-crise", "feuille-revue",
        "main-poignee", "coeur-atelier",
    ]),
    "mfk-c2-m1": ("#4A3A6A", [
        "extrait-theatre", "critique-film", "sentiment-fin", "scene-ombres",
        "routinite", "bonheur-usine", "interview-doute", "sourire-mesure",
        "mediation-animale", "lettre-chien", "justice-douce", "banc-bete",
        "utopie-rive", "contrainte-reve", "conte-philo", "carte-ailleurs",
        "point-de-vue", "ironie-fine", "micro-bonheur", "cahier-utopie",
        "salle-herbes-soir", "masque-invente", "lampe-scene", "plume-mado",
        "radio-ame", "soleil-reve", "nuage-ennui", "feuille-lettre",
        "groupe-spectateurs", "coeur-utopie",
    ]),
    "mfk-c2-m2": ("#5A3A2A", [
        "emprunt-langue", "reine-refusee", "article-representation", "mot-voyageur",
        "lettre-ouverte", "politique-linguistique", "francophonies", "carte-voix",
        "langage-social", "deux-extraits", "registre-classe", "choisir-mot",
        "voix-haute", "concours-eloquence", "pupitre-aline", "souffle-phrase",
        "oral-rapport", "essai-dire", "micro-langue", "cahier-emprunts",
        "banc-verbes", "oreille-accent", "soleil-parler", "nuage-norme",
        "radio-francais", "feuille-ouverte", "groupe-orateurs", "balance-mots",
        "porte-voix", "coeur-langue",
    ]),
    "mfk-c2-m3": ("#1A3A4A", [
        "librairie-immense", "fil-litteraire", "debat-reseau", "resume-court",
        "campagne-prevention", "public-cible", "conseil-adapte", "affiche-gaffe",
        "torrent-infos", "paradoxe-article", "bruit-vrai", "loupe-source",
        "dystopie-demain", "machine-voix", "extrait-noir", "antenne-muette",
        "accord-concession", "desaccord-fin", "micro-fil", "cahier-alerte",
        "lampe-figue-fil", "interrupteur-doux", "soleil-ecran", "nuage-fausse",
        "radio-fil", "feuille-paradoxe", "groupe-debat", "balance-preuve",
        "porte-silence", "coeur-vigilance",
    ]),
    "mfk-c2-m4": ("#4A4A2A", [
        "tableau-pedago", "essai-support", "raisonnement-deductif", "craie-memoire",
        "editorial-accords", "plan-chrono", "assemblee-rive", "carte-pactes",
        "souvenons-nous", "discours-officiel", "chronique-guerre", "veillee-noms",
        "plaidoirie-cour", "contexte-opinion", "plan-avocat", "balance-justice",
        "histoire-memoire", "cahier-racines-vieux", "micro-hier", "urne-parole",
        "figuier-archive", "soleil-deuil", "nuage-oubli", "feuille-plaidoirie",
        "radio-memoire", "groupe-anciens-soir", "main-craie", "porte-archives",
        "lampe-veillee", "coeur-souvenir",
    ]),
    "mfk-c2-m5": ("#3A4A5A", [
        "culture-partagee", "acces-salle", "article-implicite", "billet-doux",
        "frontieres-rire", "scene-comique", "humour-seuil", "masque-rire",
        "porteurs-identite", "debat-emprunt", "tendance-peau", "tissu-signe",
        "recit-interculturel", "difference-fine", "passe-detaille", "valise-langue",
        "position-implicite", "initiative-cour", "micro-cultures", "cahier-croise",
        "pavillon-fete", "soleil-partage", "nuage-quiproquo", "feuille-debat",
        "radio-rire", "groupe-invites", "main-tissu", "porte-fete",
        "lampe-accueil", "coeur-croise",
    ]),
    "mfk-c2-m6": ("#2A5A3A", [
        "rapport-alarmant", "biodiversite-rive", "hypothese-climat", "graphique-crue",
        "consensus-argument", "reponse-doute", "article-preuve", "loupe-chiffre",
        "mesures-politiques", "programme-rive", "conference-eau", "urne-vert",
        "echos-logiques", "personnage-roman", "geste-quotidien", "mode-ethique",
        "compte-rendu-climat", "alternative-rurale", "micro-rive", "cahier-crue",
        "saule-racine", "soleil-secheresse", "nuage-crue", "feuille-programme",
        "radio-climat", "groupe-rive", "main-terre-humide", "porte-jardin",
        "lampe-veille-eau", "coeur-rive",
    ]),
}


def svg(name: str, accent: str) -> str:
    h = abs(hash(name))
    a = 18 + (h % 10)
    b = 28 + ((h >> 4) % 12)
    c = 40 + ((h >> 8) % 16)
    return f"""<svg xmlns="http://www.w3.org/2000/svg" width="320" height="200" viewBox="0 0 320 200">
  <rect width="320" height="200" rx="16" fill="#F7EFE4"/>
  <rect x="10" y="10" width="300" height="180" rx="12" fill="#FFF8F0" stroke="{accent}" stroke-width="3"/>
  <circle cx="{70 + a}" cy="{70 + (h % 20)}" r="{22 + (h % 8)}" fill="{accent}" opacity="0.88"/>
  <rect x="{150 + (h % 30)}" y="{50 + (h % 25)}" width="{70 + b}" height="{48 + c // 2}" rx="10" fill="#1E6B66" opacity="0.82"/>
  <polygon points="{40 + a},{160} {90 + a},{110 + (h % 15)} {140 + a},{160}" fill="#C4563A" opacity="0.75"/>
  <text x="160" y="188" text-anchor="middle" font-family="Georgia, serif" font-size="11" fill="#5C4033">{name.replace("-", " ")}</text>
</svg>
"""


def ensure_svgs(folder: str | None = None) -> None:
    items = SETS.items() if folder is None else [(folder, SETS[folder])]
    for name, (accent, names) in items:
        dest = ROOT / name
        dest.mkdir(parents=True, exist_ok=True)
        if len(names) != 30 or len(set(names)) != 30:
            raise ValueError(f"{name}: need 30 unique SVG names")
        for n in names:
            (dest / f"{n}.svg").write_text(svg(n, accent), encoding="utf-8")


def main() -> None:
    ensure_svgs()
    for folder, (_accent, names) in SETS.items():
        print(folder, len(names))


if __name__ == "__main__":
    main()
