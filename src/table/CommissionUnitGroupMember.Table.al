table 80008 "CommissionUnitGroupMemberTigCM"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions


    fields
    {
        field(10; "Group Code"; Code[20])
        {
            TableRelation = CommissionUnitGroupTigCM;
        }
        field(20; Type; Option)
        {
            OptionCaption = ',G/L Account,Item,Resource';
            OptionMembers = " ","G/L Account",Item,Resource,"Fixed Asset","Charge (Item)";

            trigger OnValidate();
            begin
                if Type <> xRec.Type then
                    VALIDATE("No.", '');
            end;
        }
        field(30; "No."; Code[20])
        {
            TableRelation = IF (Type = CONST(Item)) Item."No."
            ELSE
            IF (Type = CONST("G/L Account")) "G/L Account"."No."
            ELSE
            IF (Type = CONST(Resource)) Resource."No.";
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

    fieldgroups
    {
    }
}

