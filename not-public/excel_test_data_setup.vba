Sub CreateTestDatabaseSheet()
    Dim wsDatabase As Worksheet
    Dim testData As Variant
    Dim i As Long
    
    ' Delete "Database" sheet if it exists
    On Error Resume Next
    Set wsDatabase = ThisWorkbook.Sheets("Database")
    If Not wsDatabase Is Nothing Then
        Application.DisplayAlerts = False
        wsDatabase.Delete
        Application.DisplayAlerts = True
    End If
    On Error GoTo 0
    
    ' Create new "Database" sheet
    Set wsDatabase = ThisWorkbook.Sheets.Add
    wsDatabase.Name = "Database"
    
    ' Add headers (adjust column positions based on your original data structure)
    With wsDatabase
        .Cells(2, "C").Value = "String"          ' Column C
        .Cells(2, "G").Value = "Reservoir"       ' Column G  
        .Cells(2, "I").Value = "Month"           ' Column I
        .Cells(2, "J").Value = "Days"            ' Column J
        .Cells(2, "N").Value = "Oil Factor"      ' Column N
        .Cells(2, "R").Value = "Gas CD Rate"     ' Column R
        .Cells(2, "S").Value = "Oil CD Rate"     ' Column S (calculated)
        .Cells(2, "T").Value = "Water CD Rate"   ' Column T
    End With
    
    ' Add sample test data
    testData = Array( _
        Array("String1", "Reservoir1", #1/1/2024#, 31, 100, 50, "", 25), _
        Array("String1", "Reservoir1", #2/1/2024#, 29, 110, 55, "", 30), _
        Array("String2", "Reservoir2", #1/1/2024#, 31, 90, 45, "", 20), _
        Array("String2", "Reservoir2", #2/1/2024#, 29, 95, 48, "", 22), _
        Array("String1", "Reservoir1", #3/1/2024#, 31, 105, 52, "", 28) _
    )
    
    ' Populate test data starting from row 3
    For i = 0 To UBound(testData)
        wsDatabase.Cells(i + 3, "C").Value = testData(i)(0)  ' String
        wsDatabase.Cells(i + 3, "G").Value = testData(i)(1)  ' Reservoir
        wsDatabase.Cells(i + 3, "I").Value = testData(i)(2)  ' Month
        wsDatabase.Cells(i + 3, "J").Value = testData(i)(3)  ' Days
        wsDatabase.Cells(i + 3, "N").Value = testData(i)(4)  ' Oil Factor
        wsDatabase.Cells(i + 3, "R").Value = testData(i)(5)  ' Gas CD Rate
        wsDatabase.Cells(i + 3, "T").Value = testData(i)(7)  ' Water CD Rate
    Next i
    
    ' Format the Month column
    wsDatabase.Range("I3:I" & (UBound(testData) + 3)).NumberFormat = "mm/dd/yyyy"
    
    MsgBox "Test Database sheet created with sample data!" & vbCrLf & _
           "You can now run the CreateCalculatedSheetWithFormulaAndSummary() macro.", vbInformation
End Sub 