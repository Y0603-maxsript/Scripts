rollout FinalRollout "Scanner" width:280 height:1000
(
    GroupBox 'grpbx_proxy' "Proxy Objects" pos:[18,6] width:244 height:226 align:#left
	listbox 'lbx_proxy' "Proxy List" pos:[32,64] width:220 height:10 align:#left
	label 'lbl_totalProxies' "Total Proxies: 0" pos:[17,35] width:200 height:18 align:#left
	label 'lbl_totalSize' "Total Size: 0 MB" pos:[126,35] width:200 height:18 align:#left
	GroupBox 'grpbx_vertex' "Layer Vertex Counts" pos:[17,239] width:244 height:209 align:#left
	listbox 'lbx_vertexCounts' "Vertex Counts" pos:[24,264] width:220 height:10 align:#left
	GroupBox 'grpbx_sss' "SSS" pos:[16,456] width:244 height:209 align:#left
	listbox 'lbx_ssscount' "SSS count" pos:[24,496] width:220 height:9 align:#left
    GroupBox 'grp_displace' "Displacement" pos:[16,672] width:244 height:209 align:#left
	listbox 'lbx_disp' "Displacement Count" pos:[24,712] width:220 height:9 align:#left
	button 'btn_scan' "Scan" pos:[80,896] width:96 height:24 align:#left

    ------------------------------------------------------------------------------------------
    -- Functions

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

    fn processVertexCounts =
    (
        lbx_vertexCounts.items = #()  -- Clear existing list

        local layerVertexCounts = #()
        
        for i in 0 to (LayerManager.count - 1) do
        (
            local currentLayer = LayerManager.getLayer i
            local layerName = currentLayer.name
            local vertexCount = 0
            
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
            
            append layerVertexCounts #(layerName, vertexCount)  
        )

        qsort layerVertexCounts (fn compareLayers a b = b[2] - a[2])

        for i in layerVertexCounts do
        (
            local layerInfo = i[1] + ": " + i[2] as string + " Verts"
            lbx_vertexCounts.items = append lbx_vertexCounts.items layerInfo
        )
    )

    -- SSS Content
    fn processSSS =
    (
        lbx_ssscount.items = #()  -- Clear existing list

        local sssMaterials = #()
        local coronaMatFound = false  -- Flag to check if any CoronaPhysicalMtl exists

        for obj in objects do
        (
            local mat = obj.material

            if mat != undefined and classof mat == CoronaPhysicalMtl then
            (
                coronaMatFound = true  -- Set flag to true since we found a Corona material

                if mat.sssamount > 0.0 and findItem sssMaterials mat == 0 then
                (
                    append sssMaterials mat
                )
            )
        )

        -- If no Corona materials were found, show a message box
        if coronaMatFound == false then
        (
            messageBox "No Corona Physical Materials found in the scene." title:"Warning"
        )

        -- Update Listbox
        for mat in sssMaterials do
        (
            lbx_ssscount.items = append lbx_ssscount.items ("SSS: " + mat.name)
        )
    ) 
-- Displacement Content
    fn processDisplacement =
    (
        lbx_disp.items = #()  -- Clear existing list

        local displacementMaterials = #()
        local coronaMatFound = false  

        for obj in objects do
        (
            local mat = obj.material

            if mat != undefined and classof mat == CoronaPhysicalMtl then
            (
                coronaMatFound = true  -- Set flag to true since we found a Corona material
                
                if (mat.displacementTexmap != undefined and mat.displacementTexmap != null and mat.displacementMaximum > 0.0 and mat.displacementMinimum >0.0)then
            (
				
                append displacementMaterials  mat
            
            )
            )
        )

        -- If no Corona materials were found, show a message box
        if coronaMatFound == false then
        (
            messageBox "No Corona Physical Materials found in the scene." title:"Warning"
        )

        -- Update Listbox
        for mat in displacementMaterials do
        (
            lbx_disp.items = append lbx_disp.items ("Displacement: " + mat.name) -- Fixed typo from "Displcament"
        )
    )
---------------------------------------------------------------------------------------------
    -- Events

	on btn_scan pressed do
	(
	    processProxies()                 -- Scan Proxy Objects
	    processVertexCounts()             -- Scan Layer Vertex Counts
	    processSSS() 
        processDisplacement()
	)
)

---------------------------------------------------------------------------------------------
theNewFloater = newRolloutFloater "Scaner" 300 900
   addRollout FinalRollout theNewFloater