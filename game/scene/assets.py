"""Asset helpers (safe loading)."""

from __future__ import annotations

from pathlib import Path
from typing import Optional

PLACEHOLDER_PATH = Path("assets/common/card_placeholder.png")


def resolve_texture_path(path: str | Path) -> Path:
    candidate = Path(path)
    if candidate.exists():
        return candidate
    if PLACEHOLDER_PATH.exists():
        return PLACEHOLDER_PATH
    return candidate


def load_texture_safe(loader: object, path: str | Path) -> Optional[object]:
    texture_path = resolve_texture_path(path)
    try:
        # Panda3D loader has loadTexture; keep generic signature.
        return loader.loadTexture(str(texture_path))
    except Exception:
        return None
