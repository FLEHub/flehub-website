#!/usr/bin/env python3
"""Original MFK Module 5 illustrations — hour-thread style (ochre + terracotta + teal)."""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "public/elearning/mfk-a1-m5"

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
NIGHT = "#3D4F6A"
SUN = "#E6A23C"


def frame(aria: str, body: str, label: str) -> str:
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200" role="img" aria-label="{aria}">
  <rect width="200" height="200" rx="24" fill="{PAPER}"/>
  <rect x="9" y="9" width="182" height="182" rx="18" fill="none" stroke="{OCHRE}" stroke-width="1.8" opacity="0.7"/>
  <path d="M26 26 H174" stroke="{OCHRE}" stroke-width="3" stroke-linecap="round"/>
  <rect x="46" y="18" width="14" height="16" rx="2" fill="{CREAM}" stroke="{CLAY}" stroke-width="1.5"/>
  <rect x="140" y="18" width="14" height="16" rx="2" fill="{CREAM}" stroke="{TEAL}" stroke-width="1.5"/>
  <ellipse cx="100" cy="90" rx="70" ry="50" fill="{SKY}" opacity="0.5"/>
  <ellipse cx="100" cy="166" rx="74" ry="13" fill="{SAND}"/>
{body}
  <text x="100" y="188" text-anchor="middle" font-family="Georgia,serif" font-size="13" font-weight="700" fill="{INK}">{label}</text>
</svg>
'''


SCENES = {
    "heure.svg": (
        "l'heure",
        "l'heure",
        f'''  <circle cx="100" cy="96" r="42" fill="{CREAM}" stroke="{INK}" stroke-width="4"/>
  <circle cx="100" cy="96" r="5" fill="{CLAY}"/>
  <path d="M100 96 V64" stroke="{TEAL_D}" stroke-width="4" stroke-linecap="round"/>
  <path d="M100 96 L128 108" stroke="{CLAY}" stroke-width="4" stroke-linecap="round"/>
  <circle cx="100" cy="58" r="3" fill="{INK}"/>
  <circle cx="138" cy="96" r="3" fill="{INK}"/>
''',
    ),
    "midi.svg": (
        "midi",
        "midi",
        f'''  <circle cx="100" cy="88" r="28" fill="{SUN}"/>
  <path d="M100 44 V54M100 122 V132M56 88 H66M134 88 H144M70 58 L76 64M124 118 L130 124M70 118 L76 112M124 58 L130 64" stroke="{OCHRE}" stroke-width="4" stroke-linecap="round"/>
  <ellipse cx="100" cy="148" rx="50" ry="8" fill="{SAGE}" opacity="0.5"/>
''',
    ),
    "minuit.svg": (
        "minuit",
        "minuit",
        f'''  <rect x="36" y="48" width="128" height="100" rx="16" fill="{NIGHT}"/>
  <circle cx="118" cy="86" r="22" fill="{CREAM}"/>
  <circle cx="108" cy="82" r="16" fill="{NIGHT}"/>
  <circle cx="62" cy="70" r="2.5" fill="{OCHRE}"/>
  <circle cx="78" cy="92" r="2" fill="{OCHRE}"/>
  <circle cx="150" cy="118" r="2" fill="{OCHRE}"/>
''',
    ),
    "matin.svg": (
        "le matin",
        "le matin",
        f'''  <path d="M30 120 Q100 40 170 120" fill="{SUN}" opacity="0.85"/>
  <ellipse cx="100" cy="128" rx="70" ry="16" fill="{SAGE}" opacity="0.4"/>
  <circle cx="100" cy="108" r="18" fill="{SUN}"/>
''',
    ),
    "soir.svg": (
        "le soir",
        "le soir",
        f'''  <path d="M28 70 Q100 130 172 70" fill="{CLAY}" opacity="0.85"/>
  <circle cx="100" cy="92" r="20" fill="{SUN}"/>
  <path d="M40 128 h120" stroke="{TEAL_D}" stroke-width="6" stroke-linecap="round"/>
''',
    ),
    "reveil.svg": (
        "le réveil",
        "le réveil",
        f'''  <circle cx="100" cy="102" r="36" fill="{WOOD}"/>
  <circle cx="100" cy="102" r="26" fill="{CREAM}"/>
  <path d="M100 102 V82M100 102 L118 110" stroke="{CLAY}" stroke-width="3" stroke-linecap="round"/>
  <path d="M72 70 L58 52M128 70 L142 52" stroke="{INK}" stroke-width="5" stroke-linecap="round"/>
  <rect x="70" y="136" width="60" height="10" rx="4" fill="{TEAL}"/>
''',
    ),
    "lever.svg": (
        "se lever",
        "se lever",
        f'''  <rect x="48" y="118" width="104" height="28" rx="6" fill="{TEAL}"/>
  <circle cx="100" cy="70" r="14" fill="{SKIN}"/>
  <path d="M82 150c4-40 10-52 18-52s14 12 18 52" fill="{CLAY}"/>
  <path d="M84 96 L70 78M116 96 L138 70" stroke="{INK}" stroke-width="5" stroke-linecap="round"/>
''',
    ),
    "petitdej.svg": (
        "le petit déjeuner",
        "le petit déjeuner",
        f'''  <ellipse cx="100" cy="118" rx="48" ry="16" fill="{WOOD}"/>
  <ellipse cx="100" cy="104" rx="36" ry="22" fill="{CREAM}" stroke="{INK}" stroke-width="3"/>
  <ellipse cx="100" cy="100" rx="22" ry="10" fill="{OCHRE}"/>
  <path d="M132 86c14 0 18 10 10 18" fill="none" stroke="{CLAY}" stroke-width="4"/>
  <path d="M78 70c2-12 10-14 12-2" stroke="{SAGE}" stroke-width="3" fill="none"/>
''',
    ),
    "travailler.svg": (
        "travailler",
        "travailler",
        f'''  <rect x="50" y="78" width="100" height="62" rx="6" fill="{WOOD}"/>
  <rect x="62" y="90" width="52" height="36" fill="{CREAM}"/>
  <rect x="122" y="94" width="18" height="28" fill="{TEAL}"/>
  <circle cx="100" cy="58" r="12" fill="{SKIN}"/>
  <path d="M86 78c3-8 8-12 14-12s11 4 14 12" fill="{INK}"/>
''',
    ),
    "diner.svg": (
        "dîner",
        "dîner",
        f'''  <ellipse cx="100" cy="110" rx="44" ry="28" fill="{CREAM}" stroke="{INK}" stroke-width="3"/>
  <circle cx="100" cy="108" r="16" fill="{CLAY}"/>
  <path d="M54 86 l-16-28M146 86 l16-28" stroke="{TEAL_D}" stroke-width="5" stroke-linecap="round"/>
  <rect x="48" y="132" width="104" height="10" rx="3" fill="{WOOD}"/>
''',
    ),
    "coucher.svg": (
        "se coucher",
        "se coucher",
        f'''  <rect x="40" y="100" width="120" height="40" rx="8" fill="{TEAL}"/>
  <rect x="48" y="92" width="88" height="16" rx="6" fill="{CREAM}"/>
  <circle cx="58" cy="86" r="12" fill="{SKIN}"/>
  <path d="M40 140 h120" stroke="{WOOD}" stroke-width="8"/>
  <path d="M148 70 c8 4 10 16 0 22" fill="none" stroke="{NIGHT}" stroke-width="4"/>
''',
    ),
    "the.svg": (
        "le thé",
        "le thé",
        f'''  <path d="M60 88h64c4 0 8 6 8 16v28c0 14-12 22-32 22s-32-8-32-22V104c0-10 4-16 8-16z" fill="{CREAM}" stroke="{INK}" stroke-width="3"/>
  <path d="M132 108c16 0 22 10 14 22s-22 10-22 2" fill="none" stroke="{CLAY}" stroke-width="5"/>
  <ellipse cx="92" cy="88" rx="26" ry="7" fill="{TEAL}"/>
  <path d="M80 70c2-10 8-14 12-4M96 68c2-12 8-14 10-2" stroke="{SAGE}" stroke-width="3" fill="none"/>
''',
    ),
    "accueil.svg": (
        "l'accueil",
        "l'accueil",
        f'''  <rect x="44" y="70" width="112" height="72" rx="8" fill="{WOOD}"/>
  <rect x="56" y="82" width="88" height="24" fill="{CREAM}"/>
  <text x="100" y="100" text-anchor="middle" font-family="Georgia,serif" font-size="11" fill="{TEAL_D}">SEUIL</text>
  <circle cx="100" cy="54" r="12" fill="{SKIN}"/>
  <path d="M86 70c3-8 8-12 14-12s11 4 14 12" fill="{ROSE}"/>
  <rect x="70" y="118" width="60" height="12" rx="3" fill="{OCHRE}"/>
''',
    ),
    "moto.svg": (
        "la moto",
        "la moto",
        f'''  <circle cx="64" cy="128" r="22" fill="none" stroke="{INK}" stroke-width="6"/>
  <circle cx="140" cy="128" r="22" fill="none" stroke="{INK}" stroke-width="6"/>
  <path d="M64 128 L96 88 H128 L140 128" fill="none" stroke="{CLAY}" stroke-width="6"/>
  <path d="M96 88 L108 64" stroke="{TEAL_D}" stroke-width="5" stroke-linecap="round"/>
  <circle cx="128" cy="92" r="8" fill="{OCHRE}"/>
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
    "pause.svg": (
        "la pause",
        "la pause",
        f'''  <circle cx="78" cy="96" r="14" fill="{SKIN}"/>
  <path d="M62 148c3-30 9-42 16-42s13 12 16 42" fill="{TEAL}"/>
  <path d="M94 100 L118 88" stroke="{INK}" stroke-width="5" stroke-linecap="round"/>
  <path d="M118 70h28c4 0 6 4 6 10v16c0 8-6 12-16 12s-16-4-16-12V80c0-6 2-10 6-10z" fill="{CREAM}" stroke="{CLAY}" stroke-width="2"/>
''',
    ),
    "danse.svg": (
        "la danse",
        "la danse",
        f'''  <circle cx="108" cy="58" r="12" fill="{SKIN}"/>
  <path d="M86 150c6-40 12-56 22-56s14 16 18 40" fill="{ROSE}"/>
  <path d="M96 96 L70 80M124 100 L150 86" stroke="{INK}" stroke-width="5" stroke-linecap="round"/>
  <path d="M100 148 L84 168M120 140 L138 164" stroke="{CLAY_D}" stroke-width="5" stroke-linecap="round"/>
  <circle cx="62" cy="74" r="6" fill="{OCHRE}"/>
''',
    ),
    "jardin.svg": (
        "le jardin",
        "le jardin",
        f'''  <rect x="92" y="110" width="12" height="40" fill="{WOOD}"/>
  <ellipse cx="98" cy="92" rx="40" ry="28" fill="{SAGE}"/>
  <ellipse cx="80" cy="84" rx="16" ry="12" fill="{TEAL}" opacity="0.45"/>
  <circle cx="86" cy="104" r="5" fill="{ROSE}"/>
  <circle cx="110" cy="100" r="5" fill="{OCHRE}"/>
  <circle cx="100" cy="78" r="4" fill="{CLAY}"/>
''',
    ),
    "radio.svg": (
        "la radio",
        "la radio",
        f'''  <rect x="44" y="78" width="112" height="64" rx="10" fill="{WOOD}"/>
  <circle cx="86" cy="110" r="18" fill="{CREAM}" stroke="{INK}" stroke-width="3"/>
  <circle cx="86" cy="110" r="6" fill="{CLAY}"/>
  <rect x="116" y="94" width="28" height="10" rx="2" fill="{TEAL}"/>
  <rect x="116" y="112" width="28" height="10" rx="2" fill="{OCHRE}"/>
  <path d="M60 78 L52 56 M140 78 L150 54" stroke="{INK}" stroke-width="4"/>
''',
    ),
    "marche.svg": (
        "marcher",
        "marcher",
        f'''  <circle cx="108" cy="58" r="12" fill="{SKIN}"/>
  <path d="M92 150c6-44 10-58 16-58s12 16 18 44" fill="{TEAL}"/>
  <path d="M100 96 L78 118M124 100 L146 86" stroke="{INK}" stroke-width="5" stroke-linecap="round"/>
  <path d="M98 148 L86 168M120 140 L138 166" stroke="{CLAY_D}" stroke-width="5" stroke-linecap="round"/>
''',
    ),
    "invitation.svg": (
        "une invitation",
        "une invitation",
        f'''  <rect x="48" y="54" width="104" height="96" rx="8" fill="{CREAM}" stroke="{INK}" stroke-width="3"/>
  <path d="M48 54 L100 96 L152 54" fill="none" stroke="{CLAY}" stroke-width="3"/>
  <path d="M70 118 h60M70 132 h44" stroke="{TEAL}" stroke-width="3"/>
  <circle cx="100" cy="78" r="6" fill="{OCHRE}"/>
''',
    ),
    "daccord.svg": (
        "d'accord",
        "d'accord",
        f'''  <circle cx="70" cy="80" r="14" fill="{SKIN}"/>
  <circle cx="130" cy="80" r="14" fill="{SKIN_D}"/>
  <path d="M56 148c3-32 8-44 14-44s12 12 14 44" fill="{TEAL}"/>
  <path d="M116 148c3-32 8-44 14-44s12 12 14 44" fill="{CLAY}"/>
  <path d="M84 100 L100 114 L118 96" fill="none" stroke="{OCHRE}" stroke-width="5" stroke-linecap="round"/>
''',
    ),
    "refuse.svg": (
        "refuser",
        "refuser",
        f'''  <circle cx="100" cy="72" r="16" fill="{SKIN}"/>
  <path d="M76 150c4-40 12-52 24-52s20 12 24 52" fill="{TEAL}"/>
  <path d="M78 96 L64 114M122 96 L136 114" stroke="{INK}" stroke-width="5" stroke-linecap="round"/>
  <path d="M88 82c4-2 8-2 12 0" fill="none" stroke="{CLAY_D}" stroke-width="2"/>
  <path d="M70 56 L54 44M130 56 L146 44" stroke="{ROSE}" stroke-width="4" stroke-linecap="round"/>
''',
    ),
    "salle.svg": (
        "la salle",
        "la salle",
        f'''  <rect x="40" y="88" width="120" height="56" fill="{CREAM}" stroke="{INK}" stroke-width="3"/>
  <path d="M40 88 L100 48 L160 88" fill="{CLAY}"/>
  <rect x="88" y="108" width="24" height="36" fill="{WOOD}"/>
  <circle cx="72" cy="108" r="6" fill="{OCHRE}"/>
  <circle cx="128" cy="108" r="6" fill="{OCHRE}"/>
''',
    ),
    "lampion.svg": (
        "un lampion",
        "un lampion",
        f'''  <path d="M100 48 v18" stroke="{INK}" stroke-width="4"/>
  <path d="M70 66 h60 l-8 56c-6 16-38 16-44 0z" fill="{CLAY}"/>
  <path d="M78 86 h44M76 104 h48" stroke="{OCHRE}" stroke-width="3"/>
  <ellipse cx="100" cy="66" rx="30" ry="8" fill="{SUN}"/>
  <circle cx="54" cy="120" r="8" fill="{OCHRE}" opacity="0.6"/>
  <circle cx="150" cy="112" r="7" fill="{TEAL}" opacity="0.5"/>
''',
    ),
    "apresmidi.svg": (
        "l'après-midi",
        "l'après-midi",
        f'''  <circle cx="128" cy="70" r="22" fill="{SUN}"/>
  <rect x="48" y="108" width="16" height="40" fill="{WOOD}"/>
  <ellipse cx="56" cy="96" rx="22" ry="16" fill="{SAGE}"/>
  <path d="M80 148 Q100 120 140 148" fill="none" stroke="{TEAL}" stroke-width="5"/>
  <circle cx="70" cy="128" r="5" fill="{ROSE}"/>
''',
    ),
    "samedi.svg": (
        "samedi",
        "samedi",
        f'''  <rect x="52" y="48" width="96" height="108" rx="8" fill="{CREAM}" stroke="{INK}" stroke-width="3"/>
  <rect x="52" y="48" width="96" height="22" fill="{TEAL}"/>
  <circle cx="100" cy="108" r="22" fill="{OCHRE}"/>
  <text x="100" y="64" text-anchor="middle" font-family="Georgia,serif" font-size="11" fill="{CREAM}">SAM</text>
  <text x="100" y="114" text-anchor="middle" font-family="Georgia,serif" font-size="16" font-weight="700" fill="{INK}">6</text>
''',
    ),
    "weekend.svg": (
        "le week-end",
        "le week-end",
        f'''  <rect x="36" y="70" width="56" height="70" rx="6" fill="{CREAM}" stroke="{TEAL}" stroke-width="3"/>
  <rect x="108" y="70" width="56" height="70" rx="6" fill="{CREAM}" stroke="{CLAY}" stroke-width="3"/>
  <text x="64" y="112" text-anchor="middle" font-family="Georgia,serif" font-size="12" fill="{TEAL_D}">SAM</text>
  <text x="136" y="112" text-anchor="middle" font-family="Georgia,serif" font-size="12" fill="{CLAY_D}">DIM</text>
  <circle cx="100" cy="56" r="10" fill="{SUN}"/>
''',
    ),
    "fil.svg": (
        "le fil",
        "le fil",
        f'''  <path d="M30 88 H170" stroke="{OCHRE}" stroke-width="4" stroke-linecap="round"/>
  <rect x="48" y="70" width="28" height="36" rx="3" fill="{CREAM}" stroke="{CLAY}" stroke-width="2"/>
  <rect x="86" y="62" width="28" height="36" rx="3" fill="{CREAM}" stroke="{TEAL}" stroke-width="2"/>
  <rect x="124" y="74" width="28" height="36" rx="3" fill="{CREAM}" stroke="{WOOD}" stroke-width="2"/>
  <text x="62" y="92" text-anchor="middle" font-family="Georgia,serif" font-size="9" fill="{INK}">7 h</text>
  <text x="100" y="84" text-anchor="middle" font-family="Georgia,serif" font-size="9" fill="{INK}">12 h</text>
  <text x="138" y="96" text-anchor="middle" font-family="Georgia,serif" font-size="9" fill="{INK}">19 h</text>
''',
    ),
    "carte.svg": (
        "une carte",
        "une carte",
        f'''  <rect x="58" y="50" width="84" height="104" rx="6" fill="{CREAM}" stroke="{INK}" stroke-width="3"/>
  <circle cx="100" cy="88" r="18" fill="{OCHRE}"/>
  <path d="M100 88 V72M100 88 L112 96" stroke="{INK}" stroke-width="3" stroke-linecap="round"/>
  <path d="M74 124 h52M74 136 h36" stroke="{TEAL}" stroke-width="3"/>
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
