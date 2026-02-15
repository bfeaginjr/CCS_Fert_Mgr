VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CGroup"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
Option Explicit
Option Base 1

Public m_ItemCollection As ItemCollection
Public m_Handle As Long
Public m_Parent As GroupCollection

Public m_GroupForm As frmGroup

Private m_NextItemHandle As Long
Private m_nDataChangeMethod As Integer
'
' DataChange
'
'   Parameters:
'     nTransactionID  In  Long               The ID of the asynchronous transaction
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
'     Part of the trickle-up callback system. CGroup::DataChange is called by any
'     object that CGroup contains. The Group form calls this function when it has
'     data obtained from an AsyncReadComplete Event.
'
Public Sub DataChange(ByVal nTransactionID As Long, ByVal nNumItems As Long, _
                      nItemHandles() As Long, vItemValues() As Variant, _
                      nQualities() As Long, TimeStamps() As Date)

  ' Add the group handle to the DataChange trickle-up callback
  If Not m_Parent Is Nothing Then
    m_Parent.DataChange nTransactionID, m_Handle, nNumItems, nItemHandles, vItemValues, nQualities, TimeStamps
  End If

End Sub
'
' WriteComplete
'
'   Parameters:
'     nTransactionID  In  Long            The ID of the Async Write transaction
'     nNumItems       In  Long            The number of items in the transaction
'     nItemHandles()  In  Array of Longs  The handle of each item
'     nErrors()       In  Array of Longs  The error status of each item
'
'   Return Value:
'     None
'
'   Remarks:
'     Part of the trickle-up callback system. CGroup::WriteComplete is called by any
'     object that CGroup contains. The Group form calls this function when it has
'     data obtained from an AsyncWriteComplete Event.
'
Public Sub WriteComplete(ByVal nTransactionID As Long, ByVal nNumItems As Long, _
                         nItemHandles() As Long, nErrors() As Long)

  ' Add the group handle to the WriteComplete trickle-up callback
  If Not m_Parent Is Nothing Then
    m_Parent.WriteComplete nTransactionID, m_Handle, nNumItems, nItemHandles, nErrors
  End If

End Sub
'
' CancelComplete
'
'   Parameters:
'     nTransactionID  In  Long  The ID of the transaction that was canceled.
'
'   Return Value:
'     None
'
'   Remarks:
'     Part of the trickle-up callback system. CGroup::CancelComplete is called by any
'     object that CGroup contains. The Group form calls this function when it has
'     data obtained from an AsyncCancelComplete Event.
'
Public Sub CancelComplete(ByVal nTransactionID As Long)

  ' Add the group handle to the CancelComplete trickle-up callback
  If Not m_Parent Is Nothing Then
    m_Parent.CancelComplete nTransactionID, m_Handle
  End If

End Sub
'
' AddItems
'
'   Parameters:
'     nNumItems       In   Long               The number of items to add
'     sItemIDs()      In   Array of Strings   The ItemID for each item
'     bActiveStates() In   Array of Boolean   The state for each item
'     nDatatypes()    In   Array of Integers  The requested datatype for each item
'     sAccessPaths()  In   Array of Strings   The access path for each item
'     nItemHandles()  Out  Array of Longs     The assigned handle for each item
'     nErrors()       Out  Array of Longs     The error status for each item
'
'   Return Value:
'     Returns True if all of the items are added successfully.
'     Returns False if the maximum number of items is exceeded, or if one or more
'       of the items is not added successfully.
'
'   Remarks:
'     Assigns a handle to each item and attempts to add the items to the OPC server.
'     The items are initially added as inactive, and only after the adding of each
'     item is verified does the item's state get set. The generated item handle and
'     error status of each item is returned in the out parameters. The space for the
'     nItemHandles array must be allocated before calling this function whereas the
'     nErrors array should be declared as an empty array. The server will allocate
'     the space for the nErrors array.
'
Public Function AddItems(ByVal nNumItems As Long, sItemIDs() As String, _
                         bActiveStates() As Boolean, nDatatypes() As Integer, _
                         sAccessPaths() As String, nItemHandles() As Long, _
                         nErrors() As Long) As Boolean
  Dim i As Integer
  Dim ItemObject As CItem
  Dim sItemHandle As String

  AddItems = True

  ' Assign item handles for the new items
  For i = 1 To nNumItems
    ' Embed the group handle in the upper word of each item handle. This means that
    ' there will be a limit of 65535 (FFFF) items per group.
    nItemHandles(i) = (m_Handle * 65536) + m_NextItemHandle
    m_NextItemHandle = m_NextItemHandle + 1

    ' Check for maximum items
    If m_NextItemHandle > 65535 Then
      AddItems = False
      Exit Function
    End If
  Next

  ' Declare an array to hold the server handles passed back from OPCItems.AddItems
  Dim nServerHandles() As Long
  ReDim nServerHandles(nNumItems)

  ' Add the items to the OPC Group
  '
  '   The AddItems call requires variants for Access Paths and Datatypes
  Dim vDatatypes As Variant
  Dim vAccessPaths As Variant
  vDatatypes = nDatatypes
  vAccessPaths = sAccessPaths

  '  Set the default active state to false. When each item added is verified
  '  its state will be set to whatever it should be.
  m_GroupForm.m_OPCGroup.OPCItems.DefaultIsActive = False

  '  Add the items
  On Error GoTo AddItemsErr:
  m_GroupForm.m_OPCGroup.OPCItems.AddItems nNumItems, sItemIDs, nItemHandles, nServerHandles, nErrors, vDatatypes, vAccessPaths

  ' Some items might have failed, so go through the error array to determine
  ' which ones to add to the internal list of items
  Dim TheOPCItem As OPCItem
  Dim nNumItemsAdded As Integer
  nNumItemsAdded = 0
  For i = LBound(nErrors) To UBound(nErrors)
    If nErrors(i) = 0 Then
      nNumItemsAdded = nNumItemsAdded + 1

      ' Add the item object to the item collection
      sItemHandle = CStr(nItemHandles(i))
      Set ItemObject = m_ItemCollection.Add(sItemHandle)

      ' Assign the item handle and server handle to the item object
      ItemObject.m_Handle = nItemHandles(i)
      ItemObject.m_nServerHandle = nServerHandles(i)

      ' Keep a copy of the OPC Item in the item object
      Set TheOPCItem = m_GroupForm.m_OPCGroup.OPCItems.GetOPCItem(nServerHandles(i))
      Set ItemObject.m_OPCItem = TheOPCItem

      Set ItemObject = Nothing ' All done with ItemObject - decrease its refcount

      ' Activate only the items that are set to active (make as few calls as
      ' possible to reduce the number of round trips)
      If bActiveStates(i) = True Then
        TheOPCItem.IsActive = bActiveStates(i)
      End If

      ' Set the client handle for the OPC Item
      TheOPCItem.ClientHandle = nItemHandles(i)

      Set TheOPCItem = Nothing ' all done with the OPC Item - decrease its refcount
    Else
      ' Return False if any of the items failed
      AddItems = False
    End If
  Next

  If nNumItemsAdded > 0 Then
    If m_GroupForm.m_Parent Is Nothing Then
      ' Store a "pointer" to the GroupObject in the GroupForm to implement trickle-up callbacks
      Set m_GroupForm.m_Parent = Me
    End If
  End If
  Exit Function

AddItemsErr:
  AddItems = False
  Debug.Print "CGroup::AddItems Error = " & Err.Number
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
  Dim ItemObject As CItem
  Dim vKey As Variant
  Dim nNumItems As Long
  Dim nServerItemHandles(1) As Long
  Dim nErrors() As Long ' The server allocates the storage for the errors

  RemoveItem = False

  ' Look up the item object in the item collection
  vKey = CStr(nItemHandle)
  Set ItemObject = m_ItemCollection.Item(vKey)

  If Not ItemObject Is Nothing Then
    ' Remove the OPC Item
    On Error GoTo RemoveItemErr:
    nNumItems = 1
    nServerItemHandles(1) = ItemObject.m_nServerHandle
    m_GroupForm.m_OPCGroup.OPCItems.Remove nNumItems, nServerItemHandles, nErrors

    If nErrors(1) = 0 Then
      ' Remove the item from the item collection
      m_ItemCollection.Remove (vKey)

      ' Set the return value for the function
      RemoveItem = True
    End If

    Set ItemObject = Nothing ' All done with ItemObject - decrease its refcount
  End If
  Exit Function

RemoveItemErr:
  Set ItemObject = Nothing
  Debug.Print "CGroup::RemoveItem Error = " & Err.Number
End Function
'
' RemoveItems
'
'   Parameters:
'     nNumItems       In   Long               The number of items to remove
'     nItemHandles()  In   Array of Longs     The handle of each item
'     nErrors()       Out  Array of Longs     The error status of each item
'
'   Return Value:
'     Returns True if the RemoveItems call is performed.
'     Returns False if there is an error removing, or if the number of items to
'       remove is <= 0, or if the number of item handles does not match nNumItems.
'
'   Remarks:
'     CGroup::RemoveItems removes the items identified in the nItemHandles array.
'     nErrors() should be declared as an empty array as the server allocates the
'     space for the returned values.
'
Public Function RemoveItems(ByVal nNumItems As Long, _
                            nItemHandles() As Long, _
                            nErrors() As Long) As Boolean
  Dim vKey As Variant
  Dim nServerHandles() As Long
  Dim i As Integer

  RemoveItems = False

  ' Check the input parameters
  If nNumItems <= 0 Then
    Exit Function
  End If
  If UBound(nItemHandles) <> nNumItems Then
    Exit Function
  End If

  ' Turn the item handles into server handles
  ReDim nServerHandles(nNumItems)
  For i = 1 To nNumItems
    nServerHandles(i) = GetItem(nItemHandles(i)).m_nServerHandle
  Next

  ' Issue the Remove call on the OPC Items collection
  On Error GoTo RemoveItemsErr:
  m_GroupForm.m_OPCGroup.OPCItems.Remove nNumItems, nServerHandles, nErrors

  ' Remove the items from the item collection one at a time if it was
  ' successfully removed from the OPC Items collection
  RemoveItems = True
  For i = 1 To nNumItems
    If nErrors(i) = 0 Then
      ' Look up the item object in the item collection
      vKey = CStr(nItemHandles(i))
      m_ItemCollection.Remove (vKey)
    Else
      RemoveItems = False
    End If
  Next

  Exit Function

RemoveItemsErr:
  Debug.Print "CGroup::RemoveItems Error = " & Err.Number
End Function

'
' GetItem
'
'   Parameters:
'     nItemHandle  In  Long  The handle of the item to be returned
'
'   Return Value:
'     Returns a CItem object if successful.
'     Reurns Nothing if the item cannot be found.
'
'   Remarks:
'     Looks up the item object identified by nItemHandle.
'
Public Function GetItem(ByVal nItemHandle As Long) As CItem
  Dim sItemHandle As String
  Dim vKey As Variant

  Set GetItem = Nothing

  If m_ItemCollection.Count > 0 Then
    ' Convert the item handle to a string
    sItemHandle = CStr(nItemHandle)
    vKey = sItemHandle

    ' Look up the item object
    Set GetItem = m_ItemCollection.Item(vKey)
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
'     Returns True if the item is successfully read.
'     Returns False if the item can not be found or there is an error reading,
'       or nSource is not Cache or Device.
'
'   Remarks:
'     CGroup::ReadItem attempts to read the value, quality and timestamp of the
'     specified item.
'
Public Function ReadItem(ByVal nSource As Integer, ByVal nItemHandle As Long, _
                         vValue As Variant, nQuality As Long, _
                         TimeStamp As Date) As Boolean
  Dim ItemObject As CItem

  ReadItem = False

  Set ItemObject = GetItem(nItemHandle)
  If Not ItemObject Is Nothing Then
    ' Read the item and store the returned values
    ReadItem = ItemObject.ReadItem(nSource, vValue, nQuality, TimeStamp)
    Set ItemObject = Nothing ' All done with ItemObject - decrease its refcount
  End If

End Function
'
' ReadItems
'
'   Parameters:
'     nSource         In   Integer            The source of reading: Device or Cache
'     nNumItems       In   Long               The number of items to be read
'     nItemHandles()  In   Array of Longs     The handle of each item
'     vItemValues()   Out  Array of Variants  The value of each item read
'     vQualities      Out  Variant            The quality of each item read
'     vTimeStamps     Out  Variant            The timestamp of each item read
'     nErrors()       Out  Array of Longs     The error status of each item
'
'   Return Value:
'     Returns True if the SyncRead call is performed.
'     Returns False if there is an error reading, or if the number of items to read
'       is <= 0, or if the source is not Cache or Device, or if the number of item
'       handles does not match nNumItems.
'
'   Remarks:
'     CGroup::ReadItems reads one or more items from a group either from Cache or
'     Device. The results are returned in the out parameters. The values are an
'     array of variants whereas the qualities are returned in a single variant as
'     are the timestamps. vItemValues() and nErrors() should be declared as empty
'     arrays as the server allocates the space for the returned values.
'
Public Function ReadItems(ByVal nSource As Integer, ByVal nNumItems As Long, _
                          nItemHandles() As Long, vItemValues() As Variant, _
                          vQualities As Variant, vTimeStamps As Variant, _
                          nErrors() As Long) As Boolean
  Dim nServerHandles() As Long
  Dim i As Integer

  ReadItems = False

  ' Check the input parameters
  If nSource = OPCDataSource.OPCCache And nSource <> OPCDataSource.OPCDevice Then
    Exit Function
  End If
  If nNumItems <= 0 Then
    Exit Function
  End If
  If UBound(nItemHandles) <> nNumItems Then
    Exit Function
  End If

  ' Turn the item handles into server handles
  ReDim nServerHandles(nNumItems)
  For i = 1 To nNumItems
    nServerHandles(i) = GetItem(nItemHandles(i)).m_nServerHandle
  Next

  ' Issue the SyncRead call on the OPC Group
  On Error GoTo ReadItemsErr:
  m_GroupForm.m_OPCGroup.SyncRead nSource, nNumItems, nServerHandles, vItemValues, nErrors, vQualities, vTimeStamps

  ReadItems = True
  Exit Function

ReadItemsErr:
  Debug.Print "CGroup::ReadItems Error = " & Err.Number
End Function
'
' AsyncReadItems
'
'   Parameters:
'     nNumItems       In   Long               The number of items to be read
'     nItemHandles()  In   Array of Longs     The handle of each item
'     nTransactionID  In   Long               The transaction ID for this AsyncRead
'     nCancelID       Out  Long               The cancel ID generated by the server
'     nErrors()       Out  Array of Longs     The error status of each item
'
'   Return Value:
'     Returns True if the AsyncRead call is performed.
'     Returns False if there is an error performing the AsyncRead call, or if
'       nNumItems <= 0, or if nTransactionID = 0, or if the size of the item handles
'       array does not match the number of items to be read.
'
'   Remarks:
'     CGroup::AsyncReadItems converts the item handles into server handles and
'     performs an AsyncRead on the specified items in a group. The results of
'     this type of operation are returned later through a DataChange event in
'     either CServer::GlobalDataChange or ServerCollection::GlobalDataChange. For
'     both of these, the transaction ID passed in will accompany the data in the
'     GlobalDataChange event. nErrors() should be declared as an empty array as
'     the server allocates the space for the returned values.
'
Public Function AsyncReadItems(ByVal nNumItems As Long, nItemHandles() As Long, _
                               ByVal nTransactionID As Long, nCancelID As Long, _
                               nErrors() As Long) As Boolean
  Dim nServerHandles() As Long
  Dim i As Integer

  AsyncReadItems = False

  If nNumItems <= 0 Then
    Exit Function
  End If
  If UBound(nItemHandles) <> nNumItems Then
    Exit Function
  End If
  If nTransactionID = 0 Then
    Exit Function
  End If

  ' Turn the item handles into server handles
  ReDim nServerHandles(nNumItems)
  For i = 1 To nNumItems
    nServerHandles(i) = GetItem(nItemHandles(i)).m_nServerHandle
  Next

  ' Issue the AsyncRead call on the OPC Group
  On Error GoTo AsyncReadItemsErr:
  m_GroupForm.m_OPCGroup.AsyncRead nNumItems, nServerHandles, nErrors, nTransactionID, nCancelID
  AsyncReadItems = True
  Exit Function

AsyncReadItemsErr:
  Debug.Print "CGroup::AsyncReadItems Error = " & Err.Number
End Function
'
' WriteItem
'
'   Parameters:
'     nItemHandle  In  Long     The handle of the item to write to
'     vValue       In  Variant  The value to be written
'
'   Return Value:
'     Returns True if the item wass written successfully.
'     Returns False if the item can not be found, or if the item does not have
'       WRITE access rights, or if there was an error writing.
'
'   Remarks:
'     CGroup::WriteItem attempts to write vValue to the specified item.
'
Public Function WriteItem(ByVal nItemHandle As Long, ByVal vValue As Variant) As Boolean
  Dim ItemObject As CItem

  WriteItem = False

  Set ItemObject = GetItem(nItemHandle)
  If Not ItemObject Is Nothing Then
    WriteItem = ItemObject.WriteItem(vValue)
    Set ItemObject = Nothing ' All done with ItemObject - decrease its refcount
  End If

End Function
'
' WriteItems
'
'   Parameters:
'     nNumItems       In   Long               The number of items to write
'     nItemHandles()  In   Array of Longs     The handle of each item
'     vItemValues()   In   Array of Variants  The value of each item
'     nErrors()       Out  Array of Longs     The error status of each item
'
'   Return Value:
'     Returns True if the SyncWrite call is performed.
'     Returns False if nNumItems <= 0 or if the size of the item handles array does
'       not match the number of items to be written or if the SyncWrite call failed.
'
'   Remarks:
'     CGroup::WriteItems converts the item handles into server handles and issues
'     a SyncWrite call on the OPC Group. The status of each write is stored in the
'     nErrors() out parameter. nErrors() should be declared as an empty array as
'     the server allocates the space for the returned values.
'
Public Function WriteItems(ByVal nNumItems As Long, nItemHandles() As Long, _
                           vItemValues() As Variant, nErrors() As Long) As Boolean
  Dim nServerHandles() As Long
  Dim i As Integer

  WriteItems = False

  ' Check the input parameters
  If nNumItems <= 0 Then
    Exit Function
  End If
  If UBound(nItemHandles) <> nNumItems Then
    Exit Function
  End If

  ' Turn the item handles into server handles
  ReDim nServerHandles(nNumItems)
  For i = 1 To nNumItems
    nServerHandles(i) = GetItem(nItemHandles(i)).m_nServerHandle
  Next

  ' Issue the SyncWrite call on the OPC Group
  On Error GoTo WriteItemsErr:
  m_GroupForm.m_OPCGroup.SyncWrite nNumItems, nServerHandles, vItemValues, nErrors

  WriteItems = True
  Exit Function

WriteItemsErr:
  Debug.Print "CGroup::WriteItems Error = " & Err.Number
End Function
'
' AsyncWriteItems
'
'   Parameters:
'     nNumItems       In   Long               The number of items to write
'     nItemHandles()  In   Array of Longs     The handle of each item
'     vItemValues()   In   Array of Variants  The value of each item
'     nTransactionID  In   Long               The transaction ID for this AsyncWrite
'     nCancelID       Out  Long               The cancel ID generated by the server
'     nErrors()       Out  Array of Longs     The error status of each item
'
'   Return Value:
'     Returns True if the AsyncWrite call is performed.
'     Returns False if there was an error performing the AsyncWrite call, or if
'       nNumItems <= 0, or if nTransactionID = 0, or if the size of the item handles
'       array does not match the number of items to be written.
'
'   Remarks:
'     CGroup::AsyncWriteItems converts the item handles into server handles and
'     performs an AsyncWrite on the specified items in a group. The results of
'     this type of operation are returned later through a WriteComplete event in
'     either CServer::AsyncWriteComplete or ServerCollection::AsyncWriteComplete.
'     For both of these, the transaction ID passed in will accompany the data in
'     the AsyncWriteComplete event. nErrors() should be declared as an empty array
'     as the server allocates the space for the returned values.
'
Public Function AsyncWriteItems(ByVal nNumItems As Long, nItemHandles() As Long, _
                                vItemValues() As Variant, _
                                ByVal nTransactionID As Long, nCancelID As Long, _
                                nErrors() As Long) As Boolean
  Dim nServerHandles() As Long
  Dim i As Integer

  AsyncWriteItems = False

  If nNumItems <= 0 Then
    Exit Function
  End If
  If UBound(nItemHandles) <> nNumItems Then
    Exit Function
  End If
  If nTransactionID = 0 Then
    Exit Function
  End If

  ' Turn the item handles into server handles
  ReDim nServerHandles(nNumItems)
  For i = 1 To nNumItems
    nServerHandles(i) = GetItem(nItemHandles(i)).m_nServerHandle
  Next

  ' Issue the AsyncWrite call on the OPC Group
  On Error GoTo AsyncWriteItemsErr:
  m_GroupForm.m_OPCGroup.AsyncWrite nNumItems, nServerHandles, vItemValues, nErrors, nTransactionID, nCancelID
  AsyncWriteItems = True
  Exit Function

AsyncWriteItemsErr:
  Debug.Print "CGroup::AsyncWriteItems Error = " & Err.Number
End Function
'
' AsyncRefresh
'
'   Parameters:
'     nSource         In   Integer  The source of reading: Device or Cache
'     nTransactionID  In   Long     The transaction ID for this AsyncWrite
'     nCancelID       Out  Long     The cancel ID generated by the server
'
'   Return Value:
'     Returns True if the AsyncRefresh call is performed.
'     Returns False if nSource is not Cache or Device, or if the transaction ID
'       is 0 or if there is an error in the AsyncRefresh call.
'
'   Remarks:
'     CGroup::AsyncRefresh causes the value, quality and timestamp of each active
'     item in the group to be returned in a DataChange event. The results of
'     this type of operation are returned later through a DataChange event in
'     either CServer::GlobalDataChange or ServerCollection::GlobalDataChange. For
'     both of these, the transaction ID passed in will accompany the data in the
'     GlobalDataChange event.
'
Public Function AsyncRefresh(ByVal nSource As Integer, _
                             ByVal nTransactionID As Long, _
                             nCancelID As Long) As Boolean

  AsyncRefresh = False

  ' Check the input parameters
  If nSource = OPCDataSource.OPCCache And nSource <> OPCDataSource.OPCDevice Then
    Exit Function
  End If
  If nTransactionID = 0 Then
    Exit Function
  End If

  If Not m_GroupForm Is Nothing Then
    If Not m_GroupForm.m_OPCGroup Is Nothing Then
      On Error GoTo AsyncRefreshErr:
      m_GroupForm.m_OPCGroup.AsyncRefresh nSource, nTransactionID, nCancelID
      AsyncRefresh = True
    End If
  End If
  Exit Function

AsyncRefreshErr:
  Debug.Print "CGroup::AsyncRefresh Error = " & Err.Number
End Function
'
' AsyncCancel
'
'   Parameters:
'     nCancelID  In  Long  The cancel ID of the transaction to be canceled
'
'   Return Value:
'     Returns True if the AsyncCancel call is performed.
'     Returns False if the cancel ID is 0 or if there is an error in the
'       AsyncCancel call.
'
'   Remarks:
'     CGroup::AsyncCancel is called to attempt to cancel a previously dispatched
'     asynchronous transaction such as AsyncWriteItems, AsyncReadItems, or
'     AsyncRefresh. nCancelID is the cancel ID that was returned from one of those
'     functions.  The results of this type of operation are returned later through
'     a CancelComplete event in either CServer::AsyncCancelComplete or
'     ServerCollection::AsyncCancelComplete.
'
Public Function AsyncCancel(ByVal nCancelID As Long) As Boolean

  AsyncCancel = False

  ' Check the input parameters
  If nCancelID = 0 Then
    Exit Function
  End If

  If Not m_GroupForm Is Nothing Then
    If Not m_GroupForm.m_OPCGroup Is Nothing Then
      On Error GoTo AsyncCancelErr:
      m_GroupForm.m_OPCGroup.AsyncCancel nCancelID
      AsyncCancel = True
    End If
  End If
  Exit Function

AsyncCancelErr:
  Debug.Print "CGroup::AsyncCancel Error = " & Err.Number
End Function
'
' Get GroupName
'
Public Property Get GroupName() As String

  GroupName = ""

  If Not m_GroupForm Is Nothing Then
    If Not m_GroupForm.m_OPCGroup Is Nothing Then
      GroupName = m_GroupForm.m_OPCGroup.Name
    End If
  End If

End Property
'
' Let DataChangeMethod
'
Public Property Let DataChangeMethod(ByVal vData As Integer)

  If Not m_GroupForm Is Nothing Then
    If Not m_GroupForm.m_OPCGroup Is Nothing Then
      If vData = CONTINUOUS_LOGGING Then
        m_nDataChangeMethod = CONTINUOUS_LOGGING
        m_GroupForm.m_OPCGroup.AreCallbacksEnabled = False
        m_GroupForm.TimerForGroup.Interval = m_GroupForm.m_OPCGroup.UpdateRate
        m_GroupForm.TimerForGroup.Enabled = True
      Else
        m_nDataChangeMethod = SUBSCRIPTION
        m_GroupForm.TimerForGroup.Enabled = False
        m_GroupForm.m_OPCGroup.AreCallbacksEnabled = True
      End If
    End If
  End If

End Property
'
' Get DataChangeMethod
'
Public Property Get DataChangeMethod() As Integer

  DataChangeMethod = m_nDataChangeMethod

End Property
'
' Let Deadband
'
Public Property Let Deadband(ByVal vData As Single)

  If Not m_GroupForm Is Nothing Then
    If Not m_GroupForm.m_OPCGroup Is Nothing Then
      m_GroupForm.m_OPCGroup.Deadband = vData
    End If
  End If

End Property
'
' Get Deadband
'
Public Property Get Deadband() As Single

  Deadband = 0

  If Not m_GroupForm Is Nothing Then
    If Not m_GroupForm.m_OPCGroup Is Nothing Then
      Deadband = m_GroupForm.m_OPCGroup.Deadband
    End If
  End If

End Property
'
' Let IsActive
'
Public Property Let IsActive(ByVal vData As Boolean)

  If Not m_GroupForm Is Nothing Then
    If Not m_GroupForm.m_OPCGroup Is Nothing Then
      m_GroupForm.m_OPCGroup.IsActive = vData
    End If
  End If

End Property
'
' Get IsActive
'
Public Property Get IsActive() As Boolean

  IsActive = False

  If Not m_GroupForm Is Nothing Then
    If Not m_GroupForm.m_OPCGroup Is Nothing Then
      IsActive = m_GroupForm.m_OPCGroup.IsActive
    End If
  End If

End Property
'
' Let TimeBias
'
Public Property Let TimeBias(ByVal vData As Long)

  If Not m_GroupForm Is Nothing Then
    If Not m_GroupForm.m_OPCGroup Is Nothing Then
      m_GroupForm.m_OPCGroup.TimeBias = vData
    End If
  End If

End Property
'
' Get TimeBias
'
Public Property Get TimeBias() As Long

  TimeBias = 0

  If Not m_GroupForm Is Nothing Then
    If Not m_GroupForm.m_OPCGroup Is Nothing Then
      TimeBias = m_GroupForm.m_OPCGroup.TimeBias
    End If
  End If

End Property
'
' Let UpdateRate
'
Public Property Let UpdateRate(ByVal vData As Long)

  If Not m_GroupForm Is Nothing Then
    If Not m_GroupForm.m_OPCGroup Is Nothing Then
      m_GroupForm.m_OPCGroup.UpdateRate = vData
    End If
  End If

End Property
'
' Get UpdateRate
'
Public Property Get UpdateRate() As Long

  UpdateRate = 0

  If Not m_GroupForm Is Nothing Then
    If Not m_GroupForm.m_OPCGroup Is Nothing Then
      UpdateRate = m_GroupForm.m_OPCGroup.UpdateRate
    End If
  End If

End Property
'
' Class_Initialize
'
Private Sub Class_Initialize()

  m_NextItemHandle = 1
  m_nDataChangeMethod = SUBSCRIPTION

  m_Handle = 0
  Set m_Parent = Nothing
  Set m_ItemCollection = New ItemCollection

  Set m_GroupForm = New frmGroup
  Load m_GroupForm

  ' Store a "pointer" to the GroupObject in the GroupForm to implement trickle-up callbacks
  'Set m_GroupForm.m_Parent = Me

End Sub
'
' Class_Terminate
'
Private Sub Class_Terminate()
  Dim nIdx As Integer
  Dim nCount As Integer

  Debug.Print ("~CGroup Start")

  ' Empty the item collection and release it
  If Not m_ItemCollection Is Nothing Then
    nCount = m_ItemCollection.Count
    For nIdx = 1 To nCount
      m_ItemCollection.Remove (1)
    Next nIdx

    Set m_ItemCollection = Nothing
  End If

  If Not m_GroupForm Is Nothing Then
    ' Discontinue the trickle-up callbacks
    If Not m_GroupForm.m_Parent Is Nothing Then
      Set m_GroupForm.m_Parent = Nothing
    End If

    ' Release the group form
    Unload m_GroupForm
    Set m_GroupForm = Nothing
  End If

  Debug.Print ("~CGroup End")

End Sub
