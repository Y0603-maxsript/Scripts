(
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
    
    for i in layerVertexCounts do format "%: %\n" i[1] i[2]
)