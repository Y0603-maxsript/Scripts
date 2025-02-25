rollout ScanTheScane "Scanner" width:500 height:1500
(
------------------------------------------------------------------------------------------
-- **UI Elements**
GroupBox 'grpbx_proxy' "Proxy Objects" pos:[18,6] width:470 height:226 align:#left
listbox 'lbx_proxy' "Proxy List" pos:[30,68] width:450 height:10 align:#left
label 'lbl_totalProxies' "Total Proxies: 0" pos:[24,32] width:200 height:18 align:#left
label 'lbl_totalSize' "Total Size: 0 MB" pos:[384,40] width:200 height:18 align:#left
GroupBox 'grpbx_vertex' "Layer Vertex Counts" pos:[17,239] width:471 height:209 align:#left
listbox 'lbx_vertexCounts' "Vertex Counts" pos:[24,264] width:448 height:10 align:#left
GroupBox 'grpbx_sss' "SSS" pos:[16,456] width:472 height:209 align:#left
listbox 'lbx_ssscount' "SSS count" pos:[24,496] width:448 height:9 align:#left
button 'btn_removeSelectedsss' "Remove Selected" pos:[56,680] width:110 height:24 align:#left
button 'btn_removeAllsss' "Remove All" pos:[344,680] width:110 height:24 align:#left
GroupBox 'grpbx_displace' "Displacemant" pos:[16,752] width:472 height:209 align:#left
listbox 'lbx_displacemant' "Displacemant" pos:[24,792] width:448 height:9 align:#left
button 'btn_removeSelecteddisp' "Remove Selected" pos:[56,976] width:110 height:24 align:#left
button 'btn_removeAlldisp' "Remove All" pos:[344,976] width:110 height:24 align:#left
listbox 'edt1' "Bitmap" pos:[20,1045] width:460 height:10 readOnly:true align:#left
listbox 'lbx22' "Server " pos:[19,1214] width:461 height:11 align:#left
button 'btn_scan' "Scan" pos:[216,1424] width:96 height:24 align:#left
------------------------------------------------------------------------------------------
-- Load DLL for image resolution checking

------------------------------------------------------------------------------------------

    -- **Process Proxy Objects**
    fn ProxyCount =
    (
        lbx_proxy.items = #()  
        
        local proxies = for obj in geometry where (classof obj == CProxy) collect obj
        local uniqueProxies = #()
        local totalSize = 0  
         local proxyData = #() 
        for proxy in proxies do
        (
            if findItem uniqueProxies proxy.fileName == 0 do
            (
                append uniqueProxies proxy.fileName
                local fileSize = getFileSize proxy.fileName / 1024.00 / 1024.00  -- Convert to MB
                totalSize += fileSize

                -- Format and add to listbox
                local proxyInfo = proxy.name + ": " + (formattedPrint fileSize) + " GB"
                lbx_proxy.items = append lbx_proxy.items proxyInfo
            )
        )
        -- Sort proxies by file size in DESCENDING order
    qsort proxyData (fn compareProxy a b = b[3] > a[3]) 

    -- Populate listbox after sorting
    for p in proxyData do
    (
        local proxyInfo = p[1] + ": " + (formattedPrint (p[3] / 1024.0) format:"2.2f") + " GB"
        append lbx_proxy.items proxyInfo
    )

        -- Update Labels
        lbl_totalProxies.text = "Total Proxies: " + uniqueProxies.count as string
        lbl_totalSize.text = "Total Size: " + (formattedPrint totalSize) + " GB"
    )

---------------------------------------------------------------------------------------------
-- **Process Vertex Counts**
fn LayerVartexCount =
(
    lbx_vertexCounts.items = #()  -- Clear existing list
    global layerVertexCounts = #()

    for i in 0 to (LayerManager.count - 1) do
    (
        local currentLayer = LayerManager.getLayer i
        local layerName = currentLayer.name
        local vertexCount = 0

        -- Get objects in the current layer using nodes &layerNodes
        local layerNodes = #()
        currentLayer.nodes &layerNodes  -- Populate layerNodes array with nodes in the layer

        -- Iterate through objects in the current layer
        for obj in layerNodes do
        (
            if obj.layer.name == layerName and superClassOf obj == GeometryClass do
            (
                local tempMesh = snapshotAsMesh obj
                if tempMesh != undefined do
                (
                    vertexCount += tempMesh.numVerts
                )
            )
        )
        
        append layerVertexCounts #(layerName, vertexCount)  
    )

    -- Sort layers by vertex count in descending order
    qsort layerVertexCounts (fn compareLayers a b = b[2] > a[2])

    -- Populate the listbox with layer names and vertex counts
    for i in layerVertexCounts do
    (
        local layerInfo = i[1] + ": " + i[2] as string + " Verts"
        lbx_vertexCounts.items = append lbx_vertexCounts.items layerInfo
    )
)


---------------------------------------------------------------------------------------------
-- **Process SSS Materials**
 
fn MaterialSSSCount =
    (
        lbx_ssscount.items = #()  -- Clear existing list
        global sssMaterials  
        sssMaterials = #()

        -- Get all instances of CoronaPhysicalMtl and CoronaLegacyMtl
        local sceneMaterials = getClassInstances CoronaPhysicalMtl + getClassInstances CoronaLegacyMtl

        for mat in sceneMaterials do
        (
            local hasSSS = false

            -- Check SSS for CoronaPhysicalMtl
            if classOf mat == CoronaPhysicalMtl do
            (
                if mat.sssAmount > 0.0 or (isProperty mat #mapAmountSSS and mat.mapAmountSSS > 0.0) do
                (
                    hasSSS = true
                )
            )

            -- Check SSS for CoronaLegacyMtl
            if classOf mat == CoronaLegacyMtl do
            (
                if mat.mapamountSssAmount > 0.0 do
                (
                    hasSSS = true
                )
            )

            -- If SSS is found, add to the list
            if hasSSS do
            (
                append sssMaterials mat
            )
        )

        -- Populate the listbox with material names
        for mat in sssMaterials do
        (
            lbx_ssscount.items = append lbx_ssscount.items ("SSS: " + mat.name)
        )
    )

---------------------------------------------------------------------------------------------
-- **Process Displacement Materials**
     fn DisplacemantCount =
     (
         lbx_displacemant.items = #()
         global displacementMaterials = #()
 
         local material = getClassInstances CoronaPhysicalMtl 
         local material1 = getClassInstances CoronaLegacyMtl
 
         for mat in material where (mat.displacementTexmap != undefined and mat.displacementTexmap != null and mat.displacementMaximum > 0.0 and mat.displacementMinimum > 0.0) do
         (
             append displacementMaterials mat
         )
         for mat in material1 where (mat.texmapDisplace != undefined and mat.texmapDisplace != null and mat.displacementMaximum > 0.0 and mat.displacementMinimum > 0.0) do
         (
             append displacementMaterials mat
         )
 
         for mat in displacementMaterials do
         (
             lbx_displacemant.items = append lbx_displacemant.items ("Displacement: " + mat.name)
         )
        
     )
 
--------------------------------------------------------------------------------------------
-- **Process Bitmaps**

global highResCount = 0, highResSize = 0
global midResCount = 0, midResSize = 0
global lowResCount = 0, lowResSize = 0
global veryLowResCount = 0, veryLowResSize = 0
-- Function to check image resolution and file size
fn checkImageSize imagePath =
(
    if doesFileExist imagePath then
    (
        try
        (
            local checker = dotNetObject "ImageSizeChecker.Checker"
            local imageSize = checker.GetImageSize imagePath	

            -- Get file size in MB
            local fileSizeGB = (getFileSize imagePath) / 1024.0 / 1024.0/1024.0

            -- Categorize image based on resolution and add to counters
            if (imageSize.width >= 4096 or imageSize.height >= 4096) then 
            (
                highResCount += 1
                highResSize += fileSizeMB
            )
            else if (imageSize.width >= 2048 and imageSize.width < 4096) or (imageSize.height >= 2048 and imageSize.height < 4096) then 
            (
                midResCount += 1
                midResSize += fileSizeMB
            )
            else if (imageSize.width >= 1024 and imageSize.width < 2048) or (imageSize.height >= 1024 and imageSize.height < 2048) then 
            (
                lowResCount += 1
                lowResSize += fileSizeMB
            )
            else 
            (
                veryLowResCount += 1
                veryLowResSize += fileSizeMB
            )
        )
        catch (format "Error loading DLL or processing file: %\n" imagePath)
    )
    else
    (
        format "File does not exist: %\n" imagePath
    )
)
fn processBitmapFiles filePath =
(
    checkImageSize filePath
)
fn scanBitmaps =
(
    
    highResCount = 0; highResSize = 0
    midResCount = 0; midResSize = 0
    lowResCount = 0; lowResSize = 0
    veryLowResCount = 0; veryLowResSize = 0
    enumerateFiles processBitmapFiles
    edt1.items = #(
        "4K+: " + highResCount as string + " images | " + (formattedPrint highResSize) + " GB\n" ,
        "2K-4K: " + midResCount as string + " images | " + (formattedPrint midResSize) + " GB\n" ,
        "1K-2K: " + lowResCount as string + " images | " + (formattedPrint lowResSize) + " GB\n" ,
        "<1K: " + veryLowResCount as string + " images | " + (formattedPrint veryLowResSize) + " GB"
    )
    
)

--------------------------------------------------------------------------------------------
--- server function
    fn AssetsServerChack = 
(
    if ATSOps != undefined then 
    (
        local fileList = #()
        ATSOps.GetFiles &fileList

        local milkywayCount = 0
        local coreCount = 0
        local totalSizeMB = 0.0
        local milkywaySizeMB = 0.0
        local coreSizeMB = 0.0
        local fileDetails = #() 

        format "Files: %\n" fileList

        for file in fileList do
        (
            local fileSize = getFileSize file
            if fileSize != undefined then 
            (
                -- Convert size to MB
                local fileSizeMB = (fileSize as float) / (1024.0 * 1024.0*1024.0)
                totalSizeMB += fileSizeMB

                -- Add formatted file info to list
                append fileDetails (file + " - " + formattedPrint fileSizeMB format:"3.2f" + " GB")

                -- Categorize by name
                if matchPattern file pattern:"*milkyway*" then 
                (
                    milkywayCount += 1
                    milkywaySizeMB += fileSizeMB
                )

                if matchPattern file pattern:"*core*" then 
                (
                    coreCount += 1
                    coreSizeMB += fileSizeMB
                )
            )
        )

        -- Update listbox with counts, sizes, and individual file details
        lbx22.items = #(
            "Milkyway Count: " + milkywayCount as string + " | Size: " + formattedPrint milkywaySizeMB format:"3.2f" + " GB",
            "Core Count: " + coreCount as string + " | Size: " + formattedPrint coreSizeMB format:"3.2f" + " GB"
           
        ) 
    )
)

-- Event's 
---------------------------------------------------------------------------------------------

on ScanTheScane open do 
(
    dotnet.loadAssembly @"C:\Users\S117\source\repos\ImageSizeCkacker\ImageSizeCkacker\bin\Release\ImageSizeCkacker.dll"
)

-- double click proxy
on lbx_proxy doubleClicked index do
(
    local selectedIndex = lbx_proxy.selection  -- Get selected index
    if selectedIndex != undefined and selectedIndex > -1 do
    (
        local selectedText = lbx_proxy.items[selectedIndex]  -- Get full text from listbox
        local parsedText = filterString selectedText ":"  -- Split at ":"
        
        if parsedText.count > 0 do
        (
            local proxyName = trimRight parsedText[1]  -- Extract proxy name
            local proxyObj = getNodeByName proxyName  -- Find proxy object in the scene
            
            if proxyObj != undefined then
            (
                select proxyObj
                format "Selected Proxy: %\n" proxyObj
            )
            else
            (
                messageBox "No matching proxy found in the scene!" title:"Selection Error"
            )
        )
	    )
	)
------------------------------------------------------------------------------------------
-- double click sss
    on lbx_ssscount doubleClicked index do
	(
        sme.Open()  -- Opens the Slate Material Editor
	)
------------------------------------------------------------------------------------------
-- **Remove Selected SSS Material**
	on btn_removeSelectedsss pressed do
	(
        local selectedIndex = lbx_ssscount.selection
	    if selectedIndex > 0 and selectedIndex <= sssMaterials.count then
	    (
            local selectedMat = sssMaterials[selectedIndex]
	        selectedMat.sssAmount = 0.0  -- Disable SSS
            
	        -- Remove from sssMaterials array
	        deleteItem sssMaterials selectedIndex  
            
	        -- Refresh Listbox
	        processSSS()
            
	        messageBox "Selected SSS material updated and removed." title:"Material Removed"
	    )
	    else
	    (
            messageBox "Please select a material to remove." title:"Selection Error"
	    )
	)
------------------------------------------------------------------------------------------
-- **Remove All SSS Materials**
	on btn_removeAllsss pressed do
	(
        for mat in sssMaterials do
	    (
            mat.sssamount = 0.0  -- Set SSS amount to 0 for all
	    )
	    
	    lbx_ssscount.items = #()  -- Clear the listbox
	    sssMaterials = #()  -- Clear stored materials
        
	    messageBox "All SSS materials updated and removed from the list." title:"All Removed"
	)
------------------------------------------------------------------------------------------
-- double click displacemant
	on lbx_displacemant doubleClicked index do
	(
        sme.Open()  
	)
------------------------------------------------------------------------------------------
-- **Remove Selected Displacement Material**
	on btn_removeSelecteddisp pressed do
	(
        local selectedIndex = lbx_displacemant.selection
	    if selectedIndex > 0 and selectedIndex <= displacementMaterials.count then
	    (
            local selectedMat = displacementMaterials[selectedIndex]
	        selectedMat.displacementTexmap = undefined  -- Remove Displacement Texture Map
            
	        -- Remove from displacementMaterials array
	        deleteItem displacementMaterials selectedIndex  
            
	        -- Refresh Listbox
	        DisplacemantCount()
	
	        messageBox "Selected Displacement material updated and removed." title:"Material Removed"
	    )
	    else
	    (
	        messageBox "Please select a material to remove." title:"Selection Error"
	    )
	)
------------------------------------------------------------------------------------------
-- **Remove All Displacement Materials**
	on btn_removeAlldisp pressed do
	(
	    if displacementMaterials.count > 0 then
	    (
	        for mat in displacementMaterials do
	        (
	            mat.displacementTexmap = undefined   
                mat.displacementMaximum = 0.0
                mat.displacementMinimum = 0.0
                
	        )
	
	        -- Clear array and refresh listbox
	        displacementMaterials = #()
	        DisplacemantCount()
	
	        messageBox "All Displacement materials removed." title:"Materials Cleared"
	    )
	    else
	    (
            messageBox "No Displacement materials to remove." title:"Info"
	    )
	)
---------------------------------------------------------------------------------------------
-- **Main Scan Button**
	on btn_scan pressed do
	(
        ProxyCount()                 
	    LayerVartexCount()
	    MaterialSSSCount()
	    DisplacemantCount()
	    scanBitmaps()
	    AssetsServerChack()
	    
	)
)
---------------------------------------------------------------------------------------------
theNewFloater = newRolloutFloater "Scaner" 510 900
addRollout ScanTheScane theNewFloater