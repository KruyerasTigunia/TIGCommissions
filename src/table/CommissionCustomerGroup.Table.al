table 80003 "CommissionCustomerGroupTigCM"
{
    Caption = 'Commission Customer Group';
    DataClassification = CustomerContent;

    fields
    {
        field(10; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(20; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete();
    begin
        CommCustGroupMember.SETRANGE("Group Code", Code);
        CommCustGroupMember.DELETEALL(true);
    end;

    var
        CommCustGroupMember: Record CommCustomerGroupMemberTigCM;
}

