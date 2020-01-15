report 80001 "CommissionWkshttoExcelTigCM"
{
    Caption = 'Commission Worksheet to Excel';
    ApplicationArea = All;
    UsageCategory = Tasks;
    ProcessingOnly = true;

    dataset
    {
        dataitem(SalesRep; "Integer")
        {
            DataItemTableView = sorting(Number);

            trigger OnPreDataItem();
            begin
                SetRange(Number, 1, TempSalesperson.Count());
            end;

            trigger OnAfterGetRecord();
            var
                Customer: Record Customer;
                MyCurrentRow: Integer;
            begin
                TempExcelBuffer.DeleteAll();
                if Number = 1 then begin
                    TempSalesperson.FindSet();
                    WriteExcelWkshtHeader(true, TempSalesperson.Name);
                end else begin
                    TempSalesperson.Next();
                    WriteExcelWkshtHeader(false, TempSalesperson.Name);
                end;
                TempSalesperson."Commission %" := 0;

                with TempCommPmtEntry do begin
                    SetCurrentKey("Salesperson Code", "Customer No.");
                    SetRange("Salesperson Code", TempSalesperson.Code);
                    if FindSet() then begin
                        repeat
                            if not (Customer."No." = "Customer No.") then
                                Customer.Get("Customer No.");

                            TempExcelBuffer.NewRow();
                            GetCurrentRow(MyCurrentRow);

                            TempExcelBuffer.AddColumn("Batch Name", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                            TempExcelBuffer.AddColumn("Salesperson Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                            TempExcelBuffer.AddColumn("Entry Type", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                            TempExcelBuffer.AddColumn("Posting Date", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                            TempExcelBuffer.AddColumn("Payout Date", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                            TempExcelBuffer.AddColumn(Customer.Name, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                            TempExcelBuffer.AddColumn("Document No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                            TempExcelBuffer.AddColumn(Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                            TempExcelBuffer.AddColumn("Commission Plan Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                            TempExcelBuffer.AddColumn(Amount, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);

                            TempSalesperson."Commission %" += Amount;
                        until Next() = 0;

                        //Sum totals
                        TempExcelBuffer.NewRow();
                        GetCurrentRow(MyCurrentRow);
                        TempExcelBuffer.SetCurrent(MyCurrentRow, 9);
                        TempExcelBuffer.AddColumn('=SUM(J6:J' + Format(MyCurrentRow - 1) + ')', true, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    end;
                end;
                TempSalesperson.Modify();

                TempExcelBuffer.WriteSheet(TempSalesperson.Name, CompanyName(), UserId());
            end;

            trigger OnPostDataItem();
            var
                MyCurrentRow: Integer;
            begin
                //Write summary sheet if more than 1 salesperson
                if TempSalesperson.Count() > 1 then begin
                    if TempSalesperson.FindSet() then begin
                        TempExcelBuffer.DeleteAll();
                        TempExcelBuffer.SelectOrAddSheet(SummarySheetLbl);

                        TempExcelBuffer.ClearNewRow();
                        TempExcelBuffer.NewRow();
                        TempExcelBuffer.AddColumn(CopyStr(CompanyName(), 1, 250), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
                        TempExcelBuffer.NewRow();
                        TempExcelBuffer.AddColumn(ReportTitle, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
                        TempExcelBuffer.NewRow();
                        TempExcelBuffer.AddColumn(Format(ReportRunTime) + ': ' + UserId(), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
                        TempExcelBuffer.NewRow();
                        TempExcelBuffer.NewRow();
                        TempExcelBuffer.AddColumn(TempCommPmtEntry.FieldCaption("Salesperson Code"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
                        TempExcelBuffer.AddColumn(TempCommPmtEntry.FieldCaption(Amount), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);

                        repeat
                            TempExcelBuffer.NewRow();
                            TempExcelBuffer.AddColumn(TempSalesperson.Name, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                            TempExcelBuffer.AddColumn(ROUND(TempSalesperson."Commission %", 0.01), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Number);
                        until TempSalesperson.Next() = 0;

                        //Sum totals
                        TempExcelBuffer.NewRow();
                        GetCurrentRow(MyCurrentRow);
                        TempExcelBuffer.SetCurrent(MyCurrentRow, 1);
                        TempExcelBuffer.AddColumn('=SUM(B6:B' + Format(MyCurrentRow - 1) + ')', true, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);

                        TempExcelBuffer.WriteSheet(SummarySheetLbl, CompanyName(), UserId());
                    end;
                end;
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

    trigger OnPreReport();
    begin
        InitTempRecords();
        ReportRunTime := CurrentDateTime();
    end;

    trigger OnPostReport();
    begin
        TempExcelBuffer.CloseBook();
        TempExcelBuffer.SetFriendlyFilename('CommissionWorksheet');
        TempExcelBuffer.OpenExcel();
    end;

    var
        CommWkshtLine: Record CommissionWksheetLineTigCM;
        CommPmtEntry: Record CommissionPaymentEntryTigCM;
        Salesperson: Record "Salesperson/Purchaser";
        TempCommPmtEntry: Record CommissionPaymentEntryTigCM temporary;
        TempExcelBuffer: Record "Excel Buffer" temporary;
        TempSalesperson: Record "Salesperson/Purchaser" temporary;
        EntryNo: Integer;
        LastSalespersonCode: Code[20];
        SalespersonFilter: Code[20];
        ReportRunTime: DateTime;
        ReportTitle: Text[50];
        Source: Option " ",Worksheet,Posted;
        ReportTitleWkshtLbl: Label 'Suggested Commissions to Pay';
        ReporTitlePostedLbl: Label 'Posted Commission Payments';
        SummarySheetLbl: Label 'Summary';
        CustomerNameLbl: Label 'Customer Name';
        NothingToExportErr: Label 'Nothing to export';

    procedure SetSourceWorksheet(var NewCommWkshtLine: Record CommissionWksheetLineTigCM);
    begin
        if NewCommWkshtLine.IsEmpty() then
            Error(NothingToExportErr);
        CommWkshtLine.Copy(NewCommWkshtLine);
        Clear(CommPmtEntry);
        Source := Source::Worksheet;
        ReportTitle := ReportTitleWkshtLbl;
    end;

    procedure SetSourcePosted(var NewCommPmtEntry: Record CommissionPaymentEntryTigCM);
    begin
        if NewCommPmtEntry.IsEmpty() then
            Error(NothingToExportErr);
        CommPmtEntry.Copy(NewCommPmtEntry);
        Clear(CommWkshtLine);
        Source := Source::Posted;
        ReportTitle := ReporTitlePostedLbl;
    end;

    local procedure InitTempRecords()
    begin
        TempExcelBuffer.Reset();
        TempExcelBuffer.DeleteAll();
        TempCommPmtEntry.Reset();
        TempCommPmtEntry.DeleteAll();
        case Source of
            Source::Worksheet:
                begin
                    CopyWkshtToTempPmtEntry();
                    ReportTitle := ReportTitleWkshtLbl;
                end;
            Source::Posted:
                begin
                    CopyPmtEntryToTempPmtEntry();
                    ReportTitle := ReporTitlePostedLbl;
                end;
            else
                Error(NothingToExportErr);
        end;
    end;

    local procedure CopyWkshtToTempPmtEntry();
    begin
        CommWkshtLine.SetCurrentKey("Salesperson Code", "Customer No.");
        if not (SalespersonFilter = '') then
            CommWkshtLine.SetRange("Salesperson Code", SalespersonFilter);
        if CommWkshtLine.FindSet(false, false) then begin
            EntryNo := 0;
            repeat
                EntryNo += 1;
                TempCommPmtEntry.Init();
                TempCommPmtEntry."Entry No." := EntryNo;
                TempCommPmtEntry."Batch Name" := CommWkshtLine."Batch Name";
                TempCommPmtEntry."Entry Type" := CommWkshtLine."Entry Type";
                TempCommPmtEntry."Posting Date" := CommWkshtLine."Posting Date";
                TempCommPmtEntry."Payout Date" := CommWkshtLine."Payout Date";
                TempCommPmtEntry."Salesperson Code" := CommWkshtLine."Salesperson Code";
                TempCommPmtEntry."Customer No." := CommWkshtLine."Customer No.";
                TempCommPmtEntry."Document No." := CommWkshtLine."Source Document No.";
                TempCommPmtEntry.Amount := CommWkshtLine.Amount;
                TempCommPmtEntry."Commission Plan Code" := CommWkshtLine."Commission Plan Code";
                TempCommPmtEntry.Description := CommWkshtLine.Description;
                TempCommPmtEntry.Insert();
            until CommWkshtLine.Next() = 0;
            FillTempSalesPerson();
        end else begin
            Error(NothingToExportErr);
        end;
    end;

    local procedure CopyPmtEntryToTempPmtEntry();
    begin
        CommPmtEntry.SetCurrentKey("Salesperson Code", "Customer No.");
        if not (SalespersonFilter = '') then
            CommPmtEntry.SetFilter("Salesperson Code", SalespersonFilter);
        if CommPmtEntry.FindSet(false, false) then begin
            repeat
                TempCommPmtEntry := CommPmtEntry;
                TempCommPmtEntry.Insert();
            until CommPmtEntry.Next() = 0;
            FillTempSalesPerson();
        end else begin
            Error(NothingToExportErr);
        end;
    end;

    local procedure FillTempSalesPerson()
    begin
        TempSalesperson.Reset();
        TempSalesperson.DeleteAll();
        LastSalespersonCode := '';

        TempCommPmtEntry.Reset();
        TempCommPmtEntry.SetCurrentKey("Salesperson Code");
        if TempCommPmtEntry.FindSet() then begin
            repeat
                if not (TempCommPmtEntry."Salesperson Code" = LastSalespersonCode) then begin
                    LastSalespersonCode := TempCommPmtEntry."Salesperson Code";
                    if not TempSalesperson.Get(TempCommPmtEntry."Salesperson Code") then begin
                        Salesperson.Get(TempCommPmtEntry."Salesperson Code");
                        TempSalesperson := Salesperson;
                        TempSalesperson.Insert();
                    end;
                end;
            until TempCommPmtEntry.Next() = 0;
        end else begin
            Error(NothingToExportErr);
        end;
    end;

    local procedure WriteExcelWkshtHeader(CreateNewFile: Boolean; NewSheetCaption: Text[50]);
    begin
        if CreateNewFile then begin
            TempExcelBuffer.CreateNewBook(NewSheetCaption);
        end else begin
            TempExcelBuffer.SelectOrAddSheet(NewSheetCaption);
        end;

        TempExcelBuffer.ClearNewRow();
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(CopyStr(CompanyName(), 1, 250), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(ReportTitle, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(Format(ReportRunTime) + ': ' + UserId(), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.NewRow();
        TempExcelBuffer.NewRow();

        TempExcelBuffer.AddColumn(CommPmtEntry.FieldCaption("Batch Name"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CommPmtEntry.FieldCaption("Salesperson Code"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CommPmtEntry.FieldCaption("Entry Type"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CommPmtEntry.FieldCaption("Posting Date"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CommPmtEntry.FieldCaption("Payout Date"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CustomerNameLbl, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CommPmtEntry.FieldCaption("Document No."), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CommPmtEntry.FieldCaption(Description), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CommPmtEntry.FieldCaption("Commission Plan Code"), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CommPmtEntry.FieldCaption(Amount), false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
    end;

    local procedure GetCurrentRow(var MyCurrentRow: Integer)
    var
        MyCurrentRowVariant: Variant;
    begin
        TempExcelBuffer.UTgetGlobalValue('CurrentRow', MyCurrentRowVariant);
        if MyCurrentRowVariant.IsInteger() then
            MyCurrentRow := MyCurrentRowVariant;
    end;
}