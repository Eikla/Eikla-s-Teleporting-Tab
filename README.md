# Eikla's Teleporting Tab

Teleport buttons in a dedicated World Map tab, styled to fit Blizzard UI.

## Features

- Teleport categories shown as expandable rows inside the map tab.
- Core teleports, item teleports, engineering wormholes, and flyout spell teleports.
- Hearthstone selector directly in tab settings.
- Per-row collapse/expand state.
- Seasonal teleport filtering.

## Install

1. Place the `EiklasTeleportingTab` folder in:
`World of Warcraft/_retail_/Interface/AddOns/`
2. Launch the game and enable the addon.
3. Use `/ett` to open the map tab quickly.

## Release Packaging

From the addon repository root:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\package.ps1 -Version v1.1.2
```

Output zip:

`dist/EiklasTeleportingTab-v1.1.2.zip`



