table 80004 "CommissionUnitGroupTigCM"
{
    Caption = 'Commission Unit Group';
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

    trigger OnDelete();
    var
        CommUnitGroupMember: Record CommissionUnitGroupMemberTigCM;
    begin
        CommUnitGroupMember.SETRANGE("Group Code", Code);
        CommUnitGroupMember.DELETEALL(true);
    end;
}