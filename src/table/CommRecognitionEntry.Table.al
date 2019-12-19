table 80013 "CommRecognitionEntryTigCM"
{
    Caption = 'Commission Recognition Entry';
    DataClassification = CustomerContent;
    DrillDownPageID = CommRecognitionEntriesTigCM;
    LookupPageID = CommRecognitionEntriesTigCM;

    fields
    {
        field(10; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(20; "Comm. Ledger Entry No."; Integer)
        {
            Caption = 'Commission Ledger Entry No.';
            DataClassification = CustomerContent;
            TableRelation = CommissionSetupSummaryTigCM."Entry No.";
        }
        field(21; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            DataClassification = CustomerContent;
            OptionMembers = Commission,Clawback,Advance,Adjustment;
            OptionCaption = 'Commission,Clawback,Advance,Adjustment';
        }
        field(22; "Value Entry No."; Integer)
        {
            Caption = 'Value Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "Value Entry"."Entry No.";
        }
        field(23; "Item Ledger Entry No."; Integer)
        {
            Caption = 'Item Ledger Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "Item Ledger Entry"."Entry No.";
        }
        field(25; "Document Type"; Option)
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order",,Adjustment;
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order,,Adjustment';
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
            OptionMembers = " ","G/L Account",Item,Resource,"Fixed Asset","Charge (Item)";
            OptionCaption = ' ,G/L Account,Item,Resource';
        }
        field(60; "Unit No."; Code[20])
        {
            Caption = 'Unit No.';
            DataClassification = CustomerContent;
        }
        field(70; "Basis Qty."; Decimal)
        {
            Caption = 'Basis Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
        }
        field(110; "Basis Qty. Approved to Pay"; Decimal)
        {
            Caption = 'Basis Qty. Approved to Pay';
            FieldClass = FlowField;
            CalcFormula = Sum (CommApprovalEntryTigCM."Basis Qty. Approved" where("Comm. Recog. Entry No." = field("Entry No.")));
            Editable = false;
            DecimalPlaces = 0 : 2;
        }
        field(120; "Basis Qty. Paid"; Decimal)
        {
            Caption = 'Basis Quantity Paid';
            FieldClass = FlowField;
            CalcFormula = Min (CommissionPaymentEntryTigCM.Quantity where("Comm. Recog. Entry No." = field("Entry No.")));
            Editable = false;
            DecimalPlaces = 0 : 2;
        }
        field(130; "Basis Qty. Remaining"; Decimal)
        {
            Caption = 'Basis Quantity Remaining';
            FieldClass = FlowField;
            CalcFormula = Sum (CommApprovalEntryTigCM."Qty. Remaining to Pay" where("Comm. Recog. Entry No." = field("Entry No.")));
            Editable = false;
            DecimalPlaces = 0 : 2;
        }
        field(140; "Basis Amt."; Decimal)
        {
            Caption = 'Nasis Amount';
            DataClassification = CustomerContent;
        }
        field(150; "Basis Amt. Approved to Pay"; Decimal)
        {
            Caption = 'Basis Amt. Approved to Pay';
            FieldClass = FlowField;
            CalcFormula = Sum (CommApprovalEntryTigCM."Basis Amt. Approved" where("Comm. Recog. Entry No." = field("Entry No.")));
            Editable = false;
        }
        field(160; "Basis Amt. Paid"; Decimal)
        {
            Caption = 'Basis Amount Paid';
            FieldClass = FlowField;
            CalcFormula = Sum (CommissionPaymentEntryTigCM.Amount where("Comm. Recog. Entry No." = field("Entry No.")));
            Editable = false;
        }
        field(170; "Basis Amt. Remaining"; Decimal)
        {
            Caption = 'Basis Amount Remaining';
            FieldClass = FlowField;
            CalcFormula = Sum (CommApprovalEntryTigCM."Amt. Remaining to Pay" where("Comm. Recog. Entry No." = field("Entry No.")));
            Editable = false;
        }
        field(180; Open; Boolean)
        {
            Caption = 'Open';
            DataClassification = CustomerContent;
        }
        field(190; "Commission Plan Code"; Code[20])
        {
            Caption = 'Commission Plan Code';
            DataClassification = CustomerContent;
            TableRelation = CommissionPlanTigCM.Code;
        }
        field(200; "Trigger Method"; Option)
        {
            Caption = 'Trigger Method';
            DataClassification = CustomerContent;
            OptionMembers = Booking,Shipment,Invoice,Payment,,,Credit;
            OptionCaption = 'Booking,Shipment,Invoice,Payment,,,Credit';
        }
        field(210; "Trigger Document No."; Code[20])
        {
            Caption = 'Trigger Document No.';
            DataClassification = CustomerContent;
        }
        field(220; "Trigger Posting Date"; Date)
        {
            Caption = 'Trigger Posting Date';
            DataClassification = CustomerContent;
        }
        field(230; "Creation Date"; Date)
        {
            Caption = 'Creation Date';
            DataClassification = CustomerContent;
        }
        field(240; "Created By"; Code[50])
        {
            Caption = 'Createrd By';
            DataClassification = CustomerContent;
            TableRelation = User."User Name";
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