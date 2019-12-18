table 80012 "CommissionPaymentEntryTigCM"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions

    DrillDownPageID = CommPaymentEntriesTigCM;
    LookupPageID = CommPaymentEntriesTigCM;

    fields
    {
        field(10; "Entry No."; Integer)
        {
            AutoIncrement = true;
        }
        field(20; "Entry Type"; Option)
        {
            OptionMembers = Commission,Clawback,Advance,Adjustment,Payment;
        }
        field(30; "Batch Name"; Code[20])
        {
        }
        field(40; "Posting Date"; Date)
        {
        }
        field(50; "Payout Date"; Date)
        {
        }
        field(60; "Salesperson Code"; Code[20])
        {
            TableRelation = "Salesperson/Purchaser";
        }
        field(70; "Document No."; Code[20])
        {
        }
        field(75; Quantity; Decimal)
        {
            DecimalPlaces = 0 : 2;
        }
        field(80; Amount; Decimal)
        {
        }
        field(90; "Comm. Recog. Entry No."; Integer)
        {
            TableRelation = CommRecognitionEntryTigCM;
        }
        field(95; "Comm. Ledger Entry No."; Integer)
        {
            Description = 'DEPR';
            TableRelation = CommissionSetupSummaryTigCM;
        }
        field(96; "Comm. Appr. Entry No."; Integer)
        {
            TableRelation = CommApprovalEntryTigCM;
        }
        field(100; "Customer No."; Code[20])
        {
            TableRelation = Customer;
        }
        field(120; "Created Date"; Date)
        {
        }
        field(130; "Created By"; Code[50])
        {
            TableRelation = User."User Name";
        }
        field(140; "Unit Type"; Option)
        {
            OptionCaption = ',G/L Account,Item,Resource';
            OptionMembers = " ","G/L Account",Item,Resource,"Fixed Asset","Charge (Item)";
        }
        field(150; "Unit No."; Code[20])
        {
        }
        field(160; "Commission Plan Code"; Code[20])
        {
            TableRelation = CommissionPlanTigCM;
        }
        field(170; "Trigger Method"; Option)
        {
            OptionMembers = Booking,Shipment,Invoice,Payment,,,Credit;
        }
        field(180; "Trigger Document No."; Code[20])
        {
        }
        field(190; "Released to Pay"; Boolean)
        {
        }
        field(200; "Released to Pay Date"; Date)
        {
        }
        field(210; "Released to Pay By"; Code[50])
        {
            TableRelation = User."User Name";
        }
        field(220; "Payment Method"; Option)
        {
            OptionMembers = "Check as Vendor",Payroll;
        }
        field(230; "Payment Ref. No."; Code[20])
        {
        }
        field(240; "Payment Ref. Line No."; Integer)
        {
        }
        field(250; "Date Paid"; Date)
        {
        }
        field(260; Description; Text[50])
        {
        }
        field(280; Posted; Boolean)
        {
        }
        field(290; "Posted Doc. No."; Code[20])
        {
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Salesperson Code", "Customer No.")
        {
        }
        key(Key3; "Comm. Ledger Entry No.")
        {
            SumIndexFields = Quantity, Amount;
        }
        key(Key4; "Comm. Recog. Entry No.")
        {
            SumIndexFields = Quantity, Amount;
        }
        key(Key5; "Comm. Appr. Entry No.")
        {
            SumIndexFields = Quantity, Amount;
        }
        key(Key6; "Customer No.")
        {
        }
        key(Key7; "Payment Method", "Payment Ref. No.", "Payment Ref. Line No.")
        {
        }
        key(Key8; "Customer No.", "Date Paid", "Document No.")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Entry No.", "Entry Type", "Document No.")
        {
        }
    }
}

