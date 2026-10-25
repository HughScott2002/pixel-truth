# Pixel Truth

Ground-truth captures of a real application's rendering, taken
headlessly, for checking a design file against pixels instead of
guesses.

Built to verify the Aurora GTK4 kit in Figma, and growing toward the
same discipline for any app. The shipped capture profile drives
Aurora; the technique underneath (clean environment, measured
coordinates, pixel self-checks, numeric diff) carries no assumptions
about which app is on screen.

## Why pixels

A design kit matched against stylesheets loses to one matched against
renders. A render is the thing the user sees; a stylesheet is one
input to it, and toolkits do surprising things on the way to the
screen. The Aurora pass found five points the CSS reading got wrong,
including a header bar the stylesheet paints solid but the toolkit
leaves transparent, preference cards 47px narrower than the clamp
that sizes them, and a switcher styled as bare text plus a single
selected pill.

## What is in here

- `Makefile` is the front door: `make dev`, `make run`, `make build`,
  `make test`, `make release`. Nix does the work under every target.
- `capture.sh` drives the installed app under a headless X server and
  saves every screen and dialog as PNGs. Every click is followed by a
  pixel check, so a moved widget fails the run instead of quietly
  capturing the wrong thing.
- `rowruns.sh` measures a capture one row at a time, printing where
  each surface starts and ends. This is how the click coordinates are
  found, and how to re-find them when the UI moves.
- `diff.sh` scores a design export against a capture: one number for
  any difference, one for real drift.

## Running it

```
make run
```

`make dev` enters the capture shell directly, and
`make run ARGS=connecting` captures only the disconnected status page.
Everything below is what `make run` does.

The flake shell provides every tool the captures call by name
(xdotool, Xvfb, ImageMagick, fontconfig), pinned to the nixpkgs
revision this harness was verified against, so nothing needs
installing. The app comes from the profile rather than the flake, on
purpose: the harness captures what is installed and running, not what
the working tree says.

Also required today: the Aurora daemon running
(`systemctl --user start aurora`). Captures land in
`/tmp/pixel-truth/out`; set `WORK` to put them elsewhere.
`rowruns.sh` and `diff.sh` want the same shell, so prefix them the
same way.

Measuring a moved widget:

```
nix develop -c rowruns.sh /tmp/pixel-truth/out/01-lighting.png 23
```

Scoring a design export:

```
nix develop -c diff.sh export.png /tmp/pixel-truth/out/04-settings.png
```

## What it does to the machine

Nothing that outlives the run. The app runs with a clean fake HOME so
it renders its stock theme; no settings are written; and the capture
display is `:77` because a display `:99` on the machine this was
built on belongs to someone else. Aurora's slot selection is saved
before the run and restored after, and the backlight-off capture does
briefly turn the real keyboard off.

## Platforms, honestly

Today this captures Linux apps under X11, because a headless X server
plus xdotool is the mechanism it was built on. The discipline is
platform-neutral; Wayland, macOS and Windows need different capture
paths and do not exist here yet.

## The honest limit

Text pixels cannot match between an app's rasterizer and any design
tool: different engines rasterize the same glyphs differently even
with the same typeface. Flat surfaces, geometry and colour can match
exactly. `diff.sh` prints both numbers so the text remainder is never
mistaken for drift.
