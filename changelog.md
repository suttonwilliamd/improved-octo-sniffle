# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Basic enemy health bars
- Wave completion bonus gold
- Visual indicators for critical hits

### Changed
- Increased base gold drop range (50-500 → 75-600)
- Rebalanced late-game scaling

### Fixed
- Memory leak in wave transitions
- Rounding errors in defense calculations


## [0.2.0] - 2024-02-15

### Added
- Infinite wave scaling post-wave 5
- Mobile touch input handling
- Auto-save system (every 5 waves)
- Basic particle effects

### Changed
- Removed stat point requirement for upgrades
- Revised wave difficulty curve
- Improved projectile visuals

### Fixed
- Upgrade cost reset on level up
- Android screen scaling issues

## [0.1.0] - 2024-02-01

### Added
- Core gameplay loop:
  - Wave-based enemy spawning
  - Gold collection system
  - Upgrade shop with 3 initial upgrades:
    - Attack Damage
    - Attack Speed
    - Critical Chance
- Basic player progression:
  - XP/level system
  - Persistent stat upgrades
- Minimal UI:
  - Health bar
  - Gold counter
  - Wave display

### Changed
- Initial commit of core systems

## Versioning Scheme

- **MAJOR** version: Architectural changes
- **MINOR** version: Feature additions
- **PATCH** version: Bug fixes and balance

## Types of Changes

- **Added**: New features
- **Changed**: Existing functionality updates
- **Deprecated**: Soon-to-be removed features
- **Removed**: Deleted features
- **Fixed**: Bug corrections
- **Security**: Vulnerability patches