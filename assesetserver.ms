rollout assetServerRollout "Asset Server Scanner"
(
    button btnScan "Scan Assets"
    listBox lbResults "Results" height:10 width:50

    on btnScan pressed do
    (
        if ATSOps != undefined then 
        (
            local files = ATSOps.GetFiles true  
            print ("Files Retrieved: " + files as string)  
            
           
        ) 
        
    )
)

createDialog assetServerRollout