#!/usr/bin/env python3
"""Original MFK Module 9 illustrations — path-stone style (ochre + terracotta + teal)."""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "public/elearning/mfk-a1-m9"

PAPER = "#F6E6DC"
SKY = "#E8DCC8"
SAND = "#E8C99A"
TEAL = "#1E6B66"
TEAL_D = "#134E4A"
CLAY = "#C4563A"
ROSE = "#C46B6B"
SAGE = "#7FA47A"
INK = "#3A2718"
CREAM = "#FFF6EE"
OCHRE = "#D9A441"
SKIN = "#E8B888"
WOOD = "#8B5A2B"
PLUM = "#6B4C7A"


def frame(aria: str, body: str, label: str) -> str:
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200" role="img" aria-label="{aria}">
  <rect width="200" height="200" rx="24" fill="{PAPER}"/>
  <rect x="9" y="9" width="182" height="182" rx="18" fill="none" stroke="{OCHRE}" stroke-width="1.8" opacity="0.8"/>
  <path d="M22 36 L28 18 L34 36z" fill="{CLAY}"/>
  <ellipse cx="100" cy="90" rx="70" ry="50" fill="{SKY}" opacity="0.55"/>
  <ellipse cx="100" cy="166" rx="74" ry="13" fill="{SAND}"/>
{body}
  <text x="100" y="188" text-anchor="middle" font-family="Georgia,serif" font-size="13" font-weight="700" fill="{INK}">{label}</text>
</svg>
'''


SCENES = {
    "chemin.svg": (
        "un chemin",
        "un chemin",
        f'''  <path d="M40 148 Q70 110 100 120 T160 88" fill="none" stroke="{OCHRE}" stroke-width="14" stroke-linecap="round"/>
  <path d="M40 148 Q70 110 100 120 T160 88" fill="none" stroke="{WOOD}" stroke-width="4" stroke-dasharray="6 8"/>
''',
    ),
    "pas.svg": (
        "un pas",
        "un pas",
        f'''  <ellipse cx="72" cy="108" rx="18" ry="28" fill="{WOOD}"/>
  <ellipse cx="120" cy="92" rx="18" ry="28" fill="{CLAY}"/>
  <path d="M72 88 v-12M120 72 v-12" stroke="{INK}" stroke-width="3"/>
''',
    ),
    "cahier.svg": (
        "un cahier",
        "un cahier",
        f'''  <rect x="54" y="48" width="92" height="112" rx="6" fill="{PLUM}"/>
  <rect x="64" y="54" width="76" height="100" rx="3" fill="{CREAM}"/>
  <path d="M76 78 h52M76 94 h44M76 110 h50" stroke="{TEAL}" stroke-width="3"/>
  <path d="M54 48 v112" stroke="{OCHRE}" stroke-width="6"/>
''',
    ),
    "figuier.svg": (
        "le figuier",
        "le figuier",
        f'''  <rect x="92" y="88" width="16" height="60" fill="{WOOD}"/>
  <ellipse cx="100" cy="78" rx="48" ry="36" fill="{SAGE}"/>
  <circle cx="78" cy="80" r="6" fill="{CLAY}"/>
  <circle cx="118" cy="70" r="6" fill="{OCHRE}"/>
''',
    ),
    "groupe.svg": (
        "le groupe",
        "le groupe",
        f'''  <circle cx="70" cy="78" r="12" fill="{SKIN}"/>
  <circle cx="100" cy="70" r="12" fill="{SKIN}"/>
  <circle cx="130" cy="78" r="12" fill="{SKIN}"/>
  <path d="M58 148c3-36 8-48 14-48s10 12 12 36" fill="{TEAL}"/>
  <path d="M88 148c3-40 8-54 14-54s10 14 12 40" fill="{CLAY}"/>
  <path d="M118 148c3-36 8-48 14-48s10 12 12 36" fill="{WOOD}"/>
''',
    ),
    "apprendre.svg": (
        "apprendre",
        "apprendre",
        f'''  <rect x="48" y="70" width="70" height="50" rx="6" fill="{CREAM}" stroke="{INK}" stroke-width="3"/>
  <path d="M56 86 h54M56 102 h40" stroke="{TEAL}" stroke-width="3"/>
  <circle cx="140" cy="96" r="12" fill="{SKIN}"/>
  <path d="M128 148c3-24 8-34 14-34s10 10 12 34" fill="{CLAY}"/>
''',
    ),
    "pouvoir.svg": (
        "pouvoir",
        "pouvoir",
        f'''  <circle cx="100" cy="96" r="36" fill="{CREAM}" stroke="{TEAL}" stroke-width="6"/>
  <path d="M82 100 l12 12 l24-28" fill="none" stroke="{CLAY}" stroke-width="8" stroke-linecap="round"/>
''',
    ),
    "savoir.svg": (
        "savoir",
        "savoir",
        f'''  <circle cx="100" cy="88" r="28" fill="{OCHRE}"/>
  <path d="M100 116 v28" stroke="{WOOD}" stroke-width="8"/>
  <circle cx="100" cy="88" r="10" fill="{CREAM}"/>
''',
    ),
    "avant.svg": (
        "avant",
        "avant",
        f'''  <path d="M130 70 L70 100 L130 130z" fill="{PLUM}"/>
  <path d="M70 100 H50" stroke="{INK}" stroke-width="8" stroke-linecap="round"/>
''',
    ),
    "maintenant.svg": (
        "maintenant",
        "maintenant",
        f'''  <circle cx="100" cy="96" r="40" fill="{CREAM}" stroke="{INK}" stroke-width="4"/>
  <path d="M100 96 L100 68" stroke="{CLAY}" stroke-width="5"/>
  <path d="M100 96 L128 96" stroke="{TEAL}" stroke-width="5"/>
  <circle cx="100" cy="96" r="6" fill="{OCHRE}"/>
''',
    ),
    "demain.svg": (
        "demain",
        "demain",
        f'''  <circle cx="128" cy="70" r="18" fill="{OCHRE}"/>
  <path d="M40 128 Q80 100 120 128 T180 120" fill="none" stroke="{TEAL}" stroke-width="8"/>
  <path d="M148 86 L168 70" stroke="{CLAY}" stroke-width="4"/>
''',
    ),
    "merci.svg": (
        "merci",
        "merci",
        f'''  <path d="M100 56 L116 88 H148 L122 108 L132 142 L100 122 L68 142 L78 108 L52 88 H84z" fill="{CLAY}"/>
''',
    ),
    "portrait.svg": (
        "un portrait",
        "un portrait",
        f'''  <rect x="58" y="48" width="84" height="112" rx="6" fill="{CREAM}" stroke="{WOOD}" stroke-width="6"/>
  <circle cx="100" cy="88" r="18" fill="{SKIN}"/>
  <path d="M78 148c4-28 10-40 22-40s18 12 22 40" fill="{TEAL}"/>
''',
    ),
    "pierre.svg": (
        "une pierre",
        "une pierre",
        f'''  <path d="M50 128 L78 72 L130 64 L156 120 L120 148 L60 144z" fill="{WOOD}"/>
  <path d="M78 72 L100 100 L130 64" fill="{SAND}" opacity="0.5"/>
''',
    ),
    "fleche.svg": (
        "une flèche",
        "une flèche",
        f'''  <path d="M40 100 H130" stroke="{CLAY}" stroke-width="10" stroke-linecap="round"/>
  <path d="M118 72 L164 100 L118 128z" fill="{OCHRE}"/>
''',
    ),
    "arriver.svg": (
        "arriver",
        "arriver",
        f'''  <path d="M36 128 H120" stroke="{WOOD}" stroke-width="10" stroke-linecap="round"/>
  <circle cx="148" cy="78" r="12" fill="{SKIN}"/>
  <path d="M136 148c3-28 8-38 12-38s10 10 12 38" fill="{CLAY}"/>
  <circle cx="120" cy="128" r="8" fill="{OCHRE}"/>
''',
    ),
    "partir.svg": (
        "partir",
        "partir",
        f'''  <circle cx="70" cy="70" r="12" fill="{SKIN}"/>
  <path d="M58 148c3-40 8-54 14-54s10 14 12 40" fill="{TEAL}"/>
  <rect x="108" y="88" width="44" height="36" rx="6" fill="{CLAY}"/>
  <path d="M150 106 L168 106 L158 96z" fill="{OCHRE}"/>
''',
    ),
    "table.svg": (
        "une table",
        "une table",
        f'''  <rect x="40" y="96" width="120" height="16" rx="4" fill="{WOOD}"/>
  <rect x="52" y="112" width="10" height="36" fill="{INK}"/>
  <rect x="138" y="112" width="10" height="36" fill="{INK}"/>
  <ellipse cx="100" cy="88" rx="22" ry="10" fill="{CREAM}" stroke="{TEAL}" stroke-width="3"/>
''',
    ),
    "marche.svg": (
        "le marché",
        "le marché",
        f'''  <rect x="44" y="100" width="48" height="40" fill="{CREAM}" stroke="{INK}" stroke-width="3"/>
  <rect x="108" y="100" width="48" height="40" fill="{CREAM}" stroke="{INK}" stroke-width="3"/>
  <path d="M40 100 L68 70 L96 100" fill="{CLAY}"/>
  <path d="M104 100 L132 70 L160 100" fill="{TEAL}"/>
''',
    ),
    "lac.svg": (
        "un lac",
        "un lac",
        f'''  <ellipse cx="100" cy="108" rx="62" ry="28" fill="{TEAL}"/>
  <ellipse cx="100" cy="104" rx="46" ry="16" fill="{SKY}"/>
  <path d="M40 92 Q70 70 100 88 T160 86" fill="none" stroke="{SAGE}" stroke-width="6"/>
''',
    ),
    "radio.svg": (
        "la radio",
        "la radio",
        f'''  <rect x="52" y="78" width="96" height="56" rx="10" fill="{WOOD}"/>
  <circle cx="84" cy="106" r="16" fill="{CREAM}"/>
  <circle cx="84" cy="106" r="6" fill="{CLAY}"/>
  <rect x="112" y="92" width="24" height="10" fill="{OCHRE}"/>
  <rect x="112" y="110" width="24" height="10" fill="{TEAL}"/>
''',
    ),
    "page.svg": (
        "une page",
        "une page",
        f'''  <path d="M60 48 H128 L148 68 V152 H60z" fill="{CREAM}" stroke="{INK}" stroke-width="3"/>
  <path d="M128 48 V68 H148" fill="none" stroke="{INK}" stroke-width="3"/>
  <path d="M76 88 h56M76 108 h48M76 128 h52" stroke="{TEAL}" stroke-width="3"/>
''',
    ),
    "bilan.svg": (
        "un bilan",
        "un bilan",
        f'''  <rect x="50" y="58" width="100" height="92" rx="6" fill="{CREAM}" stroke="{PLUM}" stroke-width="3"/>
  <path d="M68 84 h28M68 104 h40M68 124 h24" stroke="{TEAL}" stroke-width="4"/>
  <circle cx="132" cy="96" r="14" fill="none" stroke="{CLAY}" stroke-width="4"/>
  <path d="M124 96 l6 6 l12-14" fill="none" stroke="{CLAY}" stroke-width="3"/>
''',
    ),
    "content.svg": (
        "content",
        "content",
        f'''  <circle cx="100" cy="92" r="36" fill="{OCHRE}"/>
  <circle cx="86" cy="84" r="5" fill="{INK}"/>
  <circle cx="114" cy="84" r="5" fill="{INK}"/>
  <path d="M80 104 Q100 122 120 104" fill="none" stroke="{INK}" stroke-width="4"/>
''',
    ),
    "ensemble.svg": (
        "ensemble",
        "ensemble",
        f'''  <circle cx="76" cy="88" r="22" fill="{TEAL}" opacity="0.7"/>
  <circle cx="124" cy="88" r="22" fill="{CLAY}" opacity="0.7"/>
  <circle cx="100" cy="112" r="22" fill="{OCHRE}" opacity="0.7"/>
''',
    ),
    "question.svg": (
        "une question",
        "une question",
        f'''  <circle cx="100" cy="88" r="40" fill="{CREAM}" stroke="{TEAL}" stroke-width="5"/>
  <text x="100" y="104" text-anchor="middle" font-family="Georgia,serif" font-size="48" font-weight="700" fill="{CLAY}">?</text>
''',
    ),
    "reponse.svg": (
        "une réponse",
        "une réponse",
        f'''  <circle cx="100" cy="88" r="40" fill="{CREAM}" stroke="{OCHRE}" stroke-width="5"/>
  <text x="100" y="108" text-anchor="middle" font-family="Georgia,serif" font-size="48" font-weight="700" fill="{TEAL_D}">!</text>
''',
    ),
    "adieu.svg": (
        "au revoir",
        "au revoir",
        f'''  <circle cx="70" cy="80" r="12" fill="{SKIN}"/>
  <circle cx="130" cy="80" r="12" fill="{SKIN}"/>
  <path d="M58 148c3-32 8-44 14-44s10 12 12 32" fill="{TEAL}"/>
  <path d="M118 148c3-32 8-44 14-44s10 12 12 32" fill="{CLAY}"/>
  <path d="M86 96 Q100 110 114 96" fill="none" stroke="{OCHRE}" stroke-width="4"/>
''',
    ),
    "valise.svg": (
        "une valise",
        "une valise",
        f'''  <rect x="52" y="70" width="96" height="72" rx="8" fill="{WOOD}"/>
  <rect x="60" y="78" width="80" height="56" rx="4" fill="{CLAY}"/>
  <rect x="86" y="58" width="28" height="16" rx="4" fill="{TEAL}"/>
''',
    ),
    "boussole.svg": (
        "une boussole",
        "une boussole",
        f'''  <circle cx="100" cy="96" r="42" fill="{CREAM}" stroke="{INK}" stroke-width="4"/>
  <path d="M100 62 L112 96 L100 130 L88 96z" fill="{CLAY}"/>
  <text x="100" y="58" text-anchor="middle" font-family="Georgia,serif" font-size="10" fill="{INK}">N</text>
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
