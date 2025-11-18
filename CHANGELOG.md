# Changelog

All notable changes to this project will be documented in this file, which is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

This project adheres to an adapted form of [Semantic Versioning](https://semver.org/spec/v2.0.0.html). Given a version number MAJOR.MINOR.PATCH, increment the:

1. MAJOR version when you make incompatible netcode changes.
2. MINOR version when you add backward-compatible functionality.
3. PATCH version when you make backward-compatible bug fixes.

## [3.0.0] - 2025-11-18

### Added

- Foyer level.
- Research lab level.
- Basement level.
- Player customization, including default name, hats, and preferred hunter colors.
- Sparks and sound effect when a hunter is hit by a drain area.
- Randomized level selection for menu background.
- Basic level editing tools in `level_tile_map_layers.tscn`.
- Buttons to host and join locally when running editor build.

### Changed

- Increased contrast for hunter invulnerability animation.
- Made dead hunter wall avoidance instant instead of gradual.
- Updated engine and some plugins.

### Fixed

- Gamepad text input not appearing in some cases.
- Battery spawn animation being interrupted on clients.
- Inconsistent menu widths.
- Ghost statue lighting.
- Missing bullet point in 2.2.0 changelog.

## [2.2.0] - 2025-10-27

### Added

- Ghost statue easter egg.
- Button to manually initialize Steam when running editor build.

### Fixed

- Cases where the ghost has double health.
- Battery decorations are off by a pixel.
- Focus loss when a focused player card is removed.
- Needless tooltips appear when mouse hovers over certain buttons.

## [2.1.1] - 2025-10-08

### Fixed

- Crash when a battery despawns while a flashlight is shining on it.
- Focus can be lost by clients in lobby.
- Inconsistent button content margins.
- Interface sounds play on master bus instead of effects bus.
- Most text is a light gray instead of pure white.

## [2.1.0] - 2025-10-01

### Added

- Two new fonts for use where smaller text is helpful.
- Virtual keyboard popup for text input in Steam big picture mode.
- Random pitch changes to button sounds.
- Static checks to help ensure code quality.

### Changed

- Significantly improved gamepad menu navigation.
- Converted main font from monospace to variable.
- Slightly adjusted hunter sprite suit highlights.

### Fixed

- Some candles have overlapping duplicates.
- Ghost faces wrong way on tutorial select screen.

### Removed

- Option for mailbox VSync.

## [2.0.0] - 2025-07-14

### Added

- Ascending notes that play while the ghost takes damage.
- Summon progress sound.

### Changed

- Overhauled summon progress bar.
- Overhauled settings menu.
- Ghost now rotates gradually when changing direction.
- Ghost now rotates to face a hunter it grabbed.
- Improved performance by updating engine and plugins. This breaks compatibility with 1.x releases.
- Sped up the slower tutorial text.
- Reduced music volume so its slider is more in line with the others.
- Moved cache and configuration files to new locations.
- Reduced game install size.
- Cleaned up lots of code.

## [1.11.1] - 2025-05-21

### Fixed

- Scale is not initialized to correct multiplier in cases where only one scale is allowed.

## [1.11.0] - 2025-05-20

### Added

- Scale setting.

### Fixed

- Most cases where menus played extra button sounds.

### Removed

- Automatic scaling based on window size. This is now done manually via the scale setting.

## [1.10.0] - 2025-04-21

### Added

- VSync setting.
- Version number in main menu.
- License for Kenney pixel input prompts.

### Changed

- Made adaptive VSync the default.
- Improved performance by switching to Godot's mobile renderer.
- Overhauled readme.

### Fixed

- Misplaced pixel in ghost timer sprite.

## [1.9.0] - 2025-03-31

### Changed

- Overhauled timer sprites to look much better.

## [1.8.1] - 2025-02-25

### Fixed

- If ghost switches directly from summoning to sprinting, the summon animation will continue playing until the ghost moves.

## [1.8.0] - 2025-02-24

### Added

- Ghost summon animations.

## [1.7.0] - 2025-02-14

### Added

- Ghost grab animation.

### Changed

- A grabbed hunter's alerts are hidden during the grab cutscene to reduce visual clutter.

### Fixed

- Spotlight appears stretched on different aspect ratios unless the game window is resized after the level has loaded.

### Removed

- Gradual zooming out only present in the ghost's perspective of the grab cutscene. Now the ghost and hunters see the same thing.

## [1.6.0] - 2025-02-03

### Changed

- Replaced an odd-looking white pixel in candle flame.

### Fixed

- Level is only centered at round start for the host player.

## [1.5.0] - 2025-01-23

### Added

- Zoom and spotlight animations during grab cutscene.

## [1.4.0] - 2025-01-17

### Added

- Interactive ghost and hunter tutorials.

### Changed

- Simplified hunter costume rendering to fix issues the old rendering caused in the tutorials. This comes with a small performance benefit and makes animations slightly less delayed.
- Simplified level centering by using camera offsets instead of moving the entire level. This should look identical in practice but with much less jank behind the scenes.
- Many other small technical changes needed to make the tutorials work.

### Fixed

- Hunters see battery alerts while fainted.

## [1.3.1] - 2024-12-29

### Fixed

- Hunters revive without invulnerability.

## [1.3.0] - 2024-12-20

### Added

- "You" pointer that helps new players know which character they control.

### Changed

- Hunters no longer spawn with invulnerability since it did not last long enough to make a meaningful difference.
- The light circling each hunter is more optimized (by adjusting the brightness of a single light instead of showing and hiding an overlapping light).

## [1.2.0] - 2024-12-09

### Added

- "Made with Godot" boot splash.

### Fixed

- If two opposing move inputs are simultaneously pressed and released, the ghost will continue playing the sprint animation even when not moving.
- If a lobby has 4 participants that are all hunters, a 5th participant joining the lobby will be a hunter instead of being automatically set as the ghost.

## [1.1.0] - 2024-11-29

### Added

- Mineeli and Sergio Rabello in main theme credits.
- Nerd2Death in playtest credits.

### Changed

- Flashlights no longer stack damage when hitting the ghost, preventing the ghost's health from draining at a ridiculous rate.

## [1.0.0] - 2024-11-17

### Added

- Ability to join lobbies and invite friends to lobbies through your Steam friends list.
- Ability to find and join friends-only lobbies from the lobby browser.
- Help popup explaining each lobby type.

### Changed

- Default lobby type is friends only.
- Default music volume is 40%.
- Hunter color palettes are now ordered as yellow, green, purple, red, blue.
- Lobby summary gives more space to the lobby type text.
- Lots of code is reformatted.

### Fixed

- If 6+ players are in a lobby, swapping a spectator with a hunter will appear to work but actually make both players spectators.
- Lobby summaries overlap in lobby browser.
- Broken link for 0.4.0 in this changelog.

### Removed

- Non-exclusive fullscreen, which did not seem to have the expected benefits.
- Unused assets and code.

## [0.4.0] - 2024-11-16

### Added

- This changelog.
- Note about non-Steam multiplayer in readme.
- Bullet points from Steam store page in readme.

### Changed

- Logo has much cleaner letters and outlines.
- Logo is centered in readme.

### Fixed

- Crash when a client tries to change scenes instead of letting server.

## [0.3.0] - 2024-11-12

### Added

- New ghost idle, move, and sprint animations.
- Ghost stun sound.
- Flashlight click sound.
- Button and confirmation to leave lobby.
- Button sound for more UI actions.
- Margins around the edge of every menu.
- Minimum window size.
- CC0 license for Haunting Hijinx assets.

### Changed

- Ghost panic is significantly more obvious.
- Scaling adapts much better to arbitrary window sizes.
- Various menus have limited width to look better on wide aspect ratios.
- Ghost's aura outlines are cleaner.
- "Joining" window uses theme.

### Fixed

- If the mouse is hidden, mouse movement will not make it reappear while a popup window is visible.
- Drain areas interfere with mouse input.
- Spectator menu prevents mouse input from reaching match menu.
- Logo sometimes distorted depending on window size.
- Ghost's NE sprite not given same weight as other directions.
- Match menu does not stay centered as the window is resized.
- Player notifications (e.g., heart, battery low) render on top of match menu.
- Match menu unusable when game is paused at start of ghost grab.
- Missing button sounds for some popup windows.
- Potential focus loss when escaping a line edit.
- License menu does not auto-wrap some text.
- Context menu usable on other players' cards (it should never be available).
- Typo in licenses.

### Removed

- Mouse capturing.

## [0.2.0] - 2024-10-17

### Added

- Hunter dead sprite.
- 4 new hunter color palettes that automatically apply based on the number of hunters.
- About screen with credits and licenses.
- Mouse capturing.

### Changed

- Instead of a 3-second idle timeout, the mouse is now always active when visible. Joypad input hides the mouse; mouse movement shows it again.

## [0.1.0] - 2024-10-07

### Added

- Initial release.

[3.0.0]: https://github.com/zibetnu/haunting-hijinx/compare/2.2.0...3.0.0
[2.2.0]: https://github.com/zibetnu/haunting-hijinx/compare/2.1.1...2.2.0
[2.1.1]: https://github.com/zibetnu/haunting-hijinx/compare/2.1.0...2.1.1
[2.1.0]: https://github.com/zibetnu/haunting-hijinx/compare/2.0.0...2.1.0
[2.0.0]: https://github.com/zibetnu/haunting-hijinx/compare/1.11.1...2.0.0
[1.11.1]: https://github.com/zibetnu/haunting-hijinx/compare/1.11.0...1.11.1
[1.11.0]: https://github.com/zibetnu/haunting-hijinx/compare/1.10.0...1.11.0
[1.10.0]: https://github.com/zibetnu/haunting-hijinx/compare/1.9.0...1.10.0
[1.9.0]: https://github.com/zibetnu/haunting-hijinx/compare/1.8.1...1.9.0
[1.8.1]: https://github.com/zibetnu/haunting-hijinx/compare/1.8.0...1.8.1
[1.8.0]: https://github.com/zibetnu/haunting-hijinx/compare/1.7.0...1.8.0
[1.7.0]: https://github.com/zibetnu/haunting-hijinx/compare/1.6.0...1.7.0
[1.6.0]: https://github.com/zibetnu/haunting-hijinx/compare/1.5.0...1.6.0
[1.5.0]: https://github.com/zibetnu/haunting-hijinx/compare/1.4.0...1.5.0
[1.4.0]: https://github.com/zibetnu/haunting-hijinx/compare/1.3.1...1.4.0
[1.3.1]: https://github.com/zibetnu/haunting-hijinx/compare/1.3.0...1.3.1
[1.3.0]: https://github.com/zibetnu/haunting-hijinx/compare/1.2.0...1.3.0
[1.2.0]: https://github.com/zibetnu/haunting-hijinx/compare/1.1.0...1.2.0
[1.1.0]: https://github.com/zibetnu/haunting-hijinx/compare/1.0.0...1.1.0
[1.0.0]: https://github.com/zibetnu/haunting-hijinx/compare/0.4.0...1.0.0
[0.4.0]: https://github.com/zibetnu/haunting-hijinx/compare/0.3.0...0.4.0
[0.3.0]: https://github.com/zibetnu/haunting-hijinx/compare/0.2.0...0.3.0
[0.2.0]: https://github.com/zibetnu/haunting-hijinx/compare/0.1.0...0.2.0
[0.1.0]: https://github.com/zibetnu/haunting-hijinx/releases/tag/0.1.0
