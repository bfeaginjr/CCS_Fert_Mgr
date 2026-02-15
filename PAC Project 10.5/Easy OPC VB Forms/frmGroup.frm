VERSION 5.00
Begin VB.Form frmGroup 
   Caption         =   "Group Form"
   ClientHeight    =   3195
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   4680
   LinkTopic       =   "Form2"
   ScaleHeight     =   3195
   ScaleWidth      =   4680
   StartUpPosition =   2  'CenterScreen
   Begin VB.Timer TimerForGroup 
      Enabled         =   0   'False
      Left            =   1905
      Top             =   1005
   End
End
Attribute VB_Name = "frmGroup"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
Option Base 1

Public m_Parent As CGroup

Public WithEvents m_OPCGroup As OPCGroup
Attribute m_OPCGroup.VB_VarHelpID = -1
'
' Form_Load
'
Private Sub Form_Load()

  Set m_Parent = Nothing

  Set m_OPCGroup = Nothing

End Sub
'
' Form_QueryUnload
'
Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)

  If UnloadMode = vbFormControlMenu Then
    Cancel = 1
    Me.Hide
  End If

End Sub
'
' Form_Unload
'
Private Sub Form_Unload(Cancel As Integer)
  Dim nNumItems As Integer
  Dim i As Integer
  Dim nItemServerHandles() As Long
  Dim nErrors() As Long
  
  Debug.Print ("frmGroup Unload Start")

  If Not m_OPCGroup Is Nothing Then
    ' Remove the items in the group (if any)
    nNumItems = m_OPCGroup.OPCItems.Count
    If nNumItems > 0 Then
      ReDim nItemServerHandles(nNumItems)
      For i = 1 To nNumItems
        nItemServerHandles(i) = m_OPCGroup.OPCItems(i).ServerHandle
      Next
      m_OPCGroup.OPCItems.Remove nNumItems, nItemServerHandles, nErrors
    End If

    ' Release the OPC group
    Set m_OPCGroup = Nothing
  End If

  Debug.Print ("frmGroup Unload End")
End Sub
'
' AsyncCancelComplete Event
'
Private Sub m_OPCGroup_AsyncCancelComplete(ByVal CancelID As Long)

  If Not m_Parent Is Nothing Then
    m_Parent.CancelComplete (CancelID)
  End If

End Sub
'
' AsyncReadComplete Event
'
Private Sub m_OPCGroup_AsyncReadComplete(ByVal TransactionID As Long, ByVal NumItems As Long, ClientHandles() As Long, ItemValues() As Variant, Qualities() As Long, TimeStamps() As Date, Errors() As Long)

  If Not m_Parent Is Nothing Then
    m_Parent.DataChange TransactionID, NumItems, ClientHandles(), ItemValues(), Qualities(), TimeStamps()
  End If

End Sub
'
' AsyncWriteComplete Event
'
Private Sub m_OPCGroup_AsyncWriteComplete(ByVal TransactionID As Long, ByVal NumItems As Long, ClientHandles() As Long, Errors() As Long)

  If Not m_Parent Is Nothing Then
    m_Parent.WriteComplete TransactionID, NumItems, ClientHandles, Errors
  End If

End Sub

'
' TimerForGroup_Timer
'
Private Sub TimerForGroup_Timer()

  If m_OPCGroup.OPCItems.Count > 0 Then
    Dim TransactionID As Long
    Dim Source As Integer
    Dim CancelID As Long

    TransactionID = 2
    Source = OPCDataSource.OPCCache
    Call m_OPCGroup.AsyncRefresh(Source, TransactionID, CancelID)
  End If

End Sub
