# Pixel Truth agent rules

This harness is for any app on any platform. Today it captures Linux
apps under X11; every change is constructed so that a new platform
(Wayland, macOS, Windows) is a new capture path beside the X11 one,
not a rewrite of shared code.

Always in force:

- Profile facts stay in the profile. App binaries, window names,
  coordinates, expected pixels, service commands and machine quirks
  (display :99 is taken on this machine; the bus lives at
  /run/user/<uid>/bus) belong to the one section that names the app
  they describe. Shared helpers stay app-neutral and
  platform-neutral.
- Ground truth is measured, never inferred. Expected values come
  from pixels read out of captures with rowruns.sh; stylesheets, docs
  and memory are inputs to check, not the answer.
- Every click self-checks. A capture added without a pixel check
  ships a hidden moved-widget bug; the check and the capture land
  together.
- Shell style from the origin repo carries over: explicit data
  movement with named intermediates, bounded retries, no dense
  one-liners.
- `make test` is the bar. A change to any capture path is verified
  by `make test` before it is called done.

Commits: conventional commits, subject at most 72 characters,
signed.
