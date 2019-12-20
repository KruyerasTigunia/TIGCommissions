page 80017 "CommApprovalEntriesTigCM"
{
    Caption = 'Commission Approval Entries';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = CommApprovalEntryTigCM;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry Type"; "Entry Type")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Entry Type';
                }
                field("Det. Cust. Ledger Entry No."; "Det. Cust. Ledger Entry No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Det. Cust. Ledger Entry No.';
                }
                field("Comm. Recog. Entry No."; "Comm. Recog. Entry No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Comm. Recog. Entry No.';
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
                field("Document Line No."; "Document Line No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Document Line No.';
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Customer No.';
                }
                field("Unit Type"; "Unit Type")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Unit Type';
                }
                field("Unit No."; "Unit No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Unit No.';
                }
                field("Basis Qty. Approved"; "Basis Qty. Approved")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Basis Qty. Approved';
                }
                field("Qty. Paid"; "Qty. Paid")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Qty. Paid';
                }
                field("Qty. Remaining to Pay"; "Qty. Remaining to Pay")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Qty. Remaining to Pay';
                }
                field("Basis Amt. Approved"; "Basis Amt. Approved")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Basis Amt. Approved';
                }
                field("Comm. Amt. Paid"; "Comm. Amt. Paid")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Comm. Amt. Paid';
                }
                field("Amt. Remaining to Pay"; "Amt. Remaining to Pay")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Amt. Remaining to Pay';
                }
                field(Open; Open)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Open';
                }
                field("Commission Plan Code"; "Commission Plan Code")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Commission Plan Code';
                }
                field("Trigger Method"; "Trigger Method")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Trigger Method';
                }
                field("Trigger Document No."; "Trigger Document No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Trigger Document No.';
                }
                field("Trigger Posting Date"; "Trigger Posting Date")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Trigger Posting Date';
                }
                field("Released to Pay Date"; "Released to Pay Date")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Released to Pay Date';
                }
                field("Released to Pay By"; "Released to Pay By")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Released to Pay By';
                }
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the External Document No.';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Description';
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Description 2';
                }
                field("Reason Code"; "Reason Code")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Reason Code';
                }
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Entry No.';
                }
            }
        }
    }
}