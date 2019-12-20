page 80023 "CommWizardStepsTigCM"
{
    Caption = 'Commission Wizard Steps';
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = CommWizardStepTigCM;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    RefreshOnActivate = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Line; "Entry No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Line';
                    Editable = false;
                }
                field("Action Msg."; "Action Msg.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Action Msg.';
                    Caption = 'Setup Steps';
                    Editable = false;
                }
                field(Complete; Complete)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Complete';
                    Editable = false;
                }
                field(Help; Help)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Help';
                    Editable = false;

                    trigger OnAssistEdit();
                    begin
                        Message('help');
                    end;
                }
            }
        }
    }

    procedure GetEntryNo(): Integer;
    begin
        exit("Entry No.");
    end;
}