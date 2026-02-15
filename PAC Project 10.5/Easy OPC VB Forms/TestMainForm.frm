VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "mscomctl.ocx"
Begin VB.Form TestMainForm 
   Caption         =   "Test of Opto Easy OPC VB Forms"
   ClientHeight    =   6495
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   10050
   LinkTopic       =   "Form2"
   ScaleHeight     =   6495
   ScaleWidth      =   10050
   StartUpPosition =   2  'CenterScreen
   Begin VB.Timer timerUpdateItems 
      Enabled         =   0   'False
      Interval        =   500
      Left            =   630
      Top             =   4845
   End
   Begin VB.CommandButton cmdTestGroup 
      Caption         =   "Test Group"
      Height          =   225
      Left            =   5550
      TabIndex        =   11
      Top             =   1500
      Visible         =   0   'False
      Width           =   945
   End
   Begin VB.CommandButton cmdTestItem 
      Caption         =   "Test Item"
      Height          =   225
      Left            =   375
      TabIndex        =   10
      Top             =   3915
      Visible         =   0   'False
      Width           =   945
   End
   Begin VB.CommandButton cmdRemoveItems 
      Caption         =   "Remove Items"
      Height          =   345
      Left            =   255
      TabIndex        =   8
      Top             =   5850
      Width           =   1275
   End
   Begin VB.CommandButton cmdAddItems 
      Caption         =   "Add Items"
      Height          =   345
      Left            =   225
      TabIndex        =   7
      Top             =   2535
      Width           =   1275
   End
   Begin VB.CommandButton cmdRemoveGroup 
      Caption         =   "Remove Group"
      Height          =   345
      Left            =   5400
      TabIndex        =   5
      Top             =   1830
      Width           =   1275
   End
   Begin VB.CommandButton cmdModifyGroup 
      Caption         =   "Modify Group"
      Height          =   345
      Left            =   5400
      TabIndex        =   4
      Top             =   1020
      Width           =   1275
   End
   Begin VB.CommandButton cmdAddGroup 
      Caption         =   "Add Group"
      Height          =   345
      Left            =   5400
      TabIndex        =   3
      Top             =   240
      Width           =   1275
   End
   Begin VB.CommandButton cmdRemoveServer 
      Caption         =   "Remove Server"
      Height          =   345
      Left            =   240
      TabIndex        =   1
      Top             =   1830
      Width           =   1275
   End
   Begin VB.CommandButton cmdAddServer 
      Caption         =   "Add Server"
      Height          =   345
      Left            =   240
      TabIndex        =   0
      Top             =   240
      Width           =   1275
   End
   Begin MSComctlLib.ListView listviewItems 
      Height          =   3705
      Left            =   1695
      TabIndex        =   9
      Top             =   2535
      Width           =   8040
      _ExtentX        =   14182
      _ExtentY        =   6535
      View            =   3
      LabelEdit       =   1
      MultiSelect     =   -1  'True
      LabelWrap       =   -1  'True
      HideSelection   =   0   'False
      FullRowSelect   =   -1  'True
      GridLines       =   -1  'True
      _Version        =   393217
      ForeColor       =   -2147483640
      BackColor       =   -2147483643
      BorderStyle     =   1
      Appearance      =   1
      NumItems        =   6
      BeginProperty ColumnHeader(1) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         Text            =   "Server"
         Object.Width           =   2646
      EndProperty
      BeginProperty ColumnHeader(2) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   1
         Text            =   "Group"
         Object.Width           =   1764
      EndProperty
      BeginProperty ColumnHeader(3) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   2
         Text            =   "ItemID"
         Object.Width           =   7056
      EndProperty
      BeginProperty ColumnHeader(4) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   3
         Text            =   "Value"
         Object.Width           =   1764
      EndProperty
      BeginProperty ColumnHeader(5) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   4
         Text            =   "Quality"
         Object.Width           =   1764
      EndProperty
      BeginProperty ColumnHeader(6) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   5
         Text            =   "Time/Date"
         Object.Width           =   3528
      EndProperty
   End
   Begin MSComctlLib.ListView listviewGroups 
      Height          =   1965
      Left            =   6855
      TabIndex        =   6
      Top             =   240
      Width           =   2850
      _ExtentX        =   5027
      _ExtentY        =   3466
      View            =   3
      LabelEdit       =   1
      LabelWrap       =   -1  'True
      HideSelection   =   0   'False
      _Version        =   393217
      ForeColor       =   -2147483640
      BackColor       =   -2147483643
      BorderStyle     =   1
      Appearance      =   1
      NumItems        =   1
      BeginProperty ColumnHeader(1) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         Text            =   "Groups"
         Object.Width           =   5292
      EndProperty
   End
   Begin MSComctlLib.ListView listviewServers 
      Height          =   1965
      Left            =   1695
      TabIndex        =   2
      Top             =   240
      Width           =   2850
      _ExtentX        =   5027
      _ExtentY        =   3466
      View            =   3
      LabelEdit       =   1
      LabelWrap       =   -1  'True
      HideSelection   =   0   'False
      _Version        =   393217
      ForeColor       =   -2147483640
      BackColor       =   -2147483643
      BorderStyle     =   1
      Appearance      =   1
      NumItems        =   1
      BeginProperty ColumnHeader(1) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         Text            =   "Servers"
         Object.Width           =   5292
      EndProperty
   End
End
Attribute VB_Name = "TestMainForm"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
Option Base 1

' These variables are used for resizing the Add Items dialog
Dim m_AddItemsDlgWidth As Integer
Dim m_AddItemsDlgHeight As Integer

' The Update Queue is used to efficiently process callback data
Dim m_UpdateQueue As New CHandleQueue


Dim m_bRunGroupTest As Boolean


' These constants are used when resizing the main form
Const MAINFORM_MINWIDTH = 10140
Const MAINFORM_MINHEIGHT = 6870

Public WithEvents TheServers As ServerCollection
Attribute TheServers.VB_VarHelpID = -1
'
' cmdAddGroup_Click
'
Private Sub cmdAddGroup_Click()
  Dim TheListItem As ListItem
  Dim nGroupHandle As Long

  ' Make sure a server is selected
  Set TheListItem = listviewServers.SelectedItem
  If Not TheListItem Is Nothing Then
    Dim nServerHandle As Long
    Dim sGroupName As String
    Dim nUpdateRate As Long
    Dim nTimeBias As Long
    Dim rDeadband As Single
    Dim bIsActive As Boolean
    Dim nDataChangeMethod As Integer

    nServerHandle = TheListItem.Tag
    nGroupHandle = TheServers.DialogAddGroup(nServerHandle, sGroupName, _
                                             nUpdateRate, nTimeBias, rDeadband, _
                                             bIsActive, nDataChangeMethod)
    If nGroupHandle > 0 Then
      ' Add the group to the Groups listview
      Set TheListItem = listviewGroups.ListItems.Add(, , sGroupName)
      TheListItem.Tag = nGroupHandle
      TheListItem.EnsureVisible
      TheListItem.Selected = True
    ElseIf nGroupHandle < 0 Then
      If nGroupHandle = OPCDuplicateName Then
        MsgBox ("There is already a group by that name.")
      Else
        MsgBox ("There was an error while adding the group: " & Hex(nGroupHandle))
      End If
    End If
  End If

End Sub
'
' cmdAddItems_Click
'
Private Sub cmdAddItems_Click()
  Dim TheListItem As ListItem

  ' Make sure a group is selected
  Set TheListItem = listviewGroups.SelectedItem
  If Not TheListItem Is Nothing Then
    Dim nGroupHandle As Long
    Dim bRetval As Boolean
    Dim nNumItems As Long
    Dim sItemIDs() As String
    Dim bActiveStates() As Boolean
    Dim nItemHandles() As Long
    Dim nErrors() As Long
    Dim nDatatypes() As Integer
    Dim sAccessPaths() As String

    nGroupHandle = TheListItem.Tag
    bRetval = TheServers.DialogAddItems(nGroupHandle, nNumItems, sItemIDs, _
                                        bActiveStates, nDatatypes, sAccessPaths, _
                                        nItemHandles, nErrors, m_AddItemsDlgWidth, _
                                        m_AddItemsDlgHeight)

    ' DialogAddItems returns True if all items were added successfully, but it
    ' returns False if even one item had an error. So regardless of the return
    ' value, it is a good idea to spin through the nErrors array.
    Dim sServerName As String
    Dim sGroupName As String
    Dim sItemHandle As String
    Dim i As Integer
    Dim bAtLeastOneAdded As Boolean

    sServerName = listviewServers.SelectedItem.Text
    sGroupName = listviewGroups.SelectedItem.Text

    ' Put the items that were successfully added into the Items listview
    bAtLeastOneAdded = False
    For i = 1 To nNumItems
      If nErrors(i) = 0 Then
        sItemHandle = "IH" + CStr(nItemHandles(i))
        Set TheListItem = listviewItems.ListItems.Add(, sItemHandle, sServerName)
        TheListItem.SubItems(1) = sGroupName
        TheListItem.SubItems(2) = sItemIDs(i)
        TheListItem.Tag = nItemHandles(i)
        bAtLeastOneAdded = True
      Else
        ' A more robust application would report individual item errors here
      End If
    Next

    If bAtLeastOneAdded = True Then
      ' Enable the Update Items timer
      timerUpdateItems.Enabled = True
    End If
  End If

End Sub
'
' cmdAddServer_Click
'
Private Sub cmdAddServer_Click()
  Dim nServerHandle As Long
  Dim sServerHandle As String
  Dim TheListItem As ListItem
  Dim sServerName As String
  Dim sNetworkNode As String

  ' Display the Add Server Dialog
  nServerHandle = TheServers.DialogAddServer(sServerName, sNetworkNode)
  If nServerHandle > 0 Then
    ' Add the server to the Servers listview
    sServerHandle = CStr(nServerHandle)
    Set TheListItem = listviewServers.ListItems.Add(, , sServerName)
    TheListItem.Tag = nServerHandle
    TheListItem.EnsureVisible
    TheListItem.Selected = True
  ElseIf nServerHandle < 0 Then
    MsgBox ("There was an error while adding the server: " & Hex(nServerHandle))
  End If

End Sub
'
' Modify Group Button Clicked
'
Private Sub cmdModifyGroup_Click()
  Dim TheListItem As ListItem
  Dim nGroupHandle As Long
  Dim GroupObject As CGroup

  Set TheListItem = listviewGroups.SelectedItem
  If Not TheListItem Is Nothing Then
    nGroupHandle = TheListItem.Tag
    Set GroupObject = TheServers.DialogModifyGroup(nGroupHandle)
    If Not GroupObject Is Nothing Then
      ' Make any modifications to the user interface here

      Set GroupObject = Nothing ' All done with GroupObject - decrease its refcount
    End If
  End If

End Sub
'
' Remove Group Button Clicked
'
Private Sub cmdRemoveGroup_Click()
  Dim TheListItem As ListItem
  Dim nGroupHandle As Long

  Set TheListItem = listviewGroups.SelectedItem
  If Not TheListItem Is Nothing Then
    nGroupHandle = TheListItem.Tag
    RemoveGroup nGroupHandle
  End If

End Sub
'
' Remove Items Button Clicked
'
Private Sub cmdRemoveItems_Click()
  Dim nTotalNumberOfItems  As Integer
  Dim i As Integer
  Dim bRemoved As Boolean

  nTotalNumberOfItems = listviewItems.ListItems.Count
  ' Remove items from the bottom to the top to avoid problems using the index
  For i = nTotalNumberOfItems To 1 Step -1
    ' If the item is selected, remove it
    If listviewItems.ListItems(i).Selected = True Then
      bRemoved = TheServers.RemoveItem(listviewItems.ListItems(i).Tag)
      If bRemoved = True Then
        listviewItems.ListItems.Remove (i)
      End If
    End If
  Next

  ' Disable the Update Items Timer if there are no more items
  nTotalNumberOfItems = listviewItems.ListItems.Count
  If nTotalNumberOfItems = 0 Then
    timerUpdateItems.Enabled = False
  End If

End Sub
'
' Remove Server Button Clicked
'
Private Sub cmdRemoveServer_Click()
  Dim TheListItem As ListItem
  Dim nServerHandle As Long

  Set TheListItem = listviewServers.SelectedItem
  If Not TheListItem Is Nothing Then
    nServerHandle = TheListItem.Tag
    RemoveServer nServerHandle
  End If

End Sub
'
'
'
Private Sub cmdTestGroup_Click()
'  ' Async Read Items Test
'  Dim TheListItem As ListItem
'  Set TheListItem = listviewGroups.SelectedItem
'  If Not TheListItem Is Nothing Then
'    Dim nGroupHandle As Long
'    nGroupHandle = TheListItem.Tag
'    Dim GroupObject As CGroup
'    Set GroupObject = TheServers.GetGroup(nGroupHandle)
'    If Not GroupObject Is Nothing Then
'      Dim nNumItems As Long
'      nNumItems = GroupObject.m_ItemCollection.Count
'      If nNumItems > 0 Then
'        Dim nItemHandles() As Long
'        ReDim nItemHandles(nNumItems)
'        Dim i As Integer
'        For i = 1 To nNumItems
'          nItemHandles(i) = GroupObject.m_ItemCollection(i).m_Handle
'        Next
'        Dim nErrors() As Long
'        Dim nTransactionID As Long
'        Dim nCancelID As Long
'        Dim bRetval As Boolean
'        Beep
'        For i = 1 To 10000
'          nTransactionID = i
'          bRetval = TheServers.AsyncReadItems(nGroupHandle, nNumItems, nItemHandles, nTransactionID, nCancelID, nErrors)
'          If bRetval = False Then
'            MsgBox ("Problem with AsyncReadItems")
'          End If
'        Next
'        Beep
'      End If
'      Set GroupObject = Nothing
'    End If
'  End If

'  ' Read Items Test
'  Dim TheListItem As ListItem
'  Set TheListItem = listviewGroups.SelectedItem
'  If Not TheListItem Is Nothing Then
'    Dim nGroupHandle As Long
'    nGroupHandle = TheListItem.Tag
'    Dim GroupObject As CGroup
'    Set GroupObject = TheServers.GetGroup(nGroupHandle)
'    If Not GroupObject Is Nothing Then
'      Dim nNumItems As Long
'      nNumItems = GroupObject.m_ItemCollection.Count
'      If nNumItems > 0 Then
'        Dim nItemHandles() As Long
'        ReDim nItemHandles(nNumItems)
'        Dim i As Integer
'        For i = 1 To nNumItems
'          nItemHandles(i) = GroupObject.m_ItemCollection(i).m_Handle
'        Next
'        Dim vItemValues() As Variant
'        Dim vQualities As Variant
'        Dim vTimeStamps As Variant
'        Dim nErrors() As Long
'        Dim bRetval As Boolean
'        bRetval = TheServers.ReadItems(nGroupHandle, OPCDataSource.OPCDevice, nNumItems, nItemHandles, vItemValues, vQualities, vTimeStamps, nErrors)
'        If bRetval = False Then
'          MsgBox ("Problem with ReadItems")
'        End If
'      End If
'      Set GroupObject = Nothing
'    End If
'  End If

'  ' Async Write Items Test
'  Dim TheListItem As ListItem
'  Set TheListItem = listviewGroups.SelectedItem
'  If Not TheListItem Is Nothing Then
'    Dim nGroupHandle As Long
'    nGroupHandle = TheListItem.Tag
'    Dim GroupObject As CGroup
'    Set GroupObject = TheServers.GetGroup(nGroupHandle)
'    If Not GroupObject Is Nothing Then
'      Dim nNumItems As Long
'      Dim sItemIDs() As String
'      Dim bActiveStates() As Boolean
'      Dim nItemHandles() As Long
'      Dim nDatatypes() As Integer
'      Dim sAccessPaths() As String
'      nNumItems = 1
'      ReDim sItemIDs(nNumItems)
'      ReDim nItemHandles(nNumItems)
'      ReDim bActiveStates(nNumItems)
'      ReDim nDatatypes(nNumItems)
'      ReDim sAccessPaths(nNumItems)
'      Dim nErrors() As Long
'      Dim bRetval As Boolean
'      sItemIDs(1) = "[MMIO|ip|tcp:10.192.55.69:2001]eu.8"
'      bActiveStates(1) = True
'      nDatatypes(1) = vbEmpty
'      sAccessPaths(1) = ""
'      bRetval = GroupObject.AddItems(nNumItems, sItemIDs, bActiveStates, nDatatypes, sAccessPaths, nItemHandles, nErrors)
'      If bRetval = True Then
'        Dim vItemValues(1) As Variant
'        Dim nTransactionID As Long
'        Dim nCancelID As Long
'        vItemValues(1) = CSng(1.11)
'        Dim i As Integer
'        Beep
'        For i = 1 To 5000
'          nTransactionID = i
'          bRetval = TheServers.AsyncWriteItems(nGroupHandle, nNumItems, nItemHandles, vItemValues, nTransactionID, nCancelID, nErrors)
'          If bRetval = False Then
'            MsgBox ("Problem with AsyncWriteItems")
'          End If
'          vItemValues(1) = vItemValues(1) + CSng(0.01)
'        Next
'        Beep
'      End If
'      Set GroupObject = Nothing
'    End If
'  End If

  ' Memory Leak Test
  Dim nNumItems As Long
  Dim sItemIDs() As String
  Dim bActiveStates() As Boolean
  Dim nDatatypes() As Integer
  Dim sAccessPaths() As String
  Dim nItemHandles() As Long

  If m_bRunGroupTest = True Then m_bRunGroupTest = False Else m_bRunGroupTest = True

  If m_bRunGroupTest = True Then
    ' Set up the group test
    Dim TheListItem As ListItem
    Set TheListItem = listviewGroups.SelectedItem
    If Not TheListItem Is Nothing Then
      Dim nGroupHandle As Long
      nGroupHandle = TheListItem.Tag

      ' Add 64 digital outs
      Dim nErrors() As Long
      nNumItems = 64
      ReDim sItemIDs(nNumItems)
      ReDim bActiveStates(nNumItems)
      ReDim nDatatypes(nNumItems)
      ReDim sAccessPaths(nNumItems)
      ReDim nItemHandles(nNumItems)

      Dim i As Integer
      For i = 1 To nNumItems
       sItemIDs(i) = "[b3000|tcp|10.192.54.48,2001]state." + CStr(i - 1)
       bActiveStates(i) = True
       nDatatypes(i) = vbEmpty
       sAccessPaths(i) = ""
      Next
      Dim bResult As Boolean
      bResult = TheServers.AddItems(nGroupHandle, nNumItems, sItemIDs, bActiveStates, nDatatypes, sAccessPaths, nItemHandles, nErrors)
      If bResult = False Then
        MsgBox ("AddItems failed")
      Else
        '
      End If
    End If
  Else
    ' Stop the group test
  End If
  
  While m_bRunGroupTest = True
    ' Run the group test
    Dim bState As Boolean
    bState = True
    
    
  Wend
End Sub
'
'
'
Private Sub cmdTestItem_Click()
  ' Sync Read Test
'  Dim TheListItem As ListItem
'  Set TheListItem = listviewItems.SelectedItem
'  If Not TheListItem Is Nothing Then
'    Dim nItemHandle As Long
'    nItemHandle = TheListItem.Tag
'    Dim vValue As Variant
'    Dim nQuality As Long
'    Dim TimeStamp As Date
'    Dim bRetVal As Boolean
'    bRetVal = TheServers.ReadItem(OPCDataSource.OPCDevice, nItemHandle, vValue, nQuality, TimeStamp)
'    If bRetVal = True Then
'      Dim sMessage As String
'      sMessage = "Result of ReadItem:" & Chr(13) & Chr(10) & "  Value: " & CStr(vValue) & Chr(13) & Chr(10) & "  Quality: " & ConvertQualityToString(nQuality) & Chr(13) & Chr(10) & "  TimeStamp: " & CStr(TimeStamp)
'      Dim vbr As VbMsgBoxResult
'      vbr = MsgBox(sMessage, vbOKOnly, "Sync Read of Item")
'    End If
'  End If
  
  'Sync Write Test
  Dim TheListItem As ListItem
  Set TheListItem = listviewItems.SelectedItem
  If Not TheListItem Is Nothing Then
    Dim nItemHandle As Long
    nItemHandle = TheListItem.Tag
    Dim vValue As Variant
    Dim bRetval As Boolean
    vValue = False 'CSng(8.88)
    bRetval = TheServers.WriteItem(nItemHandle, vValue)
    If bRetval = True Then
      Dim sMessage As String
      sMessage = "Result of WriteItem:" & Chr(13) & Chr(10) & "  Attempted to write: " & CStr(vValue) & Chr(13) & Chr(10) & "  To Item: " & TheListItem.Text
      Dim vbr As VbMsgBoxResult
      vbr = MsgBox(sMessage, vbOKOnly, "Sync Write of Item")
    End If
  End If

End Sub
'
' Form_Load
'
Private Sub Form_Load()
  Dim lWidth As Long
  Dim lCol As Long

  OpenLogFile ("e:\EasyOpcLog.txt")

  ' Initialize the Add Items dialog width and height
  m_AddItemsDlgWidth = 0
  m_AddItemsDlgHeight = 0

  ' Resize the columns on the Servers and Groups listview to exactly fit the box
  lWidth = LVSCW_AUTOSIZE_USEHEADER
  lCol = 0
  SendMessage listviewServers.hwnd, LVM_SETCOLUMNWIDTH, lCol, lWidth
  SendMessage listviewGroups.hwnd, LVM_SETCOLUMNWIDTH, lCol, lWidth

  ' Create the main object
  Set TheServers = New ServerCollection

  m_bRunGroupTest = False

End Sub
'
' Form_Resize
'
Private Sub Form_Resize()

  ' Don't allow the window to be sized too small
  If Me.Width < MAINFORM_MINWIDTH Then Me.Width = MAINFORM_MINWIDTH
  If Me.Height < MAINFORM_MINHEIGHT Then Me.Height = MAINFORM_MINHEIGHT

  ' Reposition the non-sizeable controls
  '
  '   Groups listview
  listviewGroups.Left = Me.Width - 3315
  '   Add Group button
  cmdAddGroup.Left = Me.Width - 4780
  '   Modify Group button
  cmdModifyGroup.Left = Me.Width - 4780
  '   Remove Group button
  cmdRemoveGroup.Left = Me.Width - 4780
  '   Remove Items button
  cmdRemoveItems.Top = Me.Height - 1020

  ' Resize the horizontal and vertical sizeable controls
  listviewItems.Width = Me.Width - 2130
  listviewItems.Height = Me.Height - 3170

End Sub
'
' Form_Unload
'
Private Sub Form_Unload(Cancel As Integer)
  Dim nCount As Integer
  Dim i As Integer
  Dim nServerHandle As Long

  nCount = listviewServers.ListItems.Count
  For i = nCount To 1 Step -1
    nServerHandle = listviewServers.ListItems(i).Tag
    RemoveServer nServerHandle
  Next

  CloseLogFile

End Sub
'
' GlobalDataChange
'
Private Sub TheServers_GlobalDataChange(ByVal nTransactionID As Long, _
                                        ByVal nServerHandle As Long, _
                                        ByVal nGroupHandle As Long, _
                                        ByVal nNumItems As Long, _
                                        nItemHandles() As Long, _
                                        vItemValues() As Variant, _
                                        nQualities() As Long, _
                                        TimeStamps() As Date)

  Dim nElement As Long
  Dim nReturn As Long

If nTransactionID = 10000 Then Beep

  ' Save the item handles into the Update Queue. It will be processed later
  ' when the timer goes off. We don't need the values or qualities or timestamps
  ' since they have already been cached by the wrapper layer.
  For nElement = 1 To nNumItems
    nReturn = m_UpdateQueue.PutHandle(nItemHandles(nElement))
    If nReturn = 0 Then
      ' Notify that the queue is full
    End If
  Next

' **************************
' The code below is a good example of what NOT to do in an OPC Client application.
' The code is extremely inefficient and it operates directly on elements of the
' listview control. These operations are notoriously slow. The end result is that
' the server is waiting for the client to finish processing the GlobalDataChange
' event, making the exchange of information very slow. It is better for the
' client application to cache the data and return as quickly as possible, as the
' code above illustrates.
'
'  Dim i As Integer
'  Dim j As Integer
'  Dim nNumListviewItems As Integer
'  Dim TheListItem As ListItem

'  nNumListviewItems = listviewItems.ListItems.Count

'  For i = 1 To nNumItems
'    For j = 1 To nNumListviewItems
'      Set TheListItem = listviewItems.ListItems(j)
'      If TheListItem.Tag = nItemHandles(i) Then
'        ' Update the Value (3), Quality (4) and TimeStamp (5)
'        TheListItem.SubItems(3) = CStr(vItemValues(i))
'        TheListItem.SubItems(4) = ConvertQualityToString(nQualities(i))
'        TheListItem.SubItems(5) = CStr(TimeStamps(i))
'        Exit For
'      End If
'
'      Set TheListItem = Nothing
'    Next
'  Next
' **************************

End Sub
'
' ServerShuttingDown
'
Private Sub TheServers_ServerShuttingDown(ByVal nServerHandle As Long, ByVal sReason As String)

  ' Shutdown the server whose handle is passed in
  RemoveServer nServerHandle

  ' Make an entry in "the log" with the reason the server shut down
End Sub
'
' RemoveServer
'
Private Sub RemoveServer(nServerHandle As Long)
  Dim bServerRemoved As Boolean

  bServerRemoved = TheServers.RemoveServer(nServerHandle)
  If bServerRemoved Then
    Dim nCount As Integer
    Dim i As Integer
    Dim TheListItem As ListItem
    Dim nTestServerHandle As Long
    Dim nGroupHandle As Long
    Dim nItemHandle As Long

    ' Remove all of the items associated with this server from the Items listview
    nCount = listviewItems.ListItems.Count
    For i = nCount To 1 Step -1
      nItemHandle = listviewItems.ListItems(i).Tag
      nTestServerHandle = GetServerHandleFromItemHandle(nItemHandle)
      If nTestServerHandle = nServerHandle Then
        listviewItems.ListItems.Remove i
      End If
    Next

    ' Remove all of the groups associated with this server from the Groups listview
    nCount = listviewGroups.ListItems.Count
    For i = nCount To 1 Step -1
      nGroupHandle = listviewGroups.ListItems(i).Tag
      nTestServerHandle = GetServerHandleFromGroupHandle(nGroupHandle)
      If nTestServerHandle = nServerHandle Then
        listviewGroups.ListItems.Remove i
      End If
    Next

    ' Remove this server from the Servers listview
    nCount = listviewServers.ListItems.Count
    For i = 1 To nCount
      If listviewServers.ListItems(i).Tag = nServerHandle Then
        listviewServers.ListItems.Remove i
        Exit For
      End If
    Next

    ' Should the Update Items Timer be disabled
    Dim nTotalNumberOfItems As Integer
    nTotalNumberOfItems = listviewItems.ListItems.Count
    If nTotalNumberOfItems = 0 Then
      timerUpdateItems.Enabled = False
    End If
  End If

End Sub
'
' RemoveGroup
'
Private Sub RemoveGroup(nGroupHandle As Long)
  Dim bGroupRemoved As Boolean
  Dim nCount As Integer
  Dim i As Integer
  Dim TheListItem As ListItem
  Dim nItemHandle As Long

  bGroupRemoved = TheServers.RemoveGroup(nGroupHandle)
  If bGroupRemoved Then
    ' Remove all of the items associated with this group from the Items listview
    nCount = listviewItems.ListItems.Count
    For i = nCount To 1 Step -1
      nItemHandle = listviewItems.ListItems(i).Tag
      If nGroupHandle = GetGroupHandleFromItemHandle(nItemHandle) Then
        listviewItems.ListItems.Remove (i)
      End If
    Next

    ' Remove this group from the Groups listview
    nCount = listviewGroups.ListItems.Count
    For i = 1 To nCount
      If listviewGroups.ListItems(i).Tag = nGroupHandle Then
        Set TheListItem = listviewGroups.ListItems(i)
        listviewGroups.ListItems.Remove (TheListItem.Index)
        Exit For
      End If
    Next
  End If

  ' Should the Update Items Timer be disabled
  Dim nTotalNumberOfItems As Integer
  nTotalNumberOfItems = listviewItems.ListItems.Count
  If nTotalNumberOfItems = 0 Then
    timerUpdateItems.Enabled = False
  End If

End Sub
'
' Update Items Timer
'
Private Sub timerUpdateItems_Timer()
  Dim nItemHandle As Long

  nItemHandle = m_UpdateQueue.GetHandle
  If nItemHandle <> 0 Then
    Dim sItemHandle As String
    Dim TheListItem As ListItem
    Dim ThisItem As CItem

    While nItemHandle <> 0
      ' Update the Items listview
      sItemHandle = "IH" + CStr(nItemHandle)
      On Error GoTo UpdateItemsErr:
      Set TheListItem = listviewItems.ListItems.Item(sItemHandle)
      If Not TheListItem Is Nothing Then
        Set ThisItem = TheServers.GetItem(nItemHandle)
        If Not ThisItem Is Nothing Then
          ' Update the Value (3), Quality (4) and TimeStamp (5)
          ' Only the handles were queued so we have to get the value, quality,
          ' and timestamp from the item object. Each item object caches its state
          ' so these calls do not result in another round-trip to the server.

          ' Test for an array type
          If ThisItem.CanonicalDatatype >= 8000 Then
            Dim sValues As String
            Dim nLength As Long
            Dim v As Integer
            nLength = UBound(ThisItem.Value)
            For v = 0 To nLength
              sValues = sValues + CStr(ThisItem.Value(v))
              If v < nLength Then
                sValues = sValues + ", "
              End If
            Next
            TheListItem.SubItems(3) = sValues
          Else
            TheListItem.SubItems(3) = CStr(ThisItem.Value)
          End If
          TheListItem.SubItems(4) = ConvertQualityToString(ThisItem.Quality)
          TheListItem.SubItems(5) = CStr(ThisItem.TimeStamp)

          Set ThisItem = Nothing
        End If

        Set TheListItem = Nothing
      End If

      nItemHandle = m_UpdateQueue.GetHandle
    Wend
  End If
  Exit Sub

UpdateItemsErr:
  Set TheListItem = Nothing
  On Error Resume Next
End Sub
