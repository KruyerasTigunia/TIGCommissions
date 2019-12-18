table 80002 "Commission Plan Payee"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions


    fields
    {
        field(10;"Commission Plan Code";Code[20])
        {
            TableRelation = "Commission Plan";
        }
        field(40;"Salesperson Code";Code[20])
        {
            TableRelation = "Salesperson/Purchaser";
        }
        field(50;"Manager Split Pct.";Decimal)
        {

            trigger OnValidate();
            begin
                if "Manager Split Pct." <> 0 then begin
                  CommPlan.GET("Commission Plan Code");
                  if not CommPlan."Manager Level" then
                    ERROR(Text001);
                end;
            end;
        }
        field(60;"Distribution Method";Option)
        {
            OptionMembers = Vendor,"External Provider",Manual;

            trigger OnValidate();
            begin
                if "Distribution Method" = "Distribution Method"::"External Provider" then
                  ERROR(FeatureNotEnabled);
            end;
        }
        field(70;"Distribution Code";Code[20])
        {
            TableRelation = IF ("Distribution Method"=CONST(Vendor)) Vendor;

            trigger OnValidate();
            begin
                SetDefaultMgrSplit;
            end;
        }
        field(80;"Distribution Account No.";Code[20])
        {
            TableRelation = "G/L Account" WHERE ("Direct Posting"=CONST(true));
        }
        field(200;"Salesperson Name";Text[50])
        {
            CalcFormula = Lookup("Salesperson/Purchaser".Name WHERE (Code=FIELD("Salesperson Code")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(210;"Distribution Name";Text[50])
        {
            CalcFormula = Lookup(Vendor.Name WHERE ("No."=FIELD("Distribution Code")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(220;"Comm. Plan Description";Text[50])
        {
            CalcFormula = Lookup("Commission Plan".Description WHERE (Code=FIELD("Commission Plan Code")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(230;"Manager Level";Boolean)
        {
            CalcFormula = Lookup("Commission Plan"."Manager Level" WHERE (Code=FIELD("Commission Plan Code")));
            Editable = false;
            FieldClass = FlowField;

            trigger OnValidate();
            begin
                SetDefaultMgrSplit;
            end;
        }
    }

    keys
    {
        key(Key1;"Commission Plan Code","Salesperson Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        CommPlan : Record "Commission Plan";
        FeatureNotEnabled : Label 'Feature not enabled.';
        Text001 : Label 'Manager Split Pct. not available unless the Commission Plan is a Manager Level Plan.';

    local procedure SetDefaultMgrSplit();
    begin
        if "Manager Level" then
          VALIDATE("Manager Split Pct.",100)
        else
          VALIDATE("Manager Split Pct.",0);
    end;
}

