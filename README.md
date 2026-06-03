# WM 2026 Tippspiel – Version 2.0

Enthalten:
- Login per E-Mail-Link
- 72 Vorrundenspiele als SQL-Import
- Tipps abgeben und bis Spielbeginn ändern
- Sperre ab Spielbeginn
- Übersicht aller Tipps
- Ergebniseingabe
- automatische Punktewertung
- Rangliste
- einfache Handy-Optimierung

## Punktewertung
- Exaktes Ergebnis: 5 Punkte
- Richtige Tordifferenz: 3 Punkte
- Richtige Tendenz: 2 Punkte
- Falsch: 0 Punkte

## Einrichtung
1. Supabase-Projekt erstellen.
2. `supabase/schema.sql` im Supabase SQL Editor ausführen.
3. `.env.local.example` in `.env.local` umbenennen.
4. Supabase URL und Anon Key eintragen.
5. Lokal starten: `npm install` und `npm run dev`.

## Spieler anlegen
Nach dem ersten Login eines Spielers muss in Supabase ein Eintrag in `players` existieren: `id` = Auth User ID, `email`, `name`, `is_admin`.
Dich selbst setzt du auf `is_admin = true`.

## Hinweis
Die Spielzeiten sind als UTC gespeichert. Die App zeigt sie automatisch in der lokalen Browser-Zeitzone an.
