rollout FinalRollout "Scanner" width:280 height:1500
(
	GroupBox 'grpbx_proxy' "Proxy Objects" pos:[18,6] width:244 height:226 align:#left
	listbox 'lbx_proxy' "Proxy List" pos:[30,68] width:220 height:10 align:#left
	label 'lbl_totalProxies' "Total Proxies: 0" pos:[17,35] width:200 height:18 align:#left
	label 'lbl_totalSize' "Total Size: 0 MB" pos:[126,35] width:200 height:18 align:#left
	GroupBox 'grpbx_vertex' "Layer Vertex Counts" pos:[17,239] width:244 height:209 align:#left
	listbox 'lbx_vertexCounts' "Vertex Counts" pos:[24,264] width:220 height:10 align:#left
	GroupBox 'grpbx_sss' "SSS" pos:[16,456] width:244 height:209 align:#left
	listbox 'lbx_ssscount' "SSS count" pos:[24,496] width:220 height:9 align:#left
	button 'btn_removeSelectedsss' "Remove Selected" pos:[24,710] width:110 height:24 align:#left
	button 'btn_removeAllsss' "Remove All" pos:[140,710] width:110 height:24 align:#left
	GroupBox 'grpbx_displace' "Displacemant" pos:[16,752] width:244 height:209 align:#left
	listbox 'lbx_displacemant' "Displacemant" pos:[24,792] width:220 height:9 align:#left
	button 'btn_removeSelecteddisp' "Remove Selected" pos:[24,1006] width:110 height:24 align:#left
	button 'btn_removeAlldisp' "Remove All" pos:[140,1007] width:110 height:24 align:#left
	listbox 'edt1' "Bitmap" pos:[20,1045] width:246 height:10 readOnly:true align:#left
	listbox 'lbx22' "Server " pos:[19,1214] width:248 height:11 align:#left


	button 'btn_scan' "Scan" pos:[75,1398] width:96 height:24 align:#left

    ------------------------------------------------------------------------------------------
    -- **Process Proxy Objects**
    fn processProxies =
    (
        lbx_proxy.items = #()  -- Clear existing list
        
        local proxies = for obj in geometry where (classof obj == CProxy) collect obj
        local uniqueProxies = #()
        local totalSize = 0  

        for proxy in proxies do
        (
            if findItem uniqueProxies proxy.fileName == 0 do
            (
                append uniqueProxies proxy.fileName
                local fileSize = getFileSize proxy.fileName / 1024.00 / 1024.00 -- Convert to MB
                totalSize += fileSize

                -- Format and add to listbox
                local proxyInfo = proxy.name + ": " + (formattedPrint fileSize) + " MB"
                lbx_proxy.items = append lbx_proxy.items proxyInfo
            )
        )

        -- Update Labels
        lbl_totalProxies.text = "Total Proxies: " + uniqueProxies.count as string
        lbl_totalSize.text = "Total Size: " + (formattedPrint totalSize) + " MB"
    )

   

-- Handle Double-Click Selection

---------------------------------------------------------------------------------------------
-- **Process Vertex Counts**
fn processVertexCounts =
(
    lbx_vertexCounts.items = #()  -- Clear existing list

    local layerVertexCounts = #()
    
    for i in 0 to (LayerManager.count - 1) do
    (
        local currentLayer = LayerManager.getLayer i
        local layerName = currentLayer.name
        local vertexCount = 0
        
        -- Check if layer is visible
        if currentLayer.on do
        (
            for obj in objects do
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
        )
        
        append layerVertexCounts #(layerName, vertexCount)  
    )

    qsort layerVertexCounts (fn compareLayers a b = b[2] - a[2])

    for i in layerVertexCounts do
    (
        local layerInfo = i[1] + ": " + i[2] as string + " Verts"
        lbx_vertexCounts.items = append lbx_vertexCounts.items layerInfo
    )
)

---------------------------------------------------------------------------------------------
--sss count
 
fn processSSS =
(
    lbx_ssscount.items = #()  -- Clear existing list

    global sssMaterials  
    sssMaterials = #()

    -- Get all CoronaPhysicalMtl materials in the scene
    local sceneMaterials = getClassInstances CoronaPhysicalMtl

    -- Loop through all CoronaPhysicalMtl materials
    for mat in sceneMaterials do
    (
        if mat.sssAmount > 0.0 then append sssMaterials mat
    )

    -- Update Listbox
    if sssMaterials.count > 0 then
    (
        for mat in sssMaterials do
        (
            lbx_ssscount.items = append lbx_ssscount.items ("SSS: " + mat.name)
        )
    )
   
)

-- Event listener for double-clicking the listbox

-- Remove Selected SSS Material
-- **Remove Selected SSS Material**


    ---------------------------------------------------------------------------------------------
    -- **Remove All SSS Materials**



    ---------------------------------------------------------------------------------------------
     -- **Process Displacement Materials**
     fn processDisplacementMaterials =
     (
         lbx_displacemant.items = #()
         global displacementMaterials = #()
 
         local sceneMaterials = getClassInstances CoronaPhysicalMtl
 
         for mat in sceneMaterials where (mat.displacementTexmap != undefined and mat.displacementTexmap != null and mat.displacementMaximum > 0.0 and mat.displacementMinimum > 0.0) do
         (
             append displacementMaterials mat
         )
 
         for mat in displacementMaterials do
         (
             lbx_displacemant.items = append lbx_displacemant.items ("Disp: " + mat.name)
         )
     )
 
    -- Event listener for double-clicking the listbox

-- **Remove Selected Displacement Material**

-- **Remove All Displacement Materials**
-- Global Counters and Size Trackers
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
            -- Load DLL for image resolution checking
            dotnet.loadAssembly @"C:\Users\S117\source\repos\ImageSizeCkacker\ImageSizeCkacker\bin\Release\ImageSizeCkacker.dll"
            local checker = dotNetObject "ImageSizeChecker.Checker"
            local imageSize = checker.GetImageSize imagePath	

            -- Get file size in MB
            local fileSizeMB = (getFileSize imagePath) / 1024.0 / 1024.0

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

-- Function to process each bitmap file
fn processBitmapFiles filePath =
(
    checkImageSize filePath
)

-- Function to enumerate and scan all bitmap files
fn scanBitmaps =
(
    -- Reset Counts and Sizes before scanning
    highResCount = 0; highResSize = 0
    midResCount = 0; midResSize = 0
    lowResCount = 0; lowResSize = 0
    veryLowResCount = 0; veryLowResSize = 0

    -- Scan all image files in the asset tracking system
    enumerateFiles processBitmapFiles

    -- Update UI with results (show count and total size)
    edt1.items = #(
        "4K+: " + highResCount as string + " images | " + (formattedPrint highResSize) + " MB\n" ,
        "2K-4K: " + midResCount as string + " images | " + (formattedPrint midResSize) + " MB\n" ,
        "1K-2K: " + lowResCount as string + " images | " + (formattedPrint lowResSize) + " MB\n" ,
        "<1K: " + veryLowResCount as string + " images | " + (formattedPrint veryLowResSize) + " MB"
    )
    
)

    --------------------------------------------------------------------------------------------
    --- server
    fn Assets = 
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
        local fileDetails = #() -- Store individual file sizes

        format "Files: %\n" fileList

        for file in fileList do
        (
            local fileSize = getFileSize file
            if fileSize != undefined then 
            (
                -- Convert size to MB
                local fileSizeMB = (fileSize as float) / (1024.0 * 1024.0)
                totalSizeMB += fileSizeMB

                -- Add formatted file info to list
                append fileDetails (file + " - " + formattedPrint fileSizeMB format:"3.2f" + " MB")

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
            "Milkyway Count: " + milkywayCount as string + " | Size: " + formattedPrint milkywaySizeMB format:"3.2f" + " MB",
            "Core Count: " + coreCount as string + " | Size: " + formattedPrint coreSizeMB format:"3.2f" + " MB"
           
        ) 
    )
)

	---------------------------------------------------------------------------------------------
    -- Event 
	
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
	on lbx_ssscount doubleClicked index do
	(
	    sme.Open()  -- Opens the Slate Material Editor
	)
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
	on lbx_displacemant doubleClicked index do
	(
	    sme.Open()  
	)
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
	        processDisplacementMaterials()
	
	        messageBox "Selected Displacement material updated and removed." title:"Material Removed"
	    )
	    else
	    (
	        messageBox "Please select a material to remove." title:"Selection Error"
	    )
	)
	on btn_removeAlldisp pressed do
	(
	    if displacementMaterials.count > 0 then
	    (
	        for mat in displacementMaterials do
	        (
	            mat.displacementTexmap = undefined  -- Remove Displacement Texture Map
	        )
	
	        -- Clear array and refresh listbox
	        displacementMaterials = #()
	        processDisplacementMaterials()
	
	        messageBox "All Displacement materials removed." title:"Materials Cleared"
	    )
	    else
	    (
	        messageBox "No Displacement materials to remove." title:"Info"
	    )
	)
	on btn_scan pressed do
	(
	    processProxies()                 
	    processVertexCounts()
	    processSSS()
	    processDisplacementMaterials()
	    scanBitmaps()
	    Assets()
	    
	)
)

---------------------------------------------------------------------------------------------
theNewFloater = newRolloutFloater "Scaner" 300 900
addRollout FinalRollout theNewFloater