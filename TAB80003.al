table 80003 "Commission Customer Group"
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
        CommCustGroupMember.SETRANGE("Group Code",Code);
        CommCustGroupMember.DELETEALL(true);
    end;

    var
        CommCustGroupMember : Record "Commission Cust. Group Member";
}

