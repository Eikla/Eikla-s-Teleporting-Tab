# Changelog

All notable changes to this project will be documented in this file.

## [1.1.1] - 2026-03-08

- Fixed a release regression where the Housing button could be hidden in packaged builds despite owned-house data being available.
- Restored robust housing refresh logic so PLAYER_HOUSE_LIST_UPDATED repopulates data and refreshes the tab reliably.

## [1.1.0] - 2026-03-08

- Fixed intermittent hearthstone warning during transient reloads when toy data is not fully initialized yet.
- Improved housing teleport button reliability by requiring valid secure-action target data.
- Removed the /ett housing debug subcommand and related debug output.

## [1.0.0] - 2026-03-06

- Initial public release of Eikla's Teleporting Tab.
- World Map tab integration for teleports.
- Category rows with expand/collapse.
- In-tab settings and hearthstone selector.


