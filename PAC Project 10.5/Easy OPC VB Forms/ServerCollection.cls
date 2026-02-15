VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ServerCollection"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Collection" ,"ServerFormClass"
Attribute VB_Ext_KEY = "Member0" ,"ServerFormClass"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
Option Explicit
Option Base 1

' Local variable to hold collection
Private mCol As Collection

' Local variable for the server handle
Private m_NextServerHandle As Long

Public Event AsyncCancelComplete(ByVal nTransactionID As Long, ByVal nServerHandle As Long, ByVal nGroupHandle As Long)
Public Event AsyncWriteComplete(ByVal nTransactionID As Long, ByVal nServerHandle As Long, ByVal nGroupHandle As Long, ByVal nNumItems As Long, nItemHandles() As Long, nErrors() As Long)
Public Event GlobalDataChange(ByVal nTransactionID As Long, ByVal nServerHandle As Long, ByVal nGroupHandle As Long, ByVal nNumItems As Long, nItemHandles() As Long, vItemValues() As Variant, nQualities() As Long, TimeStamps() As Date)
Public Event ServerShuttingDown(ByVal nServerHandle As Long, ByVal sReason As String)
'
' AServerIsShuttingDown
'
'   Parameters:
'     nServerHandle  In  Long    The handle of the server that is shutting down
'     sReason        In  String  A string sent by the server as the reason for shutting down
'
'   Return Value:
'     None
'
'   Remarks:
'     Part of the trickle-up callback system. ServerCollection::AServerIsShuttingDown
'     is called by CServer::Shutdown in order to raise a ServerShuttingDown Event.
'
Public Sub AServerIsShuttingDown(ByVal nServerHandle As Long, _
                                 ByVal sReason As String)

  RaiseEvent ServerShuttingDown(nServerHandle, sReason)

End Sub
'
' DataChange
'
'   Parameters:
'     nTransactionID  In  Long               The ID of the asynchronous transaction
'     nServerHandle   In  Long               The handle of the server that holds the group
'     nGroupHandle    In  Long               The handle of the group that holds the items
'     nNumItems       In  Long               The number of items in the transaction
'     nItemHandles()  In  Array of Longs     The handle of each item
'     vItemValues()   In  Array of Variants  The value of each item
'     nQualities()    In  Array of Longs     The quality of each item
'     TimeStamps()    In  Array of Dates     The timestamp of each item
'
'   Return Value:
'     None
'
'   Remarks:
'     Part of the trickle-up callback system. ServerCollection::DataChange is called
'     by CServer::DataChange in order to raise a GlobalDataChange Event.
'
Public Sub DataChange(ByVal nTransactionID As Long, ByVal nServerHandle As Long, _
                      ByVal nGroupHandle As Long, ByVal nNumItems As Long, _
                      nItemHandles() As Long, vItemValues() As Variant, _
                      nQualities() As Long, TimeStamps() As Date)

  RaiseEvent GlobalDataChange(nTransactionID, nServerHandle, nGroupHandle, nNumItems, nItemHandles, vItemValues, nQualities, TimeStamps)

End Sub
'
' WriteComplete
'
'   Parameters:
'     nTransactionID  In  Long            The ID of the Async Write transaction
'     nServerHandle   In  Long            The handle of the server that holds the group
'     nGroupHandle    In  Long            The handle of the group that holds the items
'     nNumItems       In  Long            The number of items in the transaction
'     nItemHandles()  In  Array of Longs  The handle of each item
'     nErrors()       In  Array of Longs  The error status of each item
'
'   Return Value:
'     None
'
'   Remarks:
'     Part of the trickle-up callback system. ServerCollection::WriteComplete is
'     called by CServer::WriteComplete in order to raise an AsyncWriteComplete
'     Event.
'
Public Sub WriteComplete(ByVal nTransactionID As Long, ByVal nServerHandle As Long, _
                         ByVal nGroupHandle As Long, ByVal nNumItems As Long, _
                         nItemHandles() As Long, nErrors() As Long)

  RaiseEvent AsyncWriteComplete(nTransactionID, nServerHandle, nGroupHandle, nNumItems, nItemHandles, nErrors)

End Sub
'
' CancelComplete
'
'   Parameters:
'     nTransactionID  In  Long  The ID of the transaction that was canceled
'     nServerHandle   In  Long  The handle of the server where the transaction originated
'     nGroupHandle    In  Long  The handle of the group where the transaction originated
'
'   Return Value:
'     None
'
'   Remarks:
'     Part of the trickle-up callback system. ServerCollection::CancelComplete is
'     called by CServer::CancelComplete in order to raise an AsyncCancelComplete
'     Event.
'
Public Sub CancelComplete(ByVal nTransactionID As Long, ByVal nServerHandle As Long, _
                          ByVal nGroupHandle As Long)

  RaiseEvent AsyncCancelComplete(nTransactionID, nServerHandle, nGroupHandle)

End Sub
'
' DialogAddServer
'
'   Parameters:
'     sServerProgID  Out  String  The ProgID of the OPC Server to start
'     sNetworkNode   Out  String  The Machine Name where the server resides
'
'   Return Value:
'     Returns 0 if a server was not added or if the user canceled out of the
'       Add Server dialog.
'     Returns a server handle if the server was successfully added.
'
'   Remarks:
'     ServerCollection::DialogAddServer displays the Add Server dialog enabling
'     the user to select one of the OPC Servers registered on the local machine.
'     A machine name can also be entered to run a server that resides somewhere
'     else on the network.
'
Public Function DialogAddServer(sServerName As String, sNetworkNode As String) As Long
  Dim ServerObject As CServer

  DialogAddServer = 0

  ' Check for maximum servers
  If m_NextServerHandle > 15 Then
    MsgBox ("The maximum number of servers has been reached.")
    Exit Function
  End If

  ' Call DialogCreateServer to display the Add Server dialog. It will return a
  ' CServer object which we do not need since the collection will create
  ' a CServer object when AddServer is called.
  Set ServerObject = DialogCreateServer(sServerName, sNetworkNode)
  If Not ServerObject Is Nothing Then
    Set ServerObject = Nothing
    DialogAddServer = AddServer(sServerName, sNetworkNode)
  End If

End Function
'
' AddServer
'
'   Parameters:
'     sServerProgID  In  String  The ProgID of the OPC Server to start
'     sNetworkNode   In  String  The Machine Name where the server resides
'
'   Return Value:
'     Returns 0 if a server was not added.
'     Returns a server handle if the server was successfully added.
'
'   Remarks:
'     ServerCollection::AddServer attempts to connect or start up the OPC Server
'     specified by sServerProgID on the machine specified by sNetworkNode. If
'     sNetworkNode is blank, the local machine is assumed.
'
Public Function AddServer(ByVal sServerProgID As String, ByVal sNetworkNode As String) As Long
  Dim sServerHandle As String
  Dim ServerObject As CServer
  Dim nResult As Long

  AddServer = 0

  ' Check the input parameters
  If Len(sServerProgID) = 0 Then Exit Function
  
  ' Check for maximum servers
  If m_NextServerHandle > 15 Then
    Exit Function
  End If

  ' Convert the server handle to a string
  sServerHandle = CStr(m_NextServerHandle)

  ' Add a server object
  Set ServerObject = Me.Add(sServerHandle)

  ' Connect to the server (will start it up if it isn't already running)
  nResult = ServerObject.ConnectToServer(sServerProgID, sNetworkNode)
  If nResult = 0 Then
    ' Assign the server handle to the server object
    ServerObject.m_Handle = m_NextServerHandle

    ' Return the server handle
    AddServer = m_NextServerHandle

    ' Increment the server handle for the next server to be added
    m_NextServerHandle = m_NextServerHandle + 1
  Else
    ' Remove the server object from the collection
    Me.Remove (sServerHandle)
    
    ' Return an invalid server handle and do not increment the server handle
    AddServer = nResult
  End If

  Set ServerObject = Nothing ' decrement ServerObject refcount

End Function
'
' RemoveServer
'
'   Parameters:
'     nServerHandle  In  Long  The handle of the server to remove
'
'   Return Value:
'     Returns True if the server is removed.
'     Returns False if the server cannot be found or if the server cannot be removed.
'
'   Remarks:
'     ServerCollection::RemoveServer looks up the server object using the server
'     handle passed in and first disconnects from the OPC Server and then removes
'     the server object from the server collection.
'
Public Function RemoveServer(ByVal nServerHandle As Long) As Boolean
  Dim ServerObject As CServer
  Dim bDisconnected As Boolean
  Dim vKey As Variant

  RemoveServer = False

  ' Look up the server object and disconnect it
  Set ServerObject = GetServer(nServerHandle)
  If Not ServerObject Is Nothing Then
    bDisconnected = ServerObject.DisconnectFromServer
    If bDisconnected Then
      Set ServerObject = Nothing ' done with ServerObject - decrease its refcount

      ' Remove the server object from the collection
      vKey = CStr(nServerHandle)
      Me.Remove (vKey)

      RemoveServer = True
    End If
  End If

End Function
'
' GetServer
'
'   Parameters:
'     nServerHandle  In  Long  The handle of the server to look up
'
'   Return Value:
'     Returns 'Nothing' if the server cannot be found.
'     Returns a reference to the server object if successful.
'
'   Remarks:
'     ServerCollection::GetServer looks up the server using the server handle passed
'     in and returns a reference to a CServer object.
'
Public Function GetServer(ByVal nServerHandle As Long) As CServer
  Dim sServerHandle As String
  Dim vKey As Variant

  Set GetServer = Nothing

  If Me.Count > 0 Then
    ' Convert the server handle to a string
    sServerHandle = CStr(nServerHandle)
    vKey = sServerHandle

    ' Look up the server object in the collection
    Set GetServer = Me.Item(vKey)
  End If

End Function
'
' DialogAddGroup
'
'   Parameters:
'     nServerHandle      In   Long     The handle of the server in which to add the group
'     sGroupName         Out  String   The name of the group chosen by the user
'     nUpdateRate        Out  Long     The update rate value chosen by the user
'     nTimeBias          Out  Long     The time bias value chosen by the user
'     rDeadband          Out  Single   The deadband value chosen by the user
'     bIsActive          Out  Boolean  The state of the group - True = Active, False = Inactive
'     nDataChangeMethod  Out  Integer  SUBSCRIPTION or CONTINUOUS_LOGGING
'
'   Return Value:
'     Returns 0 if a group was not created and added.
'     Returns a group handle if the group was successfully created and added.
'
'   Remarks:
'     ServerCollection::DialogAddGroup displays the Add Group
'     dialog enabling the user to enter a group name, update rate, time bias,
'     deadband, active state and a data change method. These are all returned as
'     out parameters after the group is added. The group name can be left blank
'     in the Add Group dialog in which case the server will generate a group name
'     and this name will be returned in the out parameter sGroupName.
'
Public Function DialogAddGroup(ByVal nServerHandle As Long, sGroupName As String, _
                               nUpdateRate As Long, nTimeBias As Long, _
                               rDeadband As Single, bIsActive As Boolean, _
                               nDataChangeMethod As Integer) As Long
  Dim ServerObject As CServer

  DialogAddGroup = 0

  ' Look up the server object in the collection
  Set ServerObject = GetServer(nServerHandle)
  If Not ServerObject Is Nothing Then
    DialogAddGroup = ServerObject.DialogAddGroup(sGroupName, nUpdateRate, nTimeBias, rDeadband, bIsActive, nDataChangeMethod)
    Set ServerObject = Nothing ' done with ServerObject - decrease its refcount
  End If

End Function
'
' AddGroup
'
'   Parameters:
'     nServerHandle      In      Long     The handle of the server in which to add the group
'     sGroupName         In/Out  String   The name of the group
'     nUpdateRate        In      Long     The update rate value
'     nTimeBias          In      Long     The time bias value
'     rDeadband          In      Single   The deadband value
'     bIsActive          In      Boolean  The state of the group - True = Active, False = Inactive
'     nDataChangeMethod  In      Integer  SUBSCRIPTION or CONTINUOUS_LOGGING
'
'   Return Value:
'     Returns 0 if a group was not created and added.
'     Returns a group handle if the group was successfully created and added.
'
'   Remarks:
'     ServerCollection::AddGroup adds a group to the OPC Server. If the group name
'     passed in is blank, the OPC Server will generate a name which is passed back
'     out. nTimeBias, rDeadband, bIsActive and nDataChangeMethod are all optional
'     parameters. If the group is set up for continuous logging, callbacks from the
'     server are disabled and a refresh timer is started in the group form.
'
Public Function AddGroup(ByVal nServerHandle As Long, _
                         sGroupName As String, _
                         nUpdateRate As Long, _
                         Optional ByVal nTimeBias As Long = 0, _
                         Optional ByVal rDeadband As Single = CSng(0), _
                         Optional ByVal bIsActive As Boolean = True, _
                         Optional ByVal nDataChangeMethod As Integer = SUBSCRIPTION) As Long
  Dim ServerObject As CServer

  AddGroup = 0

  ' Look up the server object in the collection
  Set ServerObject = GetServer(nServerHandle)
  If Not ServerObject Is Nothing Then
    AddGroup = ServerObject.AddGroup(sGroupName, nUpdateRate, nTimeBias, rDeadband, bIsActive, nDataChangeMethod)
    Set ServerObject = Nothing ' done with ServerObject - decrease its refcount
  End If

End Function
'
' RemoveGroup
'
'   Parameters:
'     nGroupHandle  In  Long  The handle of the group to remove
'
'   Return Value:
'     Returns True if the group is removed.
'     Returns False if the group cannot be found or if the group cannot be removed.
'
'   Remarks:
'     ServerCollection::RemoveGroup looks up the group object using the group handle
'     passed in and first removes the group from the group collection. It then
'     unsubscribes the group from the OPC Server and then removes the group from
'     the OPC Server.
'
Public Function RemoveGroup(ByVal nGroupHandle As Long) As Boolean
  Dim ServerObject As CServer

  RemoveGroup = False

  ' Look up the server object in the collection
  Set ServerObject = GetServer(GetServerHandleFromGroupHandle(nGroupHandle))
  If Not ServerObject Is Nothing Then
    RemoveGroup = ServerObject.RemoveGroup(nGroupHandle)
    Set ServerObject = Nothing ' done with ServerObject - decrease its refcount
  End If

End Function
'
' DialogModifyGroup
'
'   Parameters:
'     nGroupHandle  In  Long  The handle of the group to modify
'
'   Return Value:
'     Returns 'Nothing' if the group cannot be found or if the user cancels out
'       of the Modify Group dialog.
'     Returns a reference to a CGroup object if the user presses OK in the Modify
'       Group dialog.
'
'   Remarks:
'     ServerCollection::DialogModifyGroup looks up a group object using the group
'     handle passed in. It then displays the Modify Group dialog filling in the
'     fields with the current values in the group object. If the user chooses OK
'     in the Modify Group dialog, the values from the fields are put into the group
'     object and this object is passed back to the user. If the user cancels out
'     of the Modify Group dialog, this function returns 'Nothing'.
'
Public Function DialogModifyGroup(ByVal nGroupHandle As Long) As CGroup
  Dim ServerObject As CServer

  Set DialogModifyGroup = Nothing

  ' Look up the server object in the collection
  Set ServerObject = GetServer(GetServerHandleFromGroupHandle(nGroupHandle))
  If Not ServerObject Is Nothing Then
    Set DialogModifyGroup = ServerObject.DialogModifyGroup(nGroupHandle)
    Set ServerObject = Nothing ' done with ServerObject - decrease its refcount
  End If

End Function
'
' GetGroup
'
'   Parameters:
'     nGroupHandle  In  Long  The handle of the group to look up
'
'   Return Value:
'     Returns 'Nothing' if the group cannot be found.
'     Returns a reference to the group object if successful.
'
'   Remarks:
'     ServerCollection::GetGroup looks up the group using the group handle passed
'     in and returns a reference to a CGroup object.
'
Public Function GetGroup(ByVal nGroupHandle As Long) As CGroup
  Dim ServerObject As CServer

  Set GetGroup = Nothing

  ' Look up the server object in the server collection
  Set ServerObject = GetServer(GetServerHandleFromGroupHandle(nGroupHandle))
  If Not ServerObject Is Nothing Then
    ' Look up the group object in the Group collection
    Set GetGroup = ServerObject.GetGroup(nGroupHandle)
    Set ServerObject = Nothing ' done with ServerObject - decrease its refcount
  End If

End Function
'
' DialogAddItems
'
'   Parameters:
'     nGroupHandle     In      Long               The group in which to add items
'     nNumItems        Out     Long               The number of items added
'     sItemIDs()       Out     Array of Strings   The ItemID of each item
'     bActiveStates()  Out     Array of Booleans  The state of each item
'     nDatatypes()     Out     Array of Integers  The datatype of each item
'     sAccessPaths()   Out     Array of Strings   The access path of each item
'     nItemHandles()   Out     Array of Longs     The item handle of each item
'     nErrors()        Out     Array of Longs     The error status of each item
'     nDialogWidth     In/Out  Integer            Optional width of the dialog
'     nDialogHeight    In/Out  Integer            Optional height of the dialog
'
'   Return Value:
'     Returns True if all of the items are added successfully.
'     Returns False if the maximum number of items is exceeded, or if one or more
'       of the items is not added successfully or the Cancel button is pressed.
'
'   Remarks:
'     ServerCollection::DialogAddItems takes a group handle as input, displays the
'     Add Items dialog and then calls AddItems with the values entered by the user
'     in the dialog. These values are passed back out of the dialog as out parameters
'     so they can be used appropriately in user interface or storage elements. The
'     array out parameters should be declared as empty arrays, that is arrays of
'     no length. [ e.g. Dim sItemIDs() As String ] The two optional in/out parameters
'     nDialogWidth and nDialogHeight can be used to remember the size of the Add
'     Items dialog. The dialog can be resized by the user and it would be nice if
'     the dialog is that same size when it is displayed subsequently. If these two
'     parameters are supplied to this function, the final height and width of the
'     dialog will be placed into the variables. A value of 0 for the height and
'     width will make the dialog display at its default size. A value of -1 for the
'     height and width will make the dialog display in a maximized state.
'
Public Function DialogAddItems(ByVal nGroupHandle As Long, nNumItems As Long, _
                               sItemIDs() As String, bActiveStates() As Boolean, _
                               nDatatypes() As Integer, sAccessPaths() As String, _
                               nItemHandles() As Long, nErrors() As Long, _
                               Optional nDialogWidth As Integer = 0, _
                               Optional nDialogHeight As Integer = 0) As Boolean
  Dim ServerObject As CServer

  DialogAddItems = False

  ' Look up the server object in the server collection
  Set ServerObject = GetServer(GetServerHandleFromGroupHandle(nGroupHandle))
  If Not ServerObject Is Nothing Then
    DialogAddItems = ServerObject.DialogAddItems(nGroupHandle, nNumItems, sItemIDs, _
                                                 bActiveStates, nDatatypes, _
                                                 sAccessPaths, nItemHandles, _
                                                 nErrors, nDialogWidth, nDialogHeight)
    Set ServerObject = Nothing ' done with ServerObject - decrease its refcount
  End If

End Function
'
' AddItems
'
'   Parameters:
'     nGroupHandle     In  Long               The group in which to add the items
'     nNumItems        In  Long               The number of items to add
'     sItemIDs()       In  Array of Strings   The ItemId of each item to add
'     bActiveStates()  In  Array of Booleans  The state of each item to add
'     nDatatypes()     In  Array of Integers  The datatype of each item to add
'     sAccessPaths()   In  Array of Strings   The access path of each item to add
'     nItemHandles()   Out Array of Longs     The generated handle of each item
'     nErrors()        Out Array of Longs     The error status of each item
'
'   Return Value:
'     Returns True if all of the items are added successfully.
'     Returns False if the group cannot be found or if the maximum number of items
'       is exceeded, or if one or more of the items is not added successfully.
'
'   Remarks:
'     ServerCollection::AddItems attempts to add the items specified in the In
'     parameters to the group specified by nGroupHandle. An item handle will be
'     generated for each item successfully added. The space for the nItemHandles
'     array must be allocated before calling this function whereas the nErrors
'     array should be declared as an empty array. The server will allocate the
'     space for the nErrors array.
'
Public Function AddItems(ByVal nGroupHandle As Long, _
                         ByVal nNumItems As Long, _
                         sItemIDs() As String, _
                         bActiveStates() As Boolean, _
                         nDatatypes() As Integer, _
                         sAccessPaths() As String, _
                         nItemHandles() As Long, _
                         nErrors() As Long) As Boolean
  Dim ServerObject As CServer

  AddItems = False

  ' Look up the server object in the server collection
  Set ServerObject = GetServer(GetServerHandleFromGroupHandle(nGroupHandle))
  If Not ServerObject Is Nothing Then
    AddItems = ServerObject.AddItems(nGroupHandle, nNumItems, sItemIDs, bActiveStates, nDatatypes, sAccessPaths, nItemHandles, nErrors)
    Set ServerObject = Nothing ' done with ServerObject - decrease its refcount
  End If

End Function
'
' RemoveItem
'
'   Parameters:
'     nItemHandle  In  Long  The handle of the item to be removed
'
'   Return Value:
'     Returns True if the item is removed.
'     Returns False if the item is not removed.
'
'   Remarks:
'     Removes the item identified by nItemHandle.
'
Public Function RemoveItem(ByVal nItemHandle As Long) As Boolean
  Dim ServerObject As CServer

  RemoveItem = False

  ' Look up the server object
  Set ServerObject = GetServer(GetServerHandleFromItemHandle(nItemHandle))
  If Not ServerObject Is Nothing Then
    RemoveItem = ServerObject.RemoveItem(nItemHandle)
    Set ServerObject = Nothing ' All done with ServerObject - decrease its refcount
  End If

End Function
'
' RemoveItems
'
'   Parameters:
'     nGroupHandle    In   Long               The group in which the items reside
'     nNumItems       In   Long               The number of items to remove
'     nItemHandles()  In   Array of Longs     The handle of each item
'     nErrors()       Out  Array of Longs     The error status of each item
'
'   Return Value:
'     Returns True if the RemoveItems call is performed.
'     Returns False if the server cannot be found, or if the serveris not connected,
'       or if the group cannot be found, or if there is an error removing, or if
'       the number of items to remove is <= 0, or if the number of item handles
'       does not match nNumItems.
'
'   Remarks:
'     ServerCollection::RemoveItems removes one or more items from the group
'     specified by nGroupHandle and identified in the nItemHandles array.
'     nErrors() should be declared as an empty array as the server allocates the
'     space for the returned values.
'
Public Function RemoveItems(ByVal nGroupHandle As Long, _
                            ByVal nNumItems As Long, _
                            nItemHandles() As Long, _
                            nErrors() As Long) As Boolean
  Dim ServerObject As CServer

  RemoveItems = False

  ' Look up the server object
  Set ServerObject = GetServer(GetServerHandleFromGroupHandle(nGroupHandle))
  If Not ServerObject Is Nothing Then
    RemoveItems = ServerObject.RemoveItems(nGroupHandle, nNumItems, nItemHandles, nErrors)
    Set ServerObject = Nothing ' All done with ServerObject - decrease its refcount
  End If

End Function
'
' GetItem
'
'   Parameters:
'     nItemHandle  In  Long  The handle of the item to be returned
'
'   Return Value:
'     Returns a reference to a CItem object if successful.
'     Reurns 'Nothing' if the item cannot be found.
'
'   Remarks:
'     Looks up the item object identified by nItemHandle.
'
Public Function GetItem(ByVal nItemHandle As Long) As CItem
  Dim ServerObject As CServer

  Set GetItem = Nothing

  ' Look up the server object in the server collection
  Set ServerObject = GetServer(GetServerHandleFromItemHandle(nItemHandle))
  If Not ServerObject Is Nothing Then
    Set GetItem = ServerObject.GetItem(nItemHandle)
    Set ServerObject = Nothing ' done with ServerObject - decrease its refcount
  End If

End Function
'
' ReadItem
'
'   Parameters:
'     nSource      In   Integer  The source of reading: Device or Cache
'     nItemHandle  In   Long     The handle of the item to be read
'     vValue       Out  Variant  The value of the item
'     nQuality     Out  Long     The quality of the item
'     TimeStamp    Out  Date     The timestamp of the item
'
'   Return Value:
'     Returns True if the item was successfully read.
'     Returns False if the item can not be found or there is an error reading,
'       or nSource is not Cache or Device.
'
'   Remarks:
'     ServerCollection::ReadItem attempts to read the value, quality and timestamp
'     of the specified item.
'
Public Function ReadItem(ByVal nSource As Integer, ByVal nItemHandle As Long, _
                         vValue As Variant, nQuality As Long, TimeStamp As Date) As Boolean
  Dim ServerObject As CServer

  ReadItem = False

  ' Look up the server object
  Set ServerObject = GetServer(GetServerHandleFromItemHandle(nItemHandle))
  If Not ServerObject Is Nothing Then
    ReadItem = ServerObject.ReadItem(nSource, nItemHandle, vValue, nQuality, TimeStamp)
    Set ServerObject = Nothing ' All done with ServerObject - decrease its refcount
  End If

End Function
'
' ReadItems
'
'   Parameters:
'     nSource         In   Integer            The source of reading: Device or Cache
'     nGroupHandle    In   Long               The group in which the items reside
'     nNumItems       In   Long               The number of items to be read
'     nItemHandles()  In   Array of Longs     The handle of each item
'     vItemValues()   Out  Array of Variants  The value of each item read
'     vQualities      Out  Variant            The quality of each item read
'     vTimeStamps     Out  Variant            The timestamp of each item read
'     nErrors()       Out  Array of Longs     The error status of each item
'
'   Return Value:
'     Returns True if the SyncRead call is performed.
'     Returns False if the server is not connected, or if the group cannot be
'       found, or if there is an error reading, or if the number of items to read
'       is <= 0, or if the source is not Cache or Device, or if the number of item
'       handles does not match nNumItems.
'
'   Remarks:
'     ServerCollection::ReadItems reads one or more items from a group either from
'     Cache or Device. The results are returned in the out parameters. The values
'     are an array of variants whereas the qualities are returned in a single variant
'     as are the timestamps. vItemValues() and nErrors() should be declared as empty
'     arrays as the server allocates the space for the returned values.
'
Public Function ReadItems(ByVal nSource As Integer, ByVal nGroupHandle As Long, _
                          ByVal nNumItems As Long, nItemHandles() As Long, _
                          vItemValues() As Variant, vQualities As Variant, _
                          vTimeStamps As Variant, nErrors() As Long) As Boolean
  Dim ServerObject As CServer

  ReadItems = False

  ' Look up the server object
  Set ServerObject = GetServer(GetServerHandleFromGroupHandle(nGroupHandle))
  If Not ServerObject Is Nothing Then
    ReadItems = ServerObject.ReadItems(nSource, nGroupHandle, nNumItems, nItemHandles, vItemValues, vQualities, vTimeStamps, nErrors)
    Set ServerObject = Nothing ' All done with ServerObject - decrease its refcount
  End If

End Function
'
' AsyncReadItems
'
'   Parameters:
'     nGroupHandle    In   Long            The group in which the items reside
'     nNumItems       In   Long            The number of items to be read
'     nItemHandles()  In   Array of Longs  The handle of each item
'     nTransactionID  In   Long            The transaction ID for this AsyncRead
'     nCancelID       Out  Long            The cancel ID generated by the server
'     nErrors()       Out  Array of Longs  The error status of each item
'
'   Return Value:
'     Returns True if the AsyncRead call is performed.
'     Returns False if the server is not connected, or if the group cannot be
'       found, or if there is an error performing the AsyncRead call, or if
'       nNumItems <= 0, or if nTransactionID = 0, or if the size of the item handles
'       array does not match the number of items to be read.
'
'   Remarks:
'     ServerCollection::AsyncReadItems converts the item handles into server handles
'     and performs an AsyncRead on the specified items in a group. The results of
'     this type of operation are returned later through a DataChange event in
'     ServerCollection::GlobalDataChange. The transaction ID passed in will
'     accompany the data in the GlobalDataChange event. nErrors() should be declared
'     as an empty array as the server allocates the space for the returned values.
'
Public Function AsyncReadItems(ByVal nGroupHandle As Long, ByVal nNumItems As Long, _
                               nItemHandles() As Long, ByVal nTransactionID As Long, _
                               nCancelID As Long, nErrors() As Long) As Boolean
  Dim ServerObject As CServer

  AsyncReadItems = False

  ' Look up the server object from the group handle
  Set ServerObject = GetServer(GetServerHandleFromGroupHandle(nGroupHandle))
  If Not ServerObject Is Nothing Then
    AsyncReadItems = ServerObject.AsyncReadItems(nGroupHandle, nNumItems, nItemHandles, nTransactionID, nCancelID, nErrors)
    Set ServerObject = Nothing ' All done with GroupObject - decrease its refcount
  End If

End Function
'
' WriteItem
'
'   Parameters:
'     nItemHandle  In  Long     The handle of the item to write to
'     vValue       In  Variant  The value to be written
'
'   Return Value:
'     Returns True if the item was written successfully.
'     Returns False if the server is not connected, or if the group cannot be
'       found, or if the item can not be found, or if the item does not have
'       WRITE access rights, or if there was an error writing.
'
'   Remarks:
'     ServerCollection::WriteItem attempts to write vValue to the specified item.
'
Public Function WriteItem(ByVal nItemHandle As Long, ByVal vValue As Variant) As Boolean
  Dim ServerObject As CServer

  WriteItem = False

  ' Look up the server object from the item handle
  Set ServerObject = GetServer(GetServerHandleFromItemHandle(nItemHandle))
  If Not ServerObject Is Nothing Then
    WriteItem = ServerObject.WriteItem(nItemHandle, vValue)
    Set ServerObject = Nothing ' All done with ServerObject - decrease its refcount
  End If

End Function
'
' WriteItems
'
'   Parameters:
'     nGroupHandle    In   Long               The group in which the items reside
'     nNumItems       In   Long               The number of items to be write
'     nItemHandles()  In   Array of Longs     The handle of each item
'     vItemValues()   In   Array of Variants  The value of each item
'     nErrors()       Out  Array of Longs     The error status of each item
'
'   Return Value:
'     Returns True if the SyncWrite call is performed.
'     Returns False if the server is not connected, or if the group cannot be
'       found, or if nNumItems <= 0 or if the size of the item handles array does
'       not match the number of items to be written or if the SyncWrite call failed.
'
'   Remarks:
'     ServerCollection::WriteItems converts the item handles into server handles and
'     issues a SyncWrite call on the OPC Group. The status of each write is stored
'     in the nErrors() out parameter. nErrors() should be declared as an empty array
'     as the server allocates the space for the returned values.
'
Public Function WriteItems(ByVal nGroupHandle As Long, ByVal nNumItems As Long, _
                           nItemHandles() As Long, vItemValues() As Variant, _
                           nErrors() As Long) As Boolean
  Dim ServerObject As CServer

  WriteItems = False

  ' Look up the server object from the item handle
  Set ServerObject = GetServer(GetServerHandleFromGroupHandle(nGroupHandle))
  If Not ServerObject Is Nothing Then
    WriteItems = ServerObject.WriteItems(nGroupHandle, nNumItems, nItemHandles, vItemValues, nErrors)
    Set ServerObject = Nothing ' All done with ServerObject - decrease its refcount
  End If

End Function
'
' AsyncWriteItems
'
'   Parameters:
'     nGroupHandle    In   Long               The group in which the items reside
'     nNumItems       In   Long               The number of items to write
'     nItemHandles()  In   Array of Longs     The handle of each item
'     vItemValues()   In   Array of Variants  The value of each item
'     nTransactionID  In   Long               The transaction ID for this AsyncWrite
'     nCancelID       Out  Long               The cancel ID generated by the server
'     nErrors()       Out  Array of Longs     The error status of each item
'
'   Return Value:
'     Returns True if the AsyncWrite call is performed.
'     Returns False if the server is not connected, or if the group cannot be
'       found, or if there was an error performing the AsyncWrite call, or if
'       nNumItems <= 0, or if nTransactionID = 0, or if the size of the item handles
'       array does not match the number of items to be written.
'
'   Remarks:
'     ServerCollection::AsyncWriteItems converts the item handles into server handles
'     and performs an AsyncWrite on the specified items in a group. The results of
'     this type of operation are returned later through a WriteComplete event in
'     ServerCollection::AsyncWriteComplete. The transaction ID passed in will
'     accompany the data in the AsyncWriteComplete event. nErrors() should be
'     declared as an empty array as the server allocates the space for the
'     returned values.
'
Public Function AsyncWriteItems(ByVal nGroupHandle As Long, ByVal nNumItems As Long, _
                                nItemHandles() As Long, vItemValues() As Variant, _
                                ByVal nTransactionID As Long, nCancelID As Long, _
                                nErrors() As Long) As Boolean
  Dim ServerObject As CServer

  AsyncWriteItems = False

  ' Look up the server object from the group handle
  Set ServerObject = GetServer(GetServerHandleFromGroupHandle(nGroupHandle))
  If Not ServerObject Is Nothing Then
    AsyncWriteItems = ServerObject.AsyncWriteItems(nGroupHandle, nNumItems, nItemHandles, vItemValues, nTransactionID, nCancelID, nErrors)
    Set ServerObject = Nothing ' All done with ServerObject - decrease its refcount
  End If

End Function
'
' AsyncRefresh
'
'   Parameters:
'     nGroupHandle    In   Long     The group in which the items reside
'     nSource         In   Integer  The source of reading: Device or Cache
'     nTransactionID  In   Long     The transaction ID for this AsyncWrite
'     nCancelID       Out  Long     The cancel ID generated by the server
'
'   Return Value:
'     Returns True if the AsyncRefresh call is performed.
'     Returns False if the server is not connected, or if the group cannot be
'       found, or if nSource is not Cache or Device, or if the transaction ID
'       is 0 or if there is an error in the AsyncRefresh call.
'
'   Remarks:
'     ServerCollection::AsyncRefresh causes the value, quality and timestamp of
'     each active item in the group to be returned in a DataChange event. The
'     results of this type of operation are returned later through a DataChange
'     event in ServerCollection::GlobalDataChange. The transaction ID passed in
'     will accompany the data in the GlobalDataChange event.
'
Public Function AsyncRefresh(ByVal nGroupHandle As Long, ByVal nSource As Integer, _
                             ByVal nTransactionID As Long, nCancelID As Long) As Boolean
  Dim ServerObject As CServer

  AsyncRefresh = False

  ' Look up the server object from the group handle
  Set ServerObject = GetServer(GetServerHandleFromGroupHandle(nGroupHandle))
  If Not ServerObject Is Nothing Then
    AsyncRefresh = ServerObject.AsyncRefresh(nGroupHandle, nSource, nTransactionID, nCancelID)
    Set ServerObject = Nothing ' All done with ServerObject - decrease its refcount
  End If

End Function
'
' AsyncCancel
'
'   Parameters:
'     nGroupHandle  In  Long  The group in which the items reside
'     nCancelID     In  Long  The cancel ID of the transaction to be canceled
'
'   Return Value:
'     Returns True if the AsyncCancel call is performed.
'     Returns False if the server is not connected, or if the group cannot be
'       found, or if the cancel ID is 0 or if there is an error in the
'       AsyncCancel call.
'
'   Remarks:
'     ServerCollection::AsyncCancel is called to attempt to cancel a previously
'     dispatched asynchronous transaction such as AsyncWriteItems, AsyncReadItems,
'     or AsyncRefresh. nCancelID is the cancel ID that was returned from one of
'     those functions.  The results of this type of operation are returned later
'     through a CancelComplete event in ServerCollection::AsyncCancelComplete.
'
Public Function AsyncCancel(ByVal nGroupHandle As Long, ByVal nCancelID As Long) As Boolean
  Dim ServerObject As CServer

  AsyncCancel = False

  ' Look up the server object from the group handle
  Set ServerObject = GetServer(GetServerHandleFromGroupHandle(nGroupHandle))
  If Not ServerObject Is Nothing Then
    AsyncCancel = ServerObject.AsyncCancel(nGroupHandle, nCancelID)
    Set ServerObject = Nothing ' All done with ServerObject - decrease its refcount
  End If

End Function
'
'
'
Public Function Add(Optional sKey As String) As CServer

  'create a new object
  Dim objNewMember As CServer
  Set objNewMember = New CServer

  'set the properties passed into the method
  If Len(sKey) = 0 Then
    mCol.Add objNewMember
  Else
    mCol.Add objNewMember, sKey
  End If

  ' Store a "pointer" to the ServerCollection in the ServerObject to implement trickle-up callbacks
  Set objNewMember.m_Parent = Me

  'return the object created
  Set Add = objNewMember
  Set objNewMember = Nothing

End Function
'
'
'
Public Property Get Item(vntIndexKey As Variant) As CServer
Attribute Item.VB_UserMemId = 0
  'used when referencing an element in the collection
  'vntIndexKey contains either the Index or Key to the collection,
  'this is why it is declared as a Variant
  'Syntax: Set foo = x.Item(xyz) or Set foo = x.Item(5)
  Set Item = mCol(vntIndexKey)
End Property
'
'
'
Public Property Get Count() As Long
  'used when retrieving the number of elements in the
  'collection. Syntax: Debug.Print x.Count
  Count = mCol.Count
End Property
'
'
'
Public Sub Remove(vntIndexKey As Variant)
  'used when removing an element from the collection
  'vntIndexKey contains either the Index or Key, which is why
  'it is declared as a Variant
  'Syntax: x.Remove(xyz)
  mCol.Remove vntIndexKey
End Sub
'
'
'
Public Property Get NewEnum() As IUnknown
  'this property allows you to enumerate
  'this collection with the For...Each syntax
  Set NewEnum = mCol.[_NewEnum]
End Property
'
'
'
Private Sub Class_Initialize()

  ' Creates the collection when this class is created
  Set mCol = New Collection

  ' Initialize the server handle counter
  m_NextServerHandle = 1

End Sub
'
'
'
Private Sub Class_Terminate()

  ' Destroys collection when this class is terminated
  Set mCol = Nothing

End Sub
