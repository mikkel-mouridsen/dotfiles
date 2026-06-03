# NAS Manager

A Noctalia plugin for mounting and monitoring CIFS/SMB shares.

## Features

- Bar widget with mount-count badge
- Control-center widget
- Panel showing every configured share with mount / unmount / open buttons
- Settings UI for adding, editing, and removing shares
- Mount/unmount via `pkexec`, which uses your active polkit agent
- Polls `/proc/mounts` every few seconds to keep status in sync
- Tracks disk usage via `df` and shows it on each card

## Requirements

- `cifs-utils` installed (`mount.cifs`)
- A running polkit authentication agent (e.g. `hyprpolkitagent` for Hyprland,
  or install the `polkit-agent` Noctalia plugin)
- A credentials file with your SMB password (recommended), e.g.
  `~/.config/noctalia/plugins/nas-manager/nas.cred` containing:

  ```
  username=cobo
  password=...
  ```

  Then `chmod 600` it.

## First run

The default share points at `//192.168.1.68/documents`. Open
**Settings → Plugins → NAS Manager** to point it at your credentials file
(or remove the share entirely and add your own).

## IPC

```bash
qs -c noctalia-shell ipc call plugin:nas-manager refresh
qs -c noctalia-shell ipc call plugin:nas-manager mountAll
qs -c noctalia-shell ipc call plugin:nas-manager unmountAll
```

## Passwordless sudoers alternative (optional)

If you'd rather skip the polkit prompt for mount/umount, add a sudoers rule
restricting `mount`/`umount` to your NAS paths, then swap `pkexec` for `sudo`
in `Main.qml`.
