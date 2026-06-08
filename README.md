# Slicer - A Slice Master Style Game

Ein schnelles Reflexspiel basierend auf der Slice Master Mechanik. Der Spieler muss mit einem rotierenden Messer über Plattformen springen und dabei den richtigen Winkel treffen.

## 🎮 Features

### Core Gameplay ✅
- **Smooth Gameplay**: Verbesserte Physik und flüssige Bewegungen
- **Double Jump Mechanic**: Bis zu 4 Sprünge pro Plattform
- **Angle-Based Landing**: Nur horizontales Messer = erfolgreiches Landing
- **Progressive Difficulty**: Plattformen werden schwieriger mit Fortschritt
- **Combo System**: Multiplikatoren für schnelle Landings
- **Highscore Tracking**: Speichert den besten Score pro Schwierigkeitsstufe

### Schwierigkeitsstufen ✅
- **Easy**: Breitere Plattformen, größerer Abstand, langsame Steigerung
- **Normal**: Balanciertes Gameplay (Standard)
- **Hard**: Schmale Plattformen, dichter beieinander, schnelle Steigerung

### Scoring System ✅
- **Base Score**: 10 Punkte pro Platform
- **Combo Multiplier**: +10% pro Combo (bis zu 5x möglich)
- **Formula**: `score = 10 * combo_multiplier`
- **Coin Rewards**: 5 Coins + Combo Bonus pro Platform
- **Combo Reset**: Bei fehlgeschlagenem Landing

### Knife Skins & Shop ✅
**6 verschiedene Messer-Designs:**
- 🔷 **Classic** (Default) - Grau metallic
- 💛 **Gold Rush** - Goldenes Messer (500 Coins)
- 🔴 **Crimson** - Rot (750 Coins)
- 🔵 **Icy** - Blau (600 Coins)
- ⬛ **Shadow** - Dunkelgrau (800 Coins)
- 🌈 **Rainbow** - Regenbogenfarben (1200 Coins)

**Shop Features:**
- Coins durch Spielen verdienen
- Messer kaufen & ausrüsten
- Skins persistent speichern
- Live Skin-Preview im Shop

### Sound & Visuals ✅
- Sound Effects für Schnitt/Sprung/Landing
- Visual Feedback (Scale Animation)
- Partikeleffekte beim Schneiden
- Score Popups mit Combo-Display

### UI & Menüs ✅
- **Hauptmenü**: Schwierigkeitsauswahl + Shop Zugang
- **Shop**: Skin-Auswahl mit Preisen
- **Echtzeit Display**: Score, Highscore, Coins, Level
- **Combo Indicator**: Zeigt aktuellen Multiplikator
- **Pause-Menü**: ESC zum Pausieren

### Persistierung ✅
- Highscores pro Schwierigkeitsstufe
- Coins & Shop-Fortschritt
- Gekaufte Skins
- Aktuelles Messer-Skin
- Spielstatistiken (Plattformen, Spiele)
- JSON-basierte Speicherung in `user://slicer_save.json`

### Multi-Plattform Support ✅
- **Desktop**: Keyboard (Space) + Gamepad Support
- **Mobile**: Touch Controls (Tap)
- **Plattformen**: Windows, Linux, Mac, iOS, Android
- **Browser**: Web Export ready

### Performance ✅
- Object Pooling für Plattformen
- Cleanup von entfernten Objekten
- Effiziente Event-Handling
- 60+ FPS Smooth Gameplay

---

## 🎮 Kontrollen

| Aktion | Keyboard | Gamepad | Mobile |
|--------|----------|---------|--------|
| Jump | Space | A Button | Tap Screen |
| Pause | ESC | Start | Back Button |
| Menu | ESC | Menu | Back Button |

---

## 💰 Economies System

### Coins verdienen:
- **5 Coins** pro erfolgreiches Platform
- **Combo Bonus**: +10% pro Combo Streak
- **Max 1.5x** Multiplikator mit 5er Combo

### Skins kaufen:
```
Classic (Default)  → 0 Coins (Kostenlos)
Gold Rush         → 500 Coins
Crimson           → 750 Coins  
Icy               → 600 Coins
Shadow            → 800 Coins
Rainbow           → 1200 Coins (Ultra Rare)
```

---

## 📊 Score Berechnung

### Formula:
```
score_per_platform = 10 * combo_multiplier
coins_per_platform = 5 * combo_multiplier

combo_multiplier = 1.0 + (combo_count * 0.1)
```

### Beispiele:
- Platform 1 (Combo 1): 10 × 1.1 = 11 Punkte, 5 Coins
- Platform 2 (Combo 2): 10 × 1.2 = 12 Punkte, 6 Coins
- Platform 3 (Combo 3): 10 × 1.3 = 13 Punkte, 6 Coins
- Platform 4 (Combo 4): 10 × 1.4 = 14 Punkte, 7 Coins
- Platform 5 (Combo 5): 10 × 1.5 = 15 Punkte, 7 Coins
- **Total nach 5 erfolgreichen**: 65 Punkte, 32 Coins

---

## 📂 Dateisystem

```
meista/
├── tester.gd              # Player Controller
├── platformspawner.gd     # Platform Generator
├── platform.gd            # Platform Script
├── game_manager.gd        # Game State & Difficulty
├── save_manager.gd        # Speichersystem
├── shop_manager.gd        # Skin/Coin Management
├── audio_manager.gd       # Sound Manager
├── input_manager.gd       # Input Handler
├── ui_menu.gd             # Menü & Shop UI
├── main.tscn              # Hauptszene
├── platform.tscn          # Platform Szene
├── knife.tscn             # Messer Szene
└── project.godot          # Projekt Config
```

---

## 🚀 Installation & Start

1. **Godot 4.6+** herunterladen
2. Projekt öffnen
3. `meista/main.tscn` öffnen
4. F5 zum Starten oder Play-Button

---

## 🎨 Customization

### Neue Skins hinzufügen:
```gdscript
knife_skins["neuer_skin"] = {
    "name": "Skin Name",
    "description": "Beschreibung",
    "color": Color(R, G, B, A),
    "price": 999,
    "owned": false
}
```

### Score Multiplier anpassen:
```gdscript
# In tester.gd
combo_multiplier = 1.0 + (combo * 0.1)  # Aktuell: +10% pro Combo
```

---

## 📈 Statistiken

Das Spiel speichert automatisch:
- Highscores pro Schwierigkeitsstufe
- Global Highscore
- Gesamtzahl bestandener Plattformen
- Gesamtzahl Spiele gespielt
- Coins verdient
- Aktuelle Messer-Skin
- Gekaufte Skins

Speicherort: `user://slicer_save.json`

---

## 🔮 Mögliche zukünftige Features

- [ ] Leaderboard System (online)
- [ ] Achievement System
- [ ] Verschiedene Umgebungen/Themes
- [ ] Power-ups während des Spiels
- [ ] Spezial-Skins mit Effekten
- [ ] Sound Packs
- [ ] Level Editor
- [ ] Multiplayer Modus
- [ ] Rank/Tier System
- [ ] Daily Challenges

---

## 🐛 Bekannte Probleme

Keine bekannten Probleme - spielbereit!

---

## 📜 Lizenz

Frei nutzbar für private & kommerzielle Projekte

**Viel Spaß beim Spielen!** 🎮
