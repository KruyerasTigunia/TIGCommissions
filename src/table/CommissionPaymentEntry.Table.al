table 80012 "CommissionPaymentEntryTigCM"
{
    Caption = 'Commission Payment Entry';
    DataClassification = CustomerContent;
    DrillDownPageID = CommPaymentEntriesTigCM;
    LookupPageID = CommPaymentEntriesTigCM;

    fields
    {
        field(10; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(20; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            DataClassification = CustomerContent;
            OptionMembers = Commission,Clawback,Advance,Adjustment,Payment;
        }
        field(30; "Batch Name"; Code[20])
        {
            Caption = 'Batch Name';
            DataClassification = CustomerContent;
        }
        field(40; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(50; "Payout Date"; Date)
        {
            Caption = 'Payout Date';
            DataClassification = CustomerContent;
        }
        field(60; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser".Code;
        }
        field(70; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(75; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
        }
        field(80; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(90; "Comm. Recog. Entry No."; Integer)
        {
            Caption = 'Commission Recognition Entry No.';
            DataClassification = CustomerContent;
            TableRelation = CommRecognitionEntryTigCM."Entry No.";
        }
        field(95; "Comm. Ledger Entry No."; Integer)
        {
            Caption = 'Commission Ledger Entry No.';
            DataClassification = CustomerContent;
            TableRelation = CommissionSetupSummaryTigCM."Entry No.";
        }
        field(96; "Comm. Appr. Entry No."; Integer)
        {
            Caption = 'Commission Approval Entry No';
            DataClassification = CustomerContent;
            TableRelation = CommApprovalEntryTigCM."Entry No.";
        }
        field(100; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
        }
        field(120; "Created Date"; Date)
        {
            Caption = 'Created Date';
            DataClassification = CustomerContent;
        }
        field(130; "Created By"; Code[50])
        {
            Caption = 'Created By';
            DataClassification = CustomerContent;
            TableRelation = User."User Name";
        }
        field(140; "Unit Type"; Option)
        {
            Caption = 'Unit Type';
            DataClassification = CustomerContent;
            OptionCaption = ',G/L Account,Item,Resource';
            OptionMembers = " ","G/L Account",Item,Resource,"Fixed Asset","Charge (Item)";
        }
        field(150; "Unit No."; Code[20])
        {
            Caption = 'Unit No.';
            DataClassification = CustomerContent;
        }
        field(160; "Commission Plan Code"; Code[20])
        {
            Caption = 'Commission Plan Code';
            DataClassification = CustomerContent;
            TableRelation = CommissionPlanTigCM.Code;
        }
        field(170; "Trigger Method"; Option)
        {
            Caption = 'Trigger Method';
            DataClassification = CustomerContent;
            OptionMembers = Booking,Shipment,Invoice,Payment,,,Credit;
        }
        field(180; "Trigger Document No."; Code[20])
        {
            Caption = 'Trigger Document No.';
            DataClassification = CustomerContent;
        }
        field(190; "Released to Pay"; Boolean)
        {
            Caption = 'Released to Pay';
            DataClassification = CustomerContent;
        }
        field(200; "Released to Pay Date"; Date)
        {
            Caption = 'Released to Pay Date';
            DataClassification = CustomerContent;
        }
        field(210; "Released to Pay By"; Code[50])
        {
            Caption = 'Released to Pay By';
            DataClassification = CustomerContent;
            TableRelation = User."User Name";
        }
        field(220; "Payment Method"; Option)
        {
            Caption = 'Payment Method';
            DataClassification = CustomerContent;
            OptionMembers = "Check as Vendor",Payroll;
        }
        field(230; "Payment Ref. No."; Code[20])
        {
            Caption = 'Payment Reference No.';
            DataClassification = CustomerContent;
        }
        field(240; "Payment Ref. Line No."; Integer)
        {
            Caption = 'Payment Reference Line No.';
            DataClassification = CustomerContent;
        }
        field(250; "Date Paid"; Date)
        {
            Caption = 'Date Paid';
            DataClassification = CustomerContent;
        }
        field(260; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(280; Posted; Boolean)
        {
            Caption = 'Posted';
            DataClassification = CustomerContent;
        }
        field(290; "Posted Doc. No."; Code[20])
        {
            Caption = 'Posted Document No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
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