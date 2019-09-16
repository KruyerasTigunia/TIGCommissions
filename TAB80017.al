table 80017 "Comm. Report Wksht. Buffer"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions


    fields
    {
        field(5;"User ID";Code[50])
        {
        }
        field(10;"Entry No.";Integer)
        {
        }
        field(20;"Batch Name";Code[20])
        {
        }
        field(30;"Salesperson Code";Code[20])
        {
        }
        field(40;"Salesperson Name";Text[50])
        {
        }
        field(50;"Entry Type";Option)
        {
            OptionMembers = Commission,Clawback,Advance,Adjustment;
        }
        field(60;"Customer No.";Code[20])
        {
        }
        field(70;"Customer Name";Text[50])
        {
        }
        field(80;"Document Type";Option)
        {
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order",,Adjustment;
        }
        field(90;"Document No.";Code[20])
        {
        }
        field(110;"Basis Amt. Recognized";Decimal)
        {
        }
        field(130;"Basis Amt. Approved to Pay";Decimal)
        {
            Editable = false;
        }
        field(140;"Comm. Amt. Paid";Decimal)
        {
            Editable = false;
        }
        field(150;"Approved Date";Date)
        {
        }
        field(160;"Run Date-Time";DateTime)
        {
        }
        field(170;"Comm. Amt. Approved";Decimal)
        {
        }
        field(180;"External Document No.";Code[20])
        {
        }
        field(190;Description;Text[50])
        {
        }
        field(200;"Description 2";Text[50])
        {
        }
        field(210;"Posted Doc. No.";Code[20])
        {
        }
        field(220;"Trigger Doc. No.";Code[20])
        {
        }
        field(1000;Level;Option)
        {
            OptionMembers = Detail,Summary;
        }
    }

    keys
    {
        key(Key1;"User ID","Entry No.")
        {
        }
        key(Key2;"Batch Name","Salesperson Code")
        {
        }
        key(Key3;"Salesperson Code","Customer No.","Document Type","Document No.",Level)
        {
        }
    }

    fieldgroups
    {
    }
}

