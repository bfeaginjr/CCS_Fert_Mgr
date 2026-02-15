Attribute VB_Name = "EasyOpcUtil"

Const LVM_FIRST = &H1000
Public Const LVM_SETCOLUMNWIDTH = LVM_FIRST + 30
Public Const LVM_GETTOPINDEX = LVM_FIRST + 39
Public Const LVM_GETCOUNTPERPAGE = LVM_FIRST + 40
Public Const LVSCW_AUTOSIZE = -1
Public Const LVSCW_AUTOSIZE_USEHEADER = -2

Public Const SUBSCRIPTION = 1
Public Const CONTINUOUS_LOGGING = 2

Public Const vbReadOnly = &H80000000  ' Gray color for read only text field background

Dim g_bUsingLogFile As Boolean ' True if the log file has been opened
Dim g_nLogFileNum As Integer ' The file number used for output to the log file

Declare Function GetTickCount Lib "kernel32" () As Long
Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)

Public Declare Function SendMessage Lib "USER32" Alias "SendMessageA" ( _
                ByVal hwnd As Long, _
                ByVal Msg As Long, ByVal wParam As Long, _
                ByVal lParam As Long) As Long
'
' DialogCreateServer
'
'   Parameters:
'     sServerName   Out  String  The server name (ProgID) chosen by the user
'     sNetworkNode  Out  String  The network node (machine name) chosen by the user
'
'   Return Value:
'     Returns a CServer object if the user pressed OK in the Add Server dialog
'
'   Remarks:
'     DialogCreateServer displays the Add Server dialog enabling the user to choose
'     a server from the list of servers registered on this machine. A network node
'     can also be chosen but is optional. The CServer object that is returned can
'     be used to call functions in the CServer class. The server name and network
'     node are returned as out parameters. These should be used with either
'     CServer::ConnectToServer if getting data from only one server, or
'     ServerCollection::AddServer if getting data from more than one server.
'
Public Function DialogCreateServer(sServerName As String, sNetworkNode As String) As CServer

  Set DialogCreateServer = Nothing

  ' Initialize and show the AddServer dialog
  Load frmAddServer
  frmAddServer.Show (1)

  If frmAddServer.m_bOK Then
    ' Fill in all of the output variables
    sServerName = frmAddServer.m_sProgId
    sNetworkNode = frmAddServer.m_sNetworkNode

    ' Create a server object to pass back
    Dim ServerObject As CServer
    Set ServerObject = New CServer
    Set DialogCreateServer = ServerObject
  End If

  Unload frmAddServer

End Function
'
' DialogCreateGroup
'
'   Parameters:
'     sGroupName         Out  String   The name of the group chosen by the user
'     nUpdateRate        Out  Long     The update rate chosen by the user
'     nTimeBias          Out  Long     The time bias chosen by the user
'     rDeadband          Out  Single   The deadband chosen by the user
'     bIsActive          Out  Boolean  The state of the group - True = Active, False = Inactive
'     nDataChangeMethod  Out  Integer  SUBSCRIPTION or CONTINUOUS_LOGGING
'
'   Return Value:
'     Returns a CGroup object if the user pressed OK in the Add Group dialog
'
'   Remarks:
'     DialogCreateGroup displays the Add Group dialog enabling the user to enter
'     a group name, update rate, time bias, deadband, active state and a data
'     change method. These are all returned as out parameters and should be used
'     with CServer::AddGroup or ServerCollection::AddGroup. The CGroup object that
'     is returned can be used to call functions in the CGroup class. This would
'     be useful if it was not desired to use the AddGroup functions and the
'     Group Collection embedded in the CServer class. Most of the time the CGroup
'     object that is returned should be discarded by setting it to nothing.
'
Public Function DialogCreateGroup(sGroupName As String, _
                                  nUpdateRate As Long, _
                                  nTimeBias As Long, _
                                  rDeadband As Single, _
                                  bIsActive As Boolean, _
                                  nDataChangeMethod As Integer) As CGroup

  Set DialogCreateGroup = Nothing

  ' Initialize and show the AddGroup dialog
  Load frmAddGroup
  frmAddGroup.Show (1)

  If frmAddGroup.m_bOK Then
    ' Fill in all of the output variables
    sGroupName = frmAddGroup.m_sGroupName
    nUpdateRate = frmAddGroup.m_nUpdateRate
    nTimeBias = frmAddGroup.m_nTimeBias
    rDeadband = frmAddGroup.m_rDeadband
    bIsActive = frmAddGroup.m_bIsActive
    nDataChangeMethod = CONTINUOUS_LOGGING
    If frmAddGroup.m_bUseSubscriptions = True Then
      nDataChangeMethod = SUBSCRIPTION
    End If

    ' Create a group object to pass back
    Dim GroupObject As CGroup
    Set GroupObject = New CGroup
    Set DialogCreateGroup = GroupObject
  End If

  Unload frmAddGroup

End Function
'
' GetServerHandleFromGroupHandle
'
'   Parameters:
'     nGroupHandle  In  Long  The handle of a group
'
'   Return Value:
'     Returns a server handle
'
'   Remarks:
'     Every group belongs to a server and every grouphandle has its server's
'     handle embedded in the upper byte of the lower word of the group handle.
'     GetServerHandleFromGroupHandle extracts the server handle from the group
'     handle.
'
Public Function GetServerHandleFromGroupHandle(nGroupHandle As Long) As Long

  ' Integer divide the group handle by 4096 to shift the result 3 bytes to the
  ' right (or 12 bits to the right). Since the upper word of the group handle is
  ' empty, this leaves only the upper byte of the lower word as the result.
  '
  '                0  0  0  0  F  0  0  0
  ' Server Handle             |_|
  ' Group Handle              |__________|
  '
  GetServerHandleFromGroupHandle = nGroupHandle \ 4096 ' same as 0x1000

End Function
'
' GetServerHandleFromItemHandle
'
'   Parameters:
'     nItemHandle  In  Long  The handle of an item
'
'   Return Value:
'     Returns a server handle
'
'   Remarks:
'     Every item belongs to a group that belongs to a server and every item handle
'     has its group's and its server's handle embedded in it.
'     GetServerHandleFromItemHandle extracts the server handle from the item handle.
'
Public Function GetServerHandleFromItemHandle(nItemHandle As Long) As Long

  ' Integer divide the item handle by 268435456 to shift the result 7 bytes to the
  ' right (or 28 bits to the right). This leaves only the upper byte of the upper
  ' word as the result.
  '
  '                    F  0  0  0  0  0  0  0
  ' Server Handle     |_|
  ' Group Handle      |__________|
  ' Item  Handle      |______________________|
  '
  GetServerHandleFromItemHandle = nItemHandle \ 268435456 ' same as 0x10000000

End Function
'
' GetGroupHandleFromItemHandle
'
'   Parameters:
'     nItemHandle  In  Long  The handle of an item
'
'   Return Value:
'     Returns a group handle
'
'   Remarks:
'     Every item belongs to a group and every item handle has its group's handle
'     embedded in it. GetGroupHandleFromItemHandle extracts the group handle
'     from the item handle.
'
Public Function GetGroupHandleFromItemHandle(nItemHandle As Long) As Long

  ' Integer divide the item handle by 65536 to shift the result 4 bytes to the
  ' right (or 16 bits to the right). This leaves only the upper word of the item
  ' handle as the result.
  '
  '                    0  F  F  F  0  0  0  0
  ' Server Handle     |_|
  ' Group Handle      |__________|
  ' Item  Handle      |______________________|
  '
  GetGroupHandleFromItemHandle = nItemHandle \ 65536 ' same as 0x10000

End Function
'
' ConvertQualityToString
'
'   Parameters:
'     nQuality  In  Long  The quality of an represented numerically
'
'   Return Value:
'     The text description that corresponds to the numeric value.
'
'   Remarks:
'     Converts a numeric quality to a string description.
'
Public Function ConvertQualityToString(nQuality As Long) As String

  Select Case nQuality
    Case OPCQuality.OPCQualityGood:
      ConvertQualityToString = "Good"
    Case OPCQualityStatus.OPCStatusLocalOverride:
      ConvertQualityToString = "Good - Local Override"
    Case OPCQuality.OPCQualityBad:
      ConvertQualityToString = "Bad"
    Case OPCQualityStatus.OPCStatusConfigError:
      ConvertQualityToString = "Bad - Configuration Error"
    Case OPCQualityStatus.OPCStatusNotConnected:
      ConvertQualityToString = "Bad - Not Connected"
    Case OPCQualityStatus.OPCStatusDeviceFailure:
      ConvertQualityToString = "Bad - Device Failure"
    Case OPCQualityStatus.OPCStatusSensorFailure:
      ConvertQualityToString = "Bad - Sensor Failure"
    Case OPCQualityStatus.OPCStatusLastKnown:
      ConvertQualityToString = "Bad - Last Known Value"
    Case OPCQualityStatus.OPCStatusCommFailure:
      ConvertQualityToString = "Bad - Communications Failure"
    Case OPCQualityStatus.OPCStatusOutOfService:
      ConvertQualityToString = "Bad - Out Of Service"
    Case OPCQualityStatus.OPCStatusLastUsable:
      ConvertQualityToString = "Uncertain - Last Usable Value"
    Case OPCQualityStatus.OPCStatusSensorCal:
      ConvertQualityToString = "Uncertain - Sensor Not Accurate"
    Case OPCQualityStatus.OPCStatusEGUExceeded:
      ConvertQualityToString = "Uncertain - Engineering Units Exceeded"
    Case OPCQualityStatus.OPCStatusSubNormal:
      ConvertQualityToString = "Uncertain - Sub-Normal"
    Case Else
      ConvertQualityToString = "Uncertain - " & CStr(nQuality)
  End Select

End Function
'
' OpenLogFile
'
'   Parameters:
'
'   Return Value:
'     None
'
'   Remarks:
'
Public Function OpenLogFile(sFilename As String) As Boolean

  OpenLogFile = False

  If g_bUsingLogFile = True Then
    Exit Function ' more than one log file is not allowed
  End If

  On Error GoTo OpenLogFileErr:
  g_nLogFileNum = FreeFile
  Open sFilename For Output As g_nLogFileNum

  OpenLogFile = True
  Exit Function

OpenLogFileErr:

End Function
'
' WriteToLogFile
'
'   Parameters:
'
'   Return Value:
'     None
'
'   Remarks:
'
Public Function WriteToLogFile(sMessage As String) As Boolean

  WriteToLogFile = False

  If g_bUsingLogFile = False Then
    On Error GoTo WriteToLogFileErr:
    Write #g_nLogFileNum, sMessage

    WriteToLogFile = True
  End If
  Exit Function

WriteToLogFileErr:

End Function
'
' CloseLogFile
'
'   Parameters:
'
'   Return Value:
'     None
'
'   Remarks:
'
Public Function CloseLogFile() As Boolean

  CloseLogFile = False

  If g_bUsingLogFile = False Then
    Exit Function ' can't close what isn't open - duh
  End If

  On Error GoTo CloseLogFileErr:
  Close g_nLogFileNum

  g_bUsingLogFile = False
  CloseLogFile = True
  Exit Function

CloseLogFileErr:

End Function
