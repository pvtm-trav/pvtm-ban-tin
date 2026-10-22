#!/usr/bin/env python3
"""Compatibility entrypoint for BanTin Publishing Pipeline v2."""
from runpy import run_path
from pathlib import Path
run_path(str(Path(__file__).resolve().parent/'scripts'/'build.py'),run_name='__main__')
