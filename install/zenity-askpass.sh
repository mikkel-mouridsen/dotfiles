#!/bin/sh
# SUDO_ASKPASS helper: pops a graphical password dialog so sudo/paru can
# authenticate with no terminal. sudo reads the password from our stdout.
exec zenity --password --title="Authentication required" \
            --width=360 2>/dev/null
