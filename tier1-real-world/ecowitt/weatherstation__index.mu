#!/usr/bin/env python3
# Pagina dinamica NomadNet: richiede il bit eseguibile (chmod +x) sul nodo,
# altrimenti NomadNet la serve come file .mu statico invece di eseguirla.
import os
import sys

sys.stdout.reconfigure(encoding="utf-8")  # sensor units can include '°C'; some
# service environments launch with a non-UTF-8 locale otherwise
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import weather_lib
from weather_lib import get_livedata, micron_escape

print("-")
print()
print(">>Stazione Meteo Ecowitt")
print()

try:
    livedata = get_livedata()
    error = None
except Exception as exc:
    livedata = None
    error = exc

if livedata is None:
    print(f"  Impossibile contattare il gateway meteo ({micron_escape(error)}).")
    print()
else:
    # NomadNet renders anything written to stdout/stderr as Micron, so an
    # unhandled traceback here would otherwise show up on the public page.
    try:
        sections = [
            ("Sensori esterni", weather_lib.parse_common(livedata.get("common_list", []))),
            ("Sensore interno (WH25)", weather_lib.parse_wh25(livedata.get("wh25", []))),
            ("Fulmini", weather_lib.parse_lightning(livedata.get("lightning", []))),
            ("Pioggia", weather_lib.parse_rain(livedata.get("rain", []))),
            ("CO2", weather_lib.parse_co2(livedata.get("co2", []))),
        ]
        for title, entries in sections:
            if not entries:
                continue
            print(f">{title}")
            print()
            for entry in entries:
                print(f"  {micron_escape(entry)}")
            print()
    except Exception:
        print("  Errore nella lettura dei dati meteo.")
        print()

print("-")
print()
print("`F0f0`[Storico 72h`:/page/weatherstation/history.mu]`f")
print()
print("`F0f0`[Home`:/page/index.mu]`f")
print()
