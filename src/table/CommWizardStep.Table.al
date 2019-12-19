table 80019 "CommWizardStepTigCM"
{
    Caption = 'Commission Wizard Step';
    DataClassification = CustomerContent;

    fields
    {
        field(10; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(20; "Action Msg."; Text[250])
        {
            Caption = 'Action Message';
            DataClassification = CustomerContent;
        }
        field(30; Complete; Boolean)
        {
            Caption = 'Complete';
            DataClassification = CustomerContent;
        }
        field(40; "Action Code"; Code[20])
        {
            Caption = 'Action Code';
            DataClassification = CustomerContent;
        }
        field(50; Help; Text[1])
        {
            Caption = 'Help';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}