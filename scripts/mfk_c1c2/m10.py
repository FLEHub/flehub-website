"""C2 module 4 — Ce que le figuier se souvient."""
from assemble import build_module
from spec_c2 import META
from rows_c2 import module_rows

MODULE, SEQUENCES, IMG_DIR = build_module(META[3], module_rows(3))
