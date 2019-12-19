report 80003 "Commission-CalcRptWkshtTigCM"
{
    Caption = 'Commission - Calculate Report Worksheet';
    ApplicationArea = All;
    UsageCategory = Tasks;
    ProcessingOnly = true;

    dataset
    {
        dataitem(CommCustSalesperson; "CommCustomerSalespersonTigCM")
        {
            DataItemTableView = sorting("Customer No.", "Salesperson Code");
            RequestFilterFields = "Date Filter", "Salesperson Code", "Customer No.";
            dataitem("Comm. Recognition Entry"; CommRecognitionEntryTigCM)
            {
                DataItemLink = "Customer No." = field("Customer No.");
                DataItemTableView = sorting("Customer No.", "Trigger Posting Date", "Document Type", "Document No.");

                trigger OnAfterGetRecord();
                begin
                    CalcFields("Basis Amt. Approved to Pay", "Basis Amt. Paid");

                    ApprovalEntry.SetCurrentKey("Comm. Recog. Entry No.");
                    ApprovalEntry.SetRange("Comm. Recog. Entry No.", "Entry No.");
                    ApprovalEntry.CalcSums("Amt. Remaining to Pay");

                    InsertReportBufferRecog();
                end;

                trigger OnPreDataItem();
                begin
                    if TheTransactionFilter <> TheTransactionFilter::Recognized then
                        CurrReport.Break();

                    CommCustSalesperson.CopyFilter("Date Filter", "Trigger Posting Date");
                end;
            }
            dataitem("Comm. Approval Entry"; CommApprovalEntryTigCM)
            {
                DataItemLink = "Customer No." = field("Customer No.");
                DataItemTableView = sorting("Customer No.", "Trigger Posting Date", "Document Type", "Document No.");

                trigger OnAfterGetRecord();
                begin
                    CalcFields("Comm. Amt. Paid");
                    RecogEntry.Get("Comm. Recog. Entry No.");
                    RecogEntry.CalcFields("Basis Amt. Approved to Pay", "Basis Amt. Paid");

                    InsertReportBufferAppr();
                end;

                trigger OnPreDataItem();
                begin
                    if TheTransactionFilter <> TheTransactionFilter::Approved then
                        CurrReport.Break();

                    CommCustSalesperson.CopyFilter("Date Filter", "Trigger Posting Date");
                end;
            }
            dataitem("Comm. Payment Entry"; CommissionPaymentEntryTigCM)
            {
                DataItemLink = "Customer No." = field("Customer No.");
                DataItemTableView = sorting("Customer No.", "Date Paid", "Document No.");

                trigger OnAfterGetRecord();
                begin
                    //Allow initialization entries having no link
                    if RecogEntry.Get("Comm. Recog. Entry No.") then
                        RecogEntry.CalcFields("Basis Amt. Approved to Pay", "Basis Amt. Paid")
                    else
                        Clear(RecogEntry);

                    InsertReportBufferPmt();
                end;

                trigger OnPreDataItem();
                begin
                    if TheTransactionFilter <> TheTransactionFilter::Paid then
                        CurrReport.Break();

                    CommCustSalesperson.CopyFilter("Date Filter", "Posting Date");
                end;
            }

            trigger OnAfterGetRecord();
            begin
                CalcFields("Customer Name", "Salesperson Name");
            end;

            trigger OnPreDataItem();
            begin
                Window.Open(CalculatingLbl);
                DateFilter := CopyStr(GetFilter("Date Filter"), 1, MaxStrLen(DateFilter));
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
                field(TransactionFilter; TheTransactionFilter)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Transaction Filter';
                    OptionCaption = 'Recognized,Approved,Paid';
                }
            }
        }
    }

    trigger OnPostReport();
    begin
        Clear(Window);
        Message(CompleteMsg);
    end;

    trigger OnPreReport();
    begin
        ReportBuffer.SetRange("User ID", UserId());
        ReportBuffer.DeleteAll();
        EntryNo := 1;
        RunDateTime := CurrentDateTime();
    end;

    var
        ReportBuffer: Record CommReportWkshtBufferTigCM;
        RecogEntry: Record CommRecognitionEntryTigCM;
        ApprovalEntry: Record CommApprovalEntryTigCM;
        EntryNo: Integer;
        DateFilter: Text[30];
        RunDateTime: DateTime;
        TheTransactionFilter: Option Recognized,Approved,Paid;
        Window: Dialog;
        CompleteMsg: Label 'Complete';
        CalculatingLbl: Label 'Calculating...';

    local procedure InsertReportBufferRecog();
    begin
        //Create both detail and summary records
        with ReportBuffer do begin
            //Summary
            SetRange("Salesperson Code", CommCustSalesperson."Salesperson Code");
            SetRange("Customer No.", CommCustSalesperson."Customer No.");
            SetRange("Document Type", "Comm. Recognition Entry"."Document Type");
            SetRange("Document No.", "Comm. Recognition Entry"."Document No.");
            if not FindFirst() then begin
                Init();
                "User ID" := CopyStr(UserId(), 1, MaxStrLen("User ID"));
                "Entry No." := EntryNo;
                "Salesperson Code" := CommCustSalesperson."Salesperson Code";
                "Salesperson Name" := CommCustSalesperson."Customer Name";
                "Entry Type" := "Comm. Recognition Entry"."Entry Type";
                "Customer No." := CommCustSalesperson."Customer No.";
                "Customer Name" := CommCustSalesperson."Customer Name";
                "Document Type" := "Comm. Recognition Entry"."Document Type";
                "Document No." := "Comm. Recognition Entry"."Document No.";
                "External Document No." := "Comm. Recognition Entry"."External Document No.";
                "Basis Amt. Recognized" := "Comm. Recognition Entry"."Basis Amt.";
                "Basis Amt. Approved to Pay" := "Comm. Recognition Entry"."Basis Amt. Approved to Pay";
                "Comm. Amt. Paid" := "Comm. Recognition Entry"."Basis Amt. Paid";
                "Approved Date" := "Comm. Recognition Entry"."Trigger Posting Date";
                "Run Date-Time" := RunDateTime;
                Level := Level::Summary;
                "Posted Doc. No." := "Comm. Recognition Entry"."Posted Doc. No.";
                "Trigger Doc. No." := "Comm. Recognition Entry"."Trigger Document No.";
                Insert();
                EntryNo += 1;
            end else begin
                "Basis Amt. Recognized" += "Comm. Recognition Entry"."Basis Amt.";
                "Basis Amt. Approved to Pay" += "Comm. Recognition Entry"."Basis Amt. Approved to Pay";
                "Comm. Amt. Paid" += "Comm. Recognition Entry"."Basis Amt. Paid";
                Modify();
            end;

            //Detail
            Init();
            "User ID" := CopyStr(UserId(), 1, MaxStrLen("User ID"));
            "Entry No." := EntryNo;
            "Salesperson Code" := CommCustSalesperson."Salesperson Code";
            "Salesperson Name" := CommCustSalesperson."Customer Name";
            "Entry Type" := "Comm. Recognition Entry"."Entry Type";
            "Customer No." := CommCustSalesperson."Customer No.";
            "Customer Name" := CommCustSalesperson."Customer Name";
            "Document Type" := "Comm. Recognition Entry"."Document Type";
            "Document No." := "Comm. Recognition Entry"."Document No.";
            "External Document No." := "Comm. Recognition Entry"."External Document No.";
            "Basis Amt. Recognized" := "Comm. Recognition Entry"."Basis Amt.";
            "Basis Amt. Approved to Pay" := "Comm. Recognition Entry"."Basis Amt. Approved to Pay";
            "Comm. Amt. Paid" := "Comm. Recognition Entry"."Basis Amt. Paid";
            "Approved Date" := "Comm. Recognition Entry"."Trigger Posting Date";
            "Run Date-Time" := RunDateTime;
            Level := Level::Detail;
            "Posted Doc. No." := "Comm. Recognition Entry"."Posted Doc. No.";
            "Trigger Doc. No." := "Comm. Recognition Entry"."Trigger Document No.";
            Insert();
            EntryNo += 1;
        end;
    end;

    local procedure InsertReportBufferAppr();
    begin
        //Create both detail and summary records
        with ReportBuffer do begin
            //Summary
            SetRange("Salesperson Code", CommCustSalesperson."Salesperson Code");
            SetRange("Customer No.", CommCustSalesperson."Customer No.");
            SetRange("Document Type", "Comm. Approval Entry"."Document Type");
            SetRange("Document No.", "Comm. Approval Entry"."Document No.");
            if not FindFirst() then begin
                Init();
                "User ID" := CopyStr(UserId(), 1, MaxStrLen("User ID"));
                "Entry No." := EntryNo;
                "Salesperson Code" := CommCustSalesperson."Salesperson Code";
                "Salesperson Name" := CommCustSalesperson."Customer Name";
                "Entry Type" := "Comm. Approval Entry"."Entry Type";
                "Customer No." := CommCustSalesperson."Customer No.";
                "Customer Name" := CommCustSalesperson."Customer Name";
                "Document Type" := "Comm. Approval Entry"."Document Type";
                "Document No." := "Comm. Approval Entry"."Document No.";
                "External Document No." := "Comm. Approval Entry"."External Document No.";
                "Basis Amt. Recognized" := RecogEntry."Basis Amt.";
                "Basis Amt. Approved to Pay" := RecogEntry."Basis Amt. Approved to Pay";
                "Comm. Amt. Paid" := RecogEntry."Basis Amt. Paid";
                "Approved Date" := "Comm. Approval Entry"."Trigger Posting Date";
                "Run Date-Time" := RunDateTime;
                Level := Level::Summary;
                "Posted Doc. No." := "Comm. Approval Entry"."Posted Doc. No.";
                "Trigger Doc. No." := "Comm. Approval Entry"."Trigger Document No.";
                Insert();
                EntryNo += 1;
            end else begin
                "Basis Amt. Recognized" += RecogEntry."Basis Amt.";
                "Basis Amt. Approved to Pay" += RecogEntry."Basis Amt. Approved to Pay";
                "Comm. Amt. Paid" += RecogEntry."Basis Amt. Paid";
                Modify();
            end;

            //Detail
            Init();
            "User ID" := CopyStr(UserId(), 1, MaxStrLen("User ID"));
            "Entry No." := EntryNo;
            "Salesperson Code" := CommCustSalesperson."Salesperson Code";
            "Salesperson Name" := CommCustSalesperson."Customer Name";
            "Entry Type" := "Comm. Approval Entry"."Entry Type";
            "Customer No." := CommCustSalesperson."Customer No.";
            "Customer Name" := CommCustSalesperson."Customer Name";
            "Document Type" := "Comm. Approval Entry"."Document Type";
            "Document No." := "Comm. Approval Entry"."Document No.";
            "External Document No." := "Comm. Approval Entry"."External Document No.";
            "Basis Amt. Recognized" := RecogEntry."Basis Amt.";
            "Basis Amt. Approved to Pay" := RecogEntry."Basis Amt. Approved to Pay";
            "Comm. Amt. Paid" := RecogEntry."Basis Amt. Paid";
            "Approved Date" := "Comm. Approval Entry"."Trigger Posting Date";
            "Run Date-Time" := RunDateTime;
            Level := Level::Detail;
            "Posted Doc. No." := "Comm. Approval Entry"."Posted Doc. No.";
            "Trigger Doc. No." := "Comm. Approval Entry"."Trigger Document No.";
            Insert();
            EntryNo += 1;
        end;
    end;

    local procedure InsertReportBufferPmt();
    begin
        //Create both detail and summary records
        with ReportBuffer do begin
            //Summary
            SetRange("Salesperson Code", CommCustSalesperson."Salesperson Code");
            SetRange("Customer No.", CommCustSalesperson."Customer No.");
            SetRange("Document Type", RecogEntry."Document Type");
            SetRange("Document No.", RecogEntry."Document No.");
            if not FindFirst() then begin
                Init();
                "User ID" := CopyStr(UserId(), 1, MaxStrLen("User ID"));
                "Entry No." := EntryNo;
                "Salesperson Code" := CommCustSalesperson."Salesperson Code";
                "Salesperson Name" := CommCustSalesperson."Customer Name";
                "Entry Type" := "Comm. Payment Entry"."Entry Type";
                "Customer No." := CommCustSalesperson."Customer No.";
                "Customer Name" := CommCustSalesperson."Customer Name";
                "Document Type" := RecogEntry."Document Type";
                "Document No." := RecogEntry."Document No.";
                "External Document No." := RecogEntry."External Document No.";
                "Basis Amt. Recognized" := RecogEntry."Basis Amt.";
                "Basis Amt. Approved to Pay" := RecogEntry."Basis Amt. Approved to Pay";
                "Comm. Amt. Paid" := RecogEntry."Basis Amt. Paid";
                "Approved Date" := "Comm. Payment Entry"."Date Paid";
                "Run Date-Time" := RunDateTime;
                Level := Level::Summary;
                "Posted Doc. No." := "Comm. Payment Entry"."Posted Doc. No.";
                "Trigger Doc. No." := "Comm. Payment Entry"."Trigger Document No.";
                Insert();
                EntryNo += 1;
            end else begin
                "Basis Amt. Recognized" += RecogEntry."Basis Amt.";
                "Basis Amt. Approved to Pay" += RecogEntry."Basis Amt. Approved to Pay";
                "Comm. Amt. Paid" += RecogEntry."Basis Amt. Paid";
                Modify();
            end;

            //Detail
            Init();
            "User ID" := CopyStr(UserId(), 1, MaxStrLen("User ID"));
            "Entry No." := EntryNo;
            "Salesperson Code" := CommCustSalesperson."Salesperson Code";
            "Salesperson Name" := CommCustSalesperson."Customer Name";
            "Entry Type" := "Comm. Payment Entry"."Entry Type";
            "Customer No." := CommCustSalesperson."Customer No.";
            "Customer Name" := CommCustSalesperson."Customer Name";
            "Document Type" := RecogEntry."Document Type";
            "Document No." := RecogEntry."Document No.";
            "External Document No." := RecogEntry."External Document No.";
            "Basis Amt. Recognized" := RecogEntry."Basis Amt.";
            "Basis Amt. Approved to Pay" := RecogEntry."Basis Amt. Approved to Pay";
            "Comm. Amt. Paid" := RecogEntry."Basis Amt. Paid";
            "Approved Date" := "Comm. Payment Entry"."Date Paid";
            "Run Date-Time" := RunDateTime;
            Level := Level::Detail;
            "Posted Doc. No." := "Comm. Payment Entry"."Posted Doc. No.";
            "Trigger Doc. No." := "Comm. Payment Entry"."Trigger Document No.";
            Insert();
            EntryNo += 1;
        end;
    end;

    procedure GetReportFilters(var TransactionFilter2: Option Recognized,Approved,Paid; var DateFilter2: Text[30]);
    begin
        TransactionFilter2 := TheTransactionFilter;
        DateFilter2 := DateFilter;
    end;
}