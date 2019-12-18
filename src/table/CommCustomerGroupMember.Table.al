table 80007 "CommCustomerGroupMemberTigCM"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions


    fields
    {
        field(10; "Group Code"; Code[20])
        {
            TableRelation = CommissionCustomerGroupTigCM;
        }
        field(20; "Customer No."; Code[20])
        {
            TableRelation = Customer;
        }
        field(200; "Customer Name"; Text[50])
        {
            CalcFormula = Lookup (Customer.Name WHERE("No." = FIELD("Customer No.")));
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Group Code", "Customer No.")
        {
        }
        key(Key2; "Customer No.")
        {
        }
    }

    fieldgroups
    {
    }
}

