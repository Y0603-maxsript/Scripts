rollout assetServerRollout "Asset Server Scanner"
(
    button btnScan "Scan Assets"
    listBox lbResults "Results" height:10 width:50

    on btnScan pressed do
    (
        if ATSOps != undefined then 
        (
            local files = ATSOps.GetFiles true  
            local milkywayCount = 0
            local coreCount = 0

            for file in files do
            (
                if matchPattern file pattern:"*milkyway*" then
                (
                    milkywayCount += 1
                )
                else if matchPattern file pattern:"*core*" then
                (
                    coreCount += 1
                )
            )

            lbResults.items = #("Milkyway Server: " + milkywayCount as string, "Core Server: " + coreCount as string)
        ) 
    )
)
createDialog assetServerRollout