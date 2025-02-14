rollout myRollout "DotNet ListView Example"
(
    dotNetControl lvw "System.Windows.Forms.ListView" width:300 height:150
    button btnAdd "Add Item"

    on myRollout open do
    (
        -- Configure ListView
        lvw.View = lvw.View.Details
        lvw.FullRowSelect = true
        lvw.GridLines = true
        lvw.MultiSelect = false

        -- Add Columns
        lvw.Columns.Add "ID"  50
        lvw.Columns.Add "Name" 200

        -- Add Sample Data
        lvw.Items.Add (dotNetObject "System.Windows.Forms.ListViewItem" #("1", "Item One"))
        lvw.Items.Add (dotNetObject "System.Windows.Forms.ListViewItem" #("2", "Item Two"))
    )

    on btnAdd pressed do
    (
        local newItem = dotNetObject "System.Windows.Forms.ListViewItem" #("3", "New Item")
        lvw.Items.Add newItem
    )
)

createDialog myRollout width:320 height:250