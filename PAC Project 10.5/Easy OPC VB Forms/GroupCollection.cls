VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "GroupCollection"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Collection" ,"GroupFormClass"
Attribute VB_Ext_KEY = "Member0" ,"GroupFormClass"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
Option Explicit

Public m_Parent As CServer

'local variable to hold collection
Private mCol As Collection
' local variable for the group handle
Private m_NextGroupHandle As Long
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
'     Part of the trickle-up callback system. GroupCollection::DataChange is called
'     by CGroup::DataChange to pass along data obtained from an AsyncReadComplete
'     Event.
'
Public Sub DataChange(ByVal nTransactionID As Long, ByVal nGroupHandle As Long, _
                      ByVal nNumItems As Long, nItemHandles() As Long, _
                      vItemValues() As Variant, nQualities() As Long, _
                      TimeStamps() As Date)

  If Not m_Parent Is Nothing Then
    m_Parent.DataChange nTransactionID, nGroupHandle, nNumItems, nItemHandles, vItemValues, nQualities, TimeStamps
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
'     Part of the trickle-up callback system. GroupCollection::WriteComplete is
'     called by CGroup::WriteComplete to pass along data obtained from an
'     AsyncWriteComplete Event.
'
Public Sub WriteComplete(ByVal nTransactionID As Long, ByVal nGroupHandle As Long, _
                         ByVal nNumItems As Long, nItemHandles() As Long, _
                         nErrors() As Long)

  If Not m_Parent Is Nothing Then
    m_Parent.WriteComplete nTransactionID, nGroupHandle, nNumItems, nItemHandles, nErrors
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
'     Part of the trickle-up callback system. GroupCollection::CancelComplete is
'     called by CGroup::CancelComplete to pass along data obtained from an
'     AsyncCancelComplete Event.
'
Public Sub CancelComplete(ByVal nTransactionID As Long, ByVal nGroupHandle As Long)

  If Not m_Parent Is Nothing Then
    m_Parent.CancelComplete nTransactionID, nGroupHandle
  End If

End Sub
'
' AddGroup
'
'   Parameters:
'     nServerHandle  In  Long      The handle of the server that the new group belongs to
'     NewOPCGroup    In  OPCGroup  An OPCGroup object obtained from OPCGroups.Add
'
'   Return Value:
'     Returns a group handle if successful or 0 if unsuccessful.
'
'   Remarks:
'     GroupCollection::AddGroup assigns a unique group handle, creates a new CGroup
'     object in the GroupCollection, initializes the group form with the OPCGroup
'     object, and if the group is set up for continuous logging, initializes the
'     timer interval in the group form and starts the timer.
'
Public Function AddGroup(ByVal nServerHandle As Long, _
                         ByVal NewOPCGroup As OPCGroup) As Long
  Dim nGroupHandle As Long
  Dim sGroupHandle As String

  AddGroup = 0

  ' Check for maximum groups
  If m_NextGroupHandle > 4095 Then
    Exit Function
  End If

  ' Create a group handle and convert it to a string
  '
  '   Embed the server handle in the fourth byte in the lower word of the group
  '   handle. This means that there is a limit of 15 (F) servers and 4095 (FFF)
  '   groups per server.
  nGroupHandle = (nServerHandle * 4096) + m_NextGroupHandle   ' same as shift left by 12 bits
  sGroupHandle = CStr(nGroupHandle)

  ' Add a group object to the group collection
  Dim GroupObject As CGroup

  Set GroupObject = Me.Add(sGroupHandle)

  ' Initialize the group form with the OPCGroup object
  Set GroupObject.m_GroupForm.m_OPCGroup = NewOPCGroup

  ' Assign the group handle to the group object
  GroupObject.m_Handle = nGroupHandle

  ' If the group has continuous logging, set the interval and enable the timer on the group form
  If NewOPCGroup.AreCallbacksEnabled = False Then
    GroupObject.m_GroupForm.TimerForGroup.Interval = NewOPCGroup.UpdateRate
    GroupObject.m_GroupForm.TimerForGroup.Enabled = True
  End If

  Set GroupObject = Nothing ' done with GroupObject - decrease its refcount

  ' Return the group handle
  AddGroup = nGroupHandle

  ' Increment the group handle for the next group to be added
  m_NextGroupHandle = m_NextGroupHandle + 1

End Function
'
' RemoveGroup
'
'   Parameters:
'     nGroupHandle  In  Long  The handle of the group to remove
'
'   Return Value:
'     Returns True if the group was removed.
'     Returns False if the group was not removed.
'
'   Remarks:
'     GroupCollection::RemoveGroup first disables the group form timer if
'     the group is continuously logging information. It then turns off the trickle-
'     up callbacks from the group form to remove the reference to the group object.
'     It then removes the group object from the collection which forces the group
'     object to go through its Terminate procedure. This removes all references
'     to this groups OPC Items and the OPC Group, and removes the Item Collection.
'
Public Function RemoveGroup(ByVal nGroupHandle As Long) As Boolean
  Dim GroupObject As CGroup
  Dim vKey As Variant

  RemoveGroup = False

  vKey = CStr(nGroupHandle)
  Set GroupObject = Me.Item(vKey)
  If Not GroupObject Is Nothing Then
    If Not GroupObject.m_GroupForm Is Nothing Then
      ' If the group has continuous logging, turn off the timer on the group form
      If GroupObject.m_GroupForm.m_OPCGroup.AreCallbacksEnabled = False Then
        GroupObject.m_GroupForm.TimerForGroup.Enabled = False
      End If

      ' Discontinue the trickle up callbacks from the group form. It is important
      ' to do this here because it decrements the refcount on the group object
      ' (the parent of the group form). Otherwise when the group is removed below
      ' it will still have outstanding references and will not be deleted.
      If Not GroupObject.m_GroupForm.m_Parent Is Nothing Then
        Set GroupObject.m_GroupForm.m_Parent = Nothing
      End If
    End If

    Set GroupObject = Nothing ' done with GroupObject - decrease its refcount

    ' Remove the group object from the group collection
    Me.Remove (vKey)

    RemoveGroup = True
  End If

End Function
'
'
'
Public Function Add(Optional sKey As String) As CGroup

  'create a new object
  Dim objNewMember As CGroup
  Set objNewMember = New CGroup

  'set the properties passed into the method
  If Len(sKey) = 0 Then
      mCol.Add objNewMember
  Else
      mCol.Add objNewMember, sKey
  End If

  ' Store a "pointer" to the GroupCollection in the GroupObject to implement trickle-up callbacks
  Set objNewMember.m_Parent = Me

  'return the object created
  Set Add = objNewMember
  Set objNewMember = Nothing

End Function
'
'
'
Public Property Get Item(vntIndexKey As Variant) As CGroup
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
  Dim GroupObject As CGroup

  Set GroupObject = Me.Item(vntIndexKey)
  If Not GroupObject Is Nothing Then
    ' Discontinue the trickle-up callbacks
    Set GroupObject.m_Parent = Nothing
    
    Set GroupObject = Nothing ' All done with GroupObject - decrease its refcount
  End If

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
Attribute NewEnum.VB_UserMemId = -4
Attribute NewEnum.VB_MemberFlags = "40"
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

  ' Initialize the group handle counter
  m_NextGroupHandle = 1

  Set m_Parent = Nothing

End Sub
'
'
'
Private Sub Class_Terminate()

  ' Discontinue the trickle-up callbacks
  If Not m_Parent Is Nothing Then
    Set m_Parent = Nothing
  End If

  ' Destroys collection when this class is terminated
  Set mCol = Nothing

End Sub

