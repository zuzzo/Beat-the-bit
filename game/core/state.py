"""Core game state."""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Dict, List

from game.cards.models import Card


@dataclass
class DicePool:
    blue: int = 0
    green: int = 0
    red: int = 0


@dataclass
class PlayerState:
    name: str
    hearts: int
    max_hand: int
    equipment_slots: int
    dice_base: int
    dice_pool: DicePool = field(default_factory=DicePool)
    hand: List[Card] = field(default_factory=list)
    equipment: List[Card] = field(default_factory=list)
    missions: List[Card] = field(default_factory=list)


@dataclass
class TableState:
    adventure_in_play: List[Card] = field(default_factory=list)
    rewards_on_table: List[Card] = field(default_factory=list)
    shared_cards: List[Card] = field(default_factory=list)


@dataclass
class Decks:
    adventure: List[Card] = field(default_factory=list)
    treasures: List[Card] = field(default_factory=list)
    boss: List[Card] = field(default_factory=list)


@dataclass
class GameState:
    players: List[PlayerState]
    table: TableState = field(default_factory=TableState)
    decks: Decks = field(default_factory=Decks)
    current_player_index: int = 0
    turn_number: int = 1

    def current_player(self) -> PlayerState:
        return self.players[self.current_player_index]
