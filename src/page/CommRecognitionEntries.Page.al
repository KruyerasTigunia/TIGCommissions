page 80013 "CommRecognitionEntriesTigCM"
{
    Caption = 'Commission Recognition Entries';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = CommRecognitionEntryTigCM;
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
                field("Item Ledger Entry No."; "Item Ledger Entry No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Item Ledger Entry No.';
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Document No.';
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
                field("Basis Qty."; "Basis Qty.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Basis Qty.';
                }
                field("Basis Amt."; "Basis Amt.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Basis Amt.';
                }
                field("Basis Qty. Approved to Pay"; "Basis Qty. Approved to Pay")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Basis Qty. Approved to Pay';
                }
                field("Basis Amt. Approved to Pay"; "Basis Amt. Approved to Pay")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Basis Amt. Approved to Pay';
                }
                field("Basis Qty. Paid"; "Basis Qty. Paid")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Basis Qty. Paid';
                }
                field("Basis Amt. Paid"; "Basis Amt. Paid")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Basis Amt. Paid';
                }
                field("Basis Qty. Remaining"; "Basis Qty. Remaining")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Basis Qty. Remaining';
                }
                field("Basis Amt. Remaining"; "Basis Amt. Remaining")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Basis Amt. Remaining';
                }
                field(Open; Open)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Open';
                }
                field("Document Line No."; "Document Line No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Document Line No.';
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
                field("Creation Date"; "Creation Date")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Creation Date';
                }
                field("Created By"; "Created By")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Created By';
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