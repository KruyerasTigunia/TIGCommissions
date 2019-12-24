report 80001 "CommissionWkshttoExcelTigCM"
{
    //FIXME - find alternative for current excel buffer functionality
    //        for now maybe just disable it altogether?
    Caption = 'Commission Worksheet to Excel';
    ApplicationArea = All;
    UsageCategory = Tasks;
    ProcessingOnly = true;

    dataset
    {
        dataitem(CommissionPmtEntry; "Integer")
        {
            DataItemTableView = sorting(Number);
            dataitem(SalesRep; "Integer")
            {
                DataItemTableView = sorting(Number);

                trigger OnAfterGetRecord();
                begin
                    if Number = 1 then
                        SalespersonTemp.FindSet()
                    else
                        SalespersonTemp.Next();
                    SalespersonTemp."Commission %" := 0;

                    if SalespersonTemp.Code <> LastSalespersonCode then
                        WriteExcelWkshtHeader(true, SalespersonTemp.Name);

                    with CommPmtEntryTemp do begin
                        SetRange("Salesperson Code", SalespersonTemp.Code);
                        if FindSet() then begin
                            repeat
                                Customer.Get("Customer No.");
                                EnterCell(RowNo, 1, Format("Batch Name"), false, false, '', ExcelBuf."Cell Type"::Text);
                                EnterCell(RowNo, 2, Format("Salesperson Code"), false, false, '', ExcelBuf."Cell Type"::Text);
                                EnterCell(RowNo, 3, Format("Entry Type"), false, false, '', ExcelBuf."Cell Type"::Text);
                                EnterCell(RowNo, 4, Format("Posting Date"), false, false, '', ExcelBuf."Cell Type"::Text);
                                EnterCell(RowNo, 5, Format("Payout Date"), false, false, '', ExcelBuf."Cell Type"::Text);
                                EnterCell(RowNo, 6, Format(Customer.Name), false, false, '', ExcelBuf."Cell Type"::Text);
                                EnterCell(RowNo, 7, Format("Document No."), false, false, '', ExcelBuf."Cell Type"::Text);
                                EnterCell(RowNo, 8, Description, false, false, '', ExcelBuf."Cell Type"::Text);
                                EnterCell(RowNo, 9, Format("Commission Plan Code"), false, false, '', ExcelBuf."Cell Type"::Text);
                                EnterCell(RowNo, 10, Format(Amount, 0, '<Sign><Integer><Decimal,3>'), false, false, '', ExcelBuf."Cell Type"::Number);
                                RowNo += 1;

                                SalespersonTemp."Commission %" += Amount;
                                LastSalespersonCode := "Salesperson Code";
                            until Next() = 0;
                            //Sum totals
                            EnterFormula(RowNo, 10, '=SUM(J6:J' + Format(RowNo - 1) + ')', true, false, '');
                        end;
                    end;
                    SalespersonTemp.Modify();

                    ExcelBuf.WriteSheet(
                      SalespersonTemp.Name,
                      CompanyName(),
                      UserId());
                end;

                trigger OnPreDataItem();
                begin
                    SetRange(Number, 1, SalespersonTemp.Count());
                    if SalespersonTemp.FindFirst() then begin
                        WriteExcelWkshtHeader(false, SalespersonTemp.Name);
                        LastSalespersonCode := SalespersonTemp.Code;
                    end;
                end;
            }

            trigger OnPostDataItem();
            begin
                //Write summary sheet if more than 1 salesperson
                if SalespersonTemp.Count() > 1 then begin
                    if SalespersonTemp.FindSet() then begin
                        ExcelBuf.DeleteAll();
                        ExcelBuf.CreateNewSheet(SummaryLbl);

                        EnterCell(1, 1, CopyStr(CompanyName(), 1, 250), true, false, '', ExcelBuf."Cell Type"::Text);
                        EnterCell(2, 1, ReportTitle, true, false, '', ExcelBuf."Cell Type"::Text);
                        EnterCell(3, 1, Format(ReportRunTime) + ': ' + UserId(), true, false, '', ExcelBuf."Cell Type"::Text);
                        RowNo := 5;

                        EnterCell(RowNo, 1, SalespersonCodeLbl, true, false, '', ExcelBuf."Cell Type"::Text);
                        EnterCell(RowNo, 2, AmountLbl, true, false, '', ExcelBuf."Cell Type"::Text);
                        RowNo := 6;

                        repeat
                            EnterCell(RowNo, 1, SalespersonTemp.Name, false, false, '', ExcelBuf."Cell Type"::Text);
                            EnterCell(RowNo, 2, Format(ROUND(SalespersonTemp."Commission %", 0.01), 0, '<Sign><Integer><Decimal,3>'), false, false, '', ExcelBuf."Cell Type"::Number);
                            RowNo += 1;
                        until SalespersonTemp.Next() = 0;

                        //Sum totals
                        EnterFormula(RowNo, 2, '=SUM(B6:B' + Format(RowNo - 1) + ')', true, false, '');

                        ExcelBuf.WriteSheet(
                          SummaryLbl,
                          CompanyName(),
                          UserId());
                    end;
                end;
            end;

            trigger OnPreDataItem();
            begin
                case Source of
                    Source::Worksheet:
                        begin
                            CopyWkshtToLedger(CommWkshtLine, CommPmtEntryTemp, SalespersonFilter);
                            ReportTitle := ReportTitleWkshtLbl;
                        end;
                    Source::Posted:
                        begin
                            CopyLedgerToLedger(CommPmtEntry, CommPmtEntryTemp, SalespersonFilter);
                            ReportTitle := ReporTitlePostedLbl;
                        end;
                    Source::" ":
                        ERROR(NothingToPrintErr);
                end;

                SetRange(Number, 1, CommPmtEntryTemp.Count());
                CommPmtEntryTemp.SetCurrentKey("Salesperson Code", "Customer No.");
                if CommPmtEntryTemp.FindSet() then begin
                    repeat
                        if not SalespersonTemp.Get(CommPmtEntryTemp."Salesperson Code") then begin
                            Salesperson.Get(CommPmtEntryTemp."Salesperson Code");
                            SalespersonTemp := Salesperson;
                            SalespersonTemp.Insert();
                        end;
                    until CommPmtEntryTemp.Next() = 0;
                end;
                SetRange(Number, 1);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                field(TheSalespersonFilter; SalespersonFilter)
                {
                    Caption = 'Salesperson Filter';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Salesperson Filter';
                    TableRelation = "Salesperson/Purchaser";
                }
            }
        }

    }

    trigger OnPostReport();
    begin
        if BookOpen then begin
            ExcelBuf.CloseBook();
            ExcelBuf.OpenExcel();
            ExcelBuf.GiveUserControl;
        end;
    end;

    trigger OnPreReport();
    begin
        ReportRunTime := CurrentDateTime();
    end;

    var
        CommWkshtLine: Record CommissionWksheetLineTigCM;
        CommPmtEntry: Record CommissionPaymentEntryTigCM;
        CommPmtEntryTemp: Record CommissionPaymentEntryTigCM temporary;
        Salesperson: Record "Salesperson/Purchaser";
        SalespersonTemp: Record "Salesperson/Purchaser" temporary;
        Customer: Record Customer;
        ExcelBuf: Record "Excel Buffer";
        EntryNo: Integer;
        RowNo: Integer;
        BookOpen: Boolean;
        LastSalespersonCode: Code[20];
        SalespersonFilter: Code[20];
        ReportRunTime: DateTime;
        ReportTitle: Text[50];
        Source: Option " ",Worksheet,Posted;
        ReportTitleWkshtLbl: Label 'Suggested Commissions to Pay';
        ReporTitlePostedLbl: Label 'Posted Commission Payments';
        BatchNameLbl: Label 'Batch Name';
        EntryTypeLbl: Label 'Entry Type';
        PostingDateLbl: Label 'Posting Date';
        PayoutDateLbl: Label 'Payout Date';
        SalespersonCodeLbl: Label 'Salesperson';
        CustomerNoLbl: Label 'Customer';
        DocumentNoLbl: Label 'Document No.';
        DescriptionLbl: Label 'Description';
        AmountLbl: Label 'Amount';
        CommissionPlanLbl: Label 'Comm. Plan';
        SummaryLbl: Label 'Summary';
        NothingToPrintErr: Label 'Nothing to print.';

    local procedure EnterCell(RowNo: Integer; ColumnNo: Integer; CellValue: Text[250]; Bold: Boolean; UnderLine: Boolean; NumberFormat: Text[30]; CellType: Option);
    begin
        ExcelBuf.Init();
        ExcelBuf.Validate("Row No.", RowNo);
        ExcelBuf.Validate("Column No.", ColumnNo);
        ExcelBuf."Cell Value as Text" := CellValue;
        ExcelBuf.Formula := '';
        ExcelBuf.Bold := Bold;
        ExcelBuf.Underline := UnderLine;
        ExcelBuf.NumberFormat := NumberFormat;
        ExcelBuf."Cell Type" := CellType;
        ExcelBuf.Insert();
    end;

    local procedure EnterFilterInCell("Filter": Text[250]; FieldName: Text[100]);
    begin
        if Filter <> '' then begin
            RowNo := RowNo + 1;
            EnterCell(RowNo, 1, FieldName, false, false, '', ExcelBuf."Cell Type"::Text);
            EnterCell(RowNo, 2, Filter, false, false, '', ExcelBuf."Cell Type"::Text);
        end;
    end;

    local procedure EnterFormula(RowNo: Integer; ColumnNo: Integer; CellValue: Text[250]; Bold: Boolean; UnderLine: Boolean; NumberFormat: Text[30]);
    begin
        ExcelBuf.Init();
        ExcelBuf.Validate("Row No.", RowNo);
        ExcelBuf.Validate("Column No.", ColumnNo);
        ExcelBuf."Cell Value as Text" := '';
        ExcelBuf.Formula := CellValue; // is converted to formula later.
        ExcelBuf.Bold := Bold;
        ExcelBuf.Underline := UnderLine;
        ExcelBuf.NumberFormat := NumberFormat;
        ExcelBuf.Insert();
    end;

    local procedure CopyWkshtToLedger(var CommWkshtLine2: Record CommissionWksheetLineTigCM; var CommPmtEntry2: Record CommissionPaymentEntryTigCM; SalespersonFilter: Text[100]);
    begin
        CommWkshtLine2.SetCurrentKey("Salesperson Code", "Customer No.");
        if SalespersonFilter <> '' then
            CommWkshtLine2.SetRange("Salesperson Code", SalespersonFilter);
        if CommWkshtLine2.FindSet() then begin
            repeat
                EntryNo += 1;
                CommPmtEntry2.Init();
                CommPmtEntry2."Entry No." := EntryNo;
                CommPmtEntry2."Batch Name" := CommWkshtLine2."Batch Name";
                CommPmtEntry2."Entry Type" := CommWkshtLine2."Entry Type";
                CommPmtEntry2."Posting Date" := CommWkshtLine2."Posting Date";
                CommPmtEntry2."Payout Date" := CommWkshtLine2."Payout Date";
                CommPmtEntry2."Salesperson Code" := CommWkshtLine2."Salesperson Code";
                CommPmtEntry2."Customer No." := CommWkshtLine2."Customer No.";
                CommPmtEntry2."Document No." := CommWkshtLine2."Source Document No.";
                CommPmtEntry2.Amount := CommWkshtLine2.Amount;
                CommPmtEntry2."Commission Plan Code" := CommWkshtLine2."Commission Plan Code";
                CommPmtEntry2.Description := CommWkshtLine.Description;
                CommPmtEntry2.Insert();
            until CommWkshtLine2.Next() = 0;
        end;
    end;

    local procedure CopyLedgerToLedger(var CommPmtEntry2: Record CommissionPaymentEntryTigCM; var CommPmtEntry3: Record CommissionPaymentEntryTigCM; SalespersonFilter: Text[100]);
    begin
        CommPmtEntry2.SetCurrentKey("Salesperson Code", "Customer No.");
        if SalespersonFilter <> '' then
            CommPmtEntry2.SetFilter("Salesperson Code", SalespersonFilter);
        if CommPmtEntry2.FindSet() then begin
            repeat
                CommPmtEntry3 := CommPmtEntry2;
                CommPmtEntry3.Insert();
            until CommPmtEntry2.Next() = 0;
        end;
    end;

    local procedure WriteExcelWkshtHeader(CreateNewSheet: Boolean; NewSheetCaption: Text[50]);
    begin
        if not BookOpen then begin
            ExcelBuf.DeleteAll();
            ExcelBuf.CreateBook('', NewSheetCaption);
            BookOpen := true;
        end;

        if CreateNewSheet then begin
            ExcelBuf.CreateNewSheet(NewSheetCaption);
            ExcelBuf.DeleteAll();
        end;

        EnterCell(1, 1, CopyStr(CompanyName(), 1, 250), true, false, '', ExcelBuf."Cell Type"::Text);
        EnterCell(2, 1, ReportTitle, true, false, '', ExcelBuf."Cell Type"::Text);
        EnterCell(3, 1, Format(ReportRunTime) + ': ' + UserId(), true, false, '', ExcelBuf."Cell Type"::Text);
        RowNo := 5;

        EnterCell(RowNo, 1, BatchNameLbl, true, false, '', ExcelBuf."Cell Type"::Text);
        EnterCell(RowNo, 2, SalespersonCodeLbl, true, false, '', ExcelBuf."Cell Type"::Text);
        EnterCell(RowNo, 3, EntryTypeLbl, true, false, '', ExcelBuf."Cell Type"::Text);
        EnterCell(RowNo, 4, PostingDateLbl, true, false, '', ExcelBuf."Cell Type"::Text);
        EnterCell(RowNo, 5, PayoutDateLbl, true, false, '', ExcelBuf."Cell Type"::Text);
        EnterCell(RowNo, 6, CustomerNoLbl, true, false, '', ExcelBuf."Cell Type"::Text);
        EnterCell(RowNo, 7, DocumentNoLbl, true, false, '', ExcelBuf."Cell Type"::Text);
        EnterCell(RowNo, 8, DescriptionLbl, true, false, '', ExcelBuf."Cell Type"::Text);
        EnterCell(RowNo, 9, CommissionPlanLbl, true, false, '', ExcelBuf."Cell Type"::Text);
        EnterCell(RowNo, 10, AmountLbl, true, false, '', ExcelBuf."Cell Type"::Text);
        RowNo := 6;
    end;

    procedure SetSourceWorksheet(var CommWkshtLine2: Record CommissionWksheetLineTigCM);
    begin
        if CommWkshtLine2.IsEmpty() then
            ERROR(NothingToPrintErr);
        CommWkshtLine := CommWkshtLine2;
        CommWkshtLine.CopyFilters(CommWkshtLine2);
        Source := Source::Worksheet;
    end;

    procedure SetSourcePosted(var CommPmtEntry2: Record CommissionPaymentEntryTigCM);
    begin
        if CommPmtEntry2.IsEmpty() then
            ERROR(NothingToPrintErr);
        CommPmtEntry := CommPmtEntry2;
        CommPmtEntry.CopyFilters(CommPmtEntry2);
        Source := Source::Posted;
    end;
}

