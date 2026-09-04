"""C1 module 4 — Corps visibles."""
from assemble import build_module
from spec_c1 import META
from rows_c1 import module_rows

MODULE, SEQUENCES, IMG_DIR = build_module(META[3], module_rows(3))
