VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "mscomctl.ocx"
Begin VB.Form frmValidateItems 
   Caption         =   "Validate Items"
   ClientHeight    =   3195
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   7140
   LinkTopic       =   "Form2"
   MinButton       =   0   'False
   ScaleHeight     =   3195
   ScaleWidth      =   7140
   StartUpPosition =   2  'CenterScreen
   Begin MSComctlLib.ListView listviewItems 
      Height          =   2730
      Left            =   240
      TabIndex        =   0
      Top             =   225
      Width           =   6660
      _ExtentX        =   11748
      _ExtentY        =   4815
      View            =   3
      LabelEdit       =   1
      LabelWrap       =   -1  'True
      HideSelection   =   -1  'True
      FullRowSelect   =   -1  'True
      _Version        =   393217
      ForeColor       =   -2147483640
      BackColor       =   -2147483643
      BorderStyle     =   1
      Appearance      =   1
      NumItems        =   2
      BeginProperty ColumnHeader(1) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         Text            =   "Status"
         Object.Width           =   3528
      EndProperty
      BeginProperty ColumnHeader(2) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   1
         Text            =   "ItemID"
         Object.Width           =   7056
      EndProperty
   End
End
Attribute VB_Name = "frmValidateItems"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
Option Base 1

Public m_nNumItems As Long
Public m_vItemIDs As Variant
Public m_vErrors As Variant
'
' Form_Activate - The Form Has Been Activated
'
Private Sub Form_Activate()

  If m_nNumItems > 0 Then
    Dim i As Integer
    Dim TheListItem As ListItem
    Dim sError As String
    For i = 1 To m_nNumItems
      If m_vErrors(i) = 0 Then
        Set TheListItem = listviewItems.ListItems.Add(, , "Good")
      Else
        sError = "Error - 0x" & Hex(m_vErrors(i))
        Set TheListItem = listviewItems.ListItems.Add(, , sError)
      End If
      TheListItem.SubItems(1) = m_vItemIDs(i)
    Next
  End If

End Sub
'
' Form_Load - The Form Has Been Loaded
'
Private Sub Form_Load()

  m_nNumItems = 0

End Sub
'
' Form_Resize - The Form Has Been Resized
'
Private Sub Form_Resize()

  ' Guard against problem when form is restored from a minimized state. A runtime
  ' error will occur
  If Me.WindowState <> vbMinimized Then
    ' Don't allow the window to be sized too small
    If Me.Width < 2500 Then Me.Width = 2500
    If Me.Height < 2500 Then Me.Height = 2500

    ' Resize the listview
    listviewItems.Width = Me.ScaleWidth - 500
    listviewItems.Height = Me.ScaleHeight - 400

    Dim lWidth As Long
    Dim lCol As Long
    lWidth = LVSCW_AUTOSIZE_USEHEADER
    lCol = 1
    SendMessage listviewItems.hwnd, LVM_SETCOLUMNWIDTH, lCol, lWidth
  End If

End Sub

