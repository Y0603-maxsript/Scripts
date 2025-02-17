(
    fn getLayerVerticesCount layer =
    (
        local vertexCount = 0
        for i = 1 to (layer.nodes as array).count do
        (
            local obj = layer.nodes[i]
            if isKindOf obj Editable_Poly or isKindOf obj Editable_Mesh then
            (
                vertexCount += getVertCount obj
            )
        )
        return vertexCount
    )

    for i = 0 to (LayerManager.count - 1) do
    (
        local layer = LayerManager.getLayer i
        local layerName = layer.name
        local verticesCount = getLayerVerticesCount layer
        format "Layer: % - Vertices: %\n" layerName verticesCount
    )
)