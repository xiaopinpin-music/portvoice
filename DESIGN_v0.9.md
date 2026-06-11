# PortVoice v0.9 — Design Notes

**Mission:** Built from a blind maker's daily experience, designed to serve
blind and sighted users alike — accessibility is the foundation, not an
afterthought.

> *Made with patience. Finished with peace.*

---

## Three layers (priority order)

### 1. Sound / VoiceOver — the foundation
- Every control has a clear label + state (e.g. "PortVoice, listening. Button.").
- Logical focus order: opening the dashboard lands focus on the main state first.
- Hints on non-obvious controls; state changes announced.
- Never information by colour or sound alone — always readable text.
- Fully keyboard operable; respects all system accessibility settings
  (speech rate, reduce motion, increase contrast, larger text).

### 2. Visual — equally considered
- One calm "hero" state: *PortVoice is listening* / *PortVoice is off*.
- Minimalist Bekcil (the duck) as a quiet, friendly mark — not busy.
- Single window; the few settings grouped calmly below the hero.
- System font (SF Pro), generous whitespace, minimal motion.
- Accent: the user's **system accent colour** for controls + a subtle warm
  brand touch on the mark.

### 3. Menu bar
- Monochrome **template** icon (adapts to light/dark menu bar).
- Subtle on/off state (filled vs outline) + always a clear VoiceOver label.

---

## Voice / Text-to-Speech

- Uses the **system voice** (AVSpeechSynthesizer): on-device, **instant,
  offline, private**, and free — exactly what a real-time accessibility
  utility needs.
- **Follows the Mac's language automatically** (the basis of multi-language
  support).
- **No in-app voice picker** — intentional. PortVoice follows the voice the
  user has already chosen for their system / VoiceOver, so it stays
  consistent and avoids confusion.

---

## Notification etiquette (Apple-like)

- **Respects Do Not Disturb / Focus** — on by default. When the user is in a
  Focus or DND, PortVoice stays quiet, like a well-behaved system citizen.
  A single toggle lets users who *want* device announcements during DND turn
  this off.
- **Respects the system notification permission** — if the user disables
  PortVoice notifications in System Settings, it stays silent.
- **Follows the active output device and system volume** — it never forces
  loudness; it speaks where and how the Mac is already set.

## Announcement behaviour

- Speaks **device name + state** — e.g. *"Magic Keyboard connected"*,
  *"USB drive ejected"* — short and clear, in the Mac's language.
- When the device **type** is known, the phrasing enriches naturally
  (e.g. *"keyboard connected"*) — flexible, never rigid.
- **No spam:** rapid events are debounced and queued in order, never
  overlapping or repeating.

---

## Compatibility

- **Minimum: macOS 12 Monterey** — to reach older Intel Macs too.
- **Universal binary** (Apple Silicon `arm64` + Intel `x86_64`) — one build
  for everyone.
- **Adaptive design (Apple's principle):** native **Liquid Glass** on
  macOS 26+, graceful fallback to standard system materials on older
  systems. Advanced capabilities scale to what each device supports.

---

*Layer 1 (sound) is designed first, then the visual is built on top of it.*
