"""Simple event bus with priorities."""

from __future__ import annotations

from dataclasses import dataclass
from collections import defaultdict
from typing import Callable, Dict, List

Handler = Callable[[dict], None]


@dataclass(frozen=True)
class EventHandler:
    priority: int
    handler: Handler


class EventBus:
    def __init__(self) -> None:
        self._handlers: Dict[str, List[EventHandler]] = defaultdict(list)

    def on(self, event_name: str, handler: Handler, priority: int = 0) -> None:
        self._handlers[event_name].append(EventHandler(priority, handler))
        self._handlers[event_name].sort(key=lambda h: h.priority, reverse=True)

    def emit(self, event_name: str, payload: dict | None = None) -> None:
        data = payload or {}
        for handler in self._handlers.get(event_name, []):
            handler.handler(data)
