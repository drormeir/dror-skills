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

2. **Capture.** Prefer ImageMagick `import` on X11 because it can crop to one monitor's geometry. The Bash tool's env may lack `DISPLAY`, so try candidates. As written the block captures the whole virtual desktop; for one monitor, add `-crop` with that monitor's geometry from step 1 to the `import` line inside the same loop.

   ```bash
   # One monitor: add -crop WIDTHxHEIGHT+X+Y from step 1 to the import line below,
   #   e.g. -crop 1920x1080+1920+0 for the secondary screen in step 1's example.
   for D in "$DISPLAY" :0 :1 :0.0; do
     [ -z "$D" ] && continue
     DISPLAY="$D" xrandr --query >/dev/null 2>&1 || continue
     DISPLAY="$D" import -window root +repage /tmp/screen.png 2>/tmp/shot.err \
       && echo "captured on DISPLAY=$D" && break
   done
   ls -la /tmp/screen.png 2>/dev/null || { echo FAILED; cat /tmp/shot.err; }
   ```

   Fallbacks if `import` is missing or fails. Three of them take step 1's geometry non-interactively, so a monitor request survives the fallback; two cannot:
   - `gnome-screenshot -f /tmp/screen.png` (whole screen; GNOME). `-a, --area` takes no coordinates, so a named monitor is out of reach.
   - `scrot /tmp/screen.png` or `maim /tmp/screen.png` (X11); for one monitor, `scrot -a X,Y,W,H` or `maim -g WIDTHxHEIGHT+X+Y`.
   - `spectacle -b -n -o /tmp/screen.png` (KDE); `-m` captures the current monitor, and `-r` takes no coordinates, so a monitor other than the current one is out of reach.
   - Wayland: `grim /tmp/screen.png` (wlroots); for one monitor, `grim -g "X,Y WIDTHxHEIGHT"` in layout coordinates or `grim -o <output>`. GNOME Wayland often blocks CLI grabbers, in which case ask the user to run a screenshot manually and give the path.

   Where the grabber that worked is one of the two that cannot target a monitor, the PNG is the whole desktop: say so in step 3 before describing it, rather than presenting it as the monitor asked for.

3. **View it.** Read the PNG with the Read tool (`/tmp/screen.png`); it renders the image visually. Then describe what is on screen and guide the next step.

## Notes

- To capture a specific monitor, always pull its exact `WIDTHxHEIGHT+X+Y` from `xrandr` rather than guessing.
- Write captures to `/tmp` (or another non-repo path) so screenshots never get committed.
- If every grabber fails (locked-down Wayland, no DISPLAY, headless), fall back to asking the user to take the screenshot themselves and tell you the file path, then Read it.
