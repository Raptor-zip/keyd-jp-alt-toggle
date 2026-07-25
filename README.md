# keyd-jp-alt-toggle

[keyd](https://github.com/rvaiya/keyd) config that makes left/right Alt behave
as a Japanese IME toggle (tap = Muhenkan / Henkan) while still working as a
normal Alt modifier when held.

- Tap left Alt (< 200ms) -> `Muhenkan` (switch to English/direct input)
- Tap right Alt (< 200ms) -> `Henkan` (switch to Japanese input)
- Hold either Alt -> behaves as a normal Alt modifier (e.g. Alt+Tab)
- CapsLock -> layer(alt)
- Applies to all keyboards except the internal laptop keyboard
  (`0001:0001`, the standard i8042 "AT Translated Set 2 keyboard" id), so an
  internal keyboard that's disabled elsewhere (e.g. floating in xinput) stays
  untouched by keyd.

## Why `overloadt` instead of `overload`

A plain `overload(alt, muhenkan)` resolves as a held Alt the instant any other
key event is seen while it's down — including spurious bounce from some
wireless/mechanical keyboards. That made the IME toggle unreliable (sometimes
needing two presses). `overloadt(alt, muhenkan, 200)` instead decides purely
by duration: release within 200ms always sends the tap action regardless of
any intervening key events, and only holding past 200ms activates the Alt
layer.

## Install

```bash
sudo ./install.sh
```

This copies `etc-keyd/*` into `/etc/keyd/` and restarts the `keyd` service.

If your machine's internal keyboard reports a different vendor:product id
than `0001:0001`, check it first:

```bash
grep -A6 "keyboard" /proc/bus/input/devices
```

and edit the `-0001:0001` line in `etc-keyd/default.conf` before installing.

## `bin/keyboard` — toggle the internal keyboard on/off

Companion CLI that floats/reattaches the internal keyboard via `xinput`, for
when you want to use only an external keyboard and avoid accidental input
from the built-in one:

```bash
cp bin/keyboard ~/bin/keyboard   # anywhere on your PATH
keyboard off      # disable internal keyboard
keyboard on       # re-enable it
keyboard toggle
keyboard status
```

This only lasts for the current X session (nothing persists across reboot or
re-login) and requires `xinput`. It looks up the device by the name
"AT Translated Set 2 keyboard" — adjust the `NAME` variable in the script if
your internal keyboard reports a different name.

## Files

- `etc-keyd/common` — the actual key mappings (Alt overload, CapsLock layer)
- `etc-keyd/default.conf` — applies `common` to every keyboard except the
  internal one
- `etc-keyd/japanese-external.conf` — JP layout overrides for a specific
  external keyboard by id; edit or drop the `[ids]` section to match your
  own external keyboard(s)
- `bin/keyboard` — CLI to toggle the internal keyboard on/off
