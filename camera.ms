rollout coronaCamRollout "Corona Camera & Aspect Ratio" width:220 height:420
(
    -- Camera List and Controls
    listbox lstCameras "Cameras" pos:[13,7] width:166 height:10 align:#left
    button btnAddCamera "Add" pos:[18,169] width:35 height:21 align:#left
    button btnRemoveCamera "Remove" pos:[60,169] width:55 height:21 align:#left
    button btnRefreshList "Refresh" pos:[125,168] width:54 height:21 align:#left

    -- Aspect Ratio Controls
    spinner spnAspect "Aspect Ratio" pos:[12,208] width:74 height:16 range:[0.1,5,1.77] type:#float align:#left
    checkbox chkAutoVerticalTilt "VTS" pos:[152,208] width:49 height:15 align:#left

    -- Aspect Ratio Preset Buttons
    button btnAspect08 "0.8" pos:[18,240] width:50 height:21 align:#left
    button btnAspect10 "1.0" pos:[78,240] width:50 height:21 align:#left
    button btnAspect177 "1.77" pos:[138,240] width:50 height:21 align:#left

    -- Function to Update Camera List
    fn updateCameraList =
    (
        lstCameras.items = for obj in objects where classof obj == CoronaCam collect obj.name
    )

    -- Function to Update Spinner with Selected Camera's Aspect Ratio
    fn updateSpinnerWithCameraAspect =
    (
        if lstCameras.selection > 0 then
        (
            local cam = getNodeByName lstCameras.items[lstCameras.selection]
            if cam != undefined and isProperty cam #aspectRatio then
                spnAspect.value = cam.aspectRatio
        )
    )

    -- Function to Update Safe Frame
    fn updateViewportAndSafeFrame aspectRatio =
    (
        if not viewport.IsSafeFrameEnabled() then viewport.ToggleSafeFrames()
        viewport.setTM viewport.getTM() -- Refresh viewport
        actionMan.executeAction 0 "40045" -- Safe Frame Toggle ON
        print ("Viewport and Safe Frame updated to Aspect Ratio: " + aspectRatio as string)
    )

    -- Function to Set Aspect Ratio of Selected Camera and Render Setup
    fn setAspectRatio value =
    (
        -- Update Camera Aspect Ratio
        if lstCameras.selection > 0 then
        (
            local cam = getNodeByName lstCameras.items[lstCameras.selection]
            if cam != undefined and isProperty cam #aspectRatio then
            (
                cam.aspectRatio = value
                spnAspect.value = value
                print ("Aspect Ratio changed to: " + value as string)
                updateViewportAndSafeFrame value
            )
        )

        -- Update Render Settings
        local rendWidth = renderWidth
        if rendWidth != undefined and rendWidth > 0 then
        (
            local newHeight = rendWidth / value
            renderHeight = newHeight
            print ("New Render Aspect Ratio Set: " + (rendWidth as float / newHeight as float) as string)
        )
    )

    -- Function to Create a Corona Camera
    fn createCoronaCamera =
    (
        actionMan.executeAction 572340868 "11" -- Chaos Corona: Create Corona Camera from View
        local newCam = undefined
        for obj in objects where classof obj == CoronaCam do newCam = obj -- Get the last created camera

        if newCam != undefined then
        (
            updateCameraList()
            lstCameras.selection = findItem lstCameras.items newCam.name -- Select the new camera in the list
            print ("Corona Camera Created: " + newCam.name)
        )
        else
        (
            print "Error: Failed to create Corona Camera!"
        )
    )

    -- Rollout Open Event
    on coronaCamRollout open do updateCameraList()

    -- Camera Selection Event
    on lstCameras selected index do
    (
        if index > 0 then
        (
            local cam = getNodeByName lstCameras.items[index]
            if cam != undefined then
            (
                select cam
                updateSpinnerWithCameraAspect()
            )
        )
    )

    -- Add Camera Event
    on btnAddCamera pressed do createCoronaCamera()

    -- Remove Camera Event
    on btnRemoveCamera pressed do
    (
        if lstCameras.selection > 0 then
        (
            local cam = getNodeByName lstCameras.items[lstCameras.selection]
            if cam != undefined then delete cam
            updateCameraList()
            print (cam.name + " deleted.")
        )
    )

    -- Refresh Camera List Event
    on btnRefreshList pressed do updateCameraList()

    -- Auto Vertical Tilt Toggle Event
    on chkAutoVerticalTilt changed state do
    (
        if selection.count == 1 and classof selection[1] == CoronaCam then
        (
            local cam = selection[1]
            if isProperty cam #autoVerticalTilt then
            (
                cam.autoVerticalTilt = state
                print ("Auto Vertical Tilt changed to: " + state as string)
            )
        )
    )

    -- Aspect Ratio Change Event
    on spnAspect changed val do setAspectRatio val

    -- Aspect Ratio Preset Buttons
    on btnAspect08 pressed do setAspectRatio 0.8
    on btnAspect10 pressed do setAspectRatio 1.0
    on btnAspect177 pressed do setAspectRatio 1.77
)

createDialog coronaCamRollout 220 420
