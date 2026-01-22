"""Placeholder JSON deck loader."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Dict, List

from game.cards.models import Card, CardType, TreasureRarity


def load_cards_from_json(path: Path) -> List[Card]:
    data = json.loads(path.read_text(encoding="utf-8"))
    cards: List[Card] = []
    for entry in data:
        cards.append(
            Card(
                card_id=entry["id"],
                name=entry["name"],
                card_type=CardType(entry["type"]),
                cost=entry.get("cost"),
                rarity=TreasureRarity(entry["rarity"]) if entry.get("rarity") else None,
                text=entry.get("text"),
                tags=entry.get("tags", []),
                effects=entry.get("effects", []),
            )
        )
    return cards


def load_deck_folder(folder: Path) -> Dict[str, List[Card]]:
    result: Dict[str, List[Card]] = {"adventure": [], "treasures": [], "boss": []}
    for key in result.keys():
        file_path = folder / f"{key}.json"
        if file_path.exists():
            result[key] = load_cards_from_json(file_path)
    return result
