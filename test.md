# SimpleCursorRing Full Test Checklist

## Setup
1. Download `SimpleCursorRing-v0.1.0.zip` from GitHub Releases (or copy `SimpleCursorRing/` folder)
2. Extract into `WoW/Interface/AddOns/` — folder structure must be `Interface/AddOns/SimpleCursorRing/SimpleCursorRing.toc`
3. Launch WoW and log into a character

## 1. Addon Loads
- [ ] SimpleCursorRing appears in addon list at character select
- [ ] No Lua errors on login

## 2. Ring Display
- [ ] White ring visible on screen after logging in
- [ ] Ring is centered on mouse cursor
- [ ] Ring follows cursor smoothly without lag
- [ ] Ring is above most UI elements but below tooltips

## 3. Settings Access
- [ ] Type `/scr` → settings panel opens
- [ ] Type `/simplecursorring` → settings panel opens
- [ ] Open Interface Options (Esc > Options > AddOns) → SimpleCursorRing is listed
- [ ] Clicking it in Interface Options shows the settings panel

## 4. Size Slider
- [ ] "Ring Size" slider visible in settings
- [ ] Drag to minimum (20) → ring becomes very small
- [ ] Drag to maximum (200) → ring becomes very large
- [ ] Value label updates as you drag
- [ ] Ring resizes in real-time while dragging

## 5. Color Picker
- [ ] Color swatch button visible in settings
- [ ] Click swatch → WoW color picker opens
- [ ] Select red → ring turns red immediately
- [ ] Select blue → ring turns blue immediately
- [ ] Adjust opacity slider → ring becomes more transparent
- [ ] Click Cancel → ring reverts to previous color

## 6. Class Color Toggle
- [ ] "Use Class Color" checkbox visible in settings
- [ ] Check it → ring changes to your class color
- [ ] Color swatch becomes grayed out (disabled)
- [ ] Uncheck → ring reverts to custom color
- [ ] Color swatch re-enables

## 7. Ring Style Dropdown
- [ ] "Ring Style" dropdown visible below class color checkbox
- [ ] Default selection shows "Medium"
- [ ] Select "Thin" → ring becomes thinner (2px stroke)
- [ ] Select "Medium" → ring is standard thickness (4px stroke)
- [ ] Select "Thick (Bold)" → ring is visibly thicker (8px stroke)
- [ ] Each option is visually distinguishable

## 8. Persistence
- [ ] Set size to 100, color to red, style to Thick
- [ ] Type `/reload`
- [ ] Ring still shows: size 100, red, thick style
- [ ] Open `/scr` → slider shows 100, swatch is red, dropdown shows "Thick (Bold)"
- [ ] Check "Use Class Color", `/reload` → class color still active
- [ ] Uncheck "Use Class Color", `/reload` → custom color restored

## Expected Texture Appearance

| Style | Stroke | Description |
|-------|--------|-------------|
| Thin | 2px | Subtle, delicate |
| Medium | 4px | Standard visibility (default) |
| Thick (Bold) | 8px | Bold, EnhanceQoL-style |

## Bug Report Template

If something fails, note:
- **Test #:** which test failed
- **Expected:** what should happen
- **Actual:** what happened instead
- **Error:** any Lua error text (if visible)
