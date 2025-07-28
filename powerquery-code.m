let
    Period = Range("MånadVald"),
    AlderLista = List.Transform({0..100}, each Text.From(_)) & {"100+"},
    KommunKod = "0682",
    Body = Text.ToBinary("
    {
      ""query"": [
        {""code"": ""Region"", ""selection"": {""filter"": ""item"", ""values"": [""" & KommunKod & """]}},
        {""code"": ""Alder"", ""selection"": {""filter"": ""item"", ""values"": [" & Text.Combine(List.Transform(AlderLista, each """""" & _ & """"""), ",") & "]}},
        {""code"": ""Kon"", ""selection"": {""filter"": ""item"", ""values"": [""TotSa"", ""1"", ""2""]}},
        {""code"": ""Tid"", ""selection"": {""filter"": ""item"", ""values"": [""" & Period & """]}}
      ],
      ""response"": {""format"": ""json""}
    }
    "),
    Källa = Json.Document(Web.Contents(
        "https://api.scb.se/OV0104/v1/doris/sv/ssd/BE/BE0101/BE0101A/BefolkningNy",
        [Headers = [#"Content-Type"="application/json"], Content = Body]
    )),
    Data = Källa[data],
    Tabell = Table.FromList(Data, Splitter.SplitByNothing(), {"Post"}),
    Expand = Table.ExpandRecordColumn(Tabell, "Post", {"key", "values"}),
    ExpandKeys = Table.ExpandListColumn(Expand, "key"),
    KeysGrouped = Table.Group(ExpandKeys, {"values"}, {
        {"Nycklar", each Text.Combine([key], "|"), type text}
    }),
    NyckelTabell = Table.SplitColumn(KeysGrouped, "Nycklar", Splitter.SplitTextByDelimiter("|"), {"Region", "Kön", "Ålder", "Tid"}),
    Rename = Table.RenameColumns(NyckelTabell, {{"values", "Antal"}}),
    Typade = Table.TransformColumnTypes(Rename, {{"Antal", Int64.Type}, {"Ålder", type text}, {"Kön", type text}}),
    Pivot = Table.Pivot(Typade, List.Distinct(Typade[Kön]), "Kön", "Antal"),
    BytNamn = Table.RenameColumns(Pivot, {{"TotSa", "Totalt"}, {"1", "Män"}, {"2", "Kvinnor"}}),
    LäggTillSort = Table.AddColumn(BytNamn, "SortÅlder", each if Text.EndsWith([Ålder], "+") then 100 else Number.FromText([Ålder])),
    Sorterad = Table.Sort(LäggTillSort, {{"SortÅlder", Order.Ascending}}),
    Slut = Table.RemoveColumns(Sorterad, {"SortÅlder"})
in
    Slut
