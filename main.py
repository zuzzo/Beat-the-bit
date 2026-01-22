"""Entry point."""

from __future__ import annotations

from game.scene.app import GameApp


def main() -> None:
    app = GameApp()
    app.run()


if __name__ == "__main__":
    main()
