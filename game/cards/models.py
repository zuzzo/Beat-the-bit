"""Card models and enums."""

from __future__ import annotations

from dataclasses import dataclass, field
from enum import Enum
from typing import List


class CardType(str, Enum):
    SCONTRO = "scontro"
    EVENTO = "evento"
    CONCATENAMENTO = "concatenamento"
    MALEDIZIONE = "maledizione"
    EQUIPAGGIAMENTO = "equipaggiamento"
    ISTANTANEO = "istantaneo"
    MISSIONE = "missione"
    BOSS = "boss"
    BOSS_FINALE = "boss_finale"


class TreasureRarity(str, Enum):
    COMUNE = "comune"
    RARO = "raro"
    MITICO = "mitico"


@dataclass
class Card:
    card_id: str
    name: str
    card_type: CardType
    cost: int | None = None
    rarity: TreasureRarity | None = None
    text: str | None = None
    tags: List[str] = field(default_factory=list)
    effects: List[str] = field(default_factory=list)
