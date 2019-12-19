table 80001 "CommissionPlanCalculationTigCM"
{
    Caption = 'Commission Plan Calculation';
    DataClassification = CustomerContent;

    fields
    {
        field(10; "Commission Plan Code"; Code[20])
        {
            Caption = 'Commission Plan Code';
            DataClassification = CustomerContent;
            TableRelation = CommissionPlanTigCM.Code;
        }
        field(20; "Tier Amount/Qty."; Decimal)
        {
            Caption = 'Tier Amount/Quantity';
            DataClassification = CustomerContent;
        }
        field(30; "Commission Rate"; Decimal)
        {
            Caption = 'Commission Rate';
            DataClassification = CustomerContent;
        }
        field(40; Retroactive; Boolean)
        {
            Caption = 'Retroactive';
            DataClassification = CustomerContent;

            trigger OnValidate();
            begin
                if Retroactive then
                    Error(FeatureNotEnabledErr);
            end;
        }
        field(100; "Introductory Rate"; Decimal)
        {
            Caption = 'Introductory Rate';
            DataClassification = CustomerContent;
        }
        field(110; "Intro Expires From First Sale"; DateFormula)
        {
            Caption = 'Intro Expires From First Sale';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Commission Plan Code")
        {
            Clustered = true;
        }
        key(Key2; "Tier Amount/Qty.")
        {
        }
    }

    var
        FeatureNotEnabledErr: Label 'Feature not enabled.';
}