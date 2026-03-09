# 🍽️ Evidence Restaurací

Projekt vznikl v rámci práce ve 4 ročníku v předmětu programování, kdy je naším cílem vytvořit flutter aplikaci s využitím firebase
Mobilní aplikace pro vedení personálního deníku restaurací s podrobným hodnocením jednotlivých jídel, obsluhy a atmosféry.

## 📋 Popis

Aplikace **Evidence Restaurací** umožňuje zaznamenávat vaše zážitky z návštěv v restauracích. Pro každou restauraci si můžete poznamenat:

- **Název restaurace**
- **Libovolný počet jídel** s vlastním názorem
  - Jméno jídla
  - Bodové hodnocení (0–5 hvězdiček v půlkrocích)
  - Slovní komentář k chuti a kvalitě
- **Hodnocení obsluhy** (0–5 hvězdiček)
- **Hodnocení atmosféry** (0–5 hvězdiček)
- **Celkový komentář** k prostředí
- **Automatické uložení času vytvoření** recenze

## ✨ Hlavní funkce

✅ **Přidávání restaurací** – Stiskni tlačítko + a vyplň formulář  
✅ **Více jídel na restauraci** – Přidej tolik jídel, kolik jsi ochutnal  
✅ **Hvězdičkové hodnocení** – Tapni na hvězdu nebo její polovinu (např. 3,5★)  
✅ **Slovní komentáře** – Popisy ke každému jídlu i celkové poznatky  
✅ **Editace záznamů** – Klepni na ✏️ a změň cokoliv  
✅ **Mazání položek** – Klepni na 🗑️ a potvrď  
✅ **Přehled se časy** – Vždy vidíš, kdy jsi recenzi vytvořil  

## 🚀 Jak začít

### Požadavky

- Flutter SDK (verze 3.0 nebo novější)
- Dart SDK (součást Flutter)
- Android Studio, Xcode nebo VS Code s Flutter rozšířením

### Instalace a spuštění

1. **Klonuj nebo stáhni projekt**
   ```bash
   cd c:\Users\pavelka_vojtech\flutter\evidencerestauraci
   ```

2. **Stáhni závislosti**
   ```bash
   flutter pub get
   ```

3. **Připrav zařízení**
   - Spusť Android emulátor, iOS simulátor nebo připoj fyzické zařízení
   - Ověř připojení:
   ```bash
   flutter devices
   ```

4. **Spusť aplikaci**
   ```bash
   flutter run
   ```

## 📱 Jak používat aplikaci

### Přidání nové restaurace

1. Klepni na **modré tlačítko s +** v pravém dolním rohu
2. Vyplň **název restaurace**
3. Přidej **první jídlo**:
   - Napiš jeho název
   - Tapni na hvězdy (nebo jejich poloviny) pro hodnocení
   - Přidej komentář (nepovinně)
4. Chceš přidat více jídel? Klepni na **„Přidat další jídlo"**
5. Vyplň **obsluhu a atmosféru** (hvězdičky)
6. Přidej **volný komentář** k prostředí (nepovinně)
7. Stiskni **Uložit**

### Úprava restaurace

1. V seznamu najdi restauraci, kterou chceš upravit
2. Klepni na **✏️ (tužka)** v pravém rohu
3. Změň cokoliv – jména jídel, hodnocení, komentáře
4. **Původní čas vytvoření** se zachová
5. Stiskni **Uložit**

### Smazání restaurace

1. Klepni na **🗑️ (koš)** u restaurace
2. Potvrď smazání v dialogovém okně
3. Záznam bude odstraněn

## 💾 Uložení dat

Aplikace v současné chvíli ukládá data do paměti během běhu. Při uzavření aplikace se data ztratí.

**Tip:** V budoucnu lze snadno přidat ukládání do lokální databáze (SQLite) nebo cloudového úložiště (Firebase).

## 🛠️ Struktura projektu

```
evidencerestauraci/
├── lib/
│   └── main.dart          # Hlavní kód aplikace
├── pubspec.yaml           # Závislosti a konfigurace
├── README.md              # Tento soubor
└── android/, ios/, web/   # Kód pro jednotlivé platformy
```

## 📚 Technologie

- **Framework:** Flutter (Dart)
- **UI Material Design 3**
- **Barva motivu:** Oranžová
- **Platforma:** Android, iOS, Web

## 🎨 Vzhled a design

Aplikace používá jednoduchý a čistý design s podporou Material Design 3. Hvězdičky jsou interaktivní a reagují na tapnutí – můžeš klikat na levou polovinu hvězdy pro hodnocení na 0,5 bodu.

## 🔮 Budoucí rozšíření

Zde je pár nápadů na vylepšení:

- 💾 **Trvalé uložení** – SQLite lokálně nebo Firebase v cloudu
- 📊 **Statistiky** – Průměrné hodnocení, nejlepší jídla atd.
- 🖼️ **Fotografie** – Přidej fotky jídel a prostředí
- 🏷️ **Kategorie** – Kategorizuj restaurace (italská, thajská, domácí, atd.)
- 📍 **Mapa** – Zobraz restaurace na mapě podle GPS
- 🔍 **Vyhledávání** – Hledej mezi uloženými záznamy
- ⭐ **Oblíbené** – Označ si své top restaurace
- 📤 **Export** – Vyexportuj seznam jako PDF nebo CSV

## 🐛 Hlášení chyb

Pokud narazíš na nějaký problém, zkus:

1. Spusť aplikaci znovu (`flutter run`)
2. Vyčisti cache (`flutter clean` + `flutter pub get`)
3. Ujisti se, že máš nejnovější Flutter SDK (`flutter upgrade`)

## 📝 Poznámky k kódu

Kód je opatřen **českými komentáři**, aby se v něm mohl orientovat i člověk bez programovacích zkušeností. Každá tříída a metoda je vysvětlena.

## 👨‍💻 Autor

Vytvořeno pro osobní použití – Evidence restaurací a jednoduchou správu recenzí.

---

**Příjemné ochutnávky! 🍽️✨**
