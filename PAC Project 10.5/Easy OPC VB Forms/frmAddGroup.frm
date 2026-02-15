VERSION 5.00
Begin VB.Form frmAddGroup 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Add Group"
   ClientHeight    =   4695
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   4020
   LinkTopic       =   "Form3"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   4695
   ScaleWidth      =   4020
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.Frame frameDataChangeMethod 
      Caption         =   "Data Change Reporting Method"
      Height          =   1065
      Left            =   240
      TabIndex        =   13
      Top             =   2655
      Width           =   3495
      Begin VB.OptionButton optionContinuous 
         Caption         =   "Continuous Logging"
         Height          =   225
         Left            =   240
         TabIndex        =   6
         Top             =   660
         Width           =   2895
      End
      Begin VB.OptionButton optionSubscription 
         Caption         =   "Subscription"
         Height          =   225
         Left            =   225
         TabIndex        =   5
         Top             =   330
         Value           =   -1  'True
         Width           =   2625
      End
   End
   Begin VB.CheckBox cbActive 
      Caption         =   "Active"
      Height          =   195
      Left            =   240
      TabIndex        =   4
      Top             =   2145
      Value           =   1  'Checked
      Width           =   1020
   End
   Begin VB.TextBox txtDeadband 
      Height          =   315
      Left            =   1635
      TabIndex        =   3
      Text            =   "0"
      Top             =   1590
      Width           =   2100
   End
   Begin VB.TextBox txtTimeBias 
      Height          =   315
      Left            =   1635
      TabIndex        =   2
      Text            =   "0"
      Top             =   1140
      Width           =   2100
   End
   Begin VB.TextBox txtUpdateRate 
      Height          =   315
      Left            =   1635
      TabIndex        =   1
      Text            =   "1000"
      Top             =   690
      Width           =   2100
   End
   Begin VB.CommandButton cmdCancel 
      Cancel          =   -1  'True
      Caption         =   "Cancel"
      Height          =   375
      Left            =   1575
      TabIndex        =   8
      Top             =   4050
      Width           =   1215
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "OK"
      Default         =   -1  'True
      Height          =   375
      Left            =   240
      TabIndex        =   7
      Top             =   4050
      Width           =   1215
   End
   Begin VB.TextBox txtGroupName 
      Height          =   315
      Left            =   1635
      TabIndex        =   0
      Top             =   240
      Width           =   2100
   End
   Begin VB.Label lblDeadband 
      Caption         =   "% Deadband:"
      Height          =   255
      Left            =   240
      TabIndex        =   12
      Top             =   1635
      Width           =   1005
   End
   Begin VB.Label lblTimeBias 
      Caption         =   "Time Bias:"
      Height          =   255
      Left            =   240
      TabIndex        =   11
      Top             =   1185
      Width           =   1005
   End
   Begin VB.Label lblUpdateRate 
      Caption         =   "Update Rate (ms):"
      Height          =   255
      Left            =   240
      TabIndex        =   10
      Top             =   735
      Width           =   1305
   End
   Begin VB.Label lblGroupName 
      Caption         =   "Group Name:"
      Height          =   255
      Left            =   240
      TabIndex        =   9
      Top             =   285
      Width           =   1005
   End
End
Attribute VB_Name = "frmAddGroup"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'
' How To Use This Form
'
'   Start by loading the form
'      Load frmAddGroup
'
'   The form has two modes, adding a new group or modifying an existing group
'   which is controlled by setting the m_bAdding public member variable.
'   When adding a new group, there is no need to initialize the form as the
'   default values and settings should suffice. When modifying an existing group,
'   initialize the fields and buttons by giving initial values to their
'   corresponding public member variables.
'     Member Variable          Field               Description
'     ---------------          -----               -----------
'     m_sGroupName             Group Name          The Group Name
'     m_nUpdateRate            Update Rate         The Update Rate
'     m_nTimeBias              Time Bias           The Time Bias
'     m_rDeadband              % Deadband          The % Deadband
'     m_bIsActive              Active              The Active Checkbox
'     m_bUseSubscriptions      Data Change Method  The Subscription and Continuous Logging Radio Buttons
'   When m_bAdding is set to False, the txtGroupName field is put in Read-Only mode
'   in the Form_Activate() subroutine.
'
'   Display the form
'      frmAddGroup.Show (1)
'
'   When the user exits the dialog, check the value of frmAddGroup.m_bOK. If it is
'   True, the OK button was chosen and you should process and store the contents of
'   the dialog as in the following example code snippet:
'      If frmAddGroup.m_bOK Then
'        ' Update the group object with the new settings
'        GroupObject.UpdateRate = frmAddGroup.m_nUpdateRate
'        GroupObject.TimeBias = frmAddGroup.m_nTimeBias
'        GroupObject.Deadband = frmAddGroup.m_rDeadband
'        etc.
'      EndIf
'
'   For more detailed example code look at DialogCreateGroup() and DialogModifyGroup()
'
Option Explicit
Option Base 1

Public m_bOK As Boolean
Public m_bAdding As Boolean
Public m_sGroupName As String
Public m_nUpdateRate As Long
Public m_nTimeBias As Long
Public m_rDeadband As Single
Public m_bIsActive As Boolean
Public m_bUseSubscriptions As Boolean
'
' Form_Activate - The Form Has Been Activated
'
Private Sub Form_Activate()

  Me.txtGroupName = m_sGroupName
  Me.txtUpdateRate = CStr(m_nUpdateRate)
  Me.txtTimeBias = CStr(m_nTimeBias)
  Me.txtDeadband = CStr(m_rDeadband)
  If m_bIsActive = True Then
    Me.cbActive.Value = 1
  Else
    Me.cbActive.Value = 0
  End If
  If m_bUseSubscriptions = True Then
    Me.optionContinuous = False
    Me.optionSubscription = True
  Else
    Me.optionContinuous = True
    Me.optionSubscription = False
  End If

  If m_bAdding = False Then
    ' If a group is being modified, the Name cannot be changed. Disable the field
    ' and change the appearance to a Read-Only state.
    txtGroupName.Enabled = False
    txtGroupName.BackColor = vbReadOnly
  End If

End Sub
'
' Form_Load - The Form Has Been Loaded
'
Private Sub Form_Load()

  m_bOK = False
  m_bAdding = True
  m_sGroupName = ""
  m_nUpdateRate = 1000
  m_nTimeBias = 0
  m_rDeadband = 0#
  m_bIsActive = True
  m_bUseSubscriptions = True

End Sub
'
' cmdCancel_Click - The Cancel Button Has Been Activated
'
Private Sub cmdCancel_Click()

  Me.Hide

End Sub
'
' cmdOK_Click - The OK Button Has Been Activated
'
Private Sub cmdOK_Click()
  Dim rDeadband As Single
  Dim nUpdateRate As Long

  ' Check the Deadband field
  rDeadband = Val(txtDeadband.Text)
  If rDeadband < 0 Or rDeadband > 100 Then
    MsgBox ("The Deadband is out of range!")
    Exit Sub
  End If

  ' Check the Update Rate field
  nUpdateRate = Val(txtUpdateRate.Text)
  If nUpdateRate < 0 Then
    MsgBox ("The Update Rate is out of range!")
    Exit Sub
  End If

  ' Update the public member variables
  m_sGroupName = Me.txtGroupName
  m_nUpdateRate = CLng(Me.txtUpdateRate)
  m_nTimeBias = CLng(Me.txtTimeBias)
  m_rDeadband = CSng(Me.txtDeadband)
  If Me.cbActive.Value = 1 Then
    m_bIsActive = True
  Else
    m_bIsActive = False
  End If
  If Me.optionSubscription.Value = True Then
    m_bUseSubscriptions = True
  Else
    m_bUseSubscriptions = False
  End If
  m_bOK = True

  Me.Hide

End Sub
'
' optionContinuous_Click - The Continuous Radio Button Has Been Activated
'
Private Sub optionContinuous_Click()

  ' Turn the Subscription button off
  optionSubscription.Value = False

End Sub
'
' optionSubscription_Click - The Subscription Radio Button Has Been Activated
'
Private Sub optionSubscription_Click()

  ' Turn the Continuous button off
  optionContinuous.Value = False

End Sub
