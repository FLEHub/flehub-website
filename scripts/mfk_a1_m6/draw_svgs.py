#!/usr/bin/env python3
"""Original MFK Module 6 illustrations — story-notebook style (plum + terracotta + teal)."""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "public/elearning/mfk-a1-m6"

PAPER = "#F6E6DC"
SKY = "#E8D5C8"
SAND = "#E8C99A"
TEAL = "#1E6B66"
TEAL_D = "#134E4A"
CLAY = "#C4563A"
CLAY_D = "#8E3B2A"
ROSE = "#C46B6B"
SAGE = "#7FA47A"
INK = "#3A2718"
CREAM = "#FFF6EE"
OCHRE = "#D9A441"
SKIN = "#E8B888"
SKIN_D = "#C48A5A"
WOOD = "#8B5A2B"
PLUM = "#6B4C7A"
PLUM_D = "#4A3456"
NIGHT = "#3D4F6A"


def frame(aria: str, body: str, label: str) -> str:
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200" role="img" aria-label="{aria}">
  <rect width="200" height="200" rx="24" fill="{PAPER}"/>
  <rect x="9" y="9" width="182" height="182" rx="18" fill="none" stroke="{PLUM}" stroke-width="1.8" opacity="0.7"/>
  <path d="M28 22 v28" stroke="{PLUM}" stroke-width="8" stroke-linecap="round"/>
  <rect x="24" y="18" width="16" height="22" rx="2" fill="{OCHRE}"/>
  <ellipse cx="100" cy="90" rx="70" ry="50" fill="{SKY}" opacity="0.45"/>
  <ellipse cx="100" cy="166" rx="74" ry="13" fill="{SAND}"/>
{body}
  <text x="100" y="188" text-anchor="middle" font-family="Georgia,serif" font-size="13" font-weight="700" fill="{INK}">{label}</text>
</svg>
'''


SCENES = {
    "cahier.svg": (
        "un cahier",
        "un cahier",
        f'''  <rect x="52" y="48" width="96" height="112" rx="6" fill="{WOOD}"/>
  <rect x="64" y="54" width="78" height="100" rx="3" fill="{CREAM}"/>
  <path d="M76 78 h54M76 94 h48M76 110 h52" stroke="{PLUM}" stroke-width="3"/>
  <path d="M52 48 v112" stroke="{OCHRE}" stroke-width="6"/>
''',
    ),
    "hier.svg": (
        "hier",
        "hier",
        f'''  <circle cx="86" cy="96" r="32" fill="{NIGHT}" opacity="0.85"/>
  <circle cx="124" cy="88" r="26" fill="{OCHRE}" opacity="0.7"/>
  <path d="M54 96 H78" stroke="{CREAM}" stroke-width="4" stroke-linecap="round"/>
  <path d="M54 96 l12-10M54 96 l12 10" stroke="{CREAM}" stroke-width="4" stroke-linecap="round"/>
''',
    ),
    "apprendre.svg": (
        "apprendre",
        "apprendre",
        f'''  <circle cx="78" cy="72" r="14" fill="{SKIN}"/>
  <path d="M62 148c4-40 10-52 16-52s12 12 16 52" fill="{TEAL}"/>
  <path d="M94 90 L118 78" stroke="{INK}" stroke-width="5" stroke-linecap="round"/>
  <rect x="114" y="70" width="40" height="52" rx="4" fill="{CLAY}"/>
  <path d="M134 70 v52" stroke="{CREAM}" stroke-width="3"/>
''',
    ),
    "ecrire.svg": (
        "écrire",
        "écrire",
        f'''  <rect x="46" y="70" width="88" height="64" rx="4" fill="{CREAM}" stroke="{INK}" stroke-width="3"/>
  <path d="M60 92 h50M60 108 h38" stroke="{PLUM}" stroke-width="3"/>
  <path d="M128 128 L168 64" stroke="{CLAY}" stroke-width="8" stroke-linecap="round"/>
  <path d="M164 58 l12 8 -8 12" fill="{OCHRE}"/>
''',
    ),
    "lire.svg": (
        "lire",
        "lire",
        f'''  <path d="M48 62h48v80H48a10 10 0 0 1-10-10V72a10 10 0 0 1 10-10z" fill="{TEAL}"/>
  <path d="M104 62h48a10 10 0 0 1 10 10v60a10 10 0 0 1-10 10h-48z" fill="{TEAL_D}"/>
  <path d="M100 62v80" stroke="{CREAM}" stroke-width="3"/>
  <path d="M62 86h22M62 102h18M116 86h22" stroke="{OCHRE}" stroke-width="2"/>
''',
    ),
    "talent.svg": (
        "un talent",
        "un talent",
        f'''  <path d="M100 48 L112 84 H150 L120 106 L132 144 L100 122 L68 144 L80 106 L50 84 H88z" fill="{OCHRE}"/>
  <circle cx="100" cy="100" r="10" fill="{CREAM}"/>
''',
    ),
    "tambour.svg": (
        "un tambour",
        "un tambour",
        f'''  <ellipse cx="100" cy="78" rx="46" ry="16" fill="{CREAM}" stroke="{INK}" stroke-width="3"/>
  <path d="M54 78 v48c0 14 20 22 46 22s46-8 46-22V78" fill="{WOOD}"/>
  <path d="M70 96 h60M66 114 h68" stroke="{OCHRE}" stroke-width="3"/>
  <path d="M148 58 l18-22" stroke="{CLAY}" stroke-width="5" stroke-linecap="round"/>
''',
    ),
    "courir.svg": (
        "courir",
        "courir",
        f'''  <circle cx="118" cy="56" r="12" fill="{SKIN}"/>
  <path d="M96 148c8-44 12-58 22-58s10 16 14 40" fill="{TEAL}"/>
  <path d="M108 96 L78 86M132 100 L158 78" stroke="{INK}" stroke-width="5" stroke-linecap="round"/>
  <path d="M108 148 L90 168M128 138 L152 162" stroke="{CLAY_D}" stroke-width="5" stroke-linecap="round"/>
''',
    ),
    "recent.svg": (
        "venir de",
        "venir de",
        f'''  <circle cx="100" cy="96" r="40" fill="{CREAM}" stroke="{PLUM}" stroke-width="4"/>
  <path d="M100 96 V68" stroke="{CLAY}" stroke-width="4" stroke-linecap="round"/>
  <path d="M100 96 L128 96" stroke="{TEAL_D}" stroke-width="4" stroke-linecap="round"/>
  <path d="M148 70 l16-8" stroke="{OCHRE}" stroke-width="4" stroke-linecap="round"/>
''',
    ),
    "projet.svg": (
        "un projet",
        "un projet",
        f'''  <path d="M44 110 L100 58 L156 110" fill="none" stroke="{TEAL}" stroke-width="8" stroke-linecap="round" stroke-linejoin="round"/>
  <circle cx="156" cy="110" r="10" fill="{OCHRE}"/>
  <rect x="88" y="110" width="24" height="36" fill="{CLAY}"/>
''',
    ),
    "plume.svg": (
        "une plume",
        "une plume",
        f'''  <path d="M52 140 L148 52" stroke="{PLUM}" stroke-width="6" stroke-linecap="round"/>
  <path d="M148 52 c18 8 8 28 -6 24" fill="{CREAM}" stroke="{INK}" stroke-width="2"/>
  <path d="M80 112 l16-16M96 96 l16-16M112 80 l14-12" stroke="{SAGE}" stroke-width="3"/>
  <path d="M48 148 l18-8" stroke="{CLAY}" stroke-width="5"/>
''',
    ),
    "livre.svg": (
        "un livre",
        "un livre",
        f'''  <rect x="50" y="56" width="100" height="92" rx="6" fill="{PLUM}"/>
  <rect x="58" y="64" width="84" height="76" rx="3" fill="{CREAM}"/>
  <path d="M70 88 h60M70 104 h50" stroke="{TEAL}" stroke-width="3"/>
  <rect x="50" y="56" width="12" height="92" fill="{PLUM_D}"/>
''',
    ),
    "naissance.svg": (
        "naître",
        "naître",
        f'''  <circle cx="100" cy="96" r="28" fill="{SKIN}"/>
  <path d="M78 96c6-24 14-30 22-30s16 6 22 30" fill="{INK}"/>
  <path d="M70 148c6-28 14-36 30-36s24 8 30 36" fill="{ROSE}"/>
  <circle cx="56" cy="70" r="8" fill="{OCHRE}" opacity="0.7"/>
  <circle cx="148" cy="66" r="6" fill="{OCHRE}" opacity="0.5"/>
''',
    ),
    "portrait.svg": (
        "un portrait",
        "un portrait",
        f'''  <rect x="48" y="42" width="104" height="118" rx="6" fill="{WOOD}"/>
  <rect x="58" y="52" width="84" height="86" rx="4" fill="{CREAM}"/>
  <circle cx="100" cy="84" r="16" fill="{SKIN}"/>
  <path d="M82 132c4-22 10-28 18-28s14 6 18 28" fill="{TEAL}"/>
  <rect x="70" y="146" width="60" height="8" fill="{PLUM}"/>
''',
    ),
    "cheveux.svg": (
        "les cheveux",
        "les cheveux",
        f'''  <circle cx="100" cy="96" r="28" fill="{SKIN}"/>
  <path d="M70 96c6-36 18-44 30-44s24 8 30 44c-8-18-18-20-30-20s-22 2-30 20z" fill="{INK}"/>
  <circle cx="90" cy="100" r="3" fill="{INK}"/>
  <circle cx="110" cy="100" r="3" fill="{INK}"/>
''',
    ),
    "lunettes.svg": (
        "les lunettes",
        "les lunettes",
        f'''  <circle cx="100" cy="88" r="22" fill="{SKIN}"/>
  <circle cx="88" cy="92" r="10" fill="none" stroke="{PLUM}" stroke-width="3"/>
  <circle cx="112" cy="92" r="10" fill="none" stroke="{PLUM}" stroke-width="3"/>
  <path d="M98 92h4" stroke="{PLUM}" stroke-width="3"/>
  <path d="M78 90h-10M132 90h10" stroke="{INK}" stroke-width="3"/>
''',
    ),
    "grand.svg": (
        "grand",
        "grand",
        f'''  <circle cx="100" cy="52" r="12" fill="{SKIN}"/>
  <path d="M78 158c5-56 12-72 22-72s17 16 22 72" fill="{TEAL}"/>
  <path d="M88 86 L72 70M112 86 L128 70" stroke="{INK}" stroke-width="4" stroke-linecap="round"/>
''',
    ),
    "choix.svg": (
        "un choix",
        "un choix",
        f'''  <path d="M100 150 V96" stroke="{WOOD}" stroke-width="8"/>
  <path d="M100 96 L58 58M100 96 L142 58" stroke="{CLAY}" stroke-width="8" stroke-linecap="round"/>
  <circle cx="58" cy="58" r="10" fill="{TEAL}"/>
  <circle cx="142" cy="58" r="10" fill="{OCHRE}"/>
''',
    ),
    "avant.svg": (
        "avant",
        "avant",
        f'''  <rect x="40" y="70" width="52" height="64" rx="6" fill="{NIGHT}" opacity="0.55"/>
  <rect x="108" y="70" width="52" height="64" rx="6" fill="{OCHRE}" opacity="0.35"/>
  <path d="M118 102 H78" stroke="{CREAM}" stroke-width="5" stroke-linecap="round"/>
  <path d="M78 102 l14-12M78 102 l14 12" stroke="{CREAM}" stroke-width="5" stroke-linecap="round"/>
''',
    ),
    "maintenant.svg": (
        "maintenant",
        "maintenant",
        f'''  <circle cx="100" cy="96" r="36" fill="{OCHRE}"/>
  <circle cx="100" cy="96" r="14" fill="{CREAM}"/>
  <path d="M100 60 v12M100 120 v12M64 96 h12M124 96 h12" stroke="{CLAY}" stroke-width="4" stroke-linecap="round"/>
''',
    ),
    "conseil.svg": (
        "un conseil",
        "un conseil",
        f'''  <path d="M70 70c0-22 14-36 30-36s30 14 30 36c0 16-10 24-18 30v12H88v-12c-8-6-18-14-18-30z" fill="{OCHRE}"/>
  <rect x="88" y="118" width="24" height="10" fill="{WOOD}"/>
  <rect x="92" y="132" width="16" height="14" rx="2" fill="{TEAL}"/>
''',
    ),
    "journal.svg": (
        "un journal",
        "un journal",
        f'''  <rect x="44" y="50" width="112" height="104" rx="4" fill="{CREAM}" stroke="{INK}" stroke-width="3"/>
  <rect x="44" y="50" width="112" height="22" fill="{PLUM}"/>
  <text x="100" y="66" text-anchor="middle" font-family="Georgia,serif" font-size="9" fill="{CREAM}">FEUILLE</text>
  <path d="M58 88 h84M58 104 h70M58 120 h78" stroke="{TEAL}" stroke-width="3"/>
''',
    ),
    "question.svg": (
        "une question",
        "une question",
        f'''  <circle cx="100" cy="88" r="40" fill="{CREAM}" stroke="{PLUM}" stroke-width="4"/>
  <path d="M84 78c0-14 28-18 28 2 0 12-14 12-14 24" fill="none" stroke="{CLAY}" stroke-width="6" stroke-linecap="round"/>
  <circle cx="98" cy="118" r="5" fill="{CLAY}"/>
''',
    ),
    "ecouter.svg": (
        "écouter",
        "écouter",
        f'''  <circle cx="78" cy="96" r="28" fill="{SKIN}"/>
  <path d="M70 86c8-16 16-18 22-8" fill="none" stroke="{INK}" stroke-width="3"/>
  <path d="M118 70c22 10 28 30 22 50" fill="none" stroke="{TEAL}" stroke-width="6" stroke-linecap="round"/>
  <path d="M130 80c14 8 16 22 12 34" fill="none" stroke="{OCHRE}" stroke-width="5" stroke-linecap="round"/>
''',
    ),
    "aller.svg": (
        "aller",
        "aller",
        f'''  <path d="M40 128 H130" stroke="{WOOD}" stroke-width="10" stroke-linecap="round"/>
  <path d="M130 128 L108 108M130 128 L108 148" stroke="{CLAY}" stroke-width="8" stroke-linecap="round"/>
  <circle cx="70" cy="88" r="10" fill="{SKIN}"/>
  <path d="M60 128c2-20 6-28 12-28s8 8 10 28" fill="{TEAL}"/>
''',
    ),
    "arriver.svg": (
        "arriver",
        "arriver",
        f'''  <rect x="48" y="88" width="70" height="52" fill="{CREAM}" stroke="{INK}" stroke-width="3"/>
  <path d="M48 88 L83 58 L118 88" fill="{CLAY}"/>
  <circle cx="148" cy="78" r="12" fill="{SKIN}"/>
  <path d="M136 148c3-28 8-38 12-38s10 10 12 38" fill="{TEAL}"/>
  <path d="M118 120 H136" stroke="{OCHRE}" stroke-width="5"/>
''',
    ),
    "danse.svg": (
        "la danse",
        "la danse",
        f'''  <circle cx="108" cy="58" r="12" fill="{SKIN}"/>
  <path d="M86 150c6-40 12-56 22-56s14 16 18 40" fill="{ROSE}"/>
  <path d="M96 96 L70 80M124 100 L150 86" stroke="{INK}" stroke-width="5" stroke-linecap="round"/>
  <path d="M100 148 L84 168M120 140 L138 164" stroke="{CLAY_D}" stroke-width="5" stroke-linecap="round"/>
''',
    ),
    "photo.svg": (
        "une photo",
        "une photo",
        f'''  <rect x="40" y="54" width="120" height="92" rx="8" fill="{CREAM}" stroke="{INK}" stroke-width="3"/>
  <rect x="50" y="64" width="100" height="62" fill="{SKY}"/>
  <circle cx="86" cy="88" r="10" fill="{SKIN}"/>
  <path d="M74 118c2-14 7-18 12-18s10 4 12 18" fill="{TEAL}"/>
  <circle cx="128" cy="80" r="12" fill="{OCHRE}" opacity="0.5"/>
''',
    ),
    "jeune.svg": (
        "jeune",
        "jeune",
        f'''  <circle cx="100" cy="72" r="16" fill="{SKIN}"/>
  <path d="M84 64c6-14 10-16 16-16s10 2 16 16" fill="{INK}"/>
  <path d="M76 150c4-38 14-50 24-50s20 12 24 50" fill="{OCHRE}"/>
  <circle cx="78" cy="118" r="8" fill="{SAGE}"/>
''',
    ),
    "figuier.svg": (
        "le figuier",
        "le figuier",
        f'''  <rect x="92" y="108" width="16" height="42" fill="{WOOD}"/>
  <ellipse cx="100" cy="88" rx="52" ry="36" fill="{SAGE}"/>
  <ellipse cx="78" cy="80" rx="18" ry="14" fill="{TEAL}" opacity="0.45"/>
  <circle cx="86" cy="100" r="6" fill="{CLAY}"/>
  <circle cx="118" cy="94" r="6" fill="{PLUM}"/>
  <circle cx="104" cy="72" r="5" fill="{OCHRE}"/>
''',
    ),
}


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for name, (aria, label, body) in SCENES.items():
        (OUT / name).write_text(frame(aria, body, label), encoding="utf-8")
    print(f"Wrote {len(SCENES)} SVGs to {OUT}")


if __name__ == "__main__":
    main()
