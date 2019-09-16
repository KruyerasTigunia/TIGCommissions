table 80004 "Commission Unit Group"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions


    fields
    {
        field(10;"Code";Code[20])
        {
        }
        field(20;Description;Text[50])
        {
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete();
    begin
        CommUnitGroupMember.SETRANGE("Group Code",Code);
        CommUnitGroupMember.DELETEALL(true);
    end;

    var
        CommUnitGroupMember : Record "Commission Unit Group Member";
}

