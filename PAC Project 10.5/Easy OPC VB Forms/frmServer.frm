VERSION 5.00
Begin VB.Form frmServer 
   Caption         =   "Server Form"
   ClientHeight    =   3195
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   4680
   LinkTopic       =   "Form2"
   ScaleHeight     =   3195
   ScaleWidth      =   4680
   StartUpPosition =   3  'Windows Default
End
Attribute VB_Name = "frmServer"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
Option Base 1

Public m_Parent As CServer

Public WithEvents m_OPCServer As OPCServer
Attribute m_OPCServer.VB_VarHelpID = -1
Public WithEvents m_OpcGroupCollection As OPCGroups
Attribute m_OpcGroupCollection.VB_VarHelpID = -1
'
' Form_Load
'
Private Sub Form_Load()

  Set m_Parent = Nothing

  Set m_OPCServer = New OPCServer
  Set m_OpcGroupCollection = m_OPCServer.OPCGroups

End Sub
'
' Form_QueryUnload
'
Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)

End Sub
'
' Form_Unload
'
Private Sub Form_Unload(Cancel As Integer)

  ' Discontinue the trickle-up callbacks
  If Not m_Parent Is Nothing Then
    Set m_Parent = Nothing
  End If

  ' Release the OPC Group collection
  If Not m_OpcGroupCollection Is Nothing Then
    Set m_OpcGroupCollection = Nothing
  End If

  ' Release the OPC Server object
  If Not m_OPCServer Is Nothing Then
    Set m_OPCServer = Nothing
  End If

End Sub
'
' GlobalDataChange
'
Private Sub m_OpcGroupCollection_GlobalDataChange(ByVal TransactionID As Long, ByVal GroupHandle As Long, ByVal NumItems As Long, ClientHandles() As Long, ItemValues() As Variant, Qualities() As Long, TimeStamps() As Date)

  If Not m_Parent Is Nothing Then
    m_Parent.DataChange TransactionID, GroupHandle, NumItems, ClientHandles(), ItemValues(), Qualities(), TimeStamps()
  End If

End Sub
'
' ServerShutDown
'
Private Sub m_OPCServer_ServerShutDown(ByVal Reason As String)

  If Not m_Parent Is Nothing Then
    m_Parent.Shutdown (Reason)
  End If

End Sub
