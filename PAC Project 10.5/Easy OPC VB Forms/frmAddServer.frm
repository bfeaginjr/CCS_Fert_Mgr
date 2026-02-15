VERSION 5.00
Begin VB.Form frmAddServer 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Add Server"
   ClientHeight    =   5025
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   3660
   LinkTopic       =   "Form3"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   5025
   ScaleWidth      =   3660
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.TextBox txtNode 
      Height          =   315
      Left            =   240
      TabIndex        =   2
      Top             =   3820
      Width           =   3150
   End
   Begin VB.TextBox txtProgID 
      Height          =   315
      Left            =   240
      TabIndex        =   1
      Text            =   "Opto22.OpcServer"
      Top             =   3000
      Width           =   3150
   End
   Begin VB.ListBox listboxServers 
      Height          =   2010
      Left            =   255
      TabIndex        =   0
      Top             =   500
      Width           =   3150
   End
   Begin VB.CommandButton cmdCancel 
      Cancel          =   -1  'True
      Caption         =   "Cancel"
      Height          =   375
      Left            =   1545
      TabIndex        =   4
      Top             =   4420
      Width           =   1215
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "OK"
      Default         =   -1  'True
      Height          =   375
      Left            =   240
      TabIndex        =   3
      Top             =   4420
      Width           =   1215
   End
   Begin VB.Label lblNodeName 
      Caption         =   "Machine Name (Optional) :"
      Height          =   255
      Left            =   240
      TabIndex        =   7
      Top             =   3520
      Width           =   1890
   End
   Begin VB.Label lblProgID 
      Caption         =   "Program Identifer (ProgID) :"
      Height          =   255
      Left            =   240
      TabIndex        =   6
      Top             =   2720
      Width           =   2040
   End
   Begin VB.Label lblServers 
      Caption         =   "Installed Servers:"
      Height          =   255
      Left            =   240
      TabIndex        =   5
      Top             =   200
      Width           =   1275
   End
End
Attribute VB_Name = "frmAddServer"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'
' How To Use This Form
'
'   Start by loading the form
'      Load frmAddServer
'
'   Initialize the field information by giving initial values to their
'   corresponding public member variables. This is typically not necessary in this
'   form as the default values should suffice.
'     Member Variable          Field           Description
'     ---------------          -----           -----------
'     m_sProgId                txtProgID       The Program Identifier
'     m_sNetworkNode           txtNode         The Network Node Name (computer name)
'
'   Display the form
'      frmAddServer.Show (1)
'
'   When the user exits the dialog, check the value of frmAddServer.m_bOK. If it is
'   True, the OK button was chosen and you should process and store the contents of
'   the dialog as in the following example code snippet:
'      If frmAddServer.m_bOK Then
'        sServerName = frmAddServer.m_sProgId
'        sNetworkNode = frmAddServer.m_sNetworkNode
'        etc.
'      EndIf
'
'   For more detailed example code look at DialogCreateServer()
'
Option Explicit
Option Base 1

Public m_sProgId As String
Public m_sNetworkNode As String
Public m_bOK As Boolean
Private m_OPCServer As OPCServer
'
' Form_Activate - The Form Has Been Activated
'
Private Sub Form_Activate()

  ' Initialize the Installed Servers listbox
  If m_OPCServer Is Nothing Then
    MsgBox ("The OPCServer Automation Object could not be created. Check registration.")
    Me.Hide
    Exit Sub
  Else
    Dim vServers As Variant
    Dim i As Integer

    vServers = m_OPCServer.GetOPCServers
    For i = LBound(vServers) To UBound(vServers)
      listboxServers.AddItem (vServers(i))
    Next
  End If

  ' Initialize the ProgID field
  txtProgID = m_sProgId

  ' Initialize the Node field
  txtNode = m_sNetworkNode

End Sub
'
' Form_Load - The Form Has Been Loaded
'
Private Sub Form_Load()

  ' This creates the OPCServer Automation Object
  Set m_OPCServer = New OPCServer

  m_bOK = False

  ' Set the default Network Node and ProgID
  m_sNetworkNode = ""
  m_sProgId = "Opto22.OpcServer"

End Sub
'
' Form_Unload - The Form Is Being Unloaded
'
Private Sub Form_Unload(Cancel As Integer)

  ' Destroy the OPCServer Automation Object when the form is unloaded
  If Not m_OPCServer Is Nothing Then
    Set m_OPCServer = Nothing
  End If

End Sub
'
' The OK Button Has Been Activated
'
Private Sub cmdOK_Click()

  m_bOK = True

  ' Fill in the public variables with information from the text fields
  m_sProgId = Me.txtProgID
  m_sNetworkNode = Me.txtNode

  Me.Hide

End Sub
'
' The Cancel Button Has Been Activated
'
Private Sub cmdCancel_Click()

  Me.Hide

End Sub
'
' The Servers Listbox Has Been Clicked
'
Private Sub listboxServers_Click()
  Dim nSelectedItem As Integer

  ' Transfer the text to the ProgID edit box
  nSelectedItem = listboxServers.ListIndex
  txtProgID.Text = listboxServers.List(nSelectedItem)
End Sub
