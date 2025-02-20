rollout unnamedRollout "Untitled" width:162 height:300
(
    button 'btn1' "Button" pos:[32,16] width:96 height:24 align:#left
    editText 'edt1' "" pos:[17,54] width:124 height:108 align:#left

    --- Global Variables
    global highResCount = 0
    global midResCount = 0
    global lowResCount = 0
    global veryLowResCount = 0

    --- Functions
    fn checkImageSize imagePath =
    (
        if (doesFileExist imagePath) then
        (
            dotnet.loadAssembly @"C:\Users\S117\source\repos\ImageSizeCkacker\ImageSizeCkacker\bin\Release\ImageSizeCkacker.dll"
            checker = dotNetObject "ImageSizeChecker.Checker"
            local imageSize = checker.GetImageSize imagePath	
            
            if (imageSize.width >= 4096 or imageSize.height >= 4096) then (
                highResCount += 1
            )
            else if (imageSize.width >= 2048 and imageSize.width < 4096) or (imageSize.height >= 2048 and imageSize.height < 4096) then (
                midResCount += 1
            )
            else if (imageSize.width >= 1024 and imageSize.width < 2048) or (imageSize.height >= 1024 and imageSize.height < 2048) then (
                lowResCount += 1
            )
            else (
                veryLowResCount += 1
            )
        )
        else
        (
            format "Error: File % does not exist.\n" imagePath
        )
    )

    fn processBitmapFiles filePath =
    (
        checkImageSize filePath
    )

    -- Event Handler
    on btn1 pressed do
    (
        -- Reset Counts
        highResCount = 0
        midResCount = 0
        lowResCount = 0
        veryLowResCount = 0

        -- Process Files
        enumerateFiles processBitmapFiles

        -- Update UI
        edt1.text = "4K+: " + highResCount as string + "\n" +
                    "2K-4K: " + midResCount as string + "\n" +
                    "1K-2K: " + lowResCount as string + "\n" +
                    "Less than 1K Bitmaps: " + veryLowResCount as string
    )
)

createDialog unnamedRollout width:162 height:300
