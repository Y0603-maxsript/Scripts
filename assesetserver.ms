

rollout assetTrackerRollout "Asset Tracker"
(
    listbox assetList "Assets" width:300 height:200
    button btnScan "Scan Assets"
    edittext totalSizeBox "Total Size (MB):" readonly:true
    
    fn getAssetData =
    (
        local assets = #()
        local paths = getFiles "C:\\path\\to\\assets\\*.*" -- Change this path accordingly
        local totalSize = 0.0
        
        for path in paths do
        (
            local fileSize = (getFileSize path) / (1024.0 * 1024.0) -- Convert to MB
            local server = if findString path "Milkyway" != undefined then "Milkyway" else "Core"
            append assets #(getFilenameFile path, server, fileSize)
            totalSize += fileSize
        )
        
        return #(assets, totalSize)
    )
    
    on btnScan pressed do
    (
        assetList.items = #() -- Clear the list
        local result = getAssetData()
        local assets = result[1]
        local totalSize = result[2]
        
        for asset in assets do
        (
            assetList.items += (asset[1] + " | " + asset[2] + " | " + formattedPrint asset[3] format:"%.2f")
        )
        
        totalSizeBox.text = formattedPrint totalSize format:"%.2f"
    )
)

createDialog assetTrackerRollout 320 300