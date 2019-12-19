table 80002 "CommissionPlanPayeeTigCM"
{
    Caption = 'Commission Plan Payee';
    DataClassification = CustomerContent;

    fields
    {
        field(10; "Commission Plan Code"; Code[20])
        {
            Caption = 'Commission plan Code';
            DataClassification = CustomerContent;
            TableRelation = CommissionPlanTigCM.Code;
        }
        field(40; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser".Code;
        }
        field(50; "Manager Split Pct."; Decimal)
        {
            Caption = 'Manager Split Percent';
            DataClassification = CustomerContent;

            trigger OnValidate();
            var
                CommPlan: Record CommissionPlanTigCM;
                ManagerLevelErr: Label 'Manager Split Pct. not available unless the Commission Plan is a Manager Level Plan.';
            begin
                if "Manager Split Pct." = 0 then
                    exit;

                CommPlan.Get("Commission Plan Code");
                if not CommPlan."Manager Level" then
                    Error(ManagerLevelErr);
            end;
        }
        field(60; "Distribution Method"; Option)
        {
            Caption = 'Distribution Method';
            DataClassification = CustomerContent;
            OptionMembers = Vendor,"External Provider",Manual;
            OptionCaption = 'Vendor,External Provider,Manual';

            trigger OnValidate();
            var
                FeatureNotEnabledErr: Label 'Feature not enabled.';
            begin
                if "Distribution Method" = "Distribution Method"::"External Provider" then
                    Error(FeatureNotEnabledErr);
            end;
        }
        field(70; "Distribution Code"; Code[20])
        {
            Caption = 'Distribution Code';
            DataClassification = CustomerContent;
            TableRelation = if ("Distribution Method" = const(Vendor)) Vendor;

            trigger OnValidate();
            begin
                SetDefaultMgrSplit();
            end;
        }
        field(80; "Distribution Account No."; Code[20])
        {
            Caption = 'Distribution Account No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" where("Direct Posting" = const(true));
        }
        field(200; "Salesperson Name"; Text[50])
        {
            Caption = 'Salesperson Name';
            FieldClass = FlowField;
            CalcFormula = Lookup ("Salesperson/Purchaser".Name WHERE(Code = FIELD("Salesperson Code")));
            Editable = false;
        }
        field(210; "Distribution Name"; Text[50])
        {
            Caption = 'Distribution Name';
            FieldClass = FlowField;
            CalcFormula = Lookup (Vendor.Name where("No." = field("Distribution Code")));
            Editable = false;
        }
        field(220; "Comm. Plan Description"; Text[50])
        {
            Caption = 'Commission Plan Description';
            FieldClass = FlowField;
            CalcFormula = Lookup (CommissionPlanTigCM.Description where(Code = field("Commission Plan Code")));
            Editable = false;
        }
        field(230; "Manager Level"; Boolean)
        {
            Caption = 'Manager Level';
            FieldClass = FlowField;
            CalcFormula = Lookup (CommissionPlanTigCM."Manager Level" where(Code = field("Commission Plan Code")));
            Editable = false;

            trigger OnValidate();
            begin
                SetDefaultMgrSplit();
            end;
        }
    }

    keys
    {
        key(PK; "Commission Plan Code", "Salesperson Code")
        {
            Clustered = true;
        }
    }

    local procedure SetDefaultMgrSplit();
    begin
        CalcFields("Manager Level");
        if "Manager Level" then
            Validate("Manager Split Pct.", 100)
        else
            Validate("Manager Split Pct.", 0);
    end;
}

