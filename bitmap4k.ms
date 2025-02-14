rollout bitmapRollout "Bitmap Checker" width:160 height:152
(
	button 'btnbtmpres' "Check Bitmaps" pos:[39,7] width:85 height:21 align:#left
	edittext 'outputEdtBox' "" pos:[5,44] width:148 height:100 readOnly:true align:#left

    local highResCount = 0
    local midResCount = 0
    local lowResCount = 0
    local veryLowResCount = 0

    function categorizeBitmap bitmapTex = (
        if (isKindOf bitmapTex Bitmaptexture) then (
            local bmp = bitmapTex.bitmap
            if (bmp.width >= 4096 or bmp.height >= 4096) then (
                highResCount += 1
            )
            else if (bmp.width >= 2048 and bmp.width < 4096) or (bmp.height >= 2048 and bmp.height < 4096) then (
                midResCount += 1
            )
            else if (bmp.width >= 1024 and bmp.width < 2048) or (bmp.height >= 1024 and bmp.height < 2048) then (
                lowResCount += 1
            )
            else (
                veryLowResCount += 1
            )
        )
    )

    function processAllBitmaps = (
        highResCount = 0
        midResCount = 0
        lowResCount = 0
        veryLowResCount = 0

        local allBitmaps = getClassInstances Bitmaptexture
        for tex in allBitmaps do (
            categorizeBitmap tex
        )

        local outputText = "4K+: " + highResCount as string + "\n" +
                           "2K-4K: " + midResCount as string + "\n" +
                           "1K-2K: " + lowResCount as string + "\n" +
                           "Less than 1K Bitmaps: " + veryLowResCount as string
        outputEdtBox.text = outputText
    )

	on btnbtmpres pressed do
	(
	    processAllBitmaps()
	)
)

createDialog bitmapRollout
