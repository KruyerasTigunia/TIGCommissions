table 80011 "Commission Setup Summary"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions

    DrillDownPageID = "Comm. Report Worksheet";
    LookupPageID = "Comm. Report Worksheet";

    fields
    {
        field(10;"User ID";Code[50])
        {
        }
        field(20;"Entry No.";Integer)
        {
        }
        field(30;"Customer No.";Code[20])
        {
            TableRelation = Customer;
        }
        field(40;"Cust. Salesperson Code";Code[20])
        {
            TableRelation = "Salesperson/Purchaser";
        }
        field(45;"Pay Salesperson Code";Code[20])
        {
            TableRelation = "Salesperson/Purchaser";
        }
        field(50;"Comm. Plan Code";Code[20])
        {
            TableRelation = "Commission Plan";
        }
        field(60;"Commission Rate";Decimal)
        {
        }
        field(1000;"Customer Name";Text[50])
        {
            CalcFormula = Lookup(Customer.Name WHERE ("No."=FIELD("Customer No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(1010;"Salesperson Name";Text[50])
        {
            CalcFormula = Lookup("Salesperson/Purchaser".Name WHERE (Code=FIELD("Cust. Salesperson Code")));
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"User ID","Entry No.")
        {
        }
        key(Key2;"Customer No.","Cust. Salesperson Code")
        {
        }
        key(Key3;"Cust. Salesperson Code","Customer No.")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown;"User ID","Entry No.","Cust. Salesperson Code")
        {
        }
    }
}

