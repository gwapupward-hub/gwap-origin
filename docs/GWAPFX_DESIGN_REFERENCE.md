# GwapFX design references for GWAP Origin

**Status:** product design direction approved from six founder-supplied examples, October 24, 2026. Reference JPEGs were reviewed privately but are **not** redistributed here. This document governs GwapStyle Studio presets; it does not silently replace the existing canonical GwapFX sticker system.

## Preset A — GwapFX Signature (3D)

- Recognizable source identity comes first.
- Premium sculpted, rounded, dimensional subject; controlled glossy near-black materials and emerald neon rim lighting.
- Dominant brand green: `#13DD13`; layered lighting and highlights, not uncontrolled glow.
- **Locked micro-accents:** orange `#FF8A24` and purple `#9B6CFF`, used sparingly together or individually. They must not compete with green or distort meaningful original colors.
- Clean transparent square PNG is the **default sticker master**. A composited export may have an intentional background if the user chooses it.
- Preserve skin tones, text, symbols and brand identity; avoid automatic crowns, jewelry, cash, or new logos.

## Preset B — GwapFX Shadow (high-contrast silhouette)

The six references repeat the same powerful visual grammar: a bold, centered, **solid black** symbol, lettering, logo, or recognizable object silhouette against an electric green field with a subtly darker green outer vignette. Negative space does much of the work.

1. **Subject**: pure or near-black (`#000000`–`#050505`), flat fill, decisive clean edges, no 3D sculpting, gloss, texture, fine interior shading, generic neon border, or unnecessary glow.
2. **Background**: vivid `#13DD13` brand-green visual center, with a restrained radial green gradient to darker green edges. No gray, white, checkerboard, black rectangle or fake transparency.
3. **Composition**: one central silhouette; strong readable geometry; meaningful cutouts preserved; wide breathing room; generally square (1:1) unless the export format requires otherwise.
4. **Lettering/logos**: preserve provided exact glyphs and geometry. Never fabricate a crowned G or replace the user's own mark.
5. **Accents**: orange and purple are core Signature micro-accents. Shadow defaults to **no** accent where a truly monochrome black-on-green result is strongest; if selected, allow only tiny, purposeful hints that do not spoil the stark two-tone effect.
6. **User photos**: preserve subject proportions and pose; use silhouette only with explicit user selection because facial identity/skin details can be intentionally lost. If segmentation cannot produce a recognizable shape, report that the photo is a poor Shadow candidate rather than inventing details.

## Reference reading (six separate uploaded examples)

- 01: solid black crowned-G mark, centered on luminous green with darker edge vignette.
- 02: stylized black linked-symbol geometry against the same green field.
- 03: black GNS lettering under a simplified crown; exact glyphs and cutouts matter.
- 04: bold flexed-arm silhouette; subject readable without interior shading.
- 05: black shield with green negative-space cutouts/pixel motif.
- 06: heavy GWAP lettering, sparse small crown details, generous green field.

The images are reference materials, not permission to transfer or publish someone else's rights to the underlying marks. Each user must attest to rights when uploading source images.

## Prompt contract for generation worker (not yet deployed)

### Signature
Transform the provided image into GwapFX Signature: recognize and preserve subject identity, create high-quality sculpted dimensional forms, glossy premium black where appropriate, layered luminous green #13DD13 edges and restrained reflections, with minimal #FF8A24 orange and #9B6CFF purple micro-accents. Avoid random logos, crowns, face changes, poor anatomy, and visual clutter.

### Shadow
Isolate the main recognizable subject or exact supplied graphic shape. Render it as a crisp, completely opaque black silhouette centered over a vibrant #13DD13-centered radial green background with subtly darker green corners. Preserve distinctive geometry, negative-space holes, pose and proportions. Minimalist, powerful, flat, high-contrast, generous space. Do not add 3D treatment, glossy finish, decorations, new symbols, text, or faces. Orange/purple hints only when specifically enabled.

## Quality checks

- Recognizability at 64 px and 100 px thumbnails, no cut-off extremities or clipped marks.
- Silhouette extraction preserves negative-space geometry (e.g. letters and shields) and does not merge distinct objects unintentionally.
- No source copyright or authorship claims inferred from stylization.
- Source-to-output lineage, declared AI use, exact-byte hash, GwapFX preset/version and final C2PA receipt must be recorded by GWAP Origin when those services are implemented.
- C2PA signing, extraction of an invisible watermark, and image generation are **not** implemented by this document.
