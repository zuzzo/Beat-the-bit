"""Deck registry and plugin hooks."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Dict, List

from game.cards.models import Card
from game.events.bus import EventBus


@dataclass
class DeckModule:
    name: str
    register_cards: Callable[[], Dict[str, List[Card]]]
    register_rules: Callable[[EventBus], None]


class DeckRegistry:
    def __init__(self) -> None:
        self._modules: Dict[str, DeckModule] = {}

    def register(self, module: DeckModule) -> None:
        self._modules[module.name] = module

    def load_all(self, event_bus: EventBus) -> Dict[str, List[Card]]:
        cards: Dict[str, List[Card]] = {
            "adventure": [],
            "treasures": [],
            "boss": [],
        }
        for module in self._modules.values():
            module.register_rules(event_bus)
            module_cards = module.register_cards()
            for key, values in module_cards.items():
                cards[key].extend(values)
        return cards
