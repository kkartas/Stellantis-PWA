# Stellantis Brand Themes

Reference for the 13 brand themes shipped in `mobile/lib/theme/brand_theme.dart`.
Each entry below maps to one `static const BrandTheme` instance and one
`assets/brands/<brand>.svg` logo.

> **Source of truth:** the `BrandTheme.perBrand` map in
> [`mobile/lib/theme/brand_theme.dart`](../mobile/lib/theme/brand_theme.dart).
> When palette values diverge from this doc, the Dart constant wins.

---

## 1. Palette quick-reference

Hex values are the **light-mode** primary / secondary / tertiary tokens.
Dark-mode primaries are typically a brighter shift of the same hue to lift
off near-black surfaces.

| Brand        | Primary  | Secondary | Tertiary  | Background |
|--------------|----------|-----------|-----------|------------|
| Peugeot      | `#1A1A1A` | `#B8962E` | `#767676` | `#F2F2F2`  |
| Citroën      | `#DA1E1E` | `#1A1A1A` | `#FF6B6B` | `#FAF7F5`  |
| DS           | `#1A1A2E` | `#D4AF37` | `#8B8B8B` | `#F0EFE9`  |
| Opel         | `#F4C22B` | `#1A1A1A` | `#EAEAEA` | `#F5F5F5`  |
| Vauxhall     | `#C8102E` | `#1A1A1A` | `#E85A6B` | `#F5F5F5`  |
| Fiat         | `#CC0000` | `#1C3F6E` | `#FFC845` | `#FAF6F0`  |
| Lancia       | `#003399` | `#CC0000` | `#B8B8B8` | `#F0F0F8`  |
| Alfa Romeo   | `#CC0000` | `#003087` | `#2D2D2D` | `#F8F4F2`  |
| Jeep         | `#1F4A2E` | `#8B6F47` | `#C0BC9E` | `#F2EFE6`  |
| Maserati     | `#00205B` | `#D4AF37` | `#8B8B8B` | `#F0EFE9`  |
| Chrysler     | `#1C1C1C` | `#C5A028` | `#8B8B8B` | `#F4F2EE`  |
| Dodge        | `#CC0000` | `#1A1A1A` | `#E85C5C` | `#F2F0EE`  |
| RAM          | `#B32024` | `#1A1A1A` | `#6B6B6B` | `#EFEDE9`  |

---

## 2. Motion language

Every `BrandTheme` exposes four motion tokens:

- `fastCurve` / `fastDuration` — affordances (button feedback, ripple)
- `slowCurve` / `slowDuration` — transitions (route push, sheet open)

Defaults: `Curves.easeOut` / 200 ms, `Curves.easeInOut` / 350 ms.

Per-brand overrides:

| Brand        | fastDuration | slowDuration | fastCurve         | Reason |
|--------------|--------------|--------------|-------------------|--------|
| DS           | 200 ms       | 450 ms       | `easeOut`         | Deliberate luxury cadence |
| Fiat         | 180 ms       | 350 ms       | `easeOut`         | Snappy 500-character |
| Lancia       | 200 ms       | 420 ms       | `easeOut`         | Elegant, classical |
| Alfa Romeo   | 170 ms       | 350 ms       | `easeOutCubic`    | Racing reflexes |
| Jeep         | 200 ms       | 400 ms       | `easeOut`         | Deliberate, capable |
| Maserati     | 200 ms       | 470 ms       | `easeOut`         | Unhurried grand-touring |
| Dodge        | 150 ms       | 350 ms       | `easeOutCubic`    | Aggressive muscle-car |
| RAM          | 200 ms       | 380 ms       | `easeOut`         | Heavy-duty deliberateness |

All other brands inherit the defaults.

---

## 3. Typography

Every brand currently uses `displayFont: 'Inter'`. The token exists so each
brand can later swap in its corporate face (Peugeot New, Citroën Type,
Alfa Sans, etc.) without changing widget code — just point `displayFont`
and `bodyFont` at the registered font family in `pubspec.yaml`.

`bodyFont` is null on every brand today, which causes the theme builder
to fall back to `displayFont` for body styles. Set it independently when a
brand mandates a distinct copy face from its headline face.

---

## 4. Asset paths

Every brand resolves its logo from `assets/brands/<key>.svg`:

```
assets/brands/alfaromeo.svg
assets/brands/chrysler.svg
assets/brands/citroen.svg
assets/brands/dodge.svg
assets/brands/ds.svg
assets/brands/fiat.svg
assets/brands/jeep.svg
assets/brands/lancia.svg
assets/brands/maserati.svg
assets/brands/opel.svg
assets/brands/peugeot.svg
assets/brands/ram.svg
assets/brands/stellantis.svg   (neutral fallback)
assets/brands/vauxhall.svg
```

The 7 PSA / FCA brands restored from the legacy PWA SVG set: alfaromeo,
citroen, ds, fiat, jeep, opel, peugeot, vauxhall. The 5 placeholder SVGs
(chrysler, dodge, lancia, maserati, ram) use the brand palette and a
simple geometric motif — replace with the official wordmark when the
licensing path is clarified.

`heroAsset` is unused so far; reserve for a per-brand hero illustration
on the dashboard.

---

## 5. Brand auto-detection

`activeBrandThemeProvider` (in `mobile/lib/theme/brand_detector.dart`)
resolves the theme in this order:

1. If `brandOverrideProvider` is non-null → use that override.
2. Otherwise, read the brand string from the most recently seen
   `VehicleRecord` and pass it to `BrandDetector.fromString`.
3. If nothing matches → `BrandTheme.neutral`.

`BrandDetector.fromString` accepts any of:

- Realm strings: `clientsB2CPeugeot`, `clientsB2CCitroen`, …
- Customer-ID prefixes: `AP` (Peugeot), `AC` (Citroën), `DS`, `OP`, `VX`
- Human-readable names: `Peugeot`, `Citroën`, `Fiat`, `Alfa Romeo`, …

Case-insensitive; substring match for the human-readable forms.

---

## 6. How to add a new brand

1. Add the value to `Brand` (sorted alphabetically) in
   `mobile/lib/stellantis/brands/brand_constants.dart`.
2. If the brand has its own PSA OAuth realm, add entries to
   `realm`, `tokenUrl`, `authorizeUrl`, `redirectScheme`,
   `brandCode`, and `mqttBrandCode` maps. FCA brands skip these for now.
3. Add a `static const BrandTheme <brand>` block to `BrandTheme` with the
   palette, dark-mode overrides, asset path, and any motion tweaks.
4. Add the entry to `BrandTheme.perBrand` (keep the map alphabetical).
5. Drop the SVG logo into `mobile/assets/brands/<key>.svg`.
6. Extend `BrandDetector.fromString` with a match for the brand's string
   representations.
7. The brand theme test in
   `mobile/test/theme/brand_theme_test.dart` picks up the new entry
   automatically.
