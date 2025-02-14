rollout assetServerRollout "Asset Server Checker"
(
    button btnScan "Scan Assets"
    listbox lbResults "Results" width:300 height:200

    on btnScan pressed do
    (
        local result = scanAssetsAndMapToServers()
        local assetServerMapping = result[1]
        local serverCounts = result[2]

        lbResults.items = #()

        -- Display asset-to-server mappings
        for mapping in assetServerMapping do
        (
            lbResults.items += #(mapping[1] + " - " + mapping[2])
        )

        -- Display server count summary
        lbResults.items += #("Server Counts:")
        for i = 1 to serverCounts.count do
        (
            lbResults.items += #(serverCounts[i][1] + ": " + serverCounts[i][2] as string)
        )
    )
)

createDialog assetServerRollout 400 300

fn checkAssetServer assetPath =
(
    if matchPattern assetPath pattern:"*milkyway*" then
        return "milkyway"
    else if matchPattern assetPath pattern:"*core*" then
        return "core"
    else
        return "unknown"
)

fn scanAssetsAndMapToServers =
(
    local assets = getFiles "C:/path/to/assets/*.*" -- Change this to your assets directory
    local assetServerMap = #()
    
    -- Use an array to store server counts
    local serverCounts = #(#("milkyway", 0), #("core", 0), #("unknown", 0))

    for asset in assets do
    (
        local server = checkAssetServer asset
        append assetServerMap #(asset, server)

        -- Update the correct server count
        for i = 1 to serverCounts.count do
        (
            if serverCounts[i][1] == server then
            (
                serverCounts[i][2] += 1
            )
        )
    )

    return #(assetServerMap, serverCounts)
)
