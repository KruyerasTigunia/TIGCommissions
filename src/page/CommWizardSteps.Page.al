page 80023 "CommWizardStepsTigCM"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions

    Caption = 'Setup Steps';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    PageType = ListPart;
    RefreshOnActivate = true;
    SourceTable = CommWizardStepTigCM;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Line; "Entry No.")
                {
                    Editable = false;
                }
                field("Action Msg."; "Action Msg.")
                {
                    Caption = 'Setup Steps';
                    Editable = false;
                }
                field(Complete; Complete)
                {
                    Editable = false;
                }
                field(Help; Help)
                {
                    Editable = false;

                    trigger OnAssistEdit();
                    begin
                        MESSAGE('help');
                    end;
                }
            }
        }
    }

    actions
    {
    }

    procedure GetEntryNo(): Integer;
    begin
        exit("Entry No.");
    end;
}

