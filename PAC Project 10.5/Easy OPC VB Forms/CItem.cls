VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CItem"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
Option Explicit
Option Base 1

Public m_nServerHandle As Long
Public m_Handle As Long

Public m_OPCItem As OPCItem
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
'     Returns False if there was an error reading, or nSource was invalid.
'
'   Remarks:
'     CItem::ReadItem attempts to read the value, quality and timestamp of the
'     specified item.
'
Public Function ReadItem(ByVal nSource As Integer, vValue As Variant, _
                         nQuality As Long, TimeStamp As Date) As Boolean
  Dim vQuality As Variant
  Dim vTimeStamp As Variant

  ReadItem = False

  ' Check the input parameters
  If nSource <> OPCDataSource.OPCCache And nSource <> OPCDataSource.OPCDevice Then
    Exit Function
  End If

  If Not m_OPCItem Is Nothing Then
    ' Read the item and store the returned values
    On Error GoTo ReadItemErr:
    m_OPCItem.Read nSource, vValue, vQuality, vTimeStamp
    nQuality = CLng(vQuality)
    TimeStamp = CDate(vTimeStamp)

    ReadItem = True
  End If
  Exit Function
  
ReadItemErr:
  Debug.Print "CItem::ReadItem Error = " & Err.Number
End Function
'
' WriteItem
'
'   Parameters:
'     vValue  In  Variant  The value to be written
'
'   Return Value:
'     Returns True if the item was written successfully.
'     Returns False if the item does not have WRITE access rights, or if there
'       was an error writing or if the input variant is empty.
'
'   Remarks:
'     CItem::WriteItem attempts to write vValue to the specified item.
'
Public Function WriteItem(ByVal vValue As Variant) As Boolean

  WriteItem = False

  ' Check the input parameters
  If VarType(vValue) = vbEmpty Then Exit Function

  If AccessRights And OPCAccessRights.OPCWritable Then
    If Not m_OPCItem Is Nothing Then
      On Error GoTo WriteItemErr:
      m_OPCItem.Write vValue

      WriteItem = True
    End If
  End If
  Exit Function

WriteItemErr:
  Debug.Print "CItem::WriteItem Error = " & Err.Number
End Function
'
' Get AccessPath
'
Public Property Get AccessPath() As Integer

  AccessPath = ""

  If Not m_OPCItem Is Nothing Then
    AccessPath = m_OPCItem.AccessPath
  End If

End Property
'
' Get AccessRights
'
Public Property Get AccessRights() As Long

  AccessRights = 0

  If Not m_OPCItem Is Nothing Then
    AccessRights = m_OPCItem.AccessRights
  End If

End Property
'
' Get CanonicalDatatype
'
Public Property Get CanonicalDatatype() As Integer

  CanonicalDatatype = vbEmpty

  If Not m_OPCItem Is Nothing Then
    CanonicalDatatype = m_OPCItem.CanonicalDatatype
  End If

End Property
'
' Let IsActive
'
Public Property Let IsActive(ByVal vData As Boolean)

  If Not m_OPCItem Is Nothing Then
    m_OPCItem.IsActive = vData
  End If

End Property
'
' Get IsActive
'
Public Property Get IsActive() As Boolean

  IsActive = False

  If Not m_OPCItem Is Nothing Then
    IsActive = m_OPCItem.IsActive
  End If

End Property
'
' Get ItemID
'
Public Property Get ItemID() As Integer

  ItemID = ""

  If Not m_OPCItem Is Nothing Then
    ItemID = m_OPCItem.ItemID
  End If

End Property
'
' Let RequestedDatatype
'
Public Property Let RequestedDatatype(ByVal vData As Integer)

  If Not m_OPCItem Is Nothing Then
    m_OPCItem.RequestedDatatype = vData
  End If

End Property
'
' Get IsActive
'
Public Property Get RequestedDatatype() As Integer

  RequestedDatatype = 0

  If Not m_OPCItem Is Nothing Then
    RequestedDatatype = m_OPCItem.RequestedDatatype
  End If

End Property
'
' Get Quality
'
Public Property Get Quality() As Long

  Quality = OPCQuality.OPCQualityBad

  If Not m_OPCItem Is Nothing Then
    Quality = m_OPCItem.Quality
  End If

End Property
'
' Get TimeStamp
'
Public Property Get TimeStamp() As Date

  TimeStamp = 0

  If Not m_OPCItem Is Nothing Then
    TimeStamp = m_OPCItem.TimeStamp
  End If

End Property
'
' Get Value
'
Public Property Get Value() As Variant

  Value = vbEmpty

  If Not m_OPCItem Is Nothing Then
    Value = m_OPCItem.Value
  End If

End Property
'
'
'
Private Sub Class_Initialize()

  m_nServerHandle = 0
  m_Handle = 0

  Set m_OPCItem = Nothing

End Sub
'
'
'
Private Sub Class_Terminate()

  ' Release the OPC Item
  If Not m_OPCItem Is Nothing Then
    Set m_OPCItem = Nothing
  End If

End Sub
