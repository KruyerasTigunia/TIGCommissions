table 80009 "CommissionVendorGroupTigCM"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions


    fields
    {
        field(10; "Code"; Code[20])
        {
        }
        field(20; Description; Text[50])
        {
            TableRelation = CommissionUnitGroupTigCM;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }
}

