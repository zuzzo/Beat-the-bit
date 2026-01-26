# NOTE_CHAT

## Stato attuale (Godot)
- Progetto in `godot/` con menu iniziale, scena principale, tavolo, dadi fisici, UI debug.
- Dadi: facce con texture 1-6, lettura della faccia superiore basata su orientamento; la mappa ora e:
  - Top: 2
  - Bottom: 6
  - Front: 5
  - Back: 1
  - Right: 3
  - Left: 4
- Lancio dadi:
  - Tenere premuto tasto sinistro e rilasciare.
  - Ogni lancio rimuove i dadi sul tavolo, aggiunge 1 dado in piu, calcola somma.
  - Spazio: reset a 1 dado e azzera storico.
- UI: etichetta in alto a sinistra con risultati e colori (debug).
- Layout: placeholder per mazzo avventura, mazzo tesori, carta personaggio.

## Dati carte
- File dati: `godot/data/cards.json`.
- Mazzi separati in `CardDatabase.gd`.
- Regole gruppi tesori:
  - `reward_group_vaso_di_coccio` = vaso di coccio.
  - `reward_group_chest` = scrigno.
  - `reward_token_tombstone` = token lapide.
- Maledizioni con `stats` e `remove_condition`:
  - Forma di Rana: max_hand 1, min_dice 2, start_hearts 1, max_slots 1, remove_condition when_two_dice_match.
  - Invecchiamento: max_hand 2, min_dice 2, start_hearts 2, max_slots 2, remove_condition discard_two_cards, effect plus_one_each_die.
- Sir Arthur:
  - A: max_hand 3, start_hearts 3, max_slots 2, start_dice 2, max_hearts 3, start_items vaso di coccio, regno del male in gioco.
  - B: start_hearts 1, max_hearts 3, max_hand 2, max_slots 2, start_dice 2.

## Asset e risorse
- Texture carte caricate in `godot/assets/cards/ghost_n_goblins/...`.
- Texture dadi in `godot/assets/dice/1.png` ... `6.png`.
- Audio: `godot/assets/dice/dice-89594.mp3`.
- Font: `godot/assets/Font/ARCADECLASSIC.TTF`.

## Script principali
- `godot/scripts/Main.gd`: input, lancio dadi, pan/zoom, UI debug.
- `godot/scripts/Dice.gd`: calcolo faccia superiore.
- `godot/scripts/CardDatabase.gd`: loader JSON e mazzi.
- `godot/scripts/DeckUtils.gd`: shuffle e draw_until_group.
- `godot/scripts/AbilityRegistry.gd` + `scripts/abilities/*.gd` stub.

## Prossimi step suggeriti
1) Sistemare definitivamente mappa facce se serve (verificare con texture reali).
2) Implementare pesca/scarto dei mazzi (avventura/tesori/boss).
3) Sostituire UI debug con pannello pulito (somma, dadi, mano).
4) Collegare `cards.json` alle texture reali delle carte.
