"""Turn state machine (placeholder)."""

from __future__ import annotations

from enum import Enum


class Phase(str, Enum):
    ORGANIZZAZIONE = "organizzazione"
    AVVENTURA = "avventura"
    RIPOSO = "riposo"


class TurnFlow:
    def __init__(self) -> None:
        self.phase = Phase.ORGANIZZAZIONE

    def next_phase(self) -> Phase:
        if self.phase == Phase.ORGANIZZAZIONE:
            self.phase = Phase.AVVENTURA
        elif self.phase == Phase.AVVENTURA:
            self.phase = Phase.RIPOSO
        else:
            self.phase = Phase.ORGANIZZAZIONE
        return self.phase
