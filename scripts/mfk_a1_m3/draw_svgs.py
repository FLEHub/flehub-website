#!/usr/bin/env python3
"""Original MFK Module 3 illustrations — courtyard / terracotta-map style."""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "public/elearning/mfk-a1-m3"

PAPER = "#F4E8D4"
SKY = "#D7E8E2"
SAND = "#E8C99A"
TEAL = "#1E6B66"
TEAL_D = "#134E4A"
CLAY = "#C4563A"
CLAY_D = "#8E3B2A"
SAGE = "#7FA47A"
INK = "#3A2718"
CREAM = "#FFF8EE"
OCHRE = "#D9A441"
SKIN = "#E8B888"
WOOD = "#8B5A2B"
WHITE = "#FFFDF8"


def frame(aria: str, body: str, label: str) -> str:
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200" role="img" aria-label="{aria}">
  <rect width="200" height="200" rx="24" fill="{PAPER}"/>
  <rect x="9" y="9" width="182" height="182" rx="18" fill="none" stroke="{CLAY}" stroke-width="1.8" opacity="0.4"/>
  <path d="M18 18h164v62H18z" fill="{SKY}" opacity="0.55"/>
  <path d="M18 72c28-18 54-8 82-16 26-8 50 6 64 14v10H18z" fill="{SAGE}" opacity="0.35"/>
  <path d="M168 20c2 6-2 10-7 12 6 1 8 7 5 12 6-2 12 2 12 8 4-8 2-18-4-24-3-4-6-6-6-8z" fill="{TEAL}" opacity="0.18"/>
  <ellipse cx="100" cy="166" rx="74" ry="13" fill="{SAND}"/>
{body}
  <text x="100" y="188" text-anchor="middle" font-family="Georgia,serif" font-size="13" font-weight="700" fill="{INK}">{label}</text>
</svg>
'''


SCENES = {
    "marche.svg": (
        "le marché",
        "le marché",
        f'''  <ellipse cx="68" cy="150" rx="28" ry="7" fill="{CLAY_D}" opacity="0.18"/>
  <rect x="42" y="118" width="52" height="28" rx="3" fill="{WOOD}"/>
  <path d="M36 118h64l-8-22H44z" fill="{CLAY}"/>
  <path d="M44 96h48" stroke="{CLAY_D}" stroke-width="3"/>
  <circle cx="52" cy="132" r="6" fill="{OCHRE}"/>
  <circle cx="68" cy="134" r="5" fill="{TEAL}"/>
  <ellipse cx="84" cy="133" rx="7" ry="5" fill="{SAGE}"/>
  <ellipse cx="132" cy="152" rx="26" ry="7" fill="{CLAY_D}" opacity="0.16"/>
  <rect x="110" y="122" width="46" height="26" rx="3" fill="{WOOD}"/>
  <path d="M104 122h58l-10-20H114z" fill="{TEAL}"/>
  <path d="M114 102h38" stroke="{TEAL_D}" stroke-width="3"/>
  <rect x="118" y="130" width="10" height="8" fill="{CREAM}"/>
  <rect x="132" y="128" width="8" height="10" fill="{OCHRE}"/>
  <rect x="144" y="131" width="7" height="7" fill="{CLAY}"/>
  <circle cx="58" cy="88" r="9" fill="{SKIN}"/>
  <path d="M46 112c2-14 8-16 12-16s10 2 12 16" fill="{TEAL_D}"/>
  <circle cx="140" cy="92" r="8" fill="{SKIN}"/>
  <path d="M129 114c2-12 7-14 11-14s10 2 11 14" fill="{CLAY_D}"/>
''',
    ),
    "pharmacie.svg": (
        "la pharmacie",
        "la pharmacie",
        f'''  <rect x="48" y="70" width="104" height="86" rx="6" fill="{CREAM}"/>
  <rect x="48" y="70" width="104" height="22" fill="{TEAL}"/>
  <path d="M48 70h104v8H48z" fill="{TEAL_D}"/>
  <rect x="86" y="98" width="28" height="58" fill="{WOOD}"/>
  <circle cx="108" cy="128" r="2.2" fill="{OCHRE}"/>
  <rect x="58" y="102" width="20" height="22" fill="#B8D9C8"/>
  <rect x="122" y="102" width="20" height="22" fill="#B8D9C8"/>
  <rect x="86" y="44" width="28" height="26" rx="4" fill="{TEAL}"/>
  <rect x="96" y="50" width="8" height="16" fill="{WHITE}"/>
  <rect x="90" y="56" width="20" height="8" fill="{WHITE}"/>
  <path d="M70 70l30-18 30 18" fill="none" stroke="{CLAY}" stroke-width="4" stroke-linejoin="round"/>
''',
    ),
    "banque.svg": (
        "la banque",
        "la banque",
        f'''  <rect x="40" y="86" width="120" height="70" fill="{CREAM}"/>
  <path d="M32 86h136L100 48z" fill="{CLAY}"/>
  <path d="M32 86h136" stroke="{CLAY_D}" stroke-width="3"/>
  <rect x="56" y="102" width="18" height="36" fill="#C9B8A0"/>
  <rect x="91" y="102" width="18" height="36" fill="#C9B8A0"/>
  <rect x="126" y="102" width="18" height="36" fill="#C9B8A0"/>
  <rect x="88" y="118" width="24" height="38" fill="{WOOD}"/>
  <circle cx="70" cy="78" r="10" fill="{OCHRE}"/>
  <circle cx="70" cy="78" r="6" fill="#E8C25A"/>
  <path d="M70 70v16M64 78h12" stroke="{INK}" stroke-width="1.4"/>
''',
    ),
    "parc.svg": (
        "le parc",
        "le parc",
        f'''  <ellipse cx="64" cy="148" rx="22" ry="7" fill="{TEAL_D}" opacity="0.2"/>
  <path d="M64 148c-18-4-22-40-8-58 6 10 12 10 18 0 12 18 8 54-10 58z" fill="{SAGE}"/>
  <rect x="60" y="118" width="8" height="30" fill="{WOOD}"/>
  <ellipse cx="136" cy="150" rx="20" ry="6" fill="{TEAL_D}" opacity="0.18"/>
  <path d="M136 150c-16-4-20-36-6-52 5 8 11 8 16 0 11 16 8 48-10 52z" fill="{TEAL}"/>
  <rect x="132" y="122" width="8" height="28" fill="{WOOD}"/>
  <rect x="78" y="128" width="44" height="8" rx="2" fill="{WOOD}"/>
  <rect x="82" y="118" width="6" height="12" fill="{WOOD}"/>
  <rect x="112" y="118" width="6" height="12" fill="{WOOD}"/>
  <circle cx="100" cy="108" r="5" fill="{OCHRE}" opacity="0.7"/>
  <circle cx="86" cy="102" r="3.5" fill="{CLAY}" opacity="0.6"/>
''',
    ),
    "rue.svg": (
        "la rue",
        "la rue",
        f'''  <path d="M30 156 L88 88 h24 L170 156z" fill="#C4B49A"/>
  <path d="M100 90 v64" stroke="{CREAM}" stroke-width="3" stroke-dasharray="7 6"/>
  <rect x="36" y="78" width="28" height="40" fill="{CREAM}"/>
  <path d="M34 78h32l-16-16z" fill="{CLAY}"/>
  <rect x="136" y="70" width="30" height="48" fill="{CREAM}"/>
  <path d="M134 70h34l-17-16z" fill="{TEAL}"/>
  <rect x="44" y="92" width="8" height="10" fill="#B8D4C8"/>
  <rect x="146" y="86" width="8" height="10" fill="#B8D4C8"/>
  <circle cx="78" cy="132" r="6" fill="{SKIN}"/>
  <path d="M70 150c2-10 5-12 8-12s7 2 8 12" fill="{TEAL_D}"/>
''',
    ),
    "carte.svg": (
        "la carte",
        "la carte",
        f'''  <rect x="42" y="48" width="116" height="108" rx="8" fill="{CREAM}" stroke="{INK}" stroke-width="2"/>
  <path d="M56 86c24-16 40 8 62-4 14-8 28 4 36 10" fill="none" stroke="{TEAL}" stroke-width="3" stroke-linecap="round"/>
  <path d="M60 128c18-6 30 8 52 0 16-6 30 4 40 8" fill="none" stroke="{SAGE}" stroke-width="2.5"/>
  <circle cx="78" cy="80" r="5" fill="{CLAY}"/>
  <circle cx="124" cy="96" r="5" fill="{OCHRE}"/>
  <circle cx="98" cy="126" r="5" fill="{TEAL}"/>
  <rect x="52" y="56" width="22" height="8" rx="2" fill="{CLAY}" opacity="0.35"/>
  <path d="M148 58l8 4-8 4-8-4z" fill="{TEAL_D}"/>
''',
    ),
    "gauche.svg": (
        "à gauche",
        "à gauche",
        f'''  <path d="M150 150 C150 110 148 96 118 88 C92 82 78 96 70 118" fill="none" stroke="{SAND}" stroke-width="18" stroke-linecap="round"/>
  <path d="M150 150 C150 110 148 96 118 88 C92 82 78 96 70 118" fill="none" stroke="{CLAY}" stroke-width="3" stroke-dasharray="8 7" opacity="0.7"/>
  <path d="M78 104 L52 122 L82 128" fill="{TEAL}"/>
  <circle cx="132" cy="118" r="8" fill="{SKIN}"/>
  <path d="M122 146c2-16 7-18 10-18s9 2 11 18" fill="{TEAL_D}"/>
''',
    ),
    "droite.svg": (
        "à droite",
        "à droite",
        f'''  <path d="M50 150 C50 110 52 96 82 88 C108 82 122 96 130 118" fill="none" stroke="{SAND}" stroke-width="18" stroke-linecap="round"/>
  <path d="M50 150 C50 110 52 96 82 88 C108 82 122 96 130 118" fill="none" stroke="{CLAY}" stroke-width="3" stroke-dasharray="8 7" opacity="0.7"/>
  <path d="M122 104 L148 122 L118 128" fill="{TEAL}"/>
  <circle cx="68" cy="118" r="8" fill="{SKIN}"/>
  <path d="M58 146c2-16 7-18 10-18s9 2 11 18" fill="{CLAY_D}"/>
''',
    ),
    "tout-droit.svg": (
        "tout droit",
        "tout droit",
        f'''  <path d="M100 158 V62" stroke="{SAND}" stroke-width="20" stroke-linecap="round"/>
  <path d="M100 154 V70" stroke="{CLAY}" stroke-width="3" stroke-dasharray="8 7" opacity="0.7"/>
  <path d="M84 78 L100 50 L116 78z" fill="{TEAL}"/>
  <circle cx="100" cy="120" r="8" fill="{SKIN}"/>
  <path d="M90 148c2-16 7-18 10-18s9 2 11 18" fill="{TEAL_D}"/>
''',
    ),
    "bus.svg": (
        "le bus",
        "le bus",
        f'''  <rect x="34" y="86" width="132" height="52" rx="12" fill="{TEAL}"/>
  <rect x="34" y="86" width="132" height="16" rx="12" fill="{TEAL_D}"/>
  <rect x="46" y="106" width="28" height="16" rx="3" fill="#C5E4DC"/>
  <rect x="80" y="106" width="28" height="16" rx="3" fill="#C5E4DC"/>
  <rect x="114" y="106" width="20" height="16" rx="3" fill="#C5E4DC"/>
  <rect x="140" y="108" width="16" height="22" rx="3" fill="{OCHRE}"/>
  <circle cx="62" cy="142" r="11" fill="{INK}"/>
  <circle cx="62" cy="142" r="6" fill="#C9C2B2"/>
  <circle cx="138" cy="142" r="11" fill="{INK}"/>
  <circle cx="138" cy="142" r="6" fill="#C9C2B2"/>
  <rect x="54" y="74" width="18" height="14" rx="3" fill="{CLAY}"/>
''',
    ),
    "minibus.svg": (
        "le minibus",
        "le minibus",
        f'''  <rect x="46" y="92" width="108" height="44" rx="10" fill="{CLAY}"/>
  <rect x="46" y="92" width="108" height="14" rx="10" fill="{CLAY_D}"/>
  <rect x="56" y="110" width="22" height="14" rx="2" fill="#F0D8B0"/>
  <rect x="84" y="110" width="22" height="14" rx="2" fill="#F0D8B0"/>
  <rect x="128" y="112" width="16" height="18" rx="2" fill="{OCHRE}"/>
  <circle cx="70" cy="140" r="10" fill="{INK}"/>
  <circle cx="70" cy="140" r="5" fill="#C9C2B2"/>
  <circle cx="132" cy="140" r="10" fill="{INK}"/>
  <circle cx="132" cy="140" r="5" fill="#C9C2B2"/>
  <text x="100" y="88" text-anchor="middle" font-family="Georgia,serif" font-size="9" fill="{TEAL_D}">Figuier 7</text>
''',
    ),
    "velo.svg": (
        "le vélo",
        "le vélo",
        f'''  <circle cx="64" cy="132" r="22" fill="none" stroke="{INK}" stroke-width="5"/>
  <circle cx="136" cy="132" r="22" fill="none" stroke="{INK}" stroke-width="5"/>
  <circle cx="64" cy="132" r="5" fill="{OCHRE}"/>
  <circle cx="136" cy="132" r="5" fill="{OCHRE}"/>
  <path d="M64 132 L96 96 L128 132 M96 96 L96 80 M86 80h28" fill="none" stroke="{TEAL_D}" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M96 96 L64 132" stroke="{CLAY}" stroke-width="3"/>
  <circle cx="108" cy="70" r="8" fill="{SKIN}"/>
''',
    ),
    "moto.svg": (
        "la moto",
        "la moto",
        f'''  <circle cx="58" cy="138" r="16" fill="none" stroke="{INK}" stroke-width="6"/>
  <circle cx="142" cy="138" r="16" fill="none" stroke="{INK}" stroke-width="6"/>
  <path d="M58 138 L88 112 L130 116 L142 138" fill="none" stroke="{TEAL}" stroke-width="6" stroke-linejoin="round"/>
  <path d="M88 112 L100 92 L124 96" fill="none" stroke="{CLAY}" stroke-width="5" stroke-linecap="round"/>
  <rect x="96" y="108" width="28" height="10" rx="3" fill="{OCHRE}"/>
  <circle cx="118" cy="80" r="8" fill="{SKIN}"/>
  <path d="M108 100c2-10 6-12 10-12s9 2 10 12" fill="{TEAL_D}"/>
''',
    ),
    "a-pied.svg": (
        "à pied",
        "à pied",
        f'''  <circle cx="100" cy="70" r="14" fill="{SKIN}"/>
  <path d="M78 156c4-36 12-48 22-48s18 12 22 48" fill="{TEAL}"/>
  <path d="M88 108 L72 132" stroke="{INK}" stroke-width="5" stroke-linecap="round"/>
  <path d="M112 108 L136 96" stroke="{INK}" stroke-width="5" stroke-linecap="round"/>
  <path d="M90 156 L82 172" stroke="{CLAY_D}" stroke-width="5" stroke-linecap="round"/>
  <path d="M110 156 L124 172" stroke="{CLAY_D}" stroke-width="5" stroke-linecap="round"/>
''',
    ),
    "arret.svg": (
        "l'arrêt",
        "l'arrêt",
        f'''  <rect x="92" y="48" width="10" height="110" fill="{WOOD}"/>
  <rect x="64" y="44" width="72" height="46" rx="6" fill="{TEAL}"/>
  <rect x="70" y="50" width="60" height="34" rx="3" fill="{CREAM}"/>
  <path d="M76 62h48M76 70h36" stroke="{INK}" stroke-width="2"/>
  <rect x="70" y="148" width="18" height="8" rx="2" fill="{CLAY}"/>
  <circle cx="130" cy="132" r="7" fill="{SKIN}"/>
  <path d="M120 154c2-12 6-14 10-14s9 2 10 14" fill="{TEAL_D}"/>
''',
    ),
    "chambre.svg": (
        "une chambre",
        "une chambre",
        f'''  <rect x="36" y="58" width="128" height="96" rx="6" fill="{CREAM}"/>
  <rect x="36" y="58" width="128" height="16" fill="{CLAY}" opacity="0.25"/>
  <rect x="50" y="108" width="78" height="34" rx="4" fill="{TEAL}"/>
  <rect x="50" y="100" width="78" height="14" rx="4" fill="{CLAY}"/>
  <circle cx="86" cy="96" r="8" fill="{CREAM}"/>
  <rect x="140" y="78" width="14" height="36" fill="#C9B8A0"/>
  <rect x="54" y="74" width="22" height="16" fill="#B8D4C8"/>
  <path d="M36 154h128" stroke="{WOOD}" stroke-width="4"/>
''',
    ),
    "cuisine.svg": (
        "une cuisine",
        "une cuisine",
        f'''  <rect x="40" y="88" width="120" height="56" rx="4" fill="{CREAM}"/>
  <rect x="40" y="88" width="120" height="12" fill="{WOOD}"/>
  <rect x="50" y="108" width="28" height="22" rx="3" fill="#B8D4C8"/>
  <circle cx="92" cy="120" r="10" fill="{TEAL}"/>
  <circle cx="92" cy="120" r="4" fill="{TEAL_D}"/>
  <rect x="114" y="110" width="34" height="20" rx="3" fill="{CLAY}"/>
  <path d="M70 88 V68 h20 v20" fill="none" stroke="{INK}" stroke-width="3"/>
  <ellipse cx="80" cy="64" rx="10" ry="5" fill="{SAGE}"/>
''',
    ),
    "douche.svg": (
        "une douche",
        "une douche",
        f'''  <rect x="62" y="52" width="76" height="108" rx="8" fill="#D5E6E2"/>
  <rect x="62" y="52" width="76" height="14" fill="{TEAL}"/>
  <path d="M100 66 V86" stroke="{INK}" stroke-width="4"/>
  <path d="M86 86h28" stroke="{INK}" stroke-width="4" stroke-linecap="round"/>
  <path d="M90 96c2 16 6 28 10 36M100 96c0 18 2 28 0 38M110 96c-2 16-6 28-10 36" stroke="{TEAL}" stroke-width="2.4" fill="none" opacity="0.7"/>
  <ellipse cx="100" cy="150" rx="22" ry="6" fill="{TEAL}" opacity="0.25"/>
''',
    ),
    "cle.svg": (
        "la clé",
        "la clé",
        f'''  <circle cx="72" cy="96" r="26" fill="none" stroke="{OCHRE}" stroke-width="12"/>
  <circle cx="72" cy="96" r="10" fill="{PAPER}"/>
  <path d="M94 96 H158" stroke="{OCHRE}" stroke-width="12" stroke-linecap="round"/>
  <path d="M136 96 v18M150 96 v24" stroke="{OCHRE}" stroke-width="10" stroke-linecap="round"/>
  <circle cx="72" cy="96" r="4" fill="{INK}"/>
''',
    ),
    "toit.svg": (
        "un toit",
        "un toit",
        f'''  <rect x="48" y="96" width="104" height="56" fill="{CREAM}"/>
  <path d="M36 100 L100 50 L164 100z" fill="{CLAY}"/>
  <path d="M36 100 L100 50 L164 100" fill="none" stroke="{CLAY_D}" stroke-width="3"/>
  <rect x="88" y="118" width="24" height="34" fill="{WOOD}"/>
  <rect x="60" y="110" width="16" height="14" fill="#B8D4C8"/>
  <rect x="124" y="110" width="16" height="14" fill="#B8D4C8"/>
  <circle cx="154" cy="64" r="10" fill="{OCHRE}" opacity="0.7"/>
''',
    ),
    "pont.svg": (
        "le pont",
        "le pont",
        f'''  <path d="M20 128 C60 80 140 80 180 128" fill="none" stroke="{WOOD}" stroke-width="10"/>
  <path d="M20 128 C60 80 140 80 180 128" fill="none" stroke="{INK}" stroke-width="2" opacity="0.35"/>
  <rect x="18" y="124" width="164" height="10" fill="{SAND}"/>
  <path d="M40 150 C70 132 130 132 160 150" fill="{TEAL}" opacity="0.35"/>
  <rect x="46" y="96" width="8" height="30" fill="{WOOD}"/>
  <rect x="146" y="96" width="8" height="30" fill="{WOOD}"/>
  <circle cx="100" cy="108" r="6" fill="{SKIN}"/>
  <path d="M92 128c2-10 5-12 8-12s7 2 8 12" fill="{TEAL_D}"/>
''',
    ),
    "fontaine.svg": (
        "la fontaine",
        "la fontaine",
        f'''  <ellipse cx="100" cy="148" rx="46" ry="12" fill="{TEAL}" opacity="0.3"/>
  <rect x="70" y="118" width="60" height="18" rx="8" fill="{TEAL}"/>
  <rect x="90" y="86" width="20" height="36" fill="#C9B8A0"/>
  <circle cx="100" cy="80" r="12" fill="{SAGE}"/>
  <path d="M100 80c-8 10-6 20 0 28M92 88c8 8 12 8 16 0" fill="none" stroke="{TEAL_D}" stroke-width="2"/>
  <path d="M88 70c4-10 12-12 16-2" fill="{SAGE}"/>
''',
    ),
    "guide.svg": (
        "le guide",
        "le guide",
        f'''  <circle cx="88" cy="68" r="14" fill="{SKIN}"/>
  <path d="M66 150c4-38 12-50 22-50s18 12 22 50" fill="{TEAL}"/>
  <path d="M108 108 L136 92" stroke="{INK}" stroke-width="5" stroke-linecap="round"/>
  <rect x="128" y="70" width="36" height="28" rx="3" fill="{CREAM}" stroke="{INK}" stroke-width="1.6"/>
  <path d="M134 84h24M134 90h16" stroke="{TEAL}" stroke-width="2"/>
  <circle cx="148" cy="78" r="3" fill="{CLAY}"/>
''',
    ),
    "valise.svg": (
        "la valise",
        "la valise",
        f'''  <rect x="56" y="78" width="88" height="70" rx="8" fill="{CLAY}"/>
  <rect x="56" y="78" width="88" height="16" fill="{CLAY_D}"/>
  <rect x="80" y="58" width="40" height="22" rx="8" fill="none" stroke="{INK}" stroke-width="6"/>
  <rect x="92" y="104" width="16" height="10" rx="2" fill="{OCHRE}"/>
  <path d="M68 108h64" stroke="{CREAM}" stroke-width="2" opacity="0.4"/>
''',
    ),
    "horloge.svg": (
        "l'heure",
        "l'heure",
        f'''  <circle cx="100" cy="104" r="46" fill="{CREAM}" stroke="{INK}" stroke-width="5"/>
  <circle cx="100" cy="104" r="38" fill="{WHITE}"/>
  <path d="M100 104 L100 76" stroke="{TEAL_D}" stroke-width="5" stroke-linecap="round"/>
  <path d="M100 104 L124 112" stroke="{CLAY}" stroke-width="4" stroke-linecap="round"/>
  <circle cx="100" cy="104" r="4" fill="{INK}"/>
  <circle cx="100" cy="68" r="3" fill="{INK}"/>
  <circle cx="136" cy="104" r="3" fill="{INK}"/>
  <circle cx="100" cy="140" r="3" fill="{INK}"/>
  <circle cx="64" cy="104" r="3" fill="{INK}"/>
''',
    ),
    "porte.svg": (
        "la porte",
        "la porte",
        f'''  <rect x="62" y="48" width="76" height="112" rx="6" fill="{WOOD}"/>
  <rect x="70" y="56" width="60" height="96" rx="4" fill="#A56B36"/>
  <circle cx="118" cy="108" r="5" fill="{OCHRE}"/>
  <rect x="84" y="70" width="16" height="22" rx="2" fill="#E6D2B0" opacity="0.5"/>
  <path d="M54 160h92" stroke="{INK}" stroke-width="6" stroke-linecap="round"/>
  <path d="M70 48h60" stroke="{CLAY}" stroke-width="6"/>
''',
    ),
    "figuier.svg": (
        "le figuier",
        "le figuier",
        f'''  <rect x="92" y="108" width="16" height="48" fill="{WOOD}"/>
  <ellipse cx="100" cy="88" rx="54" ry="38" fill="{SAGE}"/>
  <ellipse cx="78" cy="78" rx="22" ry="16" fill="{TEAL}" opacity="0.45"/>
  <ellipse cx="122" cy="74" rx="20" ry="15" fill="{TEAL}" opacity="0.4"/>
  <circle cx="86" cy="96" r="6" fill="{CLAY}" opacity="0.75"/>
  <circle cx="112" cy="102" r="5" fill="{CLAY}" opacity="0.7"/>
  <circle cx="100" cy="70" r="5" fill="{OCHRE}" opacity="0.7"/>
''',
    ),
    "affiche.svg": (
        "l'affiche",
        "l'affiche",
        f'''  <rect x="52" y="44" width="96" height="112" rx="4" fill="{WOOD}"/>
  <rect x="62" y="56" width="76" height="54" rx="3" fill="{CREAM}"/>
  <path d="M70 70h60M70 80h48M70 90h54" stroke="{INK}" stroke-width="2.4"/>
  <rect x="62" y="116" width="34" height="28" rx="2" fill="{TEAL}" opacity="0.35"/>
  <rect x="104" y="116" width="34" height="28" rx="2" fill="{CLAY}" opacity="0.35"/>
  <circle cx="70" cy="52" r="3" fill="{INK}"/>
  <circle cx="130" cy="52" r="3" fill="{INK}"/>
''',
    ),
    "lit.svg": (
        "un lit",
        "un lit",
        f'''  <rect x="38" y="108" width="124" height="36" rx="6" fill="{TEAL}"/>
  <rect x="44" y="90" width="112" height="28" rx="8" fill="{CREAM}"/>
  <rect x="44" y="82" width="40" height="20" rx="8" fill="{CLAY}"/>
  <rect x="38" y="132" width="12" height="20" fill="{WOOD}"/>
  <rect x="150" y="132" width="12" height="20" fill="{WOOD}"/>
  <circle cx="72" cy="88" r="6" fill="{CREAM}"/>
''',
    ),
    "loyer.svg": (
        "le loyer",
        "le loyer",
        f'''  <rect x="58" y="64" width="84" height="80" rx="6" fill="{CREAM}" stroke="{INK}" stroke-width="2"/>
  <rect x="58" y="64" width="84" height="18" fill="{TEAL}"/>
  <path d="M70 100h60M70 112h44M70 124h52" stroke="{INK}" stroke-width="2"/>
  <circle cx="132" cy="148" r="18" fill="{OCHRE}"/>
  <text x="132" y="154" text-anchor="middle" font-family="Georgia,serif" font-size="14" font-weight="700" fill="{INK}">F</text>
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
