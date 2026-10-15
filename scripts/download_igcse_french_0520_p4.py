#!/usr/bin/env python3
"""Télécharge les Question Papers IGCSE French 0520, Paper 4 (Writing).

Variantes ciblées : qp_41, qp_42, qp_43.
Source : pages de session PapaCambridge (liens PDF présents dans le HTML).

Dépendances : requests, beautifulsoup4
"""

from __future__ import annotations

import argparse
import random
import sys
import time
from dataclasses import dataclass, field
from pathlib import Path
from urllib.parse import parse_qs, unquote, urljoin, urlparse

import requests
from bs4 import BeautifulSoup

USER_AGENT = (
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"
)

SESSION_URLS = [
    "https://pastpapers.papacambridge.com/papers/caie/igcse-french-0520-2021-march",
    "https://pastpapers.papacambridge.com/papers/caie/igcse-french-0520-2021-may-june",
    "https://pastpapers.papacambridge.com/papers/caie/igcse-french-0520-2021-oct-nov",
    "https://pastpapers.papacambridge.com/papers/caie/igcse-french-0520-2022-feb-march",
    "https://pastpapers.papacambridge.com/papers/caie/igcse-french-0520-2022-may-june",
    "https://pastpapers.papacambridge.com/papers/caie/igcse-french-0520-2022-oct-nov",
    "https://pastpapers.papacambridge.com/papers/caie/igcse-french-0520-2023-march",
    "https://pastpapers.papacambridge.com/papers/caie/igcse-french-0520-2023-may-june",
    "https://pastpapers.papacambridge.com/papers/caie/igcse-french-0520-2023-oct-nov",
    "https://pastpapers.papacambridge.com/papers/caie/igcse-french-0520-2024-march",
    "https://pastpapers.papacambridge.com/papers/caie/igcse-french-0520-2024-may-june",
    "https://pastpapers.papacambridge.com/papers/caie/igcse-french-0520-2024-oct-nov",
    "https://pastpapers.papacambridge.com/papers/caie/igcse-french-0520-2025-march",
    "https://pastpapers.papacambridge.com/papers/caie/igcse-french-0520-2025-may-june",
    "https://pastpapers.papacambridge.com/papers/caie/igcse-french-0520-2025-oct-nov",
    "https://pastpapers.papacambridge.com/papers/caie/igcse-french-0520-2026-march",
    "https://pastpapers.papacambridge.com/papers/caie/igcse-french-0520-2026-may-june",
]

TARGET_VARIANTS = ("qp_41", "qp_42", "qp_43")
PDF_MAGIC = b"%PDF-"


@dataclass
class PaperLink:
    filename: str
    url: str
    variant: str


@dataclass
class SessionResult:
    year: str
    session: str
    page_url: str
    pdf_links_in_html: int = 0
    no_pdf_links: bool = False
    page_error: str = ""
    files: dict[str, str] = field(default_factory=dict)
    statuses: dict[str, str] = field(default_factory=dict)


def pause() -> None:
    time.sleep(random.uniform(1.0, 2.0))


def make_session() -> requests.Session:
    http = requests.Session()
    http.headers.update(
        {
            "User-Agent": USER_AGENT,
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "Accept-Language": "fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7",
        }
    )
    return http


def parse_session_url(url: str) -> tuple[str, str]:
    slug = urlparse(url).path.rstrip("/").split("/")[-1]
    prefix = "igcse-french-0520-"
    if not slug.startswith(prefix):
        raise ValueError(f"URL de session inattendue : {url}")
    rest = slug[len(prefix) :]
    year, _, session = rest.partition("-")
    if len(year) != 4 or not year.isdigit() or not session:
        raise ValueError(f"Impossible d'extraire année/session depuis {url}")
    return year, session


def variant_of(filename: str) -> str | None:
    lower = filename.lower()
    if not lower.endswith(".pdf"):
        return None
    for variant in TARGET_VARIANTS:
        if variant in lower:
            return variant
    return None


def filename_from_url(url: str) -> str:
    return unquote(urlparse(url).path.split("/")[-1])


def paper_link_from_href(page_url: str, html_base: str, href: str) -> PaperLink | None:
    absolute = urljoin(html_base or page_url, href)
    parsed = urlparse(absolute)
    files = parse_qs(parsed.query).get("files", [])
    pdf_url = absolute
    filename = filename_from_url(absolute)
    if files:
        candidate = files[0]
        candidate_name = filename_from_url(candidate)
        if candidate_name.lower().endswith(".pdf"):
            pdf_url = candidate
            filename = candidate_name
    variant = variant_of(filename)
    if variant is None:
        return None
    return PaperLink(filename=filename, url=pdf_url, variant=variant)


def html_base_url(page_url: str, soup: BeautifulSoup) -> str:
    tag = soup.find("base", href=True)
    if tag is None:
        return page_url
    return urljoin(page_url, tag["href"])


def find_paper_links(page_url: str, html: str) -> tuple[list[PaperLink], int]:
    soup = BeautifulSoup(html, "html.parser")
    base = html_base_url(page_url, soup)
    pdf_hrefs = []
    for anchor in soup.find_all("a", href=True):
        href = anchor["href"]
        if ".pdf" not in href.lower():
            continue
        pdf_hrefs.append(href)
    found: dict[str, PaperLink] = {}
    for href in pdf_hrefs:
        link = paper_link_from_href(page_url, base, href)
        if link is not None and link.filename not in found:
            found[link.filename] = link
    return list(found.values()), len(pdf_hrefs)


def is_valid_pdf(path: Path) -> bool:
    if not path.is_file() or path.stat().st_size < 5:
        return False
    with path.open("rb") as handle:
        return handle.read(5) == PDF_MAGIC


def download_pdf(http: requests.Session, link: PaperLink, dest: Path, referer: str) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    partial = dest.with_suffix(dest.suffix + ".part")
    try:
        with http.get(
            link.url,
            stream=True,
            timeout=90,
            headers={"Referer": referer, "Accept": "application/pdf,*/*"},
        ) as response:
            response.raise_for_status()
            with partial.open("wb") as handle:
                for chunk in response.iter_content(chunk_size=65536):
                    if chunk:
                        handle.write(chunk)
        if not is_valid_pdf(partial):
            raise RuntimeError(
                f"le contenu reçu pour {link.filename} n'est pas un PDF "
                f"(HTTP {response.status_code}, {partial.stat().st_size} octets)"
            )
        partial.replace(dest)
    finally:
        if partial.exists():
            partial.unlink()


def fetch_page(http: requests.Session, url: str) -> str:
    response = http.get(url, timeout=45)
    response.raise_for_status()
    response.encoding = response.encoding or "utf-8"
    return response.text


def collect_session(http: requests.Session, page_url: str, output_dir: Path, first_request: bool) -> SessionResult:
    year, session = parse_session_url(page_url)
    result = SessionResult(year=year, session=session, page_url=page_url)
    print(f"\n=== {year} / {session} ===")
    print(page_url)
    if not first_request:
        pause()
    try:
        html = fetch_page(http, page_url)
    except requests.RequestException as exc:
        result.page_error = str(exc)
        print(f"ERREUR page : {exc}")
        return result

    links, pdf_count = find_paper_links(page_url, html)
    result.pdf_links_in_html = pdf_count
    if pdf_count == 0:
        result.no_pdf_links = True
        print(
            "ATTENTION : aucun lien PDF dans le HTML de cette page. "
            "Playwright n'est pas utilisé ; la session est signalée comme vide."
        )
        return result

    print(f"Liens PDF dans le HTML : {pdf_count} ; Question Papers Paper 4 : {len(links)}")
    by_variant = {link.variant: link for link in links}
    for variant in TARGET_VARIANTS:
        link = by_variant.get(variant)
        if link is None:
            result.statuses[variant] = "manquant"
            print(f"  manquant : {variant}")
            continue
        dest = output_dir / year / session / link.filename
        result.files[variant] = str(dest)
        if is_valid_pdf(dest):
            result.statuses[variant] = "déjà présent"
            print(f"  déjà présent : {dest}")
            continue
        pause()
        try:
            download_pdf(http, link, dest, referer=page_url)
        except (requests.RequestException, OSError, RuntimeError) as exc:
            result.statuses[variant] = "erreur"
            result.files[variant] = f"{link.filename} ({exc})"
            print(f"  ERREUR {link.filename} : {exc}")
            continue
        result.statuses[variant] = "téléchargé"
        print(f"  téléchargé : {dest} ({dest.stat().st_size} octets)")
    return result


def print_report(results: list[SessionResult]) -> None:
    print("\n" + "=" * 88)
    print("BILAN — Question Papers IGCSE French 0520 Paper 4 (qp_41, qp_42, qp_43)")
    print("=" * 88)
    header = f"{'Année':<6} {'Session':<12} {'qp_41':<28} {'qp_42':<28} {'qp_43':<28}"
    print(header)
    print("-" * len(header))
    downloaded = 0
    skipped = 0
    missing_rows: list[str] = []
    empty_pages: list[str] = []
    for result in results:
        cells = []
        for variant in TARGET_VARIANTS:
            status = result.statuses.get(variant, "")
            if result.page_error:
                cells.append("erreur page")
            elif result.no_pdf_links:
                cells.append("page sans PDF")
            elif status == "manquant" or not status:
                cells.append("MANQUANT")
                missing_rows.append(f"{result.year}/{result.session}  {variant}")
            elif status == "téléchargé":
                downloaded += 1
                name = Path(result.files[variant]).name
                cells.append(f"{name} [nouveau]")
            elif status == "déjà présent":
                skipped += 1
                name = Path(result.files[variant]).name
                cells.append(f"{name} [déjà là]")
            else:
                cells.append(status)
        if result.no_pdf_links:
            empty_pages.append(f"{result.year}/{result.session}  {result.page_url}")
        if result.page_error:
            missing_rows.append(f"{result.year}/{result.session}  page inaccessible ({result.page_error})")
        print(f"{result.year:<6} {result.session:<12} {cells[0]:<28} {cells[1]:<28} {cells[2]:<28}")

    print("-" * len(header))
    print(f"Nouveaux fichiers : {downloaded}    Déjà présents : {skipped}")
    print("\nFichiers manquants par session :")
    if missing_rows:
        for row in missing_rows:
            print(f"  - {row}")
    else:
        print("  (aucun)")
    if empty_pages:
        print("\nPages sans aucun lien PDF dans le HTML (Playwright non lancé) :")
        for row in empty_pages:
            print(f"  - {row}")


def select_urls(only: list[str]) -> list[str]:
    if not only:
        return list(SESSION_URLS)
    wanted = set(only)
    selected = []
    known = []
    for url in SESSION_URLS:
        year, session = parse_session_url(url)
        key = f"{year}-{session}"
        known.append(key)
        if key in wanted or session in wanted:
            selected.append(url)
            wanted.discard(key)
            wanted.discard(session)
    if wanted:
        known_list = ", ".join(known)
        raise SystemExit(f"Session inconnue : {', '.join(sorted(wanted))}. Connues : {known_list}")
    return selected


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--only",
        action="append",
        default=[],
        metavar="ANNEE-SESSION",
        help="Limiter à une session, par ex. 2022-may-june. Répétable.",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path("IGCSE_French_0520_P4"),
        help="Dossier racine (défaut : IGCSE_French_0520_P4)",
    )
    args = parser.parse_args(argv)
    urls = select_urls(args.only)
    http = make_session()
    results: list[SessionResult] = []
    for index, url in enumerate(urls):
        results.append(
            collect_session(http, url, args.output_dir, first_request=(index == 0 and not results))
        )
    print_report(results)
    failed = any(
        item.page_error or item.no_pdf_links or "erreur" in item.statuses.values()
        for item in results
    )
    missing = any(item.statuses.get(variant) == "manquant" for item in results for variant in TARGET_VARIANTS)
    return 1 if failed or missing else 0


if __name__ == "__main__":
    sys.exit(main())
