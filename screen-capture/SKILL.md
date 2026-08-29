---
name: screen-capture
description: Capture the user's screen (or a specific monitor / region) to a PNG and view it, so Claude can see what is on screen and guide GUI steps. Trigger when the user says "look at my screen", "can you see my screen", "take a screenshot", "on the secondary/second monitor", "what do you see on my display", or asks for visual help with a desktop app.
---

# Screen capture

Let Claude see the user's live desktop by capturing it to an image file and reading that file. Works on Linux X11 (and Wayland where a grabber exists). This is a snapshot, not a live feed; re-capture after the user changes the screen.

## Procedure

1. **Detect environment** (monitors, tools, session type):

   ```bash
   echo "=== monitors ==="; xrandr --query 2>/dev/null | grep -E " connected"
   echo "=== tools ==="; which import gnome-screenshot scrot spectacle maim grim 2>/dev/null
   echo "=== session ==="; echo "XDG_SESSION_TYPE=$XDG_SESSION_TYPE  DISPLAY=$DISPLAY  WAYLAND_DISPLAY=$WAYLAND_DISPLAY"
   ```

   `xrandr` lists each monitor with its geometry as `WIDTHxHEIGHT+XOFFSET+YOFFSET`, e.g. `HDMI-0 connected 1920x1080+1920+0` is a secondary screen offset 1920px to the right of primary. `primary` marks the main screen.

2. **Capture.** Prefer ImageMagick `import` on X11 because it can crop to one monitor's geometry. The Bash tool's env may lack `DISPLAY`, so try candidates. Replace the crop geometry with the target monitor's from step 1 (omit `-crop` for the whole virtual desktop).

   ```bash
   # Whole desktop:
   #   import -window root +repage /tmp/screen.png
   # One monitor (example geometry 1920x1080+1920+0 = secondary):
   for D in "$DISPLAY" :0 :1 :0.0; do
     [ -z "$D" ] && continue
     DISPLAY="$D" xrandr --query >/dev/null 2>&1 || continue
     DISPLAY="$D" import -window root -crop 1920x1080+1920+0 +repage /tmp/screen.png 2>/tmp/shot.err \
       && echo "captured on DISPLAY=$D" && break
   done
   ls -la /tmp/screen.png 2>/dev/null || { echo FAILED; cat /tmp/shot.err; }
   ```

   Fallbacks if `import` is missing or fails:
   - `gnome-screenshot -f /tmp/screen.png` (whole screen; GNOME).
   - `scrot /tmp/screen.png` or `maim /tmp/screen.png` (X11).
   - `spectacle -b -n -o /tmp/screen.png` (KDE).
   - Wayland: `grim /tmp/screen.png` (wlroots); GNOME Wayland often blocks CLI grabbers, in which case ask the user to run a screenshot manually and give the path.

3. **View it.** Read the PNG with the Read tool (`/tmp/screen.png`); it renders the image visually. Then describe what is on screen and guide the next step.

## Notes

- To capture a specific monitor, always pull its exact `WIDTHxHEIGHT+X+Y` from `xrandr` rather than guessing.
- Write captures to `/tmp` (or another non-repo path) so screenshots never get committed.
- If every grabber fails (locked-down Wayland, no DISPLAY, headless), fall back to asking the user to take the screenshot themselves and tell you the file path, then Read it.
