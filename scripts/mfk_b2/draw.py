#!/usr/bin/env python3
"""SVG originaux B2 — style A1/A2/B1, accents différents par module."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2] / "public" / "elearning"

SETS = {
    "mfk-b2-m1": ("#4A6B8C", [
        "mode-apparence", "participe-present", "adjectif-verbal", "tissu-tendance",
        "assiette-futur", "consommation", "marche-herbes", "horloge-anterieur",
        "vacances-seuil", "opposition", "concession", "valise-commentaire",
        "conjonction-temps", "texte-explicatif", "fleche-quand", "cahier-analyse",
        "debat-tendances", "table-figuier", "micro-chronique", "radio-figuier",
        "rose-couture", "felicie-bol", "lanterne-soir", "banc-avis",
        "graphique-mode", "nuage-habitude", "soleil-saison", "feuille-edito",
        "balance-pour-contre", "coeur-seuil",
    ]),
    "mfk-b2-m2": ("#6B3A2A", [
        "hypothese-passe", "si-pqp", "conditionnel-passe", "photo-ancienne",
        "metier-evolution", "societe-change", "atelier-avant", "ligne-temps",
        "passe-simple", "lieu-enfance", "preposition-lieu", "banc-souvenir",
        "raconter-histoire", "trois-voix", "cahier-chemin", "archives-figuier",
        "table-ronde", "micro-memoire", "lettre-grand-mere", "pont-hier",
        "figuier-racines", "radio-echo", "carte-rukiri", "horloge-jadis",
        "groupe-anciens", "sami-recit", "mado-plume", "soleil-memoire",
        "nuage-si", "feuille-archive",
    ]),
    "mfk-b2-m3": ("#7A3B5C", [
        "comparatif-oeuvre", "superlatif-avis", "resume-piece", "etoile-saison",
        "portrait-relatif", "debat-culture", "pupitre-aline", "cadre-personnage",
        "mise-en-relief", "probleme-culturel", "solution-cour", "scene-herbes",
        "pronoms-en-y", "registre-familier", "processus-creation", "tissu-rose",
        "manifeste-seuil", "bilan-voix", "livre-mado", "tambour-sami",
        "masque-invente", "micro-avis", "cahier-critique", "danse-cour",
        "radio-culture", "figuier-theatre", "calendrier-voix", "soleil-oeuvre",
        "balance-gouts", "coeur-commun",
    ]),
    "mfk-b2-m4": ("#1A4A6A", [
        "actu-tech", "inversion-question", "prefixe-negatif", "lampe-figue",
        "duree-evolution", "reseau-fil", "horloge-depuis", "graphique-usage",
        "prefixe-re", "cause-consequence", "memoire-nuage", "antenne-radio",
        "connecteur-raison", "deconnexion", "charte-numerique", "interrupteur",
        "debat-fil", "casque-lea", "studio-radio", "filtre-herbes",
        "telephone-invente", "main-ecran", "banc-sans-fil", "oreille-silence",
        "feuille-charte", "nuage-alerte", "soleil-pause", "groupe-debat",
        "micro-lila", "porte-fermee",
    ]),
    "mfk-b2-m5": ("#8B5A2B", [
        "voix-passive", "enjeu-societe", "banderole-rive", "titre-une",
        "subjonctif-opinion", "prise-position", "micro-debat", "balance-avis",
        "fait-politique", "fait-culturel", "urne-inventee", "salle-herbes",
        "alternative-subj", "comparaison-nuance", "enquete-rukiri", "loupe-fait",
        "editorial-racines", "cahier-racines", "plume-marc", "tampon-cour",
        "riviere-enjeu", "figuier-agora", "groupe-citoyens", "affiche-societe",
        "radio-soir", "nuage-doute", "soleil-position", "main-vote",
        "feuille-edito", "oreille-nuance",
    ]),
    "mfk-b2-m6": ("#2F6B4A", [
        "bilan-condition", "si-imparfait", "assemblee-figuier", "graphique-bilan",
        "conditionnel-conseil", "regret-passe", "recommandation", "main-conscience",
        "action-citoyenne", "indefinis", "petition-solange", "seau-commun",
        "locution-prep", "accord-cod", "denoncer", "solution-rive",
        "motion-bureau", "tampon-motion", "lettre-officielle", "porte-escales",
        "compost-cour", "arbre-proteger", "groupe-agir", "micro-appel",
        "banderole-demain", "cahier-signatures", "soleil-agir", "nuage-si",
        "feuille-motion", "coeur-citoyen",
    ]),
    "mfk-b2-m7": ("#5C4A8A", [
        "discours-indirect", "parcours-pro", "choix-vie", "cv-croise",
        "competence-pro", "badge-savoir", "atelier-tissu", "antenne-stage",
        "double-pronom", "figure-style", "reunion-cour", "carnet-pro",
        "nuance-avis", "metier-argument", "charte-travail", "table-sources-pro",
        "entretien-croise", "porte-essai", "dieudonne-outil", "casque-joel",
        "main-poignee", "horloge-poste", "feuille-charte", "etoile-competence",
        "radio-travail", "nuage-choix", "soleil-equipe", "groupe-collegues",
        "tampon-ok", "balance-pratique",
    ]),
    "mfk-b2-m8": ("#3D6B4F", [
        "objectif-relatif", "subjonctif-opinion", "atelier-aline", "cahier-eleve",
        "expliquer-resultat", "graphique-notes", "commentaire", "loupe-chiffre",
        "diplome-probabilite", "subjonctif-probable", "question-utilite", "tampon-diplome",
        "initiative-educ", "negation-ni", "difference-modele", "deux-ecoles",
        "bilan-pedago", "projet-cour", "banc-lecon", "livre-ouvert",
        "radio-classe", "groupe-apprenants", "pupitre-aline", "soleil-apprendre",
        "nuage-doute", "feuille-projet", "figuier-ecole", "main-craie",
        "horloge-cours", "coeur-transmission",
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
