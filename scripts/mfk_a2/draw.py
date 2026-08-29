#!/usr/bin/env python3
"""SVG originaux A2 — style A1, accents différents par module."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2] / "public" / "elearning"

SETS = {
    "mfk-a2-m1": ("#2F6FAE", [
        "comparatif-sejours", "valise-aline", "billet-escale", "carte-valpeupliers",
        "bureau-escales", "formulaire-y", "enveloppe-en", "affiche-demarche",
        "minibus-figuier", "sac-marc", "horaire-train", "plan-quai",
        "annonce-chambre", "cle-logement", "regle-colocation", "fenetre-cour",
        "maison-vents", "jardin-haut", "escalier-gauche", "banc-dessous",
        "panneau-qui", "fleche-que", "carnet-itineraire", "pont-riviere",
        "radio-figuier", "table-sources", "cahier-chemin", "horloge-depart",
        "nuage-pluie", "soleil-arrivee",
    ]),
    "mfk-a2-m2": ("#7A4E9A", [
        "recit-lea", "valise-ouverte", "photo-souvenir", "accord-etre",
        "affiche-regle", "panneau-interdit", "conseil-aline", "carnet-subjonctif",
        "cahier-emotions", "pluie-imparfait", "rire-pc", "banc-souvenir",
        "week-end-theme", "cest-qui", "cest-que", "tente-figuier",
        "carte-genre", "sac-masculin", "boussole-feminine", "liste-noms",
        "fil-parcours", "horloge-depuis", "calendrier-pendant", "fleche-dans",
        "groupe-amis", "feu-camp", "carte-mwezi", "journal-aventure",
        "chaussure-marche", "lampe-soir",
    ]),
    "mfk-a2-m3": ("#C4563A", [
        "offre-atelier", "cv-patrick", "qualite-equipe", "competence-accueil",
        "badge-presente", "articulateur", "micro-radio", "carte-visite",
        "service-propose", "horloge-adverbe", "panier-lentement", "clef-soigneusement",
        "carrefour-si", "deux-chemins", "choix-joel", "nuage-hypothese",
        "ligne-temps", "plus-que-parfait", "ancien-poste", "nouveau-badge",
        "question-formelle", "reponse-assurance", "liste-indefinis", "porte-entretien",
        "atelier-tissu", "table-sources-pro", "cahier-notes", "tampon-ok",
        "main-poignee", "etoile-qualite",
    ]),
    "mfk-a2-m4": ("#1E6B66", [
        "nuance-adverbe", "phrase-place", "fete-sources", "lanterne-soir",
        "ce-qui", "ce-que", "recit-evenement", "micro-temoin",
        "enquete-lequel", "quatre-affiches", "loupe-question", "carnet-enquete",
        "podium-superlatif", "etoile-meilleur", "avis-hawa", "tasse-plus",
        "inversion-question", "pupitre-aline", "point-interrogation", "salle-herbes",
        "souhait-conditionnel", "lettre-conseil", "nuage-si", "main-aide",
        "danse-cultures", "tissu-partage", "livre-conte", "radio-soir",
        "marche-lampions", "cour-fete",
    ]),
    "mfk-a2-m5": ("#B8860B", [
        "portrait-croise", "cest-relative", "deux-visages", "cadre-photo",
        "bulle-indirect", "oreille-dit", "cahier-on-dit", "radio-echo",
        "accord-ou", "desaccord-dont", "deux-avis", "table-debat",
        "main-avis", "carnet-opinion", "balance-pour", "balance-contre",
        "celui-celle", "fleche-demonstratif", "trois-choix", "panier-ceux",
        "horloge-en-train", "futur-proche", "passe-recent", "nuage-esprit",
        "cour-ensemble", "banc-voisins", "affiche-vivre", "cle-partage",
        "arbre-figuier", "porte-ouverte",
    ]),
    "mfk-a2-m6": ("#3D6B4F", [
        "verbe-cer", "verbe-ger", "verbe-yer", "tableau-conjug",
        "recette-felicie", "bol-essayer", "cuillere-reussir", "cahier-preposition",
        "mode-emploi", "si-imparfait", "quelqu-un", "boite-notice",
        "accord-avoir", "assiette-reussie", "tache-faite", "sourire-hawa",
        "pronoms-possessifs", "miroir-soin", "serviette-mienne", "brosse-tienne",
        "avant-de", "apres-inf", "fleche-suite", "horloge-actions",
        "marche-herbes", "panier-jour", "eau-soin", "plante-balcon",
        "tablier-cuisine", "liste-courses",
    ]),
    "mfk-a2-m7": ("#6B3A2A", [
        "recit-temps", "trois-temps", "cahier-memoire", "photo-ancienne",
        "souvenir-duree", "horloge-moment", "banc-longtemps", "lettre-passe",
        "suite-faits", "fleches-dates", "calendrier-marqueurs", "pont-temps",
        "cause-consequence", "affiche-cause", "main-defense", "arbre-proteger",
        "nature-agir", "preposition-a", "preposition-de", "seau-eau",
        "de-plus-en-plus", "de-moins-en-moins", "graphique-avis", "micro-opinion",
        "groupe-engagement", "banderole", "cahier-signatures", "figuier-racines",
        "riviere-propre", "soleil-memoire",
    ]),
    "mfk-a2-m8": ("#1A4A6A", [
        "voix-passive", "journal-fait", "micro-info", "titre-une",
        "nominalisation", "mots-noms", "cahier-info", "antenne-radio",
        "gerondif", "deux-actions", "velo-en-parlant", "main-reagir",
        "suggestion", "bulle-conditionnel", "carnet-proposer", "table-idees",
        "subjonctif-espoir", "monde-meilleur", "coeur-il-faut", "nuage-souhait",
        "livre-on", "pronom-on", "lecteur-marc", "couverture-conte",
        "studio-radio", "carte-direct", "horloge-journal", "feuille-une",
        "casque-lea", "fenetre-monde",
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


def main() -> None:
    for folder, (accent, names) in SETS.items():
        dest = ROOT / folder
        dest.mkdir(parents=True, exist_ok=True)
        for n in names:
            (dest / f"{n}.svg").write_text(svg(n, accent), encoding="utf-8")
        print(folder, len(names))


if __name__ == "__main__":
    main()
