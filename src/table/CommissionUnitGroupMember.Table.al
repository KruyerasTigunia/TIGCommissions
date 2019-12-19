table 80008 "CommissionUnitGroupMemberTigCM"
{
    Caption = 'Commission Unit Group Member';
    DataClassification = CustomerContent;

    fields
    {
        field(10; "Group Code"; Code[20])
        {
            Caption = 'Group Code';
            DataClassification = CustomerContent;
            TableRelation = CommissionUnitGroupTigCM.Code;
        }
        field(20; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionMembers = " ","G/L Account",Item,Resource,"Fixed Asset","Charge (Item)";
            OptionCaption = ' ,G/L Account,Item,Resource';

            trigger OnValidate();
            begin
                if Type <> xRec.Type then
                    Validate("No.", '');
            end;
        }
        field(30; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = if (Type = const(Item)) Item."No."
            else
            if (Type = const("G/L Account")) "G/L Account"."No."
            else
            if (Type = const(Resource)) Resource."No.";
        }
    }

    keys
    {
        key(Key1; "Group Code", Type, "No.")
        {
        }
        key(Key2; Type, "No.")
        {
        }
    }
}