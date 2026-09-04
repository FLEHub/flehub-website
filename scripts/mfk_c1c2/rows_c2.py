"""36 kernels C2 compact (dossiers Cosmopolite 5 n° 7–12)."""
from __future__ import annotations

from complete import build
from rows_c2a import A
from rows_c2b import B
from rows_c2c import C

ROWS = A + B + C


def module_rows(i: int) -> list[dict]:
    start = i * 6
    chunk = ROWS[start : start + 6]
    if len(chunk) != 6:
        raise ValueError(f"C2 module {i}: expected 6 sequences, got {len(chunk)} (total {len(ROWS)})")
    return [build(d) for d in chunk]
