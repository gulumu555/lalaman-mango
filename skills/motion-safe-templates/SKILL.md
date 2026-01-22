---
name: motion-safe-templates
description: Use when planning or implementing SAFE motion templates and fallback rules for MomentPin renders.
---

# Motion Safe Templates

Use this skill when defining or adjusting motion templates, fallback order, or acceptance checks for motion safety.

## Workflow
1) Confirm input type: photo only, photo+voice, or pre-rendered video.
2) Choose a template from the safe list and apply parameters within bounds.
3) If motion area is uncertain, downgrade using the fallback order.
4) Verify outputs against the acceptance checklist.

## Fallback order (must keep)
- Partner micro-motion
- Atmosphere overlay
- Light camera push/pull
- Waveform-only motion
- Static frame (labeled "quiet version")

## References
- Template catalog and parameter bounds: `references/templates.md`
