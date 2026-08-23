#!/usr/bin/env python3
"""Original MFK Module 4 illustrations — portrait-album style (rose + terracotta + teal)."""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "public/elearning/mfk-a1-m4"

PAPER = "#F6E6DC"
SKY = "#E8D5C8"
SAND = "#E8C99A"
TEAL = "#1E6B66"
TEAL_D = "#134E4A"
CLAY = "#C4563A"
CLAY_D = "#8E3B2A"
ROSE = "#C46B6B"
ROSE_D = "#8E3F45"
SAGE = "#7FA47A"
INK = "#3A2718"
CREAM = "#FFF6EE"
OCHRE = "#D9A441"
SKIN = "#E8B888"
SKIN_D = "#C48A5A"
WOOD = "#8B5A2B"
WHITE = "#FFFDF8"


def frame(aria: str, body: str, label: str) -> str:
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200" role="img" aria-label="{aria}">
  <rect width="200" height="200" rx="24" fill="{PAPER}"/>
  <rect x="9" y="9" width="182" height="182" rx="18" fill="none" stroke="{ROSE}" stroke-width="1.8" opacity="0.45"/>
  <ellipse cx="100" cy="86" rx="70" ry="52" fill="{SKY}" opacity="0.55"/>
  <path d="M168 18c3 7-1 12-6 14 6 2 9 8 6 13 6-2 13 3 13 9 4-9 1-20-5-26-3-4-7-7-8-10z" fill="{TEAL}" opacity="0.16"/>
  <ellipse cx="100" cy="166" rx="74" ry="13" fill="{SAND}"/>
{body}
  <text x="100" y="188" text-anchor="middle" font-family="Georgia,serif" font-size="13" font-weight="700" fill="{INK}">{label}</text>
</svg>
'''


SCENES = {
    "mere.svg": (
        "la mère",
        "la mère",
        f'''  <circle cx="100" cy="72" r="18" fill="{SKIN}"/>
  <path d="M78 72c4-22 14-28 22-28s18 6 22 28" fill="{INK}"/>
  <path d="M72 150c4-40 14-52 28-52s24 12 28 52" fill="{ROSE}"/>
  <circle cx="94" cy="70" r="2" fill="{INK}"/>
  <circle cx="108" cy="70" r="2" fill="{INK}"/>
  <path d="M94 80c4 4 8 4 12 0" fill="none" stroke="{CLAY_D}" stroke-width="2"/>
''',
    ),
    "pere.svg": (
        "le père",
        "le père",
        f'''  <circle cx="100" cy="70" r="17" fill="{SKIN_D}"/>
  <path d="M82 62c6-16 12-18 18-18s12 2 18 18" fill="{INK}"/>
  <path d="M74 150c4-40 14-50 26-50s22 10 26 50" fill="{TEAL}"/>
  <rect x="86" y="66" width="28" height="6" rx="2" fill="{INK}" opacity="0.35"/>
  <circle cx="93" cy="68" r="1.8" fill="{INK}"/>
  <circle cx="107" cy="68" r="1.8" fill="{INK}"/>
''',
    ),
    "frere.svg": (
        "le frère",
        "le frère",
        f'''  <circle cx="100" cy="68" r="16" fill="{SKIN}"/>
  <path d="M84 60c6-14 10-16 16-16s10 2 16 16" fill="{INK}"/>
  <path d="M76 150c4-38 14-50 24-50s20 12 24 50" fill="{OCHRE}"/>
  <path d="M88 150h24v8H88z" fill="{TEAL_D}"/>
  <circle cx="94" cy="66" r="1.8" fill="{INK}"/>
  <circle cx="106" cy="66" r="1.8" fill="{INK}"/>
''',
    ),
    "soeur.svg": (
        "la sœur",
        "la sœur",
        f'''  <circle cx="100" cy="70" r="16" fill="{SKIN}"/>
  <path d="M78 74c6-24 14-30 22-30s16 6 22 30" fill="{CLAY_D}"/>
  <path d="M76 150c4-38 12-50 24-50s20 12 24 50" fill="{ROSE}"/>
  <circle cx="78" cy="92" r="5" fill="{OCHRE}"/>
  <circle cx="122" cy="92" r="5" fill="{OCHRE}"/>
  <path d="M94 78c4 3 8 3 12 0" fill="none" stroke="{CLAY}" stroke-width="2"/>
''',
    ),
    "enfant.svg": (
        "un enfant",
        "un enfant",
        f'''  <circle cx="100" cy="86" r="14" fill="{SKIN}"/>
  <path d="M86 80c4-12 8-14 14-14s10 2 14 14" fill="{INK}"/>
  <path d="M80 154c3-30 10-40 20-40s17 10 20 40" fill="{SAGE}"/>
  <circle cx="78" cy="130" r="8" fill="{OCHRE}"/>
  <circle cx="94" cy="84" r="1.6" fill="{INK}"/>
  <circle cx="106" cy="84" r="1.6" fill="{INK}"/>
''',
    ),
    "famille.svg": (
        "la famille",
        "la famille",
        f'''  <circle cx="70" cy="78" r="12" fill="{SKIN_D}"/>
  <path d="M54 148c3-30 10-40 16-40s13 10 16 40" fill="{TEAL}"/>
  <circle cx="108" cy="74" r="12" fill="{SKIN}"/>
  <path d="M92 148c3-32 10-44 16-44s13 12 16 44" fill="{ROSE}"/>
  <circle cx="140" cy="92" r="10" fill="{SKIN}"/>
  <path d="M128 150c2-24 7-32 12-32s10 8 12 32" fill="{OCHRE}"/>
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
    "petit.svg": (
        "petit",
        "petit",
        f'''  <circle cx="100" cy="96" r="12" fill="{SKIN}"/>
  <path d="M82 158c4-28 10-38 18-38s14 10 18 38" fill="{CLAY}"/>
  <path d="M90 122 L78 134M110 122 L122 134" stroke="{INK}" stroke-width="4" stroke-linecap="round"/>
''',
    ),
    "cheveux.svg": (
        "les cheveux",
        "les cheveux",
        f'''  <circle cx="100" cy="96" r="28" fill="{SKIN}"/>
  <path d="M70 96c6-36 18-44 30-44s24 8 30 44c-8-18-18-20-30-20s-22 2-30 20z" fill="{INK}"/>
  <path d="M68 100c-6 10-4 22 4 20M132 100c6 10 4 22-4 20" fill="{INK}"/>
  <circle cx="90" cy="100" r="3" fill="{INK}"/>
  <circle cx="110" cy="100" r="3" fill="{INK}"/>
''',
    ),
    "lunettes.svg": (
        "les lunettes",
        "les lunettes",
        f'''  <circle cx="100" cy="88" r="22" fill="{SKIN}"/>
  <path d="M78 78c6-16 14-18 22-18s16 2 22 16" fill="{INK}"/>
  <circle cx="88" cy="92" r="10" fill="none" stroke="{TEAL_D}" stroke-width="3"/>
  <circle cx="112" cy="92" r="10" fill="none" stroke="{TEAL_D}" stroke-width="3"/>
  <path d="M98 92h4" stroke="{TEAL_D}" stroke-width="3"/>
  <path d="M78 90h-10M132 90h10" stroke="{INK}" stroke-width="3"/>
''',
    ),
    "livre.svg": (
        "un livre",
        "un livre",
        f'''  <path d="M52 56h44v84H52a8 8 0 0 1-8-8V64a8 8 0 0 1 8-8z" fill="{TEAL}"/>
  <path d="M104 56h44a8 8 0 0 1 8 8v68a8 8 0 0 1-8 8h-44z" fill="{TEAL_D}"/>
  <path d="M100 56v84" stroke="{CREAM}" stroke-width="3"/>
  <path d="M64 76h24M64 90h20M116 76h24M116 90h18" stroke="{OCHRE}" stroke-width="2"/>
''',
    ),
    "musique.svg": (
        "la musique",
        "la musique",
        f'''  <ellipse cx="78" cy="128" rx="18" ry="12" fill="{INK}"/>
  <ellipse cx="128" cy="118" rx="16" ry="11" fill="{INK}"/>
  <path d="M96 128 V64 h50 V118" fill="none" stroke="{ROSE}" stroke-width="6"/>
  <path d="M146 64c8 4 10 12 4 18" fill="none" stroke="{OCHRE}" stroke-width="4"/>
  <circle cx="70" cy="70" r="5" fill="{TEAL}"/>
  <circle cx="58" cy="84" r="3.5" fill="{TEAL}"/>
''',
    ),
    "football.svg": (
        "le football",
        "le football",
        f'''  <circle cx="100" cy="100" r="38" fill="{CREAM}" stroke="{INK}" stroke-width="3"/>
  <path d="M100 70 L118 84 L112 106 L88 106 L82 84z" fill="{INK}"/>
  <path d="M118 84 L136 92M82 84 L64 92M112 106 L124 128M88 106 L76 128" stroke="{INK}" stroke-width="3"/>
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
    "portrait.svg": (
        "un portrait",
        "un portrait",
        f'''  <rect x="48" y="40" width="104" height="120" rx="6" fill="{WOOD}"/>
  <rect x="58" y="50" width="84" height="88" rx="4" fill="{CREAM}"/>
  <circle cx="100" cy="84" r="16" fill="{SKIN}"/>
  <path d="M82 132c4-22 10-28 18-28s14 6 18 28" fill="{TEAL}"/>
  <rect x="70" y="146" width="60" height="8" fill="{ROSE}"/>
''',
    ),
    "maison.svg": (
        "la maison",
        "la maison",
        f'''  <rect x="50" y="96" width="100" height="54" fill="{CREAM}"/>
  <path d="M40 100 L100 52 L160 100z" fill="{CLAY}"/>
  <rect x="88" y="116" width="24" height="34" fill="{WOOD}"/>
  <rect x="62" y="108" width="16" height="14" fill="#C9D8C8"/>
  <rect x="122" y="108" width="16" height="14" fill="#C9D8C8"/>
''',
    ),
    "ballon.svg": (
        "un ballon",
        "un ballon",
        f'''  <circle cx="100" cy="96" r="40" fill="{OCHRE}"/>
  <path d="M100 56c18 12 28 28 28 40s-10 28-28 40c-18-12-28-28-28-40s10-28 28-40z" fill="none" stroke="{INK}" stroke-width="3"/>
  <path d="M68 80h64M68 112h64" stroke="{CREAM}" stroke-width="3"/>
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
    "tete.svg": (
        "la tête",
        "la tête",
        f'''  <circle cx="100" cy="96" r="40" fill="{SKIN}"/>
  <path d="M68 86c8-28 18-34 32-34s24 6 32 34" fill="{INK}"/>
  <circle cx="86" cy="96" r="4" fill="{INK}"/>
  <circle cx="114" cy="96" r="4" fill="{INK}"/>
  <path d="M88 116c8 8 16 8 24 0" fill="none" stroke="{CLAY_D}" stroke-width="3"/>
''',
    ),
    "main.svg": (
        "la main",
        "la main",
        f'''  <ellipse cx="100" cy="128" rx="28" ry="22" fill="{SKIN}"/>
  <rect x="72" y="62" width="12" height="56" rx="6" fill="{SKIN}"/>
  <rect x="88" y="50" width="12" height="70" rx="6" fill="{SKIN}"/>
  <rect x="104" y="54" width="12" height="66" rx="6" fill="{SKIN}"/>
  <rect x="120" y="66" width="12" height="52" rx="6" fill="{SKIN}"/>
  <rect x="58" y="100" width="22" height="14" rx="7" fill="{SKIN}" transform="rotate(-25 69 107)"/>
''',
    ),
    "pied.svg": (
        "le pied",
        "le pied",
        f'''  <ellipse cx="108" cy="128" rx="46" ry="22" fill="{SKIN}"/>
  <rect x="78" y="70" width="22" height="58" rx="10" fill="{SKIN}"/>
  <ellipse cx="70" cy="132" rx="10" ry="7" fill="{SKIN_D}"/>
  <ellipse cx="88" cy="138" rx="8" ry="6" fill="{SKIN_D}"/>
  <ellipse cx="104" cy="140" rx="8" ry="6" fill="{SKIN_D}"/>
  <ellipse cx="120" cy="138" rx="8" ry="6" fill="{SKIN_D}"/>
  <ellipse cx="136" cy="132" rx="8" ry="6" fill="{SKIN_D}"/>
''',
    ),
    "dos.svg": (
        "le dos",
        "le dos",
        f'''  <circle cx="100" cy="58" r="14" fill="{SKIN}"/>
  <path d="M70 150c6-52 14-70 30-70s24 18 30 70" fill="{TEAL}"/>
  <path d="M100 80 v50" stroke="{CREAM}" stroke-width="3" stroke-dasharray="6 5"/>
  <path d="M84 96 L70 88M116 96 L130 88" stroke="{INK}" stroke-width="4" stroke-linecap="round"/>
''',
    ),
    "sourire.svg": (
        "un sourire",
        "un sourire",
        f'''  <circle cx="100" cy="96" r="40" fill="{SKIN}"/>
  <circle cx="84" cy="88" r="4" fill="{INK}"/>
  <circle cx="116" cy="88" r="4" fill="{INK}"/>
  <path d="M78 108c10 16 34 16 44 0" fill="none" stroke="{CLAY}" stroke-width="5" stroke-linecap="round"/>
  <circle cx="76" cy="100" r="6" fill="{ROSE}" opacity="0.35"/>
  <circle cx="124" cy="100" r="6" fill="{ROSE}" opacity="0.35"/>
''',
    ),
    "fatigue.svg": (
        "fatigué",
        "fatigué",
        f'''  <circle cx="100" cy="96" r="38" fill="{SKIN}"/>
  <path d="M70 88c8-4 16-2 20 2M110 90c8-4 16-4 20 0" fill="none" stroke="{INK}" stroke-width="3"/>
  <path d="M82 120c8-6 28-6 36 0" fill="none" stroke="{CLAY_D}" stroke-width="3"/>
  <path d="M58 70c-6-10-4-16 4-14M142 70c6-10 4-16-4-14" stroke="{TEAL}" stroke-width="3" fill="none"/>
''',
    ),
    "tante.svg": (
        "la tante",
        "la tante",
        f'''  <circle cx="100" cy="70" r="16" fill="{SKIN}"/>
  <path d="M78 74c6-22 14-28 22-28s16 6 22 28" fill="{ROSE_D}"/>
  <path d="M74 150c4-40 12-52 26-52s22 12 26 52" fill="{SAGE}"/>
  <circle cx="132" cy="108" r="8" fill="{OCHRE}"/>
  <path d="M92 78c5 4 11 4 16 0" fill="none" stroke="{CLAY}" stroke-width="2"/>
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
  <rect x="70" y="154" width="60" height="8" rx="2" fill="{ROSE}"/>
''',
    ),
    "adorer.svg": (
        "adorer",
        "adorer",
        f'''  <circle cx="78" cy="78" r="10" fill="{SKIN}"/>
  <circle cx="122" cy="78" r="10" fill="{SKIN}"/>
  <path d="M64 148c3-32 8-42 14-42s12 10 14 42" fill="{ROSE}"/>
  <path d="M108 148c3-32 8-42 14-42s12 10 14 42" fill="{TEAL}"/>
  <path d="M88 88c4 10 20 10 24 0" fill="none" stroke="{CLAY}" stroke-width="3"/>
  <path d="M100 70c0-10 4-16 10-10" fill="none" stroke="{OCHRE}" stroke-width="3"/>
''',
    ),
    "oncle.svg": (
        "l'oncle",
        "l'oncle",
        f'''  <circle cx="100" cy="70" r="16" fill="{SKIN_D}"/>
  <path d="M84 62c6-14 10-16 16-16s10 2 16 16" fill="{INK}"/>
  <path d="M74 150c4-40 12-50 26-50s22 10 26 50" fill="{CLAY}"/>
  <rect x="70" y="108" width="60" height="8" fill="{OCHRE}"/>
  <circle cx="93" cy="68" r="1.8" fill="{INK}"/>
  <circle cx="107" cy="68" r="1.8" fill="{INK}"/>
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
