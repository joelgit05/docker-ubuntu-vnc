#!/bin/bash

# Inicia el servidor VNC
vncserver :1 -geometry 1280x800 -depth 24

# Inicia l'escriptori XFCE
startxfce4 &

# Manté el contenidor viu (per evitar que s'aturi immediatament)
tail -f /dev/null
