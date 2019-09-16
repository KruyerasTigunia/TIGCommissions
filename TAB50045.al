table 50045 "Comm. Initial Import"
{
    // version TIGCOMMCust


    fields
    {
        field(10;"Salesperson Code";Code[20])
        {
            TableRelation = "Salesperson/Purchaser";
        }
        field(20;"Customer No.";Code[20])
        {
            TableRelation = "Cust. Ledger Entry";
        }
        field(30;"Comm. Rate";Decimal)
        {
        }
        field(50;"Comm. Code";Code[20])
        {
        }
    }

    keys
    {
        key(Key1;"Salesperson Code","Comm. Rate","Customer No.")
        {
        }
    }

    fieldgroups
    {
    }
}

