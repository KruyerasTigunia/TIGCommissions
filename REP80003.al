report 80003 "Commission-Calc Report Wksht."
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Royalties

    ProcessingOnly = true;

    dataset
    {
        dataitem(CommCustSalesperson;"Commission Cust/Salesperson")
        {
            DataItemTableView = SORTING("Customer No.","Salesperson Code");
            RequestFilterFields = "Date Filter","Salesperson Code","Customer No.";
            dataitem("Comm. Recognition Entry";"Comm. Recognition Entry")
            {
                DataItemLink = "Customer No."=FIELD("Customer No.");
                DataItemTableView = SORTING("Customer No.","Trigger Posting Date","Document Type","Document No.");

                trigger OnAfterGetRecord();
                begin
                    CALCFIELDS("Basis Amt. Approved to Pay","Basis Amt. Paid");

                    ApprovalEntry.SETCURRENTKEY("Comm. Recog. Entry No.");
                    ApprovalEntry.SETRANGE("Comm. Recog. Entry No.","Entry No.");
                    ApprovalEntry.CALCSUMS("Amt. Remaining to Pay");

                    InsertReportBufferRecog;
                end;

                trigger OnPreDataItem();
                begin
                    if TransactionFilter <> TransactionFilter::Recognized then
                      CurrReport.BREAK;

                    CommCustSalesperson.COPYFILTER("Date Filter","Trigger Posting Date");
                end;
            }
            dataitem("Comm. Approval Entry";"Comm. Approval Entry")
            {
                DataItemLink = "Customer No."=FIELD("Customer No.");
                DataItemTableView = SORTING("Customer No.","Trigger Posting Date","Document Type","Document No.");

                trigger OnAfterGetRecord();
                begin
                    CALCFIELDS("Comm. Amt. Paid");
                    RecogEntry.GET("Comm. Recog. Entry No.");
                    RecogEntry.CALCFIELDS("Basis Amt. Approved to Pay","Basis Amt. Paid");

                    InsertReportBufferAppr;
                end;

                trigger OnPreDataItem();
                begin
                    if TransactionFilter <> TransactionFilter::Approved then
                      CurrReport.BREAK;

                    CommCustSalesperson.COPYFILTER("Date Filter","Trigger Posting Date");
                end;
            }
            dataitem("Comm. Payment Entry";"Comm. Payment Entry")
            {
                DataItemLink = "Customer No."=FIELD("Customer No.");
                DataItemTableView = SORTING("Customer No.","Date Paid","Document No.");

                trigger OnAfterGetRecord();
                begin
                    //Allow initialization entries having no link
                    if RecogEntry.GET("Comm. Recog. Entry No.") then
                      RecogEntry.CALCFIELDS("Basis Amt. Approved to Pay","Basis Amt. Paid")
                    else
                      CLEAR(RecogEntry);

                    InsertReportBufferPmt;
                end;

                trigger OnPreDataItem();
                begin
                    if TransactionFilter <> TransactionFilter::Paid then
                      CurrReport.BREAK;

                    CommCustSalesperson.COPYFILTER("Date Filter","Posting Date");
                end;
            }

            trigger OnAfterGetRecord();
            begin
                CALCFIELDS("Customer Name","Salesperson Name");
            end;

            trigger OnPreDataItem();
            begin
                Window.OPEN(Text002);
                DateFilter := GETFILTER("Date Filter");
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
                field("Transaction Type";TransactionFilter)
                {
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
        CLEAR(Window);
        MESSAGE(Text001);
    end;

    trigger OnPreReport();
    begin
        ReportBuffer.SETRANGE("User ID",USERID);
        ReportBuffer.DELETEALL;
        EntryNo := 1;

        RunDateTime := CURRENTDATETIME;
    end;

    var
        ReportBuffer : Record "Comm. Report Wksht. Buffer";
        RecogEntry : Record "Comm. Recognition Entry";
        ApprovalEntry : Record "Comm. Approval Entry";
        EntryNo : Integer;
        RunDateTime : DateTime;
        Window : Dialog;
        Text001 : Label 'Complete';
        Text002 : Label 'Calculating...';
        TransactionFilter : Option Recognized,Approved,Paid;
        DateFilter : Text[30];

    local procedure InsertReportBufferRecog();
    begin
        //Create both detail and summary records
        with ReportBuffer do begin
          //Summary
          SETRANGE("Salesperson Code",CommCustSalesperson."Salesperson Code");
          SETRANGE("Customer No.",CommCustSalesperson."Customer No.");
          SETRANGE("Document Type","Comm. Recognition Entry"."Document Type");
          SETRANGE("Document No.","Comm. Recognition Entry"."Document No.");
          if not FINDFIRST then begin
            INIT;
            "User ID" := USERID;
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
            INSERT;
            EntryNo += 1;
          end else begin
            "Basis Amt. Recognized" += "Comm. Recognition Entry"."Basis Amt.";
            "Basis Amt. Approved to Pay" += "Comm. Recognition Entry"."Basis Amt. Approved to Pay";
            "Comm. Amt. Paid" += "Comm. Recognition Entry"."Basis Amt. Paid";
            MODIFY;
          end;

          //Detail
          INIT;
          "User ID" := USERID;
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
          INSERT;
          EntryNo += 1;
        end;
    end;

    local procedure InsertReportBufferAppr();
    begin
        //Create both detail and summary records
        with ReportBuffer do begin
          //Summary
          SETRANGE("Salesperson Code",CommCustSalesperson."Salesperson Code");
          SETRANGE("Customer No.",CommCustSalesperson."Customer No.");
          SETRANGE("Document Type","Comm. Approval Entry"."Document Type");
          SETRANGE("Document No.","Comm. Approval Entry"."Document No.");
          if not FINDFIRST then begin
            INIT;
            "User ID" := USERID;
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
            INSERT;
            EntryNo += 1;
          end else begin
            "Basis Amt. Recognized" += RecogEntry."Basis Amt.";
            "Basis Amt. Approved to Pay" += RecogEntry."Basis Amt. Approved to Pay";
            "Comm. Amt. Paid" += RecogEntry."Basis Amt. Paid";
            MODIFY;
          end;

          //Detail
          INIT;
          "User ID" := USERID;
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
          INSERT;
          EntryNo += 1;
        end;
    end;

    local procedure InsertReportBufferPmt();
    begin
        //Create both detail and summary records
        with ReportBuffer do begin
          //Summary
          SETRANGE("Salesperson Code",CommCustSalesperson."Salesperson Code");
          SETRANGE("Customer No.",CommCustSalesperson."Customer No.");
          SETRANGE("Document Type",RecogEntry."Document Type");
          SETRANGE("Document No.",RecogEntry."Document No.");
          if not FINDFIRST then begin
            INIT;
            "User ID" := USERID;
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
            INSERT;
            EntryNo += 1;
          end else begin
            "Basis Amt. Recognized" += RecogEntry."Basis Amt.";
            "Basis Amt. Approved to Pay" += RecogEntry."Basis Amt. Approved to Pay";
            "Comm. Amt. Paid" += RecogEntry."Basis Amt. Paid";
            MODIFY;
          end;

          //Detail
          INIT;
          "User ID" := USERID;
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
          INSERT;
          EntryNo += 1;
        end;
    end;

    procedure GetReportFilters(var TransactionFilter2 : Option Recognized,Approved,Paid;var DateFilter2 : Text[30]);
    begin
        TransactionFilter2 := TransactionFilter;
        DateFilter2 := DateFilter;
    end;
}

