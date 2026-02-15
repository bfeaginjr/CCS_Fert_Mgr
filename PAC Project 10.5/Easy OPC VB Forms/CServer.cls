VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CServer"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
Option Explicit
Option Base 1

Public m_GroupCollection As GroupCollection
Public m_Handle As Long
Public m_Parent As ServerCollection

Private m_ServerForm As frmServer
Attribute m_ServerForm.VB_VarHelpID = -1
Private m_bConnected As Boolean

Public Event AsyncCancelComplete(ByVal nTransactionID As Long, ByVal nGroupHandle As Long)
Public Event AsyncWriteComplete(ByVal nTransactionID As Long, ByVal nGroupHandle As Long, ByVal nNumItems As Long, nItemHandles() As Long, nErrors() As Long)
Public Event GlobalDataChange(ByVal nTransactionID As Long, ByVal nGroupHandle As Long, ByVal nNumItems As Long, nItemHandles() As Long, vItemValues() As Variant, nQualities() As Long, TimeStamps() As Date)
Public Event ServerShuttingDown(sReason As String)
'
' DataChange
'
'   Parameters:
'     nTransactionID  In  Long               The ID of the asynchronous transaction
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
'     Part of the trickle-up callback system. CServer::DataChange is called
'     to pass along data obtained from an AsyncReadComplete Event in the group
'     form, or a GlobalDataChange Event in the server form. If the Server Object
'     has no parent, a GlobalDataChange Event is raised. Otherwise, the handle
'     of the Server Object is added to the DataChange trickle-up callback.
'
Public Sub DataChange(ByVal nTransactionID As Long, ByVal nGroupHandle As Long, _
                      ByVal nNumItems As Long, nItemHandles() As Long, _
                      vItemValues() As Variant, nQualities() As Long, _
                      TimeStamps() As Date)

  If m_bConnected Then
    If m_Parent Is Nothing Then
      ' If there is no parent, this object is not part of a collection so an event
      ' must be raised so the instantiator of the object can catch it.
      RaiseEvent GlobalDataChange(nTransactionID, nGroupHandle, nNumItems, nItemHandles, vItemValues, nQualities, TimeStamps)
    Else
      ' Add the server handle to the DataChange trickle-up callback
      m_Parent.DataChange nTransactionID, m_Handle, nGroupHandle, nNumItems, nItemHandles, vItemValues, nQualities, TimeStamps
    End If
  End If

End Sub
'
' Shutdown
'
'   Parameters:
'     sReason  In  String  The description of why the server is shutting down
'
'   Return Value:
'     None
'
'   Remarks:
'     Notifies that the OPC Server is shutting down. If the Server Object
'     has no parent, a ServerShuttingDown Event is raised. Otherwise, the handle
'     of the Server Object is added to the AServerIsShuttingDown trickle-up callback.
'
Public Sub Shutdown(sReason As String)

  If m_bConnected Then
    If m_Parent Is Nothing Then
      RaiseEvent ServerShuttingDown(sReason)
    Else
      m_Parent.AServerIsShuttingDown m_Handle, sReason
    End If
  End If

End Sub
'
' WriteComplete
'
'   Parameters:
'     nTransactionID  In  Long            The ID of the Async Write transaction
'     nGroupHandle    In  Long            The handle of the group that holds the items
'     nNumItems       In  Long            The number of items in the transaction
'     nItemHandles()  In  Array of Longs  The handle of each item
'     nErrors()       In  Array of Longs  The error status of each item
'
'   Return Value:
'     None
'
'   Remarks:
'     Part of the trickle-up callback system. CServer::WriteComplete is
'     called by GroupCollection::WriteComplete to pass along data obtained from an
'     AsyncWriteComplete Event. If the Server Object has no parent, an
'     AsyncWriteComplete Event is raised. Otherwise, the handle
'     of the Server Object is added to the WriteComplete trickle-up callback.
'
Public Sub WriteComplete(ByVal nTransactionID As Long, ByVal nGroupHandle As Long, _
                         ByVal nNumItems As Long, nItemHandles() As Long, _
                         nErrors() As Long)

  If m_bConnected Then
    If m_Parent Is Nothing Then
      ' If there is no parent, this object is not part of a collection so an event
      ' must be raised so the instantiator of the object can catch it.
      RaiseEvent AsyncWriteComplete(nTransactionID, nGroupHandle, nNumItems, nItemHandles, nErrors)
    Else
     ' Add the server handle to the WriteComplete trickle-up callback
      m_Parent.WriteComplete nTransactionID, m_Handle, nGroupHandle, nNumItems, nItemHandles, nErrors
    End If
  End If

End Sub
'
' CancelComplete
'
'   Parameters:
'     nTransactionID  In  Long  The ID of the transaction that was canceled
'     nGroupHandle    In  Long  The handle of the group where the transaction originated
'
'   Return Value:
'     None
'
'   Remarks:
'     Part of the trickle-up callback system. CServer::CancelComplete is
'     called by GroupCollection::CancelComplete to pass along data obtained from an
'     AsyncCancelComplete Event.  If the Server Object has no parent, an
'     AsyncCancelComplete Event is raised. Otherwise, the handle
'     of the Server Object is added to the CancelComplete trickle-up callback.
'
Public Sub CancelComplete(ByVal nTransactionID As Long, ByVal nGroupHandle As Long)

  If m_bConnected Then
    If m_Parent Is Nothing Then
      ' If there is no parent, this object is not part of a collection so an event
      ' must be raised so the instantiator of the object can catch it.
      RaiseEvent AsyncCancelComplete(nTransactionID, nGroupHandle)
    Else
     ' Add the server handle to the WriteComplete trickle-up callback
      m_Parent.CancelComplete nTransactionID, m_Handle, nGroupHandle
    End If
  End If

End Sub
'
' ConnectToServer
'
'   Parameters:
'     sServerProgID  In  String  The ProgID of the OPC Server to connect to
'     sNetworkNode   In  String  The machine name where the server is located
'
'   Return Value:
'     Returns 0 if successful, otherwise the value of the error code
'
'   Remarks:
'     Connects to the OPC Server specified in sServerProgID or starts it up if it
'     is not already running. If sNetworkNode is empty, the server will be accessed
'     locally. Otherwise it should specify a machine name on the local network.
'
Public Function ConnectToServer(ByVal sServerProgID As String, _
                                ByVal sNetworkNode As String) As Long

  ConnectToServer = 0

  If Len(sServerProgID) = 0 Then Exit Function
  
  If m_bConnected = True Then Exit Function

  ' Initialize the server form and the group collection
  Set m_ServerForm = New frmServer
  Load m_ServerForm
  Set m_GroupCollection = New GroupCollection

  ' Connect to the server
  On Error GoTo ConnectToServerErr:
  If Len(sNetworkNode) = 0 Then
    m_ServerForm.m_OPCServer.Connect sServerProgID
  Else
    m_ServerForm.m_OPCServer.Connect sServerProgID, sNetworkNode
  End If

  ' Store a reference to the ServerObject in the ServerForm to implement trickle-up callbacks
  Set m_ServerForm.m_Parent = Me
  ' Store a reference to the ServerObject in the GroupCollection to implement trickle-up callbacks
  Set m_GroupCollection.m_Parent = Me

  m_bConnected = True
  Exit Function

ConnectToServerErr:
  Set m_GroupCollection = Nothing
  Unload m_ServerForm
  Set m_ServerForm = Nothing
  Debug.Print "ConnectToServer Error = " & Err.Number & " " & Err.Description
  ConnectToServer = Err.Number
End Function
'
' DisconnectFromServer
'
'   Parameters:
'     None
'
'   Return Value:
'     Returns True if disconnection is successful.
'     Returns False if not successful.
'
'   Remarks:
'     In theory, we could just disconnect from the server and rely on it to clean
'     up after itself. However, this code will endeavor to be a good client and
'     remove all the groups and items before disconnecting from the server. So
'     here is a description of what happens as a result of the following calls.
'
'     RemoveGroup is called for each group in the group collection. This results
'     in the group object being destroyed. When the group object is destroyed, its
'     item collection is removed, then the group form (frmGroup) is released.
'     Releasing the group form makes all the OPC Items for that group be removed
'     from the server. Then the OPC Group is removed from the OPC group collection
'     which resides within the OPCServer Object within the server form (frmServer).
'     When all the groups in the group collection are removed, the group collection
'     is destroyed.
'
'     Then RemoveAll on the OPCGroupCollection in the server form is called, even
'     though all of the OPC groups should already have been removed. So at that
'     point the server should be clear of items and groups and we can safely
'     disconnect.
'
Public Function DisconnectFromServer() As Boolean
  Dim nIdx As Integer
  Dim nCount As Integer

  DisconnectFromServer = True

  If m_bConnected = True Then
    ' Empty the group collection and release it
    If Not m_GroupCollection Is Nothing Then
      nCount = m_GroupCollection.Count
      For nIdx = nCount To 1 Step -1
        RemoveGroup (m_GroupCollection.Item(nIdx).m_Handle)
      Next nIdx

      ' Discontinue the trickle-up callbacks in the GroupCollection
      If Not m_GroupCollection.m_Parent Is Nothing Then
        Set m_GroupCollection.m_Parent = Nothing
      End If
 
      Set m_GroupCollection = Nothing
    End If

    ' Disconnect from the OPC Server
    If Not m_ServerForm Is Nothing Then
      ' Discontinue the trickle-up callbacks in the server form
      If Not m_ServerForm.m_Parent Is Nothing Then
        Set m_ServerForm.m_Parent = Nothing
      End If

      ' Empty out the OPC Group collection (should not be necessary)
      If Not m_ServerForm.m_OpcGroupCollection Is Nothing Then
        m_ServerForm.m_OpcGroupCollection.RemoveAll
      End If

      ' Disconnect from the server
      If Not m_ServerForm.m_OPCServer Is Nothing Then
        On Error GoTo DisconnectFromServerErr:
        m_ServerForm.m_OPCServer.Disconnect
      End If

      ' Unload the server form and release it
      Unload m_ServerForm
      Set m_ServerForm = Nothing
    End If

    m_bConnected = False
  End If
  Exit Function

DisconnectFromServerErr:
  DisconnectFromServer = False
End Function
'
' DialogAddGroup
'
'   Parameters:
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
'     CServer::DialogAddGroup calls DialogCreateGroup to display the Add Group
'     dialog enabling the user to enter a group name, update rate, time bias,
'     deadband, active state and a data change method. These are all returned as
'     out parameters and are passed to CServer::AddGroup. The CGroup object that
'     is returned by DialogCreateGroup is discarded by setting it to nothing.
'     CServer::AddGroup will return a group handle if it is successful in adding
'     the group.
'
Public Function DialogAddGroup(sGroupName As String, nUpdateRate As Long, _
                               nTimeBias As Long, rDeadband As Single, _
                               bIsActive As Boolean, _
                               nDataChangeMethod As Integer) As Long
  Dim GroupObject As CGroup

  DialogAddGroup = 0

  If m_bConnected = True Then
    ' Call DialogCreateGroup to display the Add Group dialog. It will return a
    ' CGroup object which we do not need since the collection will create
    ' a CGroup object when AddGroup is called.
    Set GroupObject = DialogCreateGroup(sGroupName, nUpdateRate, nTimeBias, rDeadband, bIsActive, nDataChangeMethod)
    If Not GroupObject Is Nothing Then
      Set GroupObject = Nothing
      DialogAddGroup = AddGroup(sGroupName, nUpdateRate, nTimeBias, rDeadband, bIsActive, nDataChangeMethod)
    End If
  End If

End Function
'
' AddGroup
'
'   Parameters:
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
'     CServer::AddGroup adds a group to the OPC Server. If the group name passed in
'     is blank, the OPC Server will generate a name which is passed back out. If
'     the group is set up for continuous logging, callbacks from the server are
'     disabled and a refresh timer is started in the group form. Finally, a group
'     is added to the group collection where a group handle is assigned. This group
'     handle becomes the return value of this function.
'
Public Function AddGroup(sGroupName As String, nUpdateRate As Long, _
                         ByVal nTimeBias As Long, ByVal rDeadband As Single, _
                         ByVal bIsActive As Boolean, _
                         ByVal nDataChangeMethod As Integer) As Long

  AddGroup = 0

  If m_bConnected = True Then
    ' Set the default update rate, time bias, deadband, and active state
    m_ServerForm.m_OpcGroupCollection.DefaultGroupUpdateRate = nUpdateRate
    m_ServerForm.m_OpcGroupCollection.DefaultGroupTimeBias = nTimeBias
    m_ServerForm.m_OpcGroupCollection.DefaultGroupDeadband = rDeadband
    m_ServerForm.m_OpcGroupCollection.DefaultGroupIsActive = bIsActive

    ' Add a group to the OPC server
    Dim NewOPCGroup As OPCGroup
    Dim vGroupName As Variant
    Dim lGroupClientHandle As Long
    
    vGroupName = sGroupName
    On Error GoTo AddGroupErr
    Set NewOPCGroup = m_ServerForm.m_OpcGroupCollection.Add(vGroupName)

    ' If the user puts in a blank GroupName, the server will generate one
    ' so reset the group name after adding the group
    sGroupName = NewOPCGroup.Name

    ' Now subscribe to the OPC group to setup the callback mechanism
    NewOPCGroup.IsSubscribed = True

    ' For continuous logging, disable the sending of callbacks by the server.
    ' Data will be retrieved by the group form using an AsyncRefresh call which
    ' forces values to be returned for every active item in the group, not just
    ' the ones whose value has changed.
    If nDataChangeMethod = CONTINUOUS_LOGGING Then
      NewOPCGroup.AreCallbacksEnabled = False
    End If

    ' Add the group to the group collection, passing in the server handle
    lGroupClientHandle = m_GroupCollection.AddGroup(m_Handle, NewOPCGroup)
    
    ' Set the client handle for the group object - this handle will be returned
    ' in callbacks such as GlobalDataChange
    NewOPCGroup.ClientHandle = lGroupClientHandle

    AddGroup = lGroupClientHandle

    Set NewOPCGroup = Nothing ' done with NewOPCGroup - decrease its refcount
  End If
  Exit Function

AddGroupErr:
  If Err.Number = OPCUnsupportedRate Then
    On Error Resume Next
  End If
  AddGroup = Err.Number ' Errors will be negative numbers
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
'     CServer::DialogModifyGroup looks up a group object using the group handle
'     passed in. It then displays the Modify Group dialog filling in the fields
'     with the current values in the group object. If the user chooses OK in the
'     Modify Group dialog, the values from the fields are put into the group
'     object and this object is passed back to the user. If the user cancels out
'     of the Modify Group dialog, this function returns 'Nothing'.
'
Public Function DialogModifyGroup(ByVal nGroupHandle As Long) As CGroup
  Dim GroupObject As CGroup

  Set DialogModifyGroup = Nothing

  Set GroupObject = GetGroup(nGroupHandle)
  If Not GroupObject Is Nothing Then
    ' Initialize the fields of the AddGroup dialog
    Load frmAddGroup
    frmAddGroup.m_bAdding = False ' Modifying, not adding a group
    frmAddGroup.m_sGroupName = GroupObject.m_GroupForm.m_OPCGroup.Name
    frmAddGroup.m_nUpdateRate = GroupObject.m_GroupForm.m_OPCGroup.UpdateRate
    frmAddGroup.m_nTimeBias = GroupObject.m_GroupForm.m_OPCGroup.TimeBias
    frmAddGroup.m_rDeadband = GroupObject.m_GroupForm.m_OPCGroup.Deadband
    frmAddGroup.m_bIsActive = GroupObject.m_GroupForm.m_OPCGroup.IsActive
    frmAddGroup.m_bUseSubscriptions = GroupObject.m_GroupForm.m_OPCGroup.AreCallbacksEnabled
    
    ' Show the AddGroup dialog
    frmAddGroup.Show (1)

    If frmAddGroup.m_bOK Then
      ' Update the group object with the new settings
      GroupObject.UpdateRate = frmAddGroup.m_nUpdateRate
      GroupObject.TimeBias = frmAddGroup.m_nTimeBias
      GroupObject.Deadband = frmAddGroup.m_rDeadband
      GroupObject.IsActive = frmAddGroup.m_bIsActive
      If frmAddGroup.m_bUseSubscriptions = True Then
        GroupObject.DataChangeMethod = SUBSCRIPTION
      Else
        GroupObject.DataChangeMethod = CONTINUOUS_LOGGING
      End If

      Set DialogModifyGroup = GroupObject
    End If

    Unload frmAddGroup
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
'     CServer::RemoveGroup looks up the group object using the group handle passed
'     in and first removes the group from the group collection. It then unsubscribes
'     the group from the OPC Server and then removes the group from the OPC Server.
'
Public Function RemoveGroup(ByVal nGroupHandle As Long) As Boolean
  Dim GroupObject As CGroup
  Dim TheOpcGroup As OPCGroup
  Dim vGroupName As Variant

  RemoveGroup = False

  If m_bConnected = True Then
    ' Look up the group object
    Set GroupObject = GetGroup(nGroupHandle)
    If Not GroupObject Is Nothing Then
      ' Get the name of the OPC Group from the OPC Group object
      vGroupName = GroupObject.m_GroupForm.m_OPCGroup.Name
      Set GroupObject = Nothing ' All done with GroupObject - decrease its refcount

      ' Remove the group object from the group collection. This will remove the
      ' group form, the OPC items and the Item collection.
      m_GroupCollection.RemoveGroup (nGroupHandle)

      On Error GoTo RemoveGroupErr:
      
      ' Now unsubscribe the OPC group
      Set TheOpcGroup = m_ServerForm.m_OpcGroupCollection.Item(vGroupName)
      TheOpcGroup.IsSubscribed = False

      ' Remove the OPC group from the OPC Group collection that resides in the server form
      m_ServerForm.m_OpcGroupCollection.Remove vGroupName

      RemoveGroup = True
    End If
  End If
  Exit Function

RemoveGroupErr:
  Debug.Print "CServer::RemoveGroup Error = " & Err.Number & " " & Err.Description
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
'     CServer::GetGroup looks up the group using the group handle passed in and
'     returns a reference to a CGroup object.
'
Public Function GetGroup(ByVal nGroupHandle As Long) As CGroup
  Dim sGroupHandle As String
  Dim vKey As Variant

  Set GetGroup = Nothing

  If m_bConnected = True Then
    If m_GroupCollection.Count > 0 Then
      ' Convert the group handle to a string
      sGroupHandle = CStr(nGroupHandle)
      vKey = sGroupHandle

      ' Look up the group object
      Set GetGroup = m_GroupCollection.Item(vKey)
    End If
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
'     CServer::DialogAddItems takes a group handle as input, displays the Add Items
'     dialog and then calls AddItems with the values entered by the user in the
'     dialog. These values are passed back out of the dialog as out parameters so
'     they can be used appropriately in user interface or storage elements. The
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

  DialogAddItems = False

  If m_bConnected = True Then
   ' Display the AddItems Dialog Box
    Load frmAddItem
    Set frmAddItem.m_OPCServer = m_ServerForm.m_OPCServer
    frmAddItem.m_GroupName = GetGroup(nGroupHandle).GroupName
    frmAddItem.m_DialogWidth = nDialogWidth
    frmAddItem.m_DialogHeight = nDialogHeight
    frmAddItem.Show (1)

    If frmAddItem.m_bOK Then
      ' Redimension the output arrays and fill with information from the dialog
      nNumItems = UBound(frmAddItem.m_vItemIDs)
      ReDim sItemIDs(nNumItems)
      sItemIDs = frmAddItem.m_vItemIDs
      ReDim sAccessPaths(nNumItems)
      sAccessPaths = frmAddItem.m_vAccessPaths
      ReDim bActiveStates(nNumItems)
      bActiveStates = frmAddItem.m_vActiveStates
      ReDim nDatatypes(nNumItems)
      nDatatypes = frmAddItem.m_vDatatypes
      ReDim nItemHandles(nNumItems)

      DialogAddItems = AddItems(nGroupHandle, nNumItems, sItemIDs, bActiveStates, nDatatypes, sAccessPaths, nItemHandles, nErrors)
    End If

    ' Retrieve the dialog's final width and height
    If frmAddItem.WindowState = vbMaximized Then
      nDialogWidth = -1
      nDialogHeight = -1
    Else
      nDialogWidth = frmAddItem.Width
      nDialogHeight = frmAddItem.Height
    End If

    Unload frmAddItem
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
'     CServer::AddItems attempts to add the items specified in the In parameters to
'     the group specified by nGroupHandle. An item handle will be generated for each
'     item successfully added. The space for the nItemHandles array must be
'     allocated before calling this function whereas the nErrors array should be
'     declared as an empty array. The server will allocate the space for the
'     nErrors array.
'
Public Function AddItems(ByVal nGroupHandle As Long, ByVal nNumItems As Long, _
                         sItemIDs() As String, bActiveStates() As Boolean, _
                         nDatatypes() As Integer, sAccessPaths() As String, _
                         nItemHandles() As Long, nErrors() As Long) As Boolean
  Dim GroupObject As CGroup

  AddItems = False

  If m_bConnected = True Then
    ' Look up the group object
    Set GroupObject = GetGroup(nGroupHandle)
    If Not GroupObject Is Nothing Then
      AddItems = GroupObject.AddItems(nNumItems, sItemIDs, bActiveStates, nDatatypes, sAccessPaths, nItemHandles, nErrors)
      Set GroupObject = Nothing ' All done with GroupObject - decrease its refcount
    End If
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
  Dim GroupObject As CGroup

  RemoveItem = False

  If m_bConnected = True Then
    ' Look up the group object
    Set GroupObject = GetGroup(GetGroupHandleFromItemHandle(nItemHandle))
    If Not GroupObject Is Nothing Then
      RemoveItem = GroupObject.RemoveItem(nItemHandle)
      Set GroupObject = Nothing ' All done with GroupObject - decrease its refcount
    End If
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
'     Returns False if the server is not connected, or if the group cannot be
'       found, or if there is an error removing, or if the number of items to
'       remove is <= 0, or if the number of item handles does not match nNumItems.
'
'   Remarks:
'     CServer::RemoveItems removes one or more items from the group
'     specified by nGroupHandle and identified in the nItemHandles array.
'     nErrors() should be declared as an empty array as the server allocates the
'     space for the returned values.
'
Public Function RemoveItems(ByVal nGroupHandle As Long, _
                            ByVal nNumItems As Long, _
                            nItemHandles() As Long, _
                            nErrors() As Long) As Boolean
  Dim GroupObject As CGroup

  RemoveItems = False

  If m_bConnected = True Then
    ' Look up the group object
    Set GroupObject = GetGroup(nGroupHandle)
    If Not GroupObject Is Nothing Then
      RemoveItems = GroupObject.RemoveItems(nNumItems, nItemHandles, nErrors)
      Set GroupObject = Nothing ' All done with GroupObject - decrease its refcount
    End If
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
  Dim GroupObject As CGroup

  Set GetItem = Nothing

  ' Look up the group object in the Group collection
  Set GroupObject = GetGroup(GetGroupHandleFromItemHandle(nItemHandle))
  If Not GroupObject Is Nothing Then
    Set GetItem = GroupObject.GetItem(nItemHandle)
    Set GroupObject = Nothing ' All done with GroupObject - decrease its refcount
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
'     CServer::ReadItem attempts to read the value, quality and timestamp of the
'     specified item.
'
Public Function ReadItem(ByVal nSource As Integer, ByVal nItemHandle As Long, _
                         vValue As Variant, nQuality As Long, _
                         TimeStamp As Date) As Boolean
  Dim GroupObject As CGroup

  ReadItem = False

  If m_bConnected = True Then
    ' Look up the group object
    Set GroupObject = GetGroup(GetGroupHandleFromItemHandle(nItemHandle))
    If Not GroupObject Is Nothing Then
      ReadItem = GroupObject.ReadItem(nSource, nItemHandle, vValue, nQuality, TimeStamp)
      Set GroupObject = Nothing ' All done with GroupObject - decrease its refcount
    End If
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
'     CServer::ReadItems reads one or more items from a group either from Cache or
'     Device. The results are returned in the out parameters. The values are an
'     array of variants whereas the qualities are returned in a single variant as
'     are the timestamps. vItemValues() and nErrors() should be declared as empty
'     arrays as the server allocates the space for the returned values.
'
Public Function ReadItems(ByVal nSource As Integer, ByVal nGroupHandle As Long, _
                          ByVal nNumItems As Long, nItemHandles() As Long, _
                          vItemValues() As Variant, vQualities As Variant, _
                          vTimeStamps As Variant, nErrors() As Long) As Boolean
  Dim GroupObject As CGroup

  ReadItems = False

  If m_bConnected = True Then
    ' Look up the group object
    Set GroupObject = GetGroup(nGroupHandle)
    If Not GroupObject Is Nothing Then
      ReadItems = GroupObject.ReadItems(nSource, nNumItems, nItemHandles, vItemValues, vQualities, vTimeStamps, nErrors)
      Set GroupObject = Nothing ' All done with GroupObject - decrease its refcount
    End If
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
'     CServer::AsyncReadItems converts the item handles into server handles and
'     performs an AsyncRead on the specified items in a group. The results of
'     this type of operation are returned later through a DataChange event in
'     either CServer::GlobalDataChange or ServerCollection::GlobalDataChange. For
'     both of these, the transaction ID passed in will accompany the data in the
'     GlobalDataChange event. nErrors() should be declared as an empty array as
'     the server allocates the space for the returned values.
'
Public Function AsyncReadItems(ByVal nGroupHandle As Long, ByVal nNumItems As Long, _
                               nItemHandles() As Long, ByVal nTransactionID As Long, _
                               nCancelID As Long, nErrors() As Long) As Boolean
  Dim GroupObject As CGroup

  AsyncReadItems = False

  If m_bConnected = True Then
    ' Look up the group object
    Set GroupObject = GetGroup(nGroupHandle)
    If Not GroupObject Is Nothing Then
      AsyncReadItems = GroupObject.AsyncReadItems(nNumItems, nItemHandles, nTransactionID, nCancelID, nErrors)
      Set GroupObject = Nothing ' All done with GroupObject - decrease its refcount
    End If
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
'     CServer::WriteItem attempts to write vValue to the specified item.
'
Public Function WriteItem(ByVal nItemHandle As Long, ByVal vValue As Variant) As Boolean
  Dim GroupObject As CGroup

  WriteItem = False

  If m_bConnected = True Then
    ' Look up the group object
    Set GroupObject = GetGroup(GetGroupHandleFromItemHandle(nItemHandle))
    If Not GroupObject Is Nothing Then
      WriteItem = GroupObject.WriteItem(nItemHandle, vValue)
      Set GroupObject = Nothing ' All done with GroupObject - decrease its refcount
    End If
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
'     CServer::WriteItems converts the item handles into server handles and issues
'     a SyncWrite call on the OPC Group. The status of each write is stored in the
'     nErrors() out parameter. nErrors() should be declared as an empty array as
'     the server allocates the space for the returned values.
'
Public Function WriteItems(ByVal nGroupHandle As Long, ByVal nNumItems As Long, _
                           nItemHandles() As Long, vItemValues() As Variant, _
                           nErrors() As Long) As Boolean
  Dim GroupObject As CGroup

  WriteItems = False

  If m_bConnected = True Then
    ' Look up the group object
    Set GroupObject = GetGroup(nGroupHandle)
    If Not GroupObject Is Nothing Then
      WriteItems = GroupObject.WriteItems(nNumItems, nItemHandles, vItemValues, nErrors)
      Set GroupObject = Nothing ' All done with GroupObject - decrease its refcount
    End If
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
'     CServer::AsyncWriteItems converts the item handles into server handles and
'     performs an AsyncWrite on the specified items in a group. The results of
'     this type of operation are returned later through a WriteComplete event in
'     either CServer::AsyncWriteComplete or ServerCollection::AsyncWriteComplete.
'     For both of these, the transaction ID passed in will accompany the data in
'     the AsyncWriteComplete event. nErrors() should be declared as an empty array
'     as the server allocates the space for the returned values.
'
Public Function AsyncWriteItems(ByVal nGroupHandle As Long, ByVal nNumItems As Long, _
                                nItemHandles() As Long, vItemValues() As Variant, _
                                ByVal nTransactionID As Long, nCancelID As Long, _
                                nErrors() As Long) As Boolean
  Dim GroupObject As CGroup

  AsyncWriteItems = False

  If m_bConnected = True Then
    ' Look up the group object
    Set GroupObject = GetGroup(nGroupHandle)
    If Not GroupObject Is Nothing Then
      AsyncWriteItems = GroupObject.AsyncWriteItems(nNumItems, nItemHandles, vItemValues, nTransactionID, nCancelID, nErrors)
      Set GroupObject = Nothing ' All done with GroupObject - decrease its refcount
    End If
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
'     CServer::AsyncRefresh causes the value, quality and timestamp of each active
'     item in the group to be returned in a DataChange event. The results of
'     this type of operation are returned later through a DataChange event in
'     either CServer::GlobalDataChange or ServerCollection::GlobalDataChange. For
'     both of these, the transaction ID passed in will accompany the data in the
'     GlobalDataChange event.
'
Public Function AsyncRefresh(ByVal nGroupHandle As Long, _
                             ByVal nSource As Integer, _
                             ByVal nTransactionID As Long, _
                             nCancelID As Long) As Boolean
  Dim GroupObject As CGroup

  AsyncRefresh = False

  If m_bConnected = True Then
    ' Look up the group object
    Set GroupObject = GetGroup(nGroupHandle)
    If Not GroupObject Is Nothing Then
      AsyncRefresh = GroupObject.AsyncRefresh(nSource, nTransactionID, nCancelID)
      Set GroupObject = Nothing ' All done with GroupObject - decrease its refcount
    End If
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
'     CServer::AsyncCancel is called to attempt to cancel a previously dispatched
'     asynchronous transaction such as AsyncWriteItems, AsyncReadItems, or
'     AsyncRefresh. nCancelID is the cancel ID that was returned from one of those
'     functions.  The results of this type of operation are returned later through
'     a CancelComplete event in either CServer::AsyncCancelComplete or
'     ServerCollection::AsyncCancelComplete.
'
Public Function AsyncCancel(ByVal nGroupHandle As Long, _
                            ByVal nCancelID As Long) As Boolean
  Dim GroupObject As CGroup

  AsyncCancel = False

  If m_bConnected = True Then
    ' Look up the group object
    Set GroupObject = GetGroup(nGroupHandle)
    If Not GroupObject Is Nothing Then
      AsyncCancel = GroupObject.AsyncCancel(nCancelID)
      Set GroupObject = Nothing ' All done with GroupObject - decrease its refcount
    End If
  End If

End Function
'
' Class_Initialize
'
Private Sub Class_Initialize()

  WriteToLogFile ("CServer::Initialize")

  m_bConnected = False
  m_Handle = 0
  Set m_Parent = Nothing

  Set m_ServerForm = Nothing
  Set m_GroupCollection = Nothing

End Sub
'
' Class_Terminate
'
Private Sub Class_Terminate()
  Debug.Print ("~CServer Start")

  WriteToLogFile ("CServer::Terminate")
  
  Debug.Print ("~CServer End")
  
End Sub
