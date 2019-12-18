table 80001 "CommissionPlanCalculationTigCM"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions


    fields
    {
        field(10; "Commission Plan Code"; Code[20])
        {
            TableRelation = CommissionPlanTigCM;
        }
        field(20; "Tier Amount/Qty."; Decimal)
        {
        }
        field(30; "Commission Rate"; Decimal)
        {
        }
        field(40; Retroactive; Boolean)
        {

            trigger OnValidate();
            begin
                if Retroactive then
                    ERROR(FeatureNotEnabled);
            end;
        }
        field(100; "Introductory Rate"; Decimal)
        {
        }
        field(110; "Intro Expires From First Sale"; DateFormula)
        {
        }
    }

    keys
    {
        key(Key1; "Commission Plan Code")
        {
        }
        key(Key2; "Tier Amount/Qty.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        FeatureNotEnabled: Label 'Feature not enabled.';
}

