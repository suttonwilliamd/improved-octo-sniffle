# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Damage number scaling for critical hits

### Changed
- Improved boss teleportation logic

## [0.3.0] - 2024-03-15
### Added
- Tiered boss system (Standard, Swarmlord, Phasebeast)
- Elite enemies with modifier stacking
- Cluster spawning mechanics (post-wave 15)
- Progressive difficulty parameters
- Boss warning animations
- Damage effect system

### Changed
- Complete wave progression overhaul
- Boss health scaling formula (1.8^tier)
- Shop time decreases with wave progression
- Unified enemy stat scaling framework

### Fixed
- Memory leak in long sessions
- Defense calculation rounding errors
- Boss ability timing desync

## [0.2.0] - 2024-02-15
### Added
- Infinite wave scaling
- Mobile touch controls
- Auto-save system

### Changed
- Removed stat point requirements
- Revised wave difficulty curve

### Fixed
- Android screen scaling

## [0.1.0] - 2024-02-01
### Added
- Core wave system
- Upgrade shop
- XP/level progression

### Changed
- Initial commit
