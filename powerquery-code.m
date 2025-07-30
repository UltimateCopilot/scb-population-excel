let
    // Använd Excel-cell för period eller hårdkoda för test
    // Period = Excel.CurrentWorkbook(){[Name="MånadVald"]}[Content]{0}[Column1],
    Period = "2025M05", // Hårdkoda först för att testa
    
    AlderLista = List.Transform({0..100}, each Text.From(_)) & {"100+"},
    KommunKod = "0682",
    
    // Skapa JSON-förfrågan med korrekt struktur baserat på fungerande exempel
    QueryJson = Json.FromValue([
        query = {
            [
                code = "Region",
                selection = [
                    filter = "vs:CKM03Kommun",
                    values = {KommunKod}
                ]
            ],
            [
                code = "Alder", 
                selection = [
                    filter = "vs:CKM021år",
                    values = AlderLista
                ]
            ],
            [
                code = "Kon",
                selection = [
                    filter = "item",
                    values = {"TotSa","1","2"}
                ]
            ],
            [
                code = "Tid",
                selection = [
                    filter = "item", 
                    values = {Period}
                ]
            ]
        },
        response = [format = "json"]
    ]),
    
    // API-anrop till SCB
    Källa = Json.Document(Web.Contents(
        "https://api.scb.se/OV0104/v1/doris/sv/ssd/START/BE/BE0101/BE0101A/BefolkManadCKM",
        [Headers = [#"Content-Type"="application/json"], Content = QueryJson]
    )),
    
    // Samma databehandling som fungerade med lokal fil
    Data = Källa[data],
    Tabell = Table.FromList(Data, Splitter.SplitByNothing(), {"Post"}),
    Expand = Table.ExpandRecordColumn(Tabell, "Post", {"key", "values"}),
    
    // Key-strukturen är [Region, Ålder, Tid, Kön] och values är en lista med ett element
    AddRegion = Table.AddColumn(Expand, "Region", each [key]{0}),
    AddAlder = Table.AddColumn(AddRegion, "Ålder", each [key]{1}),
    AddTid = Table.AddColumn(AddAlder, "Tid", each [key]{2}),
    AddKon = Table.AddColumn(AddTid, "Kön", each [key]{3}),
    AddAntal = Table.AddColumn(AddKon, "Antal", each Number.FromText([values]{0})),
    
    // Ta bort original key- och values-kolumner
    RemoveOriginal = Table.RemoveColumns(AddAntal, {"key", "values"}),
    
    // Konvertera datatyper
    Typade = Table.TransformColumnTypes(RemoveOriginal, {
        {"Antal", Int64.Type}, 
        {"Ålder", type text}, 
        {"Kön", type text},
        {"Region", type text},
        {"Tid", type text}
    }),
    
    // Pivotera på kön för att få separata kolumner
    Pivot = Table.Pivot(Typade, List.Distinct(Typade[Kön]), "Kön", "Antal"),
    
    // Byt namn på könskolumner
    BytNamn = Table.RenameColumns(Pivot, {{"TotSa", "Totalt"}, {"1", "Män"}, {"2", "Kvinnor"}}),
    
    // Sortera efter ålder
    LäggTillSort = Table.AddColumn(BytNamn, "SortÅlder", each 
        if Text.EndsWith([Ålder], "+") then 100 
        else Number.FromText([Ålder])
    ),
    Sorterad = Table.Sort(LäggTillSort, {{"SortÅlder", Order.Ascending}}),
    Slut = Table.RemoveColumns(Sorterad, {"SortÅlder"})
in
    Slut
