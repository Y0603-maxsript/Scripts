rollout assetServerRollout "Asset Server Scanner"
(
    button btnScan "Scan Assets"
    listBox lbResults "Results" height:10 width:50

    on btnScan pressed do
    (
        if ATSOps != undefined then 
        (
            local fileList = #()
            ATSOps.GetFiles &fileList

            local milkywayCount = 0
            local coreCount = 0
            local totalSize = 0

            format "Files: %\n" fileList

            for file in fileList do
            (
                if matchPattern file pattern:"*milkyway*" then milkywayCount += 1
                if matchPattern file pattern:"*core*" then coreCount += 1

                local fileInfo = getFileSize file
                if fileInfo != undefined then totalSize += fileInfo
            )

            lbResults.items = fileList
            format "Milkyway Count: %\n" milkywayCount
            format "Core Count: %\n" coreCount
            format "Total Size: % bytes\n" totalSize
        )
    )
)
createDialog assetServerRollout