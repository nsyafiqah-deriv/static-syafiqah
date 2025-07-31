Sub CreateCalculatedSheetWithFormulaAndSummary()
    Dim wsDatabase As Worksheet, wsCalculated As Worksheet
    Dim lastRow As Long, i As Long
    Dim tblRange As Range, tbl As ListObject
    Dim dict As Object, key As Variant
    Dim summaryRow As Long, summaryTblRange As Range, summaryTbl As ListObject
    Dim tempArray As Variant, parts() As String

    ' Reference the "Database" sheet
    On Error Resume Next
    Set wsDatabase = ThisWorkbook.Sheets("Database")
    On Error GoTo 0

    If wsDatabase Is Nothing Then
        MsgBox "Sheet 'Database' not found!", vbCritical
        Exit Sub
    End If

    ' Delete "Calculated" sheet if it exists
    On Error Resume Next
    Set wsCalculated = ThisWorkbook.Sheets("Calculated")
    If Not wsCalculated Is Nothing Then
        Application.DisplayAlerts = False
        wsCalculated.Delete
        Application.DisplayAlerts = True
    End If
    On Error GoTo 0

    ' Create new "Calculated" sheet
    Set wsCalculated = ThisWorkbook.Sheets.Add(After:=wsDatabase)
    wsCalculated.Name = "Calculated"

    ' Add headers to row 2
    With wsCalculated
        .Range("B2:G2").Value = Array("Reservoir", "String", "Month", _
                                      "Oil CD Rate(bbls/d)", "Water CD Rate(bbls/d)", "Gas CD Rate(bbls/d)")
    End With

    ' Find last row in column C of "Database"
    lastRow = wsDatabase.Cells(wsDatabase.Rows.Count, "C").End(xlUp).Row
    If lastRow < 3 Then
        MsgBox "No data found in 'Database' sheet from row 3 onward.", vbExclamation
        Exit Sub
    End If

    ' Apply formula to column S in "Database"
    For i = 3 To lastRow
        wsDatabase.Cells(i, "S").Formula = "=(J" & i & "/DAY(EOMONTH(I" & i & ",0)))*N" & i
    Next i
    
    ' ✅ FIX: Force calculation to complete before copying values
    Application.Calculate
    DoEvents

    ' Copy data to "Calculated" sheet
    With wsCalculated
        .Range("B3:B" & lastRow).Value = wsDatabase.Range("G3:G" & lastRow).Value  ' Reservoir
        .Range("C3:C" & lastRow).Value = wsDatabase.Range("C3:C" & lastRow).Value  ' String
        .Range("D3:D" & lastRow).Value = wsDatabase.Range("I3:I" & lastRow).Value  ' Month
        .Range("E3:E" & lastRow).Value = wsDatabase.Range("S3:S" & lastRow).Value  ' Oil CD Rate
        .Range("F3:F" & lastRow).Value = wsDatabase.Range("T3:T" & lastRow).Value  ' Water CD Rate
        .Range("G3:G" & lastRow).Value = wsDatabase.Range("R3:R" & lastRow).Value  ' Gas CD Rate
        .Range("D3:D" & lastRow).NumberFormat = "mm/dd/yyyy"
    End With

    ' Create main table
    Set tblRange = wsCalculated.Range("B2:G" & lastRow)
    Set tbl = wsCalculated.ListObjects.Add(xlSrcRange, tblRange, , xlYes)
    tbl.Name = "String"

    ' Create summary table
    Set dict = CreateObject("Scripting.Dictionary")

    ' ✅ FIX: Aggregate data by String and Month (corrected dictionary handling)
    For i = 3 To lastRow
        ' ✅ FIX: Add error handling for date formatting
        On Error Resume Next
        key = wsCalculated.Cells(i, "C").Value & "|" & Format(wsCalculated.Cells(i, "D").Value, "mm/dd/yyyy")
        On Error GoTo 0
        
        ' ✅ FIX: Validate that we have a proper key
        If key <> "|" Then
            If Not dict.exists(key) Then
                ' ✅ FIX: Store values as separate items instead of array
                dict(key) = Array(CDbl(wsCalculated.Cells(i, "E").Value), _
                                  CDbl(wsCalculated.Cells(i, "F").Value), _
                                  CDbl(wsCalculated.Cells(i, "G").Value))
            Else
                ' ✅ FIX: Properly handle array modification
                tempArray = dict(key)
                tempArray(0) = tempArray(0) + CDbl(wsCalculated.Cells(i, "E").Value)
                tempArray(1) = tempArray(1) + CDbl(wsCalculated.Cells(i, "F").Value)
                tempArray(2) = tempArray(2) + CDbl(wsCalculated.Cells(i, "G").Value)
                dict(key) = tempArray
            End If
        End If
    Next i

    ' ✅ FIX: Check if we have any data before creating summary table
    If dict.Count = 0 Then
        MsgBox "No valid data found for summary table creation.", vbExclamation
        Exit Sub
    End If

    ' Output summary headers and data
    With wsCalculated
        .Range("I2:M2").Value = Array("String", "Month", "Total Oil CD Rate", "Total Water CD Rate", "Total Gas CD Rate")
        summaryRow = 3

        For Each key In dict.Keys
            parts = Split(key, "|")
            .Cells(summaryRow, "I").Value = parts(0)
            .Cells(summaryRow, "J").Value = parts(1)
            .Cells(summaryRow, "K").Value = dict(key)(0)
            .Cells(summaryRow, "L").Value = dict(key)(1)
            .Cells(summaryRow, "M").Value = dict(key)(2)
            .Cells(summaryRow, "J").NumberFormat = "mm/dd/yyyy"
            summaryRow = summaryRow + 1
        Next key

        ' Create summary table
        Set summaryTblRange = .Range("I2:M" & summaryRow - 1)
        Set summaryTbl = .ListObjects.Add(xlSrcRange, summaryTblRange, , xlYes)
        summaryTbl.Name = "Calculated_Summary"
    End With

    MsgBox "Tables 'String' and 'Calculated_Summary' created successfully!", vbInformation
End Sub 