# TBag-fufu

An alternative bag and bank interface for **World of Warcraft (retail, 12.0)** —
auto-sorting, viewable anywhere, and heavily configurable.

TBag-fufu is a **personal revival fork** of the long-abandoned **TBag**
(`tbag-shefki`). Upstream last targeted WoW 2.x/Legion and no longer works on
modern retail; this fork rebrands it to `-fufu`, ports it to the current client,
and keeps it maintained.

> Heritage: **Engbags → TBag (Talos) → tbag-shefki (Shefki) → tbag-fufu**

## Features

- **Unified inventory & bank windows** that replace the default bag/bank UI.
- **Auto-sorting into categories** by item type and your professions, with
  optional category names and adjustable spacing.
- **View any character from anywhere** — once a character's data is cached, you
  can browse its bags, bank, and currency from any other
  character via the name dropdown.
- **Item search** across the current window (and your cached data).
- **Modern 12.0 bank support** built on the new `C_Bank` API:
  - Character **and** Warband (account) bank, with a per-tab selector strip.
  - Buy new bank tabs (taint-safe), in-window.
  - **Deposit-all** buttons — "Deposit All Reagents" (Character) / "Deposit All
    Warbound" (Warband).
  - **Warband money** display with deposit / withdraw.
  - **Bank tab settings** dialog (right-click a tab): rename, pick an icon, set
    the auto-deposit assignment flags, and the expansion filter — matching
    Blizzard's own bank tab settings.
- **Manual layout mode**: free-placement, draggable category bars for a
  hand-arranged layout.
- **Scrollable, resizable windows** with configurable column counts.
- Drag-and-drop item moves and stack splitting.
- Extensive in-game options (separate inventory and bank option panels) plus an
  advanced configuration window.

## Installation

1. Download or clone this repository.
2. Place the folder in your AddOns directory so the path is:
   `World of Warcraft/_retail_/Interface/AddOns/tbag-fufu`
   (the folder **must** be named `tbag-fufu` to match the `.toc`).
3. Restart WoW or `/reload`, and enable **TBag-fufu** on the character select /
   AddOns screen.

## Getting started

TBag-fufu can only show what it has "seen." For full cross-character viewing, on
each character once:

1. Open your bags
2. Visit the bank
3. Open a merchant / trade window

After that you can view that character's contents from any other character.

## Slash commands

| Command | Opens |
| --- | --- |
| `/tbag` or `/tinv` | Inventory window |
| `/tbnk` | Bank window |

Most settings live in the right-click menus on the windows and in the options
panels reachable from there ("Advanced Configuration").

## License

See [`LICENSE`](LICENSE). In short: the original TBag/Engbags code shipped with
no license and remains under its original authors' copyright (this fork does not
relicense it); the **`-fufu` contributions** (the rebrand, the 12.0 port, and
subsequent features and fixes) are released under the **MIT License**.

## Credits

- **Talos** — original author of TBag (built on Engbags).
- **Shefki** — maintained `tbag-shefki` on CurseForge / WoWInterface.
- **Little-Bunny-FuFu** — this `-fufu` revival fork.

This is a community revival of an abandoned addon, provided **as-is** with no
warranty. Issues and suggestions: <https://github.com/Little-Bunny-FuFu/tbag-fufu/issues>.
