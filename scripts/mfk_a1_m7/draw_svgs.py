#!/usr/bin/env python3
"""Original MFK Module 7 illustrations — travel-map style (sea blue + terracotta + teal)."""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "public/elearning/mfk-a1-m7"

PAPER = "#F6E6DC"
SKY = "#D7E4E8"
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
SEA = "#3D6B8A"
SEA_D = "#2A4D66"
NIGHT = "#3D4F6A"


def frame(aria: str, body: str, label: str) -> str:
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200" role="img" aria-label="{aria}">
  <rect width="200" height="200" rx="24" fill="{PAPER}"/>
  <rect x="9" y="9" width="182" height="182" rx="18" fill="none" stroke="{SEA}" stroke-width="1.8" opacity="0.7"/>
  <circle cx="28" cy="28" r="10" fill="none" stroke="{OCHRE}" stroke-width="2"/>
  <path d="M28 20 v16M20 28 h16" stroke="{CLAY}" stroke-width="1.6"/>
  <ellipse cx="100" cy="90" rx="70" ry="50" fill="{SKY}" opacity="0.55"/>
  <ellipse cx="100" cy="166" rx="74" ry="13" fill="{SAND}"/>
{body}
  <text x="100" y="188" text-anchor="middle" font-family="Georgia,serif" font-size="13" font-weight="700" fill="{INK}">{label}</text>
</svg>
'''


SCENES = {
    "valise.svg": (
        "une valise",
        "une valise",
        f'''  <rect x="52" y="70" width="96" height="72" rx="8" fill="{WOOD}"/>
  <rect x="60" y="78" width="80" height="56" rx="4" fill="{CLAY}"/>
  <rect x="86" y="58" width="28" height="16" rx="4" fill="{TEAL}"/>
  <circle cx="72" cy="148" r="6" fill="{INK}"/>
  <circle cx="128" cy="148" r="6" fill="{INK}"/>
''',
    ),
    "carte.svg": (
        "une carte",
        "une carte",
        f'''  <rect x="40" y="50" width="120" height="100" rx="6" fill="{CREAM}" stroke="{INK}" stroke-width="3"/>
  <path d="M56 90 Q88 60 120 88 T160 92" fill="none" stroke="{SEA}" stroke-width="4"/>
  <circle cx="78" cy="86" r="6" fill="{CLAY}"/>
  <circle cx="132" cy="96" r="6" fill="{TEAL}"/>
  <path d="M78 86 L132 96" stroke="{OCHRE}" stroke-width="2" stroke-dasharray="4 3"/>
''',
    ),
    "minibus.svg": (
        "le minibus",
        "le minibus",
        f'''  <rect x="36" y="78" width="128" height="52" rx="10" fill="{TEAL}"/>
  <rect x="48" y="88" width="28" height="20" fill="{CREAM}"/>
  <rect x="84" y="88" width="28" height="20" fill="{CREAM}"/>
  <rect x="120" y="88" width="28" height="20" fill="{CREAM}"/>
  <circle cx="64" cy="136" r="12" fill="{INK}"/>
  <circle cx="140" cy="136" r="12" fill="{INK}"/>
  <rect x="36" y="118" width="18" height="10" fill="{OCHRE}"/>
''',
    ),
    "moto.svg": (
        "la moto",
        "la moto",
        f'''  <circle cx="64" cy="128" r="22" fill="none" stroke="{INK}" stroke-width="6"/>
  <circle cx="140" cy="128" r="22" fill="none" stroke="{INK}" stroke-width="6"/>
  <path d="M64 128 L96 88 H128 L140 128" fill="none" stroke="{CLAY}" stroke-width="6"/>
  <path d="M96 88 L108 64" stroke="{TEAL_D}" stroke-width="5" stroke-linecap="round"/>
''',
    ),
    "bateau.svg": (
        "un bateau",
        "un bateau",
        f'''  <path d="M40 118 L70 148 H140 L160 118z" fill="{WOOD}"/>
  <path d="M100 118 V58" stroke="{INK}" stroke-width="5"/>
  <path d="M100 58 L148 110 H100z" fill="{SEA}"/>
  <path d="M30 148 Q100 136 170 148" fill="none" stroke="{SEA}" stroke-width="5"/>
''',
    ),
    "ticket.svg": (
        "un billet",
        "un billet",
        f'''  <rect x="44" y="70" width="112" height="64" rx="8" fill="{CREAM}" stroke="{SEA}" stroke-width="3"/>
  <path d="M44 102 h112" stroke="{OCHRE}" stroke-width="2" stroke-dasharray="6 4"/>
  <circle cx="56" cy="102" r="7" fill="{PAPER}"/>
  <circle cx="144" cy="102" r="7" fill="{PAPER}"/>
  <path d="M70 86 h60M70 118 h40" stroke="{TEAL}" stroke-width="3"/>
''',
    ),
    "saison.svg": (
        "une saison",
        "une saison",
        f'''  <circle cx="70" cy="88" r="22" fill="{OCHRE}"/>
  <circle cx="130" cy="108" r="22" fill="{SEA}" opacity="0.7"/>
  <path d="M48 140 h104" stroke="{SAGE}" stroke-width="8" stroke-linecap="round"/>
  <path d="M88 70 l12-22M92 58 h16" stroke="{CLAY}" stroke-width="3"/>
''',
    ),
    "pluie.svg": (
        "la pluie",
        "la pluie",
        f'''  <ellipse cx="100" cy="70" rx="48" ry="22" fill="{NIGHT}" opacity="0.55"/>
  <path d="M70 96 l-8 28M88 100 l-6 32M108 98 l-6 30M128 96 l-8 28" stroke="{SEA}" stroke-width="5" stroke-linecap="round"/>
  <path d="M50 148 h100" stroke="{TEAL}" stroke-width="4"/>
''',
    ),
    "soleil.svg": (
        "le soleil",
        "le soleil",
        f'''  <circle cx="100" cy="92" r="28" fill="{OCHRE}"/>
  <path d="M100 44 V56M100 128 V140M52 92 H64M136 92 H148M66 60 L74 68M126 116 L134 124M66 124 L74 116M126 68 L134 60" stroke="{CLAY}" stroke-width="4" stroke-linecap="round"/>
''',
    ),
    "chambre.svg": (
        "une chambre",
        "une chambre",
        f'''  <rect x="40" y="58" width="120" height="90" fill="{CREAM}" stroke="{INK}" stroke-width="3"/>
  <rect x="50" y="100" width="70" height="28" rx="6" fill="{TEAL}"/>
  <rect x="54" y="92" width="50" height="14" rx="4" fill="{CREAM}"/>
  <rect x="128" y="78" width="22" height="28" fill="{SEA}" opacity="0.5"/>
  <rect x="88" y="118" width="18" height="30" fill="{WOOD}"/>
''',
    ),
    "auberge.svg": (
        "une auberge",
        "une auberge",
        f'''  <rect x="48" y="90" width="104" height="56" fill="{CREAM}" stroke="{INK}" stroke-width="3"/>
  <path d="M40 92 L100 48 L160 92z" fill="{CLAY}"/>
  <rect x="88" y="110" width="24" height="36" fill="{WOOD}"/>
  <rect x="60" y="104" width="16" height="14" fill="{SEA}" opacity="0.45"/>
  <rect x="124" y="104" width="16" height="14" fill="{SEA}" opacity="0.45"/>
''',
    ),
    "cle.svg": (
        "une clé",
        "une clé",
        f'''  <circle cx="70" cy="96" r="22" fill="none" stroke="{OCHRE}" stroke-width="8"/>
  <path d="M90 96 H156" stroke="{OCHRE}" stroke-width="8" stroke-linecap="round"/>
  <path d="M140 96 v18M152 96 v12" stroke="{CLAY}" stroke-width="6" stroke-linecap="round"/>
''',
    ),
    "lac.svg": (
        "un lac",
        "un lac",
        f'''  <ellipse cx="100" cy="108" rx="62" ry="28" fill="{SEA}"/>
  <ellipse cx="100" cy="104" rx="46" ry="16" fill="{SKY}"/>
  <path d="M40 92 Q70 70 100 88 T160 86" fill="none" stroke="{SAGE}" stroke-width="6"/>
  <circle cx="148" cy="70" r="10" fill="{OCHRE}" opacity="0.6"/>
''',
    ),
    "ile.svg": (
        "une île",
        "une île",
        f'''  <ellipse cx="100" cy="128" rx="70" ry="18" fill="{SEA}"/>
  <ellipse cx="100" cy="112" rx="40" ry="16" fill="{SAND}"/>
  <path d="M88 112 c4-28 8-40 12-40 6 0 10 14 14 40" fill="{SAGE}"/>
  <rect x="96" y="88" width="8" height="24" fill="{WOOD}"/>
''',
    ),
    "montagne.svg": (
        "une montagne",
        "une montagne",
        f'''  <path d="M30 148 L78 70 L110 118 L132 88 L170 148z" fill="{TEAL_D}"/>
  <path d="M78 70 L90 88 L70 88z" fill="{CREAM}"/>
  <path d="M132 88 L140 100 L126 100z" fill="{CREAM}"/>
''',
    ),
    "carnet.svg": (
        "un carnet",
        "un carnet",
        f'''  <rect x="54" y="48" width="92" height="112" rx="6" fill="{SEA_D}"/>
  <rect x="64" y="54" width="76" height="100" rx="3" fill="{CREAM}"/>
  <path d="M76 78 h52M76 94 h44M76 110 h50" stroke="{TEAL}" stroke-width="3"/>
  <path d="M54 48 v112" stroke="{OCHRE}" stroke-width="6"/>
''',
    ),
    "boussole.svg": (
        "une boussole",
        "une boussole",
        f'''  <circle cx="100" cy="96" r="42" fill="{CREAM}" stroke="{INK}" stroke-width="4"/>
  <path d="M100 62 L112 96 L100 130 L88 96z" fill="{CLAY}"/>
  <path d="M100 62 L92 96 L100 80z" fill="{SEA}"/>
  <text x="100" y="58" text-anchor="middle" font-family="Georgia,serif" font-size="10" fill="{INK}">N</text>
''',
    ),
    "partir.svg": (
        "partir",
        "partir",
        f'''  <circle cx="70" cy="70" r="12" fill="{SKIN}"/>
  <path d="M58 148c3-40 8-54 14-54s10 14 12 40" fill="{TEAL}"/>
  <rect x="108" y="88" width="44" height="36" rx="6" fill="{CLAY}"/>
  <path d="M86 110 H108" stroke="{OCHRE}" stroke-width="5"/>
  <path d="M150 106 L168 106 L158 96z" fill="{SEA}"/>
''',
    ),
    "rester.svg": (
        "rester",
        "rester",
        f'''  <rect x="48" y="88" width="70" height="52" fill="{CREAM}" stroke="{INK}" stroke-width="3"/>
  <path d="M48 88 L83 58 L118 88" fill="{CLAY}"/>
  <circle cx="148" cy="100" r="12" fill="{SKIN}"/>
  <path d="M136 148c3-24 8-34 12-34s10 10 12 34" fill="{TEAL}"/>
''',
    ),
    "visiter.svg": (
        "visiter",
        "visiter",
        f'''  <circle cx="70" cy="72" r="12" fill="{SKIN}"/>
  <path d="M58 148c3-40 8-52 14-52s10 12 12 40" fill="{TEAL}"/>
  <rect x="112" y="64" width="48" height="70" fill="{WOOD}"/>
  <path d="M112 64 L136 42 L160 64" fill="{SEA}"/>
  <rect x="128" y="96" width="16" height="38" fill="{CREAM}"/>
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
    "ete.svg": (
        "l'été",
        "l'été",
        f'''  <circle cx="100" cy="70" r="24" fill="{OCHRE}"/>
  <ellipse cx="70" cy="128" rx="18" ry="10" fill="{SAGE}"/>
  <rect x="66" y="128" width="8" height="22" fill="{WOOD}"/>
  <ellipse cx="130" cy="124" rx="20" ry="12" fill="{SAGE}"/>
  <rect x="126" y="124" width="8" height="26" fill="{WOOD}"/>
''',
    ),
    "hiver.svg": (
        "l'hiver",
        "l'hiver",
        f'''  <path d="M40 128 L78 78 L110 118 L138 86 L168 128z" fill="{SEA}" opacity="0.45"/>
  <circle cx="70" cy="70" r="5" fill="{CREAM}"/>
  <circle cx="100" cy="58" r="4" fill="{CREAM}"/>
  <circle cx="130" cy="74" r="5" fill="{CREAM}"/>
  <path d="M60 148 h80" stroke="{CREAM}" stroke-width="8"/>
''',
    ),
    "printemps.svg": (
        "le printemps",
        "le printemps",
        f'''  <rect x="92" y="100" width="12" height="48" fill="{WOOD}"/>
  <ellipse cx="98" cy="88" rx="36" ry="28" fill="{SAGE}"/>
  <circle cx="86" cy="92" r="6" fill="{ROSE}"/>
  <circle cx="112" cy="84" r="6" fill="{OCHRE}"/>
  <circle cx="98" cy="72" r="5" fill="{CLAY}"/>
''',
    ),
    "automne.svg": (
        "l'automne",
        "l'automne",
        f'''  <rect x="94" y="108" width="12" height="40" fill="{WOOD}"/>
  <ellipse cx="100" cy="90" rx="38" ry="26" fill="{CLAY}"/>
  <path d="M70 120 l-10 20M130 116 l12 22M100 128 l4 22" stroke="{OCHRE}" stroke-width="4" stroke-linecap="round"/>
''',
    ),
    "vent.svg": (
        "le vent",
        "le vent",
        f'''  <path d="M40 80 Q90 60 150 80" fill="none" stroke="{SEA}" stroke-width="6" stroke-linecap="round"/>
  <path d="M50 104 Q100 88 160 108" fill="none" stroke="{TEAL}" stroke-width="6" stroke-linecap="round"/>
  <path d="M46 128 Q96 116 154 132" fill="none" stroke="{OCHRE}" stroke-width="5" stroke-linecap="round"/>
''',
    ),
    "mer.svg": (
        "la mer",
        "la mer",
        f'''  <rect x="30" y="88" width="140" height="60" rx="8" fill="{SEA}"/>
  <path d="M30 108 Q60 96 90 108 T150 108 T170 108" fill="none" stroke="{CREAM}" stroke-width="4"/>
  <circle cx="148" cy="70" r="14" fill="{OCHRE}"/>
''',
    ),
    "pont.svg": (
        "un pont",
        "un pont",
        f'''  <path d="M30 128 Q100 70 170 128" fill="none" stroke="{WOOD}" stroke-width="10"/>
  <path d="M48 128 v20M152 128 v20" stroke="{INK}" stroke-width="6"/>
  <path d="M30 148 h140" stroke="{SEA}" stroke-width="8"/>
''',
    ),
    "nord.svg": (
        "le nord",
        "le nord",
        f'''  <path d="M100 48 L120 120 L100 104 L80 120z" fill="{CLAY}"/>
  <text x="100" y="150" text-anchor="middle" font-family="Georgia,serif" font-size="22" font-weight="700" fill="{SEA_D}">N</text>
''',
    ),
    "sud.svg": (
        "le sud",
        "le sud",
        f'''  <path d="M100 148 L80 76 L100 92 L120 76z" fill="{TEAL}"/>
  <text x="100" y="64" text-anchor="middle" font-family="Georgia,serif" font-size="22" font-weight="700" fill="{SEA_D}">S</text>
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
