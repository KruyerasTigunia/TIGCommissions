page 80016 "CommissionSetupTigCM"
{
    Caption = 'Commission Setup';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = CommissionSetupTigCM;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            group(Defaults)
            {
                field("Def. Commission Type"; "Def. Commission Type")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Def. Commission Type';
                }
                field("Def. Commission Basis"; "Def. Commission Basis")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Def. Commission Basis';
                }
                field("Recog. Trigger Method"; "Recog. Trigger Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Select the event that creates the first logging of a commissionable sale';
                }
                field("Payable Trigger Method"; "Payable Trigger Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Select the event that makes the commissionable sale eligible for payment';
                }
                field(Disabled; Disabled)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Disabled';
                }
            }
        }
    }

    trigger OnOpenPage();
    begin
        Reset();
        if not Get() then begin
            Init();
            Insert();
        end;
    end;
}

