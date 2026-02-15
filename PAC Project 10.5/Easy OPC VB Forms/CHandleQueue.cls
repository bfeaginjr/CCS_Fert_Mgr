VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "CHandleQueue"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
Option Explicit
Option Base 1

Const MAX_HANDLEQUEUE_SIZE = 5000

Private m_HandleQueue() As Long
Private m_nHead As Integer
Private m_nTail As Integer
'
' GetHandle
'
Public Function GetHandle() As Long

  GetHandle = 0

  If m_nTail <> m_nHead Then
    GetHandle = m_HandleQueue(m_nTail)

    If m_nTail = MAX_HANDLEQUEUE_SIZE Then
      m_nTail = 1
    Else
      m_nTail = m_nTail + 1
    End If
  End If

End Function
'
' PutHandle
'
Public Function PutHandle(ByVal nItemHandle As Long) As Long

  PutHandle = 0

  If m_nHead <> m_nTail - 1 Then
    m_HandleQueue(m_nHead) = nItemHandle

    If m_nHead = MAX_HANDLEQUEUE_SIZE Then
      m_nHead = 1
    Else
      m_nHead = m_nHead + 1
    End If

    PutHandle = nItemHandle
  End If

End Function
'
'
'
Private Sub Class_Initialize()

  ReDim m_HandleQueue(MAX_HANDLEQUEUE_SIZE)

  m_nHead = 1
  m_nTail = 1

End Sub
