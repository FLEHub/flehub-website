"""C1 module 1 — La colline de demain."""
from assemble import build_module
from spec_c1 import META
from rows_c1 import module_rows

MODULE, SEQUENCES, IMG_DIR = build_module(META[0], module_rows(0))
