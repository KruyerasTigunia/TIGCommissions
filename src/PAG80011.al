page 80011 "Comm. Report Worksheet"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions

    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SaveValues = true;
    SourceTable = "Comm. Report Wksht. Buffer";
    SourceTableView = SORTING("Salesperson Code","Customer No.","Document Type","Document No.",Level);

    layout
    {
        area(content)
        {
            group(View)
            {
                field("Data Level";DataLevel)
                {
                    Editable = false;
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Transaction Type";TransactionFilter)
                {
                    Editable = false;
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Date Filter";DateFilter)
                {
                    Editable = false;
                    MultiLine = true;
                    Style = Strong;
                    StyleExpr = TRUE;
                    Width = 40;
                }
            }
            repeater(Group)
            {
                field("Salesperson Code";"Salesperson Code")
                {
                }
                field("Salesperson Name";"Salesperson Name")
                {
                }
                field("Entry Type";"Entry Type")
                {
                }
                field("Customer No.";"Customer No.")
                {
                }
                field("Customer Name";"Customer Name")
                {
                }
                field("Document Type";"Document Type")
                {
                }
                field("Document No.";"Document No.")
                {
                }
                field("External Document No.";"External Document No.")
                {
                }
                field("Posted Doc. No.";"Posted Doc. No.")
                {
                }
                field("Trigger Doc. No.";"Trigger Doc. No.")
                {
                    Visible = false;
                }
                field("Basis Amt. Recognized";"Basis Amt. Recognized")
                {
                }
                field("Basis Amt. Approved to Pay";"Basis Amt. Approved to Pay")
                {
                }
                field("Comm. Amt. Paid";"Comm. Amt. Paid")
                {
                }
                field("Approved Date";"Approved Date")
                {
                }
                field("Run Date-Time";"Run Date-Time")
                {
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
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction();
                var
                    CalcReportWorksheet : Report "Commission-Calc Report Wksht.";
                begin
                    CLEAR(CalcReportWorksheet);
                    CalcReportWorksheet.RUNMODAL;
                    CalcReportWorksheet.GetReportFilters(TransactionFilter,DateFilter);
                    CurrPage.UPDATE;
                end;
            }
            action("Toggle Level")
            {
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction();
                begin
                    if DataLevel = DataLevel::Detail then
                      DataLevel := DataLevel::Summary
                    else
                      DataLevel := DataLevel::Detail;
                    SetLevel;
                end;
            }
        }
    }

    trigger OnOpenPage();
    begin
        FILTERGROUP(2);
        SETRANGE("User ID",USERID);
        SETFILTER("Entry No.",'>%1',0);
        FILTERGROUP(0);

        SetLevel;
    end;

    var
        DataLevel : Option Detail,Summary;
        TransactionFilter : Option Recognized,Approved,Paid;
        DateFilter : Text[30];

    local procedure SetLevel();
    begin
        FILTERGROUP(2);
        SETRANGE(Level,DataLevel);
        FILTERGROUP(0);
        CurrPage.UPDATE;
    end;
}

