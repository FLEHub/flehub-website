#!/usr/bin/env python3
"""SVG originaux B1 — style A1/A2, accents différents par module."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2] / "public" / "elearning"

SETS = {
    "mfk-b1-m1": ("#3A6B8C", [
        "criteres-quartier", "carte-rive-saules", "valise-lea", "clef-pavillon",
        "verbe-preposition", "lettre-polie", "souhait-conditionnel", "demande-aline",
        "place-adjectif", "banc-hypothese", "conseil-marc", "jardin-saule",
        "pronom-ou", "pronom-dont", "photo-arrivee", "souvenir-pont",
        "deux-rives", "balance-choix", "cahier-comparaison", "minibus-figuier",
        "lettre-restes", "enveloppe-patrick", "table-sources", "radio-figuier",
        "maison-vents", "bureau-escales", "nuage-ailleurs", "soleil-chez-soi",
        "figuier-racines", "horloge-depart",
    ]),
    "mfk-b1-m2": ("#8B5A2B", [
        "subjonctif-sentiment", "souci-quotidien", "voisin-bruit", "tasse-cassee",
        "infirmerie-herbes", "consequence-sante", "thermometre-hawa", "conseil-yvette",
        "formulaire-admin", "imperatif-pronoms", "discours-indirect", "tampon-bureau",
        "negation-gouts", "deux-facon-vivre", "marche-lampions", "panier-nuance",
        "rythme-jours", "horloge-habitude", "calendrier-changement", "banc-pause",
        "voisinage-tisser", "porte-ouverte", "cle-partage", "table-compromis",
        "pavillon-saule", "cahier-chemin", "affiche-regle", "oreille-plainte",
        "main-aide", "soleil-installe",
    ]),
    "mfk-b1-m3": ("#C4563A", [
        "sortie-proposee", "affiche-conseil", "mise-en-relief", "lanterne-invitation",
        "but-groupe", "pour-que", "ticket-veillee", "micro-convaincre",
        "coutume-famille", "pronoms-en-y", "opposition-concession", "danse-sources",
        "demonstratif-soiree", "indefini-chacun", "comportement-banc", "tasse-celui",
        "preparer-veillee", "liste-taches", "salle-herbes", "marche-lampions",
        "apres-fete", "remerciement", "photo-groupe", "balai-lendemain",
        "radio-figuier", "figuier-fete", "rose-tissu", "sami-tambour",
        "horloge-soir", "coeur-fete",
    ]),
    "mfk-b1-m4": ("#2F6B4A", [
        "compte-rendu", "indefinis-quantite", "reserve-adhesion", "cahier-racines",
        "participe-present", "debat-rive", "adverbe-ment", "intensite-trop",
        "projet-local", "but-subjonctif", "banderole-agir", "seau-eau",
        "eco-geste", "persuader-joel", "compost-cour", "arbre-proteger",
        "mesurer-impact", "graphique-riviere", "de-plus-en-plus", "loupe-chiffre",
        "convaincre-bureau", "lettre-solange", "tampon-projet", "main-signature",
        "riviere-propre", "figuier-ombre", "groupe-engagement", "micro-radio",
        "soleil-demain", "feuille-appel",
    ]),
    "mfk-b1-m5": ("#5C4A8A", [
        "lettre-motivation", "articulateur", "parcours-patrick", "cv-joel",
        "entretien-conseil", "porte-essai", "cravate-inventee", "notes-aline",
        "prise-risque", "experience-valoriser", "nuage-oser", "badge-stage",
        "gerondif-metier", "participe-present", "pronom-ou", "horloge-journee",
        "stage-radio", "casque-lea", "atelier-tissu", "micro-essai",
        "bilan-semaine", "cahier-notes", "tampon-ok", "table-sources-pro",
        "dieudonne-tissu", "lila-antenne", "main-poignee", "etoile-poste",
        "calendrier-stage", "porte-ouverte",
    ]),
    "mfk-b1-m6": ("#1A4A6A", [
        "source-info", "concession", "voix-passive", "deux-medias",
        "recit-journal", "faits-passes", "titre-une", "carnet-reporter",
        "fausse-info", "rumeur-marche", "loupe-verite", "tampon-verifie",
        "mise-en-evidence", "micro-public", "argumenter", "pupitre-marc",
        "journal-parle", "studio-radio", "horloge-antenne", "casque-hawa",
        "ethique-micro", "droit-reponse", "charte-figuier", "oreille-critique",
        "antenne-radio", "feuille-une", "carte-direct", "groupe-redaction",
        "nuage-rumeur", "soleil-fait",
    ]),
    "mfk-b1-m7": ("#B87333", [
        "relatif-compose", "jeune-talent", "presentation-inno", "lampe-figue",
        "expliquer-decouverte", "schema-simple", "filtre-herbes", "main-prototype",
        "progression-chrono", "opinion-concept", "dabord-ensuite", "cahier-argument",
        "doute-certitude", "futur-innovation", "balance-pour-contre", "nuage-si",
        "prototype-figuier", "atelier-lampe", "fils-solaire", "banc-test",
        "pitch-cour", "micro-lila", "affiche-pitch", "horloge-trois-minutes",
        "radio-figuier", "dieudonne-outil", "karim-idea", "feuille-brevet",
        "soleil-invention", "coeur-talent",
    ]),
    "mfk-b1-m8": ("#7A3B5C", [
        "superlatif-critique", "affiche-spectacle", "oeuvre-enthousiasme", "etoile-soir",
        "parcours-artiste", "tambour-sami", "scene-herbes", "billet-vivant",
        "double-pronom", "critique-reagir", "livre-commente", "micro-avis",
        "interrogation-lire", "importance-livres", "cahier-chemin", "lecteur-mado",
        "soiree-lecture", "lampe-page", "cercle-voix", "banc-livre",
        "saison-culturelle", "calendrier-voix", "tissu-scene", "danse-cour",
        "radio-culture", "couverture-conte", "masque-invente", "pupitre-aline",
        "figuier-theatre", "soleil-saison",
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
