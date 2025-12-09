# Canary Map Editor - Documentation

> **Linux Port:** This fork focuses on bringing Remere's Map Editor to native Linux (GTK3) with production-ready performance and stability.

## Documentation Structure

### 📐 Architecture

Technical documentation about the editor's internal architecture and execution model.

- **[ARCHITECTURE.md](architecture/ARCHITECTURE.md)** - Event-driven rendering execution model and core principles
- **[ARCHITECTURAL_SYNTHESIS.md](architecture/ARCHITECTURAL_SYNTHESIS.md)** - Comprehensive subsystem analysis (v3.9.14)
- **[FPS_TELEMETRY_ANALYSIS.md](architecture/FPS_TELEMETRY_ANALYSIS.md)** - Detailed analysis of Redraws vs Visual FPS

### 🐧 Linux Port

Documentation specific to the Linux/GTK3 port of the map editor.

- **[LINUX_PORT_AUDIT.md](linux-port/LINUX_PORT_AUDIT.md)** - Platform-specific differences, issues, and fixes
- **[TECHNICAL_REPORT.md](linux-port/TECHNICAL_REPORT.md)** - Complete panoramic technical analysis of all changes

### 🔧 Development Notes

Internal development notes and implementation details (optional reading).

- **[ICON_IMPLEMENTATION.md](dev-notes/ICON_LINUX_IMPLEMENTATION.md)** - Linux icon integration
- **[MODAL_OPTIMIZATION.md](dev-notes/MODAL_TRANSITION_OPTIMIZATION.md)** - GTK modal performance notes
- **[IMAGE_TO_ICON_GUIDE.md](dev-notes/COMO_CONVERTER_IMAGEM_PARA_ICONE.md)** - Icon conversion guide

---

## Quick Navigation

**New to the Linux port?** Start here:
1. [LINUX_PORT_AUDIT.md](linux-port/LINUX_PORT_AUDIT.md) - Overview of changes
2. [ARCHITECTURE.md](architecture/ARCHITECTURE.md) - Understanding the event-driven model

**Contributing to the port?** Read:
1. [TECHNICAL_REPORT.md](linux-port/TECHNICAL_REPORT.md) - Complete technical analysis
2. [ARCHITECTURAL_SYNTHESIS.md](architecture/ARCHITECTURAL_SYNTHESIS.md) - Subsystem deep dive

---

## Key Improvements (v3.9.15)

### Performance
- **+567% FPS** (9 Hz → 60 Hz visual)
- **-98% Input Lag** (8s → <100ms)
- **-87% Overdraw** (Z-axis occlusion culling)

### Stability
- **0% Crash Rate** (100% → 0% on map import)
- **GTK3 Compatibility** (all dialogs visible in dark themes)
- **Memory Safety** (ownership transfer protocol validated)

### Technology Readiness
- **TRL 9:** Production-ready on Linux
- **Event-driven architecture** formally documented
- **Comprehensive test suite** (valgrind, gdb validated)

---

**Documentation Version:** v3.9.15
**Last Updated:** 2025-12-08
**Status:** Production Ready
