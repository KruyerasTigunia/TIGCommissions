table 80010 "Commission Vendor Group Member"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions


    fields
    {
        field(10;"Commission Vendor Group Code";Code[20])
        {
            TableRelation = Table80020;
        }
        field(20;"Vendor No.";Code[20])
        {
            TableRelation = Vendor;
        }
    }

    keys
    {
        key(Key1;"Commission Vendor Group Code","Vendor No.")
        {
        }
    }

    fieldgroups
    {
    }
}

