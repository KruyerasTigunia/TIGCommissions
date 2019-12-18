page 80012 "CommPaymentEntriesTigCM"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions

    Editable = false;
    PageType = List;
    SourceTable = CommissionPaymentEntryTigCM;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                }
                field("Entry Type"; "Entry Type")
                {
                }
                field("Batch Name"; "Batch Name")
                {
                }
                field("Posting Date"; "Posting Date")
                {
                }
                field("Payout Date"; "Payout Date")
                {
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                }
                field("Document No."; "Document No.")
                {
                }
                field(Amount; Amount)
                {
                }
                field("Comm. Recog. Entry No."; "Comm. Recog. Entry No.")
                {
                }
                field("Customer No."; "Customer No.")
                {
                }
                field("Created Date"; "Created Date")
                {
                }
                field("Created By"; "Created By")
                {
                }
                field("Payment Method"; "Payment Method")
                {
                }
                field("Payment Ref. No."; "Payment Ref. No.")
                {
                }
                field(Description; Description)
                {
                }
                field(Posted; Posted)
                {
                }
            }
        }
    }

    actions
    {
    }
}

