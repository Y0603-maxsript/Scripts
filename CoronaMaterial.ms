fn countSSSAndDisplacement =
(
    local sssCount = 0  
    local displacementCount = 0  

    for obj in objects do
    (
        local mat = obj.material

        
        if mat != undefined and classof mat == CoronaPhysicalMtl then
        (
            
            if mat.sssamount > 0.0 then sssCount += 1

            
            if (mat.displacementTexmap != undefined and mat.displacementTexmap != null and mat.displacementMaximum > 0.0 and mat.displacementMinimum >0.0)then
            (
				
                displacementCount += 1
            
            )
        )
    )

    -- Print the final counts
    format "Total objects with SSS enabled: %\n" sssCount
    format "Total objects with displacement enabled and mapped: %\n" displacementCount
)

countSSSAndDisplacement()
