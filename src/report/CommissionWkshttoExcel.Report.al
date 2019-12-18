report 80001 "CommissionWkshttoExcelTigCM"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions

    CaptionML = ESM = 'Conciliar ctas. pdtes. con cont.',
                FRC = 'Rapprocher CF au GL',
                ENC = 'Reconcile AP to GL';
    ProcessingOnly = true;

    dataset
    {
        dataitem(CommissionPmtEntry; "Integer")
        {
            DataItemTableView = SORTING(Number);
            dataitem(SalesRep; "Integer")
            {
                DataItemTableView = SORTING(Number);

                trigger OnAfterGetRecord();
                begin
                    if Number = 1 then
                        SalespersonTemp.FIND('-')
                    else
                        SalespersonTemp.NEXT;
                    SalespersonTemp."Commission %" := 0;

                    if SalespersonTemp.Code <> LastSalespersonCode then
                        WriteExcelWkshtHeader(true, SalespersonTemp.Name);

                    with CommPmtEntryTemp do begin
                        SETRANGE("Salesperson Code", SalespersonTemp.Code);
                        if FIND('-') then begin
                            repeat
                                Customer.GET("Customer No.");
                                EnterCell(RowNo, 1, FORMAT("Batch Name"), false, false, '', ExcelBuf."Cell Type"::Text);
                                EnterCell(RowNo, 2, FORMAT("Salesperson Code"), false, false, '', ExcelBuf."Cell Type"::Text);
                                EnterCell(RowNo, 3, FORMAT("Entry Type"), false, false, '', ExcelBuf."Cell Type"::Text);
                                EnterCell(RowNo, 4, FORMAT("Posting Date"), false, false, '', ExcelBuf."Cell Type"::Text);
                                EnterCell(RowNo, 5, FORMAT("Payout Date"), false, false, '', ExcelBuf."Cell Type"::Text);
                                EnterCell(RowNo, 6, FORMAT(Customer.Name), false, false, '', ExcelBuf."Cell Type"::Text);
                                EnterCell(RowNo, 7, FORMAT("Document No."), false, false, '', ExcelBuf."Cell Type"::Text);
                                EnterCell(RowNo, 8, Description, false, false, '', ExcelBuf."Cell Type"::Text);
                                EnterCell(RowNo, 9, FORMAT("Commission Plan Code"), false, false, '', ExcelBuf."Cell Type"::Text);
                                EnterCell(RowNo, 10, FORMAT(Amount, 0, '<Sign><Integer><Decimal,3>'), false, false, '', ExcelBuf."Cell Type"::Number);
                                RowNo += 1;

                                SalespersonTemp."Commission %" += Amount;
                                LastSalespersonCode := "Salesperson Code";
                            until NEXT = 0;
                            //Sum totals
                            EnterFormula(RowNo, 10, '=SUM(J6:J' + FORMAT(RowNo - 1) + ')', true, false, '');
                        end;
                    end;
                    SalespersonTemp.MODIFY;

                    ExcelBuf.WriteSheet(
                      SalespersonTemp.Name,
                      COMPANYNAME,
                      USERID);
                end;

                trigger OnPreDataItem();
                begin
                    SETRANGE(Number, 1, SalespersonTemp.COUNT);
                    if SalespersonTemp.FINDFIRST then begin
                        WriteExcelWkshtHeader(false, SalespersonTemp.Name);
                        LastSalespersonCode := SalespersonTemp.Code;
                    end;
                end;
            }

            trigger OnPostDataItem();
            begin
                //Write summary sheet if more than 1 salesperson
                if SalespersonTemp.COUNT > 1 then begin
                    if SalespersonTemp.FIND('-') then begin
                        ExcelBuf.DELETEALL;
                        ExcelBuf.CreateNewSheet(SummaryLbl);

                        EnterCell(1, 1, COMPANYNAME, true, false, '', ExcelBuf."Cell Type"::Text);
                        EnterCell(2, 1, ReportTitle, true, false, '', ExcelBuf."Cell Type"::Text);
                        EnterCell(3, 1, FORMAT(ReportRunTime) + ': ' + USERID, true, false, '', ExcelBuf."Cell Type"::Text);
                        RowNo := 5;

                        EnterCell(RowNo, 1, SalespersonCodeLbl, true, false, '', ExcelBuf."Cell Type"::Text);
                        EnterCell(RowNo, 2, AmountLbl, true, false, '', ExcelBuf."Cell Type"::Text);
                        RowNo := 6;

                        repeat
                            EnterCell(RowNo, 1, SalespersonTemp.Name, false, false, '', ExcelBuf."Cell Type"::Text);
                            EnterCell(RowNo, 2, FORMAT(ROUND(SalespersonTemp."Commission %", 0.01), 0, '<Sign><Integer><Decimal,3>'), false, false, '', ExcelBuf."Cell Type"::Number);
                            RowNo += 1;
                        until SalespersonTemp.NEXT = 0;

                        //Sum totals
                        EnterFormula(RowNo, 2, '=SUM(B6:B' + FORMAT(RowNo - 1) + ')', true, false, '');

                        ExcelBuf.WriteSheet(
                          SummaryLbl,
                          COMPANYNAME,
                          USERID);
                    end;
                end;
            end;

            trigger OnPreDataItem();
            begin
                case Source of
                    Source::Worksheet:
                        begin
                            CopyWkshtToLedger(CommWkshtLine, CommPmtEntryTemp, SalespersonFilter);
                            ReportTitle := ReportTitleWksht;
                        end;
                    Source::Posted:
                        begin
                            CopyLedgerToLedger(CommPmtEntry, CommPmtEntryTemp, SalespersonFilter);
                            ReportTitle := ReporTitlePosted;
                        end;
                    Source::" ":
                        ERROR(NothingToPrint);
                end;

                SETRANGE(Number, 1, CommPmtEntryTemp.COUNT);
                CommPmtEntryTemp.SETCURRENTKEY("Salesperson Code", "Customer No.");
                if CommPmtEntryTemp.FIND('-') then begin
                    repeat
                        if not SalespersonTemp.GET(CommPmtEntryTemp."Salesperson Code") then begin
                            Salesperson.GET(CommPmtEntryTemp."Salesperson Code");
                            SalespersonTemp := Salesperson;
                            SalespersonTemp.INSERT;
                        end;
                    until CommPmtEntryTemp.NEXT = 0;
                end;
                SETRANGE(Number, 1);
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
                field(SalespersonFilter; SalespersonFilter)
                {
                    Caption = 'Salesperson Filter';
                    TableRelation = "Salesperson/Purchaser";
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPostReport();
    begin
        if BookOpen then begin
            ExcelBuf.CloseBook;
            ExcelBuf.OpenExcel;
            ExcelBuf.GiveUserControl;
        end;
    end;

    trigger OnPreReport();
    begin
        ReportRunTime := CURRENTDATETIME;
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
        ColNo: Integer;
        SendToExcel: Boolean;
        BookOpen: Boolean;
        ReportTitleWksht: Label 'Suggested Commissions to Pay';
        ReporTitlePosted: Label 'Posted Commission Payments';
        Source: Option " ",Worksheet,Posted;
        ReportTitle: Text[50];
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
        LastSalespersonCode: Code[20];
        SummaryLbl: Label 'Summary';
        SalespersonFilter: Code[20];
        ReportRunTime: DateTime;
        NothingToPrint: Label 'Nothing to print.';

    local procedure EnterCell(RowNo: Integer; ColumnNo: Integer; CellValue: Text[250]; Bold: Boolean; UnderLine: Boolean; NumberFormat: Text[30]; CellType: Option);
    begin
        ExcelBuf.INIT;
        ExcelBuf.VALIDATE("Row No.", RowNo);
        ExcelBuf.VALIDATE("Column No.", ColumnNo);
        ExcelBuf."Cell Value as Text" := CellValue;
        ExcelBuf.Formula := '';
        ExcelBuf.Bold := Bold;
        ExcelBuf.Underline := UnderLine;
        ExcelBuf.NumberFormat := NumberFormat;
        ExcelBuf."Cell Type" := CellType;
        ExcelBuf.INSERT;
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
        ExcelBuf.INIT;
        ExcelBuf.VALIDATE("Row No.", RowNo);
        ExcelBuf.VALIDATE("Column No.", ColumnNo);
        ExcelBuf."Cell Value as Text" := '';
        ExcelBuf.Formula := CellValue; // is converted to formula later.
        ExcelBuf.Bold := Bold;
        ExcelBuf.Underline := UnderLine;
        ExcelBuf.NumberFormat := NumberFormat;
        ExcelBuf.INSERT;
    end;

    local procedure CopyWkshtToLedger(var CommWkshtLine2: Record CommissionWksheetLineTigCM; var CommPmtEntry2: Record CommissionPaymentEntryTigCM; SalespersonFilter: Text[100]);
    begin
        CommWkshtLine2.SETCURRENTKEY("Salesperson Code", "Customer No.");
        if SalespersonFilter <> '' then
            CommWkshtLine2.SETRANGE("Salesperson Code", SalespersonFilter);
        if CommWkshtLine2.FIND('-') then begin
            repeat
                EntryNo += 1;
                CommPmtEntry2.INIT;
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
                CommPmtEntry2.INSERT;
            until CommWkshtLine2.NEXT = 0;
        end;
    end;

    local procedure CopyLedgerToLedger(var CommPmtEntry2: Record CommissionPaymentEntryTigCM; var CommPmtEntry3: Record CommissionPaymentEntryTigCM; SalespersonFilter: Text[100]);
    begin
        CommPmtEntry2.SETCURRENTKEY("Salesperson Code", "Customer No.");
        if SalespersonFilter <> '' then
            CommPmtEntry2.SETFILTER("Salesperson Code", SalespersonFilter);
        if CommPmtEntry2.FIND('-') then begin
            repeat
                CommPmtEntry3 := CommPmtEntry2;
                CommPmtEntry3.INSERT;
            until CommPmtEntry2.NEXT = 0;
        end;
    end;

    local procedure WriteExcelWkshtHeader(CreateNewSheet: Boolean; NewSheetCaption: Text[50]);
    begin
        if not BookOpen then begin
            ExcelBuf.DELETEALL;
            ExcelBuf.CreateBook('', NewSheetCaption);
            BookOpen := true;
        end;

        if CreateNewSheet then begin
            ExcelBuf.CreateNewSheet(NewSheetCaption);
            ExcelBuf.DELETEALL;
        end;

        EnterCell(1, 1, COMPANYNAME, true, false, '', ExcelBuf."Cell Type"::Text);
        EnterCell(2, 1, ReportTitle, true, false, '', ExcelBuf."Cell Type"::Text);
        EnterCell(3, 1, FORMAT(ReportRunTime) + ': ' + USERID, true, false, '', ExcelBuf."Cell Type"::Text);
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
        if CommWkshtLine2.COUNT = 0 then
            ERROR(NothingToPrint);
        CommWkshtLine := CommWkshtLine2;
        CommWkshtLine.COPYFILTERS(CommWkshtLine2);
        Source := Source::Worksheet;
    end;

    procedure SetSourcePosted(var CommPmtEntry2: Record CommissionPaymentEntryTigCM);
    begin
        if CommPmtEntry2.COUNT = 0 then
            ERROR(NothingToPrint);
        CommPmtEntry := CommPmtEntry2;
        CommPmtEntry.COPYFILTERS(CommPmtEntry2);
        Source := Source::Posted;
    end;
}

