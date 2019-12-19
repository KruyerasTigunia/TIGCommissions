table 80011 "CommissionSetupSummaryTigCM"
{
    Caption = 'Commission Setup Summary';
    DataClassification = CustomerContent;
    DrillDownPageID = CommReportWorksheetTigCM;
    LookupPageID = CommReportWorksheetTigCM;

    fields
    {
        field(10; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = CustomerContent;
        }
        field(20; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(30; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
        }
        field(40; "Cust. Salesperson Code"; Code[20])
        {
            Caption = 'Customer Salesperson Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser".Code;
        }
        field(45; "Pay Salesperson Code"; Code[20])
        {
            Caption = 'Pay Salesperson Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser".Code;
        }
        field(50; "Comm. Plan Code"; Code[20])
        {
            Caption = 'Commission Plan Code';
            DataClassification = CustomerContent;
            TableRelation = CommissionPlanTigCM.Code;
        }
        field(60; "Commission Rate"; Decimal)
        {
            Caption = 'Commission Rate';
            DataClassification = CustomerContent;
        }
        field(1000; "Customer Name"; Text[50])
        {
            Caption = 'Customer Name';
            FieldClass = FlowField;
            CalcFormula = Lookup (Customer.Name where("No." = field("Customer No.")));
            Editable = false;
        }
        field(1010; "Salesperson Name"; Text[50])
        {
            Caption = 'Salesperson Name';
            FieldClass = FlowField;
            CalcFormula = Lookup ("Salesperson/Purchaser".Name where(Code = field("Cust. Salesperson Code")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "User ID", "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Customer No.", "Cust. Salesperson Code")
        {
        }
        key(Key3; "Cust. Salesperson Code", "Customer No.")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "User ID", "Entry No.", "Cust. Salesperson Code")
        {
        }
    }
}