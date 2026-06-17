# SimpleCursorRing

## What This Is

A World of Warcraft addon that displays a customizable ring around the mouse cursor. It helps players track their cursor position during gameplay, with settings for ring size, color, and class-based coloring.

## Core Value

The cursor ring must render at the correct position every frame with zero perceptible lag — if the ring doesn't follow the cursor smoothly, nothing else matters.

## Requirements

### Validated

- ✓ Ring renders around the cursor and follows it every frame — existing
- ✓ User can adjust ring size (20–200px) via settings panel — existing
- ✓ User can pick a custom ring color via color picker — existing
- ✓ User can toggle class-colored ring mode — existing
- ✓ Settings persist across sessions via SavedVariables — existing
- ✓ Settings accessible via `/scr` or `/simplecursorring` slash commands — existing
- ✓ Settings panel integrated into WoW Interface Options — existing
- ✓ Automated release packaging via GitHub Actions — existing

### Active

(None yet — no new features planned)

### Out of Scope

(None defined yet)

## Context

- Brownfield WoW addon, currently at v1.2.0 (Interface 120007 for patch 12.0.7)
- Two-file architecture: `Core.lua` (logic/rendering) and `Settings.lua` (UI controls)
- Pure WoW Lua API — no third-party libraries
- Single texture asset: `Textures/Default.tga`
- GitHub-hosted with CI release workflow

## Constraints

- **Runtime**: WoW client sandboxed Lua (LuaJIT-based) — no external libraries, no filesystem, no network
- **Performance**: OnUpdate runs every client frame — must stay lightweight
- **API**: Must target retail WoW Interface API (currently 120007)

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Two-file split (Core + Settings) | Separation of logic and UI concerns | ✓ Good |
| Single Default.tga texture | Simplified from multiple textures in v1.1 | ✓ Good |
| SavedVariables for persistence | Standard WoW pattern, no alternatives in addon sandbox | ✓ Good |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd:complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-06-17 after initialization*
