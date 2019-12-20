page 80011 "CommReportWorksheetTigCM"
{
    Caption = 'Commission Worksheet';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Tasks;
    SourceTable = CommReportWkshtBufferTigCM;
    SourceTableView = sorting("Salesperson Code", "Customer No.", "Document Type", "Document No.", Level);
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    SaveValues = true;

    layout
    {
        area(content)
        {
            group(View)
            {
                field("Data Level"; DataLevel)
                {
                    Caption = 'Data Level';
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Data Level';
                    OptionCaption = 'Detail,Summary';
                    Editable = false;
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Transaction Type"; TransactionFilter)
                {
                    Caption = 'Transaction Type';
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Transaction Type';
                    OptionCaption = 'Recognized,Approved,Paid';
                    Editable = false;
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Date Filter"; DateFilter)
                {
                    Caption = 'Date Filter';
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Date Filter';
                    Editable = false;
                    MultiLine = true;
                    Style = Strong;
                    StyleExpr = TRUE;
                    Width = 40;
                }
            }
            repeater(Group)
            {
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Salesperson Code';
                }
                field("Salesperson Name"; "Salesperson Name")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Salesperson Name';
                }
                field("Entry Type"; "Entry Type")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Entry Type';
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Customer No.';
                }
                field("Customer Name"; "Customer Name")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Customer Name';
                }
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Document Type';
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Document No.';
                }
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the External Document No.';
                }
                field("Posted Doc. No."; "Posted Doc. No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Posted Doc. No.';
                }
                field("Trigger Doc. No."; "Trigger Doc. No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Trigger Doc. No.';
                    Visible = false;
                }
                field("Basis Amt. Recognized"; "Basis Amt. Recognized")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Basis Amt. Recognized';
                }
                field("Basis Amt. Approved to Pay"; "Basis Amt. Approved to Pay")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Basis Amt. Approved to Pay';
                }
                field("Comm. Amt. Paid"; "Comm. Amt. Paid")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Comm. Amt. Paid';
                }
                field("Approved Date"; "Approved Date")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Approved Date';
                }
                field("Run Date-Time"; "Run Date-Time")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Run Date-Time';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Calc. Commissions")
            {
                ApplicationArea = All;
                ToolTip = 'Runs the Calculate Commissions process';
                Image = Calculator;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction();
                var
                    CalcReportWorksheet: Report "Commission-CalcRptWkshtTigCM";
                begin
                    Clear(CalcReportWorksheet);
                    CalcReportWorksheet.RunModal();
                    CalcReportWorksheet.GetReportFilters(TransactionFilter, DateFilter);
                    CurrPage.Update();
                end;
            }
            action("Toggle Level")
            {
                ApplicationArea = All;
                ToolTip = 'Toggles between Summary view and Detail view';
                Image = SwitchCompanies;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction();
                begin
                    if DataLevel = DataLevel::Detail then
                        DataLevel := DataLevel::Summary
                    else
                        DataLevel := DataLevel::Detail;
                    SetLevel();
                end;
            }
        }
    }

    var
        DataLevel: Option Detail,Summary;
        TransactionFilter: Option Recognized,Approved,Paid;
        DateFilter: Text[30];

    trigger OnOpenPage();
    begin
        FilterGroup(2);
        SetRange("User ID", CopyStr(UserId(), 1, MaxStrLen("User ID")));
        SetFilter("Entry No.", '>%1', 0);
        FilterGroup(0);

        SetLevel();
    end;

    local procedure SetLevel();
    begin
        FilterGroup(2);
        SetRange(Level, DataLevel);
        FilterGroup(0);
        CurrPage.Update();
    end;
}