#!/usr/bin/env python3
# Pagina dinamica NomadNet: richiede il bit eseguibile (chmod +x) sul nodo,
# altrimenti NomadNet la serve come file .mu statico invece di eseguirla.
import os
import sys

sys.stdout.reconfigure(encoding="utf-8")  # le sparkline usano caratteri a
# blocchi unicode; alcuni ambienti di servizio partono con una locale non-UTF-8
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import weather_lib
import weather_history
from weather_lib import micron_escape

print("-")
print()
print(">>Storico Meteo (72h)")
print()

# NomadNet renderizza come Micron tutto cio' che uno script dinamico scrive
# su stdout, inclusi eventuali errori non gestiti: per questo ogni blocco e'
# avvolto in un try/except che degrada a un messaggio invece di un traceback.
records = weather_history.load_recent()

if not records:
    print("  Nessuno storico disponibile ancora.")
    print("  Il campionamento cron (ogni 5 minuti) non e' ancora partito,")
    print("  oppure e' stato appena configurato.")
    print()
else:
    try:
        livedata = weather_lib.get_livedata()
        series = weather_history.extract_series(livedata)
    except Exception:
        series = {}

    if series:
        # Solo i sensori attualmente in linea: se uno smette di rispondere
        # semplicemente sparisce dalla pagina invece di mostrare un grafico
        # piatto/vuoto.
        for key, (label, unit, _val) in series.items():
            print(weather_history.render_sparkline_block(records, key, label, unit=unit))
    else:
        # Gateway irraggiungibile in questo momento ma abbiamo comunque uno
        # storico: mostralo usando le chiavi grezze come etichetta.
        print("  (gateway non raggiungibile ora: mostro comunque lo storico salvato)")
        print()
        keys = sorted({k for r in records for k in r if k != "ts"})
        for key in keys:
            print(weather_history.render_sparkline_block(records, key, micron_escape(key)))

print("-")
print()
print("`F0f0`[Dati in diretta`:/page/weatherstation/index.mu]`f")
print()
print("`F0f0`[Home`:/page/index.mu]`f")
print()
