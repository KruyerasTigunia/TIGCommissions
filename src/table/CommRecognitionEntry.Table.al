table 80013 "CommRecognitionEntryTigCM"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions

    DrillDownPageID = CommRecognitionEntriesTigCM;
    LookupPageID = CommRecognitionEntriesTigCM;

    fields
    {
        field(10; "Entry No."; Integer)
        {
            AutoIncrement = true;
        }
        field(20; "Comm. Ledger Entry No."; Integer)
        {
            Description = 'DEPR';
            TableRelation = CommissionSetupSummaryTigCM;
        }
        field(21; "Entry Type"; Option)
        {
            OptionMembers = Commission,Clawback,Advance,Adjustment;
        }
        field(22; "Value Entry No."; Integer)
        {
            TableRelation = "Value Entry";
        }
        field(23; "Item Ledger Entry No."; Integer)
        {
            TableRelation = "Item Ledger Entry";
        }
        field(25; "Document Type"; Option)
        {
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order",,Adjustment;
        }
        field(30; "Document No."; Code[20])
        {
        }
        field(35; "Document Line No."; Integer)
        {
        }
        field(40; "Customer No."; Code[20])
        {
            TableRelation = Customer;
        }
        field(50; "Unit Type"; Option)
        {
            OptionCaption = ',G/L Account,Item,Resource';
            OptionMembers = " ","G/L Account",Item,Resource,"Fixed Asset","Charge (Item)";
        }
        field(60; "Unit No."; Code[20])
        {
        }
        field(70; "Basis Qty."; Decimal)
        {
            DecimalPlaces = 0 : 2;
        }
        field(110; "Basis Qty. Approved to Pay"; Decimal)
        {
            CalcFormula = Sum (CommApprovalEntryTigCM."Basis Qty. Approved" WHERE("Comm. Recog. Entry No." = FIELD("Entry No.")));
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(120; "Basis Qty. Paid"; Decimal)
        {
            CalcFormula = Min (CommissionPaymentEntryTigCM.Quantity WHERE("Comm. Recog. Entry No." = FIELD("Entry No.")));
            DecimalPlaces = 0 : 2;
            Editable = false;
            FieldClass = FlowField;
        }
        field(130; "Basis Qty. Remaining"; Decimal)
        {
            CalcFormula = Sum (CommApprovalEntryTigCM."Qty. Remaining to Pay" WHERE("Comm. Recog. Entry No." = FIELD("Entry No.")));
            DecimalPlaces = 0 : 2;
            Description = 'DEPR';
            Editable = false;
            FieldClass = FlowField;
        }
        field(140; "Basis Amt."; Decimal)
        {
        }
        field(150; "Basis Amt. Approved to Pay"; Decimal)
        {
            CalcFormula = Sum (CommApprovalEntryTigCM."Basis Amt. Approved" WHERE("Comm. Recog. Entry No." = FIELD("Entry No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(160; "Basis Amt. Paid"; Decimal)
        {
            CalcFormula = Sum (CommissionPaymentEntryTigCM.Amount WHERE("Comm. Recog. Entry No." = FIELD("Entry No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(170; "Basis Amt. Remaining"; Decimal)
        {
            CalcFormula = Sum (CommApprovalEntryTigCM."Amt. Remaining to Pay" WHERE("Comm. Recog. Entry No." = FIELD("Entry No.")));
            Description = 'DEPR';
            Editable = false;
            FieldClass = FlowField;
        }
        field(180; Open; Boolean)
        {
        }
        field(190; "Commission Plan Code"; Code[20])
        {
            TableRelation = CommissionPlanTigCM;
        }
        field(200; "Trigger Method"; Option)
        {
            OptionMembers = Booking,Shipment,Invoice,Payment,,,Credit;
        }
        field(210; "Trigger Document No."; Code[20])
        {
        }
        field(220; "Trigger Posting Date"; Date)
        {
        }
        field(230; "Creation Date"; Date)
        {
        }
        field(240; "Created By"; Code[50])
        {
            TableRelation = User."User Name";
        }
        field(250; "External Document No."; Code[20])
        {
        }
        field(260; Description; Text[50])
        {
        }
        field(270; "Description 2"; Text[50])
        {
        }
        field(280; "Reason Code"; Code[20])
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
        key(Key2; "Comm. Ledger Entry No.")
        {
            SumIndexFields = "Basis Qty.", "Basis Amt.";
        }
        key(Key3; "Customer No.", "Document Type", "Document No.", "Document Line No.")
        {
        }
        key(Key4; "Document Type", "Document No.", "Document Line No.")
        {
        }
        key(Key5; Open)
        {
        }
        key(Key6; "Commission Plan Code")
        {
        }
        key(Key7; "Entry Type")
        {
        }
        key(Key8; "Customer No.", "Trigger Posting Date", "Document Type", "Document No.")
        {
            SumIndexFields = "Basis Qty.", "Basis Amt.";
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Entry No.", "Entry Type", "Document No.")
        {
        }
    }
}

