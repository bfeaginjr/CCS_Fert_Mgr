VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "mscomctl.ocx"
Begin VB.Form frmAddItem 
   Caption         =   "Add Item"
   ClientHeight    =   7815
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   7050
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form2"
   MinButton       =   0   'False
   ScaleHeight     =   7815
   ScaleWidth      =   7050
   StartUpPosition =   2  'CenterScreen
   Begin MSComctlLib.ListView listviewLeaves 
      Height          =   2805
      Left            =   4320
      TabIndex        =   1
      Top             =   480
      Width           =   2475
      _ExtentX        =   4366
      _ExtentY        =   4948
      View            =   3
      LabelEdit       =   1
      MultiSelect     =   -1  'True
      LabelWrap       =   -1  'True
      HideSelection   =   -1  'True
      HideColumnHeaders=   -1  'True
      _Version        =   393217
      ForeColor       =   -2147483640
      BackColor       =   -2147483643
      BorderStyle     =   1
      Appearance      =   1
      NumItems        =   1
      BeginProperty ColumnHeader(1) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         Text            =   "Item Name"
         Object.Width           =   3528
      EndProperty
   End
   Begin VB.ComboBox comboDataType 
      Height          =   315
      ItemData        =   "frmAddItem.frx":0000
      Left            =   3540
      List            =   "frmAddItem.frx":0043
      Style           =   2  'Dropdown List
      TabIndex        =   5
      Top             =   4425
      Width           =   2190
   End
   Begin VB.TextBox txtAccessPath 
      Height          =   330
      Left            =   240
      TabIndex        =   4
      Top             =   4425
      Width           =   3105
   End
   Begin VB.CheckBox checkboxActive 
      Caption         =   "Active"
      Height          =   270
      Left            =   4995
      TabIndex        =   3
      Top             =   3780
      Value           =   1  'Checked
      Width           =   750
   End
   Begin MSComctlLib.ListView listviewItems 
      Height          =   1620
      Left            =   240
      TabIndex        =   8
      Top             =   5280
      Width           =   6555
      _ExtentX        =   11562
      _ExtentY        =   2858
      View            =   3
      LabelEdit       =   1
      MultiSelect     =   -1  'True
      LabelWrap       =   -1  'True
      HideSelection   =   0   'False
      FullRowSelect   =   -1  'True
      _Version        =   393217
      ForeColor       =   -2147483640
      BackColor       =   -2147483643
      BorderStyle     =   1
      Appearance      =   1
      NumItems        =   4
      BeginProperty ColumnHeader(1) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         Text            =   "Item"
         Object.Width           =   5292
      EndProperty
      BeginProperty ColumnHeader(2) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   1
         Text            =   "Active"
         Object.Width           =   1323
      EndProperty
      BeginProperty ColumnHeader(3) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   2
         Text            =   "Datatype"
         Object.Width           =   1764
      EndProperty
      BeginProperty ColumnHeader(4) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   3
         Text            =   "Access Path"
         Object.Width           =   3528
      EndProperty
   End
   Begin VB.TextBox txtItemName 
      Height          =   330
      Left            =   240
      TabIndex        =   2
      Top             =   3765
      Width           =   4545
   End
   Begin VB.CommandButton cmdValidate 
      Caption         =   "Validate"
      Height          =   390
      Left            =   5925
      TabIndex        =   7
      Top             =   4275
      Width           =   885
   End
   Begin VB.CommandButton cmdAddItem 
      Caption         =   "Add Item"
      Enabled         =   0   'False
      Height          =   390
      Left            =   5925
      TabIndex        =   6
      Top             =   3750
      Width           =   885
   End
   Begin MSComctlLib.TreeView treeviewBranches 
      Height          =   2805
      Left            =   240
      TabIndex        =   0
      Top             =   480
      Width           =   3900
      _ExtentX        =   6879
      _ExtentY        =   4948
      _Version        =   393217
      HideSelection   =   0   'False
      Indentation     =   706
      LabelEdit       =   1
      LineStyle       =   1
      Style           =   7
      Appearance      =   1
   End
   Begin VB.CommandButton cmdCancel 
      Cancel          =   -1  'True
      Caption         =   "Cancel"
      Height          =   375
      Left            =   1560
      TabIndex        =   10
      Top             =   7170
      Width           =   1335
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "OK"
      Default         =   -1  'True
      Height          =   375
      Left            =   240
      TabIndex        =   9
      Top             =   7170
      Width           =   1215
   End
   Begin VB.Label lblItemsToAdd 
      Caption         =   "Items To Be Added:"
      Height          =   255
      Left            =   240
      TabIndex        =   16
      Top             =   5010
      Width           =   1590
   End
   Begin VB.Label lblDataType 
      Caption         =   "Requested Datatype:"
      Height          =   255
      Left            =   3555
      TabIndex        =   15
      Top             =   4170
      Width           =   1665
   End
   Begin VB.Label lblAccessPath 
      Caption         =   "Access Path:"
      Height          =   255
      Left            =   240
      TabIndex        =   14
      Top             =   4170
      Width           =   1050
   End
   Begin VB.Label lblItemName 
      Caption         =   "Item Name:"
      Height          =   255
      Left            =   225
      TabIndex        =   13
      Top             =   3495
      Width           =   915
   End
   Begin VB.Label lblLeaves 
      Caption         =   "Browser Interface - Leaves"
      Height          =   255
      Left            =   4320
      TabIndex        =   12
      Top             =   195
      Width           =   2055
   End
   Begin VB.Label lblBranches 
      Caption         =   "Browser Interface - Branches"
      Height          =   255
      Left            =   240
      TabIndex        =   11
      Top             =   195
      Width           =   2205
   End
   Begin VB.Menu mnuLeavesPopup 
      Caption         =   "LeavesPopup"
      Visible         =   0   'False
      Begin VB.Menu mnuitemAddSelected 
         Caption         =   "Add Selected Item(s)"
      End
   End
End
Attribute VB_Name = "frmAddItem"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'
' How To Use This Form
'
'   Start by loading the form
'      Load frmAddItem
'
'   Initialize the public member variables:
'     m_OPCServer is the OPC Server that contains the group where the items will
'       be added. It is used to view the Browser Interface in the OPC Server.
'     m_GroupName is the name of the group where the items will be added. It is
'       optional, but if it is left blank, the Validate button will be disabled.
'     m_DialogWidth is the width to which to size the dialog. It is optional and if
'       left blank will default to the dialog's minimum width
'     m_DialogHeight is the height to which to size the dialog. It is optional and
'       if left blank will default to the dialog's minimum height
'
'   Display the form
'      frmAddGroup.Show (1)
'
'   When the user exits the dialog, check the value of frmAddItem.m_bOK. If it is
'   True, the OK button was chosen and you should process and store the contents of
'   the dialog as in the following example code snippet:
'      If frmAddItem.m_bOK Then
'        ' Redimension the output arrays and fill with information from the dialog
'        nNumItems = UBound(frmAddItem.m_vItemIDs)
'        ReDim sItemIDs(nNumItems)
'        sItemIDs = frmAddItem.m_vItemIDs
'        ReDim sAccessPaths(nNumItems)
'        sAccessPaths = frmAddItem.m_vAccessPaths
'        ReDim bActiveStates(nNumItems)
'        bActiveStates = frmAddItem.m_vActiveStates
'        ReDim nDatatypes(nNumItems)
'        nDatatypes = frmAddItem.m_vDatatypes
'        ReDim nItemHandles(nNumItems)
'        etc.
'      EndIf
'
'   For more detailed example code look at DialogAddItem()
'
Option Explicit
Option Base 1

' Inputs
Public m_OPCServer As OPCServer
Public m_GroupName As String
Public m_DialogWidth As Integer
Public m_DialogHeight As Integer

' Outputs
Public m_bOK As Boolean
Public m_vItemIDs As Variant
Public m_vAccessPaths As Variant
Public m_vActiveStates As Variant
Public m_vDatatypes As Variant

' Private variables for internal use by the dialog
Private m_nNextListviewItemIndex As Integer
Private m_nCurrentListviewItemIndex As Integer
Private m_sLeafItemNames() As String
Private m_sLeafItemIDs() As String
Private m_nNumLeaves As Long
Private m_bJustDeleted As Boolean

Const DLG_MINWIDTH = 7170
Const DLG_MINHEIGHT = 8220
'
' Form_Activate - The Form Has Been Activated
'
Private Sub Form_Activate()
  Dim nOrigTop As Integer
  Dim nOrigLeft As Integer
  Dim nOrigWidth As Integer
  Dim nOrigHeight As Integer
  Dim nWidthDelta As Integer
  Dim nHeightDelta As Integer

  ' See if the dialog box should be maximized
  If m_DialogWidth = -1 And m_DialogHeight = -1 Then
    Me.WindowState = vbMaximized
  Else
    ' Center the dialog box given the width and height
    nOrigTop = Me.Top
    nOrigLeft = Me.Left
    nOrigWidth = Me.Width
    nOrigHeight = Me.Height

    If m_DialogWidth < DLG_MINWIDTH Then m_DialogWidth = DLG_MINWIDTH
    If m_DialogHeight < DLG_MINHEIGHT Then m_DialogHeight = DLG_MINHEIGHT
  
    nWidthDelta = (m_DialogWidth - nOrigWidth) \ 2
    nHeightDelta = (m_DialogHeight - nOrigHeight) \ 2
    Me.Move nOrigLeft - nWidthDelta, nOrigTop - nHeightDelta, m_DialogWidth, m_DialogHeight
  End If

  ' Set the dialog box title
  If m_GroupName = "" Then
    Caption = "Add Items to the Current Group"
    cmdValidate.Enabled = False ' can't call Validate without a group name
  Else
    Caption = "Add Item(s) to Group: " & m_GroupName
  End If

  ' Initialize the Items listview
  AddBlankItemToEndOfList

  ' Initialize the Branches treeview
  FillBrowser

  ' Initialize the Datatype combobox
  comboDataType.Text = comboDataType.List(0)

End Sub
'
' Form_Load - The Form Has Been Loaded
'
Private Sub Form_Load()

  m_GroupName = ""
  m_nNextListviewItemIndex = 1
  m_nCurrentListviewItemIndex = 1
  m_nNumLeaves = 0
  m_bJustDeleted = False

End Sub
'
' Form_Resize - The Form Has Been Resized
'
Private Sub Form_Resize()

  ' Guard against problem when form is restored from a minimized state. A runtime
  ' error will occur
  If Me.WindowState <> vbMinimized Then
    ' Don't allow the window to be sized too small
    If Me.Width < DLG_MINWIDTH Then Me.Width = DLG_MINWIDTH
    If Me.Height < DLG_MINHEIGHT Then Me.Height = DLG_MINHEIGHT

    ' Reposition the non-sizeable controls
    '
    '   Leaves listview
    listviewLeaves.Left = Me.Width - 2850
    '   Leaves listview label
    lblLeaves.Left = Me.Width - 2850
    '   Add Item button
    cmdAddItem.Left = Me.Width - 1250
    '   Validate button
    cmdValidate.Left = Me.Width - 1250
    '   Active checkbox
    checkboxActive.Left = Me.Width - 2200
    '   Requested Datatype combo
    comboDataType.Left = Me.Width - 3600
    '   Requested Datatype label
    lblDataType.Left = Me.Width - 3600
    '   OK button
    cmdOK.Top = Me.Height - 1050
    '   Cancel button
    cmdCancel.Top = Me.Height - 1050

    ' Resize the horizontal-only sizeable controls
    treeviewBranches.Width = Me.Width - 3300
    txtItemName.Width = Me.Width - 2650
    txtAccessPath.Width = Me.Width - 4000

    ' Resize the horizontal and vertical sizeable controls
    listviewItems.Width = Me.Width - 550
    listviewItems.Height = Me.Height - 6600

    ' Tell the Items listview to autosize its last column
    Dim lWidth As Long
    Dim lCol As Long
    lWidth = LVSCW_AUTOSIZE_USEHEADER
    lCol = listviewItems.ColumnHeaders.Count - 1
    SendMessage listviewItems.hwnd, LVM_SETCOLUMNWIDTH, lCol, lWidth
  End If

End Sub
'
' The Active Check Box Has Been Activated
'
Private Sub checkboxActive_Click()

  ChangeCurrentListviewItem

End Sub
'
' The Add Item Button Has Been Activated
'
Private Sub cmdAddItem_Click()

  If NumLeavesSelected > 1 Then
    AddSelectedItems
  Else
    If Len(LTrim(txtItemName.Text)) > 0 Then
      ' Deselect all the items in the Items listview
      DeselectAllItemsInItemsListview

      ' Update the Items Listview
      If m_nCurrentListviewItemIndex = m_nNextListviewItemIndex Then
        AddBlankItemToEndOfList
        m_nNextListviewItemIndex = m_nNextListviewItemIndex + 1
      End If
      m_nCurrentListviewItemIndex = m_nNextListviewItemIndex

      ' Select the empty item at the end of the list
      listviewItems.ListItems(m_nNextListviewItemIndex).Selected = True
  
      ' Clear out the item attribute fields
      '
      '  Reset the Item Name, and requested data type. Leave the Active check box
      '  and the Access Path alone.
      txtItemName.Text = ""
      comboDataType.Text = comboDataType.List(0)
    End If
  End If

End Sub
'
' The Cancel Button Has Been Activated
'
Private Sub cmdCancel_Click()

  m_bOK = False
  Me.Hide

End Sub
'
' The OK Button Has Been Activated
'
Private Sub cmdOK_Click()
  Dim sItemIDs() As String
  Dim sAccessPaths() As String
  Dim bActiveStates() As Boolean
  Dim nDatatypes() As Integer
  Dim sItemID As String
  Dim sAccessPath As String
  Dim bActiveState As Boolean
  Dim nDatatype As Integer
  Dim nNumItems As Integer
  Dim nNumReturnItems As Integer
  Dim i As Integer

  nNumItems = listviewItems.ListItems.Count
  If nNumItems > 0 Then
    ' Make sure that blank lines are not returned
    nNumReturnItems = 0
    For i = 1 To nNumItems
      If LTrim(listviewItems.ListItems(i).Text) <> "" Then nNumReturnItems = nNumReturnItems + 1
    Next

    If nNumReturnItems > 0 Then
      ReDim sItemIDs(nNumReturnItems)
      ReDim sAccessPaths(nNumReturnItems)
      ReDim bActiveStates(nNumReturnItems)
      ReDim nDatatypes(nNumReturnItems)

      Dim j As Integer
      j = 1
      For i = 1 To nNumItems
        If LTrim(listviewItems.ListItems(i).Text) <> "" Then
          sItemID = listviewItems.ListItems(i).Text
          sAccessPath = listviewItems.ListItems(i).SubItems(3)
          If listviewItems.ListItems(i).SubItems(1) = "Yes" Then
            bActiveState = True
          Else
            bActiveState = False
          End If
          nDatatype = ConvertTextDatatypeToNumber(listviewItems.ListItems(i).SubItems(2))
          sItemIDs(j) = sItemID
          sAccessPaths(j) = sAccessPath
          bActiveStates(j) = bActiveState
          nDatatypes(j) = nDatatype
          j = j + 1
        End If
      Next

      ' Copy the arrays into the return variants
      m_vItemIDs = sItemIDs
      m_vAccessPaths = sAccessPaths
      m_vActiveStates = bActiveStates
      m_vDatatypes = nDatatypes

      m_bOK = True
    End If
  End If

  Me.Hide

End Sub
'
' The Validate Button Has Been Activated
'
Private Sub cmdValidate_Click()
  Dim nNumItems As Long
  Dim nNumItemsToValidate As Long
  Dim i As Integer
  Dim j As Integer

  nNumItems = listviewItems.ListItems.Count
  If nNumItems > 0 Then
    ' Make sure that blank lines are not validated
    nNumItemsToValidate = 0
    For i = 1 To nNumItems
      If LTrim(listviewItems.ListItems(i).Text) <> "" Then nNumItemsToValidate = nNumItemsToValidate + 1
    Next

    If nNumItemsToValidate > 0 Then
      ReDim sItemIDs(nNumItemsToValidate) As String
      ReDim nErrors(nNumItemsToValidate) As Long
      ReDim nRequestedDatatypes(nNumItemsToValidate) As Integer
      ReDim sAccessPaths(nNumItemsToValidate) As String
      Dim vDatatypes As Variant
      Dim vAccessPaths As Variant

      ' Fill the arrays with information from the Items listview
      j = 1
      For i = 1 To nNumItems
        If LTrim(listviewItems.ListItems(i).Text) <> "" Then
          sItemIDs(j) = listviewItems.ListItems(i).Text
          nRequestedDatatypes(j) = ConvertTextDatatypeToNumber(listviewItems.ListItems(i).SubItems(2))
          sAccessPaths(j) = listviewItems.ListItems(i).SubItems(3)
          j = j + 1
        End If
      Next

      ' The ValidateItems call wants the RequestedDatatypes and AccessPaths
      ' to be variants
      vDatatypes = nRequestedDatatypes
      vAccessPaths = sAccessPaths

      ' Validate the items
      Dim TheGroup As OPCGroup
      Dim ItemSpecifier As Variant
      ItemSpecifier = m_GroupName
      Set TheGroup = m_OPCServer.OPCGroups.Item(ItemSpecifier)
      TheGroup.OPCItems.Validate nNumItemsToValidate, sItemIDs, nErrors, _
                                 vDatatypes, vAccessPaths

      ' Display the results
      Load frmValidateItems
      frmValidateItems.m_nNumItems = nNumItemsToValidate
      frmValidateItems.m_vItemIDs = sItemIDs
      frmValidateItems.m_vErrors = nErrors

      frmValidateItems.Show (1)

      Unload frmValidateItems
    End If
  End If
End Sub
'
' A Change Has Occurred In The DataType Combo Box
'
Private Sub comboDataType_Click()

  ChangeCurrentListviewItem

End Sub
'
' An Item In The Items Listview Has Been Clicked
'
Private Sub listviewItems_ItemClick(ByVal Item As MSComctlLib.ListItem)

  If Len(LTrim(Item.Text)) > 0 Then
    ' Set the current item index before changing the edit fields
    m_nCurrentListviewItemIndex = Item.Index
    Item.Selected = True

    ' Fill in the edit fields with the values of the item clicked in the listview
    '
    '   Item Name
    txtItemName.Text = Item.Text

    '   Active Check Box
    If Item.SubItems(1) = "Yes" Then
      checkboxActive.Value = 1
    Else
      checkboxActive.Value = 0
    End If

    '   Datatype Combo Box
    comboDataType.Text = Item.SubItems(2)

    '   Access Path
    txtAccessPath.Text = Item.SubItems(3)
  End If

End Sub
'
' A Keypress Occurred In The Items Listview (handle the Delete Key and Control-A)
'
Private Sub listviewItems_KeyDown(KeyCode As Integer, Shift As Integer)
  Dim TheListItem As ListItem
  Dim nNumItems As Integer
  Dim i As Integer
  Dim nLastIndex As Integer

  If KeyCode = vbKeyDelete Then
    Set TheListItem = listviewItems.SelectedItem
    If Not TheListItem Is Nothing Then
      ' At least one item is selected, loop through and delete the selected items
      nNumItems = listviewItems.ListItems.Count
      nLastIndex = 0
      For i = nNumItems To 1 Step -1
        If listviewItems.ListItems(i).Selected = True Then
          If Len(LTrim(listviewItems.ListItems(i).Text)) > 0 Then
            nLastIndex = listviewItems.ListItems(i).Index
            listviewItems.ListItems.Remove i
            m_bJustDeleted = True
            m_nNextListviewItemIndex = m_nNextListviewItemIndex - 1
          End If
        End If
      Next

      ' Reset the selection
      If nLastIndex > 0 Then
        nNumItems = listviewItems.ListItems.Count
        If nNumItems < nLastIndex Then
          m_nCurrentListviewItemIndex = nNumItems
        Else
          m_nCurrentListviewItemIndex = nLastIndex
        End If
        listviewItems.ListItems(m_nCurrentListviewItemIndex).Selected = True
      End If

      ' Clear the Item Name field
      txtItemName.Text = ""
    End If
  ElseIf KeyCode = vbKeyA And Shift = vbCtrlMask Then
    ' Select all the items in the Items listview
    nNumItems = listviewItems.ListItems.Count
    If nNumItems > 0 Then
      For i = 1 To nNumItems
        listviewItems.ListItems(i).Selected = True
      Next
    End If
  End If

End Sub
'
' The Leaves Listview Has Been Double Clicked
'
Private Sub listviewLeaves_DblClick()

  cmdAddItem_Click ' Simulate the AddItem button click

End Sub
'
' The Leaves Listview Has Been Clicked
'
Private Sub listviewLeaves_ItemClick(ByVal Item As MSComctlLib.ListItem)

  ' Clear any multiple selection in the Items listview
  DeselectAllItemsInItemsListview

  ' Select the last item (the blank line) in the Items listview
  m_nCurrentListviewItemIndex = m_nNextListviewItemIndex
  listviewItems.ListItems(m_nCurrentListviewItemIndex).Selected = True

  If NumLeavesSelected > 1 Then
    ' Clear the Item Name field
    txtItemName = ""
  Else
    ' Fill the Item Name field with the ItemID of the item clicked in the Leaves listview
    txtItemName = Item.Key
  End If

End Sub
'
' A Keypress Occurred In The Leaves Listview
'
' Pressing Control-A selects all the items in the Leaves listview
'
' (The Form's KeyPreview property must be set to True)
'
Private Sub listviewLeaves_KeyDown(KeyCode As Integer, Shift As Integer)

  If KeyCode = vbKeyA And Shift = vbCtrlMask Then
    Dim nNumItems As Integer
    Dim i As Integer

    ' Select all the items in the Leaves listview
    nNumItems = listviewLeaves.ListItems.Count
    If nNumItems > 0 Then
      For i = 1 To nNumItems
        listviewLeaves.ListItems(i).Selected = True
      Next

      ' Clear the Item Name field
      txtItemName = ""
    End If
  End If

End Sub
'
' A MouseUp Event Occurred in the Leaves Listview
'
Private Sub listviewLeaves_MouseUp(Button As Integer, Shift As Integer, x As Single, y As Single)

  ' Check to see if the right button was clicked
  If Button = 2 Then
    ' Make sure there are items in the listview
    If listviewLeaves.ListItems.Count > 0 Then
      ' Make sure at least one item is selected
      If Not listviewLeaves.SelectedItem Is Nothing Then
        ' Display the popup menu
        PopupMenu mnuLeavesPopup
      End If
    End If
  End If

End Sub
'
' Add Selected Item(s) Chosen From The Leaves Listview Popup Menu
'
Private Sub mnuitemAddSelected_Click()

  AddSelectedItems

End Sub
'
' The Branches Treeview Has Been Clicked
'
Private Sub treeviewBranches_NodeClick(ByVal Node As MSComctlLib.Node)

  ' Clear the Item Name field if it does not hold an item being edited
  If m_nCurrentListviewItemIndex = m_nNextListviewItemIndex Then
    txtItemName.Text = ""
  End If

  ' Clear the Leaves listview
  listviewLeaves.ListItems.Clear

  ' Display the leaves of a branch in the Leaves listview
  '
  '   A node with no tag has no leaves
  If Node.Tag <> "" Then
    Dim nStartLeaf As Integer
    Dim nNumLeaves As Integer
    Dim nCommaPos As Integer
    Dim sIndexInfo As String
    Dim i As Integer

    sIndexInfo = Node.Tag
    nCommaPos = InStr(1, sIndexInfo, ",", vbTextCompare)
    If nCommaPos > 0 Then
      Dim TheListItem As ListItem
      nStartLeaf = Val(Left(sIndexInfo, nCommaPos))
      nNumLeaves = Val(Mid(sIndexInfo, nCommaPos + 1))
      For i = nStartLeaf To nStartLeaf + nNumLeaves - 1
        Set TheListItem = listviewLeaves.ListItems.Add(, m_sLeafItemIDs(i), m_sLeafItemNames(i))
      Next
    End If
  End If

End Sub
'
' A Change Occurred In The AccessPath Text Box
'
Private Sub txtAccessPath_Change()

  ChangeCurrentListviewItem

End Sub
'
' A Change Occurred In The ItemName Text Box
'
Private Sub txtItemName_Change()

  ChangeCurrentListviewItem

End Sub
'
' AddBlankItemToEndOfList
'
Private Sub AddBlankItemToEndOfList()
  Dim TheListItem As ListItem

  ' Deselect all the items in the Items listview
  DeselectAllItemsInItemsListview

  ' Add a blank line and select it
  Set TheListItem = listviewItems.ListItems.Add(, , " ")
  TheListItem.Selected = True

End Sub
'
' ChangeCurrentListviewItem
'
Private Sub ChangeCurrentListviewItem()
  Dim sItemName As String

  ' Deleting causes a change event. This code ignores that event after a deletion.
  If m_bJustDeleted = True Then
    m_bJustDeleted = False
    Exit Sub
  End If

  sItemName = txtItemName.Text
  If sItemName = "" Then
    ' Clear the current item in the Items listview
    listviewItems.ListItems(m_nCurrentListviewItemIndex).Text = ""
    listviewItems.ListItems(m_nCurrentListviewItemIndex).SubItems(1) = ""
    listviewItems.ListItems(m_nCurrentListviewItemIndex).SubItems(2) = ""
    listviewItems.ListItems(m_nCurrentListviewItemIndex).SubItems(3) = ""

    If NumLeavesSelected > 0 Then
      ' Enable the Add Item button
      cmdAddItem.Enabled = True
    Else
      ' Disable the Add Item button
      cmdAddItem.Enabled = False
    End If
  Else
    ' Fill in the current item in the Items listview
    listviewItems.ListItems(m_nCurrentListviewItemIndex).Text = txtItemName.Text
    If checkboxActive.Value = 1 Then
      listviewItems.ListItems(m_nCurrentListviewItemIndex).SubItems(1) = "Yes"
    Else
      listviewItems.ListItems(m_nCurrentListviewItemIndex).SubItems(1) = "No"
    End If
    listviewItems.ListItems(m_nCurrentListviewItemIndex).SubItems(2) = comboDataType.Text
    listviewItems.ListItems(m_nCurrentListviewItemIndex).SubItems(3) = txtAccessPath.Text

    ' Enable the Add Item button
    cmdAddItem.Enabled = True
  End If

End Sub
'
' ConvertTextDatatypeToNumber
'
Private Function ConvertTextDatatypeToNumber(sDatatype As String) As Integer
  Dim nDatatype As Integer

  Select Case sDatatype
    Case "VT_EMPTY"
      nDatatype = 0
    Case "VT_I2"
      nDatatype = 2
    Case "VT_I4"
      nDatatype = 3
    Case "VT_R4"
      nDatatype = 4
    Case "VT_R8"
      nDatatype = 5
    Case "VT_BSTR"
      nDatatype = 8
    Case "VT_BOOL"
      nDatatype = 11
    Case "VT_I1"
      nDatatype = 16
    Case "VT_UI1"
      nDatatype = 17
    Case "VT_UI2"
      nDatatype = 18
    Case "VT_UI4"
      nDatatype = 19
    Case "VT_I2 | VT_ARRAY"
      nDatatype = 2 + 8192
    Case "VT_I4 | VT_ARRAY"
      nDatatype = 3 + 8192
    Case "VT_R4 | VT_ARRAY"
      nDatatype = 4 + 8192
    Case "VT_R8 | VT_ARRAY"
      nDatatype = 5 + 8192
    Case "VT_BSTR | VT_ARRAY"
      nDatatype = 8 + 8192
    Case "VT_BOOL | VT_ARRAY"
      nDatatype = 11 + 8192
    Case "VT_I1 | VT_ARRAY"
      nDatatype = 16 + 8192
    Case "VT_UI1 | VT_ARRAY"
      nDatatype = 17 + 8192
    Case "VT_UI2 | VT_ARRAY"
      nDatatype = 18 + 8192
    Case "VT_UI4 | VT_ARRAY"
      nDatatype = 19 + 8192
  End Select

  ConvertTextDatatypeToNumber = nDatatype

End Function
'
' DeselectAllItemsInItemsListview
'
Private Sub DeselectAllItemsInItemsListview()
  Dim nNumItems As Integer
  Dim i As Integer

  nNumItems = listviewItems.ListItems.Count
  For i = 1 To nNumItems
    listviewItems.ListItems(i).Selected = False
  Next

End Sub
'
' FillBrowser
'
Private Sub FillBrowser()
  Dim bKeepGoing As Boolean
  Dim bRootLevel As Boolean
  Dim bKeepLookingForSibling As Boolean
  Dim TheNode As Node
  Dim ParentNode As Node
  Dim FirstBranchNode As Node
  Dim i As Integer
  Dim ItemName As String
  Dim Browser As OPCBrowser
  Dim nNumLeavesAtThisBranch As Long
  Dim nStartLeaf As Integer

  Set Browser = m_OPCServer.CreateBrowser
  Browser.MoveToRoot
  Set ParentNode = Nothing

  bRootLevel = True
  bKeepGoing = True
  While bKeepGoing
    Set FirstBranchNode = Nothing

    ' Add the branches at this level
    Browser.ShowBranches
    If Browser.Count > 0 Then
      For i = 1 To Browser.Count
        If bRootLevel = True Then
          Set TheNode = treeviewBranches.Nodes.Add(, , , Browser.Item(i))
        Else
          Set TheNode = treeviewBranches.Nodes.Add(ParentNode, tvwChild, , Browser.Item(i))
        End If
        ' Save a reference to the first branch
        If FirstBranchNode Is Nothing Then Set FirstBranchNode = TheNode
      Next i
    End If

    ' Add the leaves at this level
    Browser.ShowLeafs
    nNumLeavesAtThisBranch = Browser.Count
    If nNumLeavesAtThisBranch > 0 Then
      ' Initialize the position in the arrays to start adding data
      nStartLeaf = m_nNumLeaves
      ' Increase the array sizes
      m_nNumLeaves = m_nNumLeaves + nNumLeavesAtThisBranch
      ReDim Preserve m_sLeafItemNames(m_nNumLeaves)
      ReDim Preserve m_sLeafItemIDs(m_nNumLeaves)
      For i = 1 To Browser.Count
        m_sLeafItemNames(nStartLeaf + i) = Browser.Item(i)
        m_sLeafItemIDs(nStartLeaf + i) = Browser.GetItemID(Browser.Item(i))
      Next i
      ParentNode.Tag = CStr(nStartLeaf + 1) & "," & CStr(nNumLeavesAtThisBranch)
    End If

    ' Move to the appropriate level -- see if we just added branches
    If Not FirstBranchNode Is Nothing Then
      ' Move down to the first branch
      Set ParentNode = FirstBranchNode
      ItemName = FirstBranchNode.Text
      Browser.MoveDown (ItemName)
    Else
      bKeepGoing = False
      bKeepLookingForSibling = True
      ' If no branches, go back to the parent and get its sibling
      While bKeepLookingForSibling = True
        If ParentNode Is Nothing Then
          bKeepLookingForSibling = False
        Else
          Browser.MoveUp
          Set TheNode = ParentNode.Next
          If TheNode Is Nothing Then
            ' No more siblings at this level, move up to the parent
            Set ParentNode = ParentNode.Parent
          Else
            ItemName = TheNode.Text
            Browser.MoveDown (ItemName)
            Set ParentNode = TheNode
            bKeepLookingForSibling = False
            bKeepGoing = True
          End If
        End If
      Wend
    End If
    bRootLevel = False
  Wend

End Sub
'
' NumLeavesSelected
'
Private Function NumLeavesSelected() As Integer
  Dim nNumItems As Integer
  Dim i As Integer

  NumLeavesSelected = 0

  nNumItems = listviewLeaves.ListItems.Count
  For i = 1 To nNumItems
    If listviewLeaves.ListItems(i).Selected = True Then
      NumLeavesSelected = NumLeavesSelected + 1
    End If
  Next

End Function
'
' AddSelectedItems
'
Private Sub AddSelectedItems()
  Dim nNumItems As Integer
  Dim i As Integer

  nNumItems = listviewLeaves.ListItems.Count
  For i = 1 To nNumItems
    If listviewLeaves.ListItems(i).Selected = True Then
      ' Add this leaf to the Items listview
      '
      '   ItemID
      listviewItems.ListItems(m_nCurrentListviewItemIndex).Text = listviewLeaves.ListItems(i).Key
      '   Active State
      If checkboxActive.Value = 1 Then
        listviewItems.ListItems(m_nCurrentListviewItemIndex).SubItems(1) = "Yes"
      Else
        listviewItems.ListItems(m_nCurrentListviewItemIndex).SubItems(1) = "No"
      End If
      '   Requested Datatype
      listviewItems.ListItems(m_nCurrentListviewItemIndex).SubItems(2) = "VT_EMPTY"
      '   Access Path
      listviewItems.ListItems(m_nCurrentListviewItemIndex).SubItems(3) = txtAccessPath.Text

      ' Add a new blank item to the end of the Items listview and select it
      AddBlankItemToEndOfList
      m_nNextListviewItemIndex = m_nNextListviewItemIndex + 1
      m_nCurrentListviewItemIndex = m_nNextListviewItemIndex
      listviewItems.ListItems(m_nNextListviewItemIndex).Selected = True
    End If
  Next

  ' Scroll to the bottom of the list
  listviewItems.ListItems(m_nNextListviewItemIndex).EnsureVisible

End Sub
