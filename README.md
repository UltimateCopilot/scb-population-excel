# 📊 SCB Excelmall för månadsstatistik

Detta repo innehåller en färdig Excelmall som hämtar befolkningsdata från SCB:s öppna API via Power Query.

## ✅ Funktioner

- Automatisk hämtning av befolkningsdata baserat på vald månad
- Uppdelning per kön och ålder
- Excel-tabell med färdiga rubriker
- Kompatibel med Power BI och manuell uppföljning

## 🧩 Innehåll i mallen

| Plats | Innehåll |
|-------|---------|
| **A1** | Rubrik: `Folkmängden per månad efter region, ålder, månad och kön` |
| **C3** | Period (t.ex. `2025M04`) – namngiven cell: `MånadVald` |
| **B4–E4** | Kolumner: `Ålder`, `Totalt`, `Män`, `Kvinnor` |
| **B5 och nedåt** | Power Query-data laddas automatiskt hit |

## 🚀 Kom igång

1. **Ladda ner Excel-filen**  
   [📥 Klicka här för att ladda ner](https://github.com/UltimateCopilot/scb-population-excel/raw/main/Månadsstatistik_SCB_mall.xlsx)

2. Öppna i Excel
3. Gå till **Data → Uppdatera allt**
4. Klart!

📆 Byt månad i cell `C3` (t.ex. `2025M05`) för att hämta andra perioder.

## 🔧 Power Query

Power Query gör ett POST-anrop till:
https://api.scb.se/OV0104/v1/doris/sv/ssd/BE/BE0101/BE0101A/BefolkningNy


...och hämtar data för:
- Kommun: 0682 (Nässjö)
- Kön: Totalt, Män, Kvinnor
- Ålder: 0–100+
- Månad: från cell `MånadVald` (C3)

## ℹ️ Licens

Fri att använda och modifiera. Ange gärna källa vid spridning 🙌

