# SimpleCursorRing Test Checklist

## Ring Texture Selection (Quick-001)

### Setup
1. Copy `SimpleCursorRing/` folder to WoW `Interface/AddOns/`
2. Launch WoW and log into a character

### Test: Dropdown Exists
- [ ] Type `/scr` to open settings
- [ ] "Ring Style" label visible below "Use Class Color"
- [ ] Dropdown shows current selection (default: "Medium")

### Test: Texture Switching
- [ ] Select "Thin" → ring becomes thinner (2px stroke)
- [ ] Select "Medium" → ring is standard thickness (4px stroke)
- [ ] Select "Thick (Bold)" → ring is visibly thicker (8px stroke)

### Test: Persistence
- [ ] Select "Thick (Bold)"
- [ ] Type `/reload`
- [ ] Open settings with `/scr`
- [ ] Dropdown still shows "Thick (Bold)"
- [ ] Ring still displays thick style

### Test: Size Slider
- [ ] Drag slider to minimum (20) → ring shrinks
- [ ] Drag slider to maximum (200) → ring grows
- [ ] Value persists after `/reload`

### Test: Color Picker
- [ ] Click color swatch → color picker opens
- [ ] Select red → ring turns red
- [ ] Adjust opacity → ring transparency changes
- [ ] Color persists after `/reload`

### Test: Class Color
- [ ] Check "Use Class Color" → ring uses class color
- [ ] Color swatch becomes disabled (grayed out)
- [ ] Uncheck → color swatch re-enables
- [ ] Setting persists after `/reload`

## Expected Texture Appearance

| Style | Stroke | Description |
|-------|--------|-------------|
| Thin | 2px | Subtle, delicate |
| Medium | 4px | Standard visibility |
| Thick (Bold) | 8px | Bold, EnhanceQoL-style |
