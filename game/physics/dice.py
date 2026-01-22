"""Dice physics placeholder."""

from __future__ import annotations


class DiceRoll:
    def __init__(self, values: list[int]) -> None:
        self.values = values

    def total(self) -> int:
        return sum(self.values)
