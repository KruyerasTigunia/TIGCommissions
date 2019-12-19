table 80016 "CommApprovalEntryTigCM"
{
    Caption = 'Commission Approval Entry';
    DataClassification = CustomerContent;
    DrillDownPageID = CommApprovalEntriesTigCM;
    LookupPageID = CommApprovalEntriesTigCM;

    fields
    {
        field(10; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(15; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            DataClassification = CustomerContent;
            OptionMembers = Commission,Clawback,Advance,Adjustment;
        }
        field(19; "Det. Cust. Ledger Entry No."; Integer)
        {
            Caption = 'Detailed Cust. Ledher Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "Detailed Cust. Ledg. Entry"."Entry No.";
        }
        field(20; "Comm. Recog. Entry No."; Integer)
        {
            Caption = 'Commission Recognition Entry No.';
            DataClassification = CustomerContent;
            TableRelation = CommRecognitionEntryTigCM."Entry No.";
        }
        field(25; "Comm. Ledger Entry No."; Integer)
        {
            Caption = 'Commission Ledger Entry No.';
            DataClassification = CustomerContent;
            TableRelation = CommissionSetupSummaryTigCM."Entry No.";
        }
        field(28; "Document Type"; Option)
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order",,Adjustment;
        }
        field(30; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(35; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
            DataClassification = CustomerContent;
        }
        field(40; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
        }
        field(50; "Unit Type"; Option)
        {
            Caption = 'Unit Type';
            DataClassification = CustomerContent;
            OptionMembers = ,"G/L Account",Item,Resource;
        }
        field(60; "Unit No."; Code[20])
        {
            Caption = 'Unit No.';
            DataClassification = CustomerContent;
        }
        field(70; "Basis Qty. Approved"; Decimal)
        {
            Caption = 'Basis Quantity Approved';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
        }
        field(90; "Qty. Paid"; Decimal)
        {
            Caption = 'Quantity Paid';
            FieldClass = FlowField;
            CalcFormula = Min (CommissionPaymentEntryTigCM.Quantity WHERE("Comm. Appr. Entry No." = FIELD("Entry No.")));
            Editable = false;
            DecimalPlaces = 0 : 2;
        }
        field(100; "Qty. Remaining to Pay"; Decimal)
        {
            Caption = 'Quantity Remaining to Pay';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            Description = 'DEPR';
        }
        field(110; "Basis Amt. Approved"; Decimal)
        {
            Caption = 'Basis Amount Approved';
            DataClassification = CustomerContent;
        }
        field(120; "Comm. Amt. Paid"; Decimal)
        {
            Caption = 'Commission Amount Paid';
            FieldClass = FlowField;
            CalcFormula = Sum (CommissionPaymentEntryTigCM.Amount WHERE("Comm. Appr. Entry No." = FIELD("Entry No.")));
            Editable = false;
        }
        field(130; "Amt. Remaining to Pay"; Decimal)
        {
            Caption = 'Amount Remaining to Pay';
            DataClassification = CustomerContent;
        }
        field(140; Open; Boolean)
        {
            Caption = 'Open';
            DataClassification = CustomerContent;
        }
        field(150; "Commission Plan Code"; Code[20])
        {
            Caption = 'Commission Plan Code';
            DataClassification = CustomerContent;
            TableRelation = CommissionPlanTigCM.Code;
        }
        field(160; "Trigger Method"; Option)
        {
            Caption = 'Trigger Method';
            DataClassification = CustomerContent;
            OptionMembers = Booking,Shipment,Invoice,Payment,,,Credit;
        }
        field(170; "Trigger Document No."; Code[20])
        {
            Caption = 'Trigger Document No.';
            DataClassification = CustomerContent;
        }
        field(180; "Trigger Posting Date"; Date)
        {
            Caption = 'Trigger Posting Date';
            DataClassification = CustomerContent;
        }
        field(190; "Released to Pay Date"; Date)
        {
            Caption = 'Released to Pay Date';
            DataClassification = CustomerContent;
        }
        field(200; "Released to Pay By"; Code[50])
        {
            Caption = 'Released to Pay By';
            DataClassification = CustomerContent;
            TableRelation = User."User Name";
        }
        field(210; "Basis Amt. (Wksht.)"; Decimal)
        {
            Caption = 'Basis Amount (Worksheet)';
            FieldClass = FlowField;
            CalcFormula = Sum (CommissionWksheetLineTigCM."Basis Amt. (Split)" WHERE("Comm. Approval Entry No." = FIELD("Entry No.")));
            Editable = false;
        }
        field(220; "Basis Qty. (Wksht.)"; Decimal)
        {
            Caption = 'Basis Quantity (Worksheet)';
            FieldClass = FlowField;
            CalcFormula = Sum (CommissionWksheetLineTigCM.Quantity WHERE("Comm. Approval Entry No." = FIELD("Entry No.")));
            Editable = false;
        }
        field(250; "External Document No."; Code[20])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
        }
        field(260; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(270; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
            DataClassification = CustomerContent;
        }
        field(280; "Reason Code"; Code[20])
        {
            Caption = 'Reason Code';
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
        key(Key2; "Comm. Recog. Entry No.")
        {
            SumIndexFields = "Basis Qty. Approved", "Qty. Remaining to Pay", "Basis Amt. Approved", "Amt. Remaining to Pay";
        }
        key(Key3; "Comm. Ledger Entry No.")
        {
            SumIndexFields = "Basis Amt. Approved", "Amt. Remaining to Pay";
        }
        key(Key4; "Customer No.", "Document Type", "Document No.", "Document Line No.")
        {
        }
        key(Key5; "Document Type", "Document No.", "Document Line No.")
        {
            SumIndexFields = "Basis Qty. Approved", "Qty. Remaining to Pay", "Basis Amt. Approved", "Amt. Remaining to Pay";
        }
        key(Key6; "Customer No.", Open)
        {
        }
        key(Key7; "Customer No.", "Trigger Posting Date", "Document Type", "Document No.")
        {
            SumIndexFields = "Basis Qty. Approved", "Qty. Remaining to Pay", "Basis Amt. Approved", "Amt. Remaining to Pay";
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Entry No.", "Entry Type", "Document No.")
        {
        }
    }
}