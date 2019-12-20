page 80012 "CommPaymentEntriesTigCM"
{
    Caption = 'Commission Payment Entries';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = CommissionPaymentEntryTigCM;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Entry No.';
                }
                field("Entry Type"; "Entry Type")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Entry Type';
                }
                field("Batch Name"; "Batch Name")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Batch Name';
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Posting Date';
                }
                field("Payout Date"; "Payout Date")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Payout Date';
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Salesperson Code';
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Document No.';
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Amount';
                }
                field("Comm. Recog. Entry No."; "Comm. Recog. Entry No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Comm. Recog. Entry No.';
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Customer No.';
                }
                field("Created Date"; "Created Date")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Created Date';
                }
                field("Created By"; "Created By")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Created By';
                }
                field("Payment Method"; "Payment Method")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Payment Method';
                }
                field("Payment Ref. No."; "Payment Ref. No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Payment Ref. No.';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Description';
                }
                field(Posted; Posted)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Posted';
                }
            }
        }
    }
}