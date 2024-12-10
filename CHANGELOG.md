# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[1.2.0]: https://github.com/zibetnu/haunting-hijinx/compare/1.1.0...1.2.0
[1.1.0]: https://github.com/zibetnu/haunting-hijinx/compare/1.0.0...1.1.0
[1.0.0]: https://github.com/zibetnu/haunting-hijinx/compare/0.4.0...1.0.0
[0.4.0]: https://github.com/zibetnu/haunting-hijinx/compare/0.3.0...0.4.0
[0.3.0]: https://github.com/zibetnu/haunting-hijinx/compare/0.2.0...0.3.0
[0.2.0]: https://github.com/zibetnu/haunting-hijinx/compare/0.1.0...0.2.0
[0.1.0]: https://github.com/zibetnu/haunting-hijinx/releases/tag/0.1.0
