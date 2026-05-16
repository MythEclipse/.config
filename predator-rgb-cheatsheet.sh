# Predator PHN16-71 RGB Control Cheatsheet
# Tool: ~/.local/bin/facer-rgb (atau: python3 ~/.local/bin/facer-rgb)
# Device: /dev/acer-gkbbl-0 (dynamic) | /dev/acer-gkbbl-static-0 (static)

## MODES
# -m 0  Static    (per-zone, perlu -z dan -cR -cG -cB)
# -m 1  Breath    (satu warna pulsing)
# -m 2  Neon      (rainbow cycle)
# -m 3  Wave      (gelombang warna)
# -m 4  Shifting  (geser warna)
# -m 5  Zoom      (zoom dari tengah)

## CONTOH LANGSUNG
# Neon rainbow (default boot):
facer-rgb -m 2 -s 4 -b 80

# Breath biru (quiet/balanced):
facer-rgb -m 1 -s 3 -b 60 -cR 0 -cG 80 -cB 255

# Wave hijau (eco):
facer-rgb -m 3 -s 2 -b 40 -d 2

# Shifting merah api (turbo):
facer-rgb -m 4 -s 6 -b 100 -cR 255 -cG 30 -cB 0

# Static per-zone (zone 1-4, kiri ke kanan):
facer-rgb -m 0 -z 1 -cR 255 -cG 0 -cB 0    # Zone 1: merah
facer-rgb -m 0 -z 2 -cR 255 -cG 100 -cB 0  # Zone 2: orange
facer-rgb -m 0 -z 3 -cR 0 -cG 200 -cB 255  # Zone 3: cyan
facer-rgb -m 0 -z 4 -cR 150 -cG 0 -cB 255  # Zone 4: ungu

# Matikan RGB:
facer-rgb -m 0 -b 0 -z 1 && facer-rgb -m 0 -b 0 -z 2 && facer-rgb -m 0 -b 0 -z 3 && facer-rgb -m 0 -b 0 -z 4

## SIMPAN PROFIL
facer-rgb -m 2 -s 4 -b 80 -save neon-default
facer-rgb -load neon-default
facer-rgb -list

## THERMAL PROFILE (berubah otomatis dengan predator-mode)
# Keybind: $mainMod + P
# quiet → balanced → balanced-performance (Dynamic) → performance (Turbo) → quiet
