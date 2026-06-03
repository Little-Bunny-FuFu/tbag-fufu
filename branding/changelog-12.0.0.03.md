# TBag-fufu 12.0.0.03

*Released 2026-06-02 — options-menu polish and fixes.*

### Changed
- **Right-click option menus reworked** — only true on/off options show an
  indicator now: a radial button on the right (the same column as the submenu
  arrows), with the row subtly highlighted when enabled. Every other row aligns
  flush-left with no stray check boxes. The toggles are grouped at the top
  (Highlight New Items, Manual Layout / Edit Mode, Lock window), and clicking one
  keeps the menu open and updates the indicator live.

### Fixed
- **"Close Inventory"** did nothing; it now closes the window like the close
  button.
- **"Hide Player Dropdown"** closed the whole options menu (both when hiding and
  when re-showing it).
- **"Hide Bag Buttons"** left a stray empty box (the legacy keyring slot) and
  could drop world / terrain textures until the window was closed — a leftover
  placeholder model on the bag buttons is no longer rendered.
- **Bank — "Hide Bag Buttons"** now toggles the tab strip instead of retired
  static bag frames that left empty boxes behind.

### Added
- **"Hide Filter Button"** option in the Hide menu, on both the inventory and
  bank windows.
