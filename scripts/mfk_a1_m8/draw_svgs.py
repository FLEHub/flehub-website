#!/usr/bin/env python3
"""Original MFK Module 8 illustrations — market-table style (sage + terracotta + teal)."""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "public/elearning/mfk-a1-m8"

PAPER = "#F6E6DC"
SKY = "#E4EDE4"
SAND = "#E8C99A"
TEAL = "#1E6B66"
TEAL_D = "#134E4A"
CLAY = "#C4563A"
ROSE = "#C46B6B"
SAGE = "#7FA47A"
SAGE_D = "#5C7A58"
INK = "#3A2718"
CREAM = "#FFF6EE"
OCHRE = "#D9A441"
SKIN = "#E8B888"
WOOD = "#8B5A2B"
LEAF = "#4F7A4A"


def frame(aria: str, body: str, label: str) -> str:
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200" role="img" aria-label="{aria}">
  <rect width="200" height="200" rx="24" fill="{PAPER}"/>
  <rect x="9" y="9" width="182" height="182" rx="18" fill="none" stroke="{SAGE_D}" stroke-width="1.8" opacity="0.75"/>
  <ellipse cx="28" cy="28" rx="12" ry="8" fill="none" stroke="{OCHRE}" stroke-width="2"/>
  <path d="M22 28 h12" stroke="{CLAY}" stroke-width="1.6"/>
  <ellipse cx="100" cy="90" rx="70" ry="50" fill="{SKY}" opacity="0.55"/>
  <ellipse cx="100" cy="166" rx="74" ry="13" fill="{SAND}"/>
{body}
  <text x="100" y="188" text-anchor="middle" font-family="Georgia,serif" font-size="13" font-weight="700" fill="{INK}">{label}</text>
</svg>
'''


SCENES = {
    "pain.svg": (
        "du pain",
        "du pain",
        f'''  <ellipse cx="100" cy="118" rx="54" ry="22" fill="{WOOD}"/>
  <ellipse cx="100" cy="108" rx="48" ry="18" fill="{OCHRE}"/>
  <path d="M70 104 Q100 88 130 104" fill="none" stroke="{CLAY}" stroke-width="3"/>
''',
    ),
    "fromage.svg": (
        "du fromage",
        "du fromage",
        f'''  <path d="M56 128 L100 56 L144 128z" fill="{OCHRE}"/>
  <path d="M56 128 L144 128 L100 112z" fill="{CREAM}"/>
  <circle cx="92" cy="96" r="5" fill="{SAND}"/>
  <circle cx="112" cy="108" r="4" fill="{SAND}"/>
''',
    ),
    "poisson.svg": (
        "du poisson",
        "du poisson",
        f'''  <ellipse cx="96" cy="100" rx="44" ry="20" fill="{TEAL}"/>
  <path d="M140 100 L168 80 L168 120z" fill="{TEAL_D}"/>
  <circle cx="70" cy="96" r="4" fill="{CREAM}"/>
''',
    ),
    "poulet.svg": (
        "du poulet",
        "du poulet",
        f'''  <ellipse cx="100" cy="108" rx="40" ry="24" fill="{OCHRE}"/>
  <ellipse cx="64" cy="88" rx="16" ry="12" fill="{OCHRE}"/>
  <path d="M130 100 L158 86 L150 114z" fill="{CLAY}"/>
  <rect x="88" y="128" width="24" height="10" fill="{WOOD}"/>
''',
    ),
    "fruit.svg": (
        "un fruit",
        "un fruit",
        f'''  <circle cx="92" cy="104" r="28" fill="{CLAY}"/>
  <circle cx="118" cy="96" r="22" fill="{ROSE}"/>
  <path d="M100 76 L108 58" stroke="{LEAF}" stroke-width="4"/>
  <ellipse cx="114" cy="56" rx="10" ry="6" fill="{SAGE}"/>
''',
    ),
    "legume.svg": (
        "des légumes",
        "des légumes",
        f'''  <ellipse cx="78" cy="118" rx="22" ry="14" fill="{OCHRE}"/>
  <rect x="118" y="70" width="14" height="62" rx="6" fill="{LEAF}"/>
  <circle cx="100" cy="92" r="16" fill="{SAGE}"/>
  <path d="M70 118 L52 96" stroke="{LEAF}" stroke-width="4"/>
''',
    ),
    "menu.svg": (
        "un menu",
        "un menu",
        f'''  <rect x="58" y="48" width="84" height="112" rx="6" fill="{CREAM}" stroke="{INK}" stroke-width="3"/>
  <path d="M72 72 h56M72 92 h48M72 112 h52M72 132 h40" stroke="{TEAL}" stroke-width="3"/>
  <rect x="58" y="48" width="84" height="16" fill="{CLAY}"/>
''',
    ),
    "assiette.svg": (
        "une assiette",
        "une assiette",
        f'''  <ellipse cx="100" cy="108" rx="58" ry="28" fill="{CREAM}" stroke="{INK}" stroke-width="4"/>
  <ellipse cx="100" cy="108" rx="34" ry="14" fill="{SAGE}" opacity="0.35"/>
''',
    ),
    "panier.svg": (
        "un panier",
        "un panier",
        f'''  <path d="M52 100 L64 148 H136 L148 100z" fill="{WOOD}"/>
  <path d="M70 100 Q100 58 130 100" fill="none" stroke="{OCHRE}" stroke-width="8"/>
  <path d="M64 118 h72" stroke="{SAND}" stroke-width="3"/>
''',
    ),
    "bouteille.svg": (
        "une bouteille",
        "une bouteille",
        f'''  <rect x="78" y="78" width="44" height="70" rx="10" fill="{TEAL}"/>
  <rect x="90" y="48" width="20" height="34" fill="{TEAL_D}"/>
  <ellipse cx="100" cy="48" rx="12" ry="6" fill="{OCHRE}"/>
  <rect x="84" y="96" width="32" height="22" fill="{CREAM}" opacity="0.35"/>
''',
    ),
    "pot.svg": (
        "un pot",
        "un pot",
        f'''  <rect x="64" y="88" width="72" height="52" rx="8" fill="{CLAY}"/>
  <ellipse cx="100" cy="88" rx="38" ry="10" fill="{OCHRE}"/>
  <ellipse cx="100" cy="88" rx="22" ry="6" fill="{CREAM}"/>
''',
    ),
    "sac.svg": (
        "un sac",
        "un sac",
        f'''  <path d="M58 86 H142 L132 148 H68z" fill="{WOOD}"/>
  <path d="M78 86 Q100 54 122 86" fill="none" stroke="{TEAL}" stroke-width="7"/>
  <circle cx="100" cy="118" r="8" fill="{OCHRE}"/>
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
    "chemise.svg": (
        "une chemise",
        "une chemise",
        f'''  <path d="M56 70 L100 88 L144 70 L150 148 H50z" fill="{TEAL}"/>
  <path d="M56 70 L78 52 L100 70 L122 52 L144 70" fill="{CREAM}" stroke="{INK}" stroke-width="2"/>
  <path d="M100 88 v40" stroke="{CREAM}" stroke-width="3"/>
''',
    ),
    "robe.svg": (
        "une robe",
        "une robe",
        f'''  <path d="M78 58 L100 78 L122 58 L140 148 H60z" fill="{CLAY}"/>
  <circle cx="100" cy="50" r="10" fill="{SKIN}"/>
  <path d="M70 100 h60" stroke="{OCHRE}" stroke-width="3"/>
''',
    ),
    "pantalon.svg": (
        "un pantalon",
        "un pantalon",
        f'''  <path d="M70 58 H130 L126 88 L148 148 H118 L100 100 L82 148 H52 L74 88z" fill="{TEAL_D}"/>
  <path d="M70 58 H130" stroke="{OCHRE}" stroke-width="5"/>
''',
    ),
    "sandale.svg": (
        "des sandales",
        "des sandales",
        f'''  <ellipse cx="78" cy="118" rx="28" ry="14" fill="{WOOD}"/>
  <path d="M64 110 Q78 88 92 110" fill="none" stroke="{CLAY}" stroke-width="5"/>
  <ellipse cx="128" cy="108" rx="28" ry="14" fill="{WOOD}"/>
  <path d="M114 100 Q128 78 142 100" fill="none" stroke="{TEAL}" stroke-width="5"/>
''',
    ),
    "pagne.svg": (
        "un pagne",
        "un pagne",
        f'''  <path d="M62 58 H138 L128 148 H72z" fill="{SAGE}"/>
  <path d="M70 90 h60M74 118 h52" stroke="{OCHRE}" stroke-width="6"/>
  <path d="M62 58 h76" stroke="{CLAY}" stroke-width="8"/>
''',
    ),
    "the.svg": (
        "du thé",
        "du thé",
        f'''  <ellipse cx="96" cy="128" rx="40" ry="12" fill="{WOOD}"/>
  <path d="M64 128 L72 78 H120 L128 128" fill="{TEAL}"/>
  <path d="M120 92 Q150 92 150 112 Q150 128 128 118" fill="none" stroke="{INK}" stroke-width="5"/>
  <path d="M88 62 Q96 48 108 62" fill="none" stroke="{SAGE}" stroke-width="3"/>
''',
    ),
    "cafe.svg": (
        "du café",
        "du café",
        f'''  <ellipse cx="96" cy="132" rx="36" ry="10" fill="{WOOD}"/>
  <path d="M68 132 L76 86 H116 L124 132" fill="{INK}"/>
  <path d="M116 100 Q142 100 142 118 Q142 132 122 124" fill="none" stroke="{CLAY}" stroke-width="5"/>
  <ellipse cx="96" cy="86" rx="20" ry="6" fill="{WOOD}"/>
''',
    ),
    "kilo.svg": (
        "un kilo",
        "un kilo",
        f'''  <rect x="54" y="78" width="92" height="64" rx="6" fill="{CREAM}" stroke="{INK}" stroke-width="3"/>
  <circle cx="100" cy="110" r="22" fill="none" stroke="{TEAL}" stroke-width="4"/>
  <path d="M100 92 v18 h12" stroke="{CLAY}" stroke-width="3"/>
  <text x="100" y="72" text-anchor="middle" font-family="Georgia,serif" font-size="14" fill="{INK}">1 kg</text>
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
    "cuisine.svg": (
        "la cuisine",
        "la cuisine",
        f'''  <rect x="48" y="70" width="104" height="70" fill="{CREAM}" stroke="{INK}" stroke-width="3"/>
  <rect x="60" y="108" width="36" height="32" fill="{CLAY}"/>
  <circle cx="132" cy="96" r="16" fill="{TEAL}"/>
  <rect x="88" y="78" width="28" height="18" fill="{OCHRE}"/>
''',
    ),
    "tissu.svg": (
        "du tissu",
        "du tissu",
        f'''  <path d="M48 70 Q100 48 152 70 L148 140 Q100 122 52 140z" fill="{ROSE}"/>
  <path d="M60 90 Q100 78 140 90" fill="none" stroke="{OCHRE}" stroke-width="5"/>
  <path d="M58 118 Q100 106 142 118" fill="none" stroke="{TEAL}" stroke-width="5"/>
''',
    ),
    "comparer.svg": (
        "comparer",
        "comparer",
        f'''  <rect x="40" y="72" width="52" height="70" rx="6" fill="{TEAL}"/>
  <rect x="108" y="58" width="52" height="84" rx="6" fill="{CLAY}"/>
  <path d="M92 108 h16" stroke="{OCHRE}" stroke-width="5"/>
  <path d="M108 100 l12 8 l-12 8" fill="{OCHRE}"/>
''',
    ),
    "hier.svg": (
        "hier",
        "hier",
        f'''  <rect x="52" y="58" width="96" height="92" rx="8" fill="{CREAM}" stroke="{INK}" stroke-width="3"/>
  <rect x="52" y="58" width="96" height="22" fill="{CLAY}"/>
  <circle cx="76" cy="106" r="8" fill="{SAGE}"/>
  <circle cx="100" cy="106" r="8" fill="{OCHRE}"/>
  <circle cx="124" cy="106" r="8" fill="{TEAL}" opacity="0.4"/>
''',
    ),
    "avis.svg": (
        "un avis",
        "un avis",
        f'''  <path d="M48 70 h88 a16 16 0 0 1 16 16 v40 a16 16 0 0 1-16 16 H84 L60 160 v-18 H48 a16 16 0 0 1-16-16 V86 a16 16 0 0 1 16-16z" fill="{CREAM}" stroke="{INK}" stroke-width="3"/>
  <path d="M64 96 h56M64 114 h40" stroke="{TEAL}" stroke-width="4"/>
''',
    ),
    "trop.svg": (
        "trop",
        "trop",
        f'''  <circle cx="100" cy="96" r="36" fill="{CREAM}" stroke="{CLAY}" stroke-width="6"/>
  <path d="M78 78 L122 114M122 78 L78 114" stroke="{CLAY}" stroke-width="8" stroke-linecap="round"/>
''',
    ),
    "jupe.svg": (
        "une jupe",
        "une jupe",
        f'''  <path d="M78 58 H122 L148 140 H52z" fill="{ROSE}"/>
  <path d="M78 58 H122" stroke="{INK}" stroke-width="6"/>
  <path d="M70 100 h60" stroke="{OCHRE}" stroke-width="3"/>
''',
    ),
    "veste.svg": (
        "une veste",
        "une veste",
        f'''  <path d="M54 70 L100 92 L146 70 L156 148 H44z" fill="{TEAL_D}"/>
  <path d="M54 70 L76 50 L100 72 L124 50 L146 70" fill="{WOOD}"/>
  <path d="M100 92 v40" stroke="{OCHRE}" stroke-width="4"/>
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
