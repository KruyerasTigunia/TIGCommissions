page 80016 "Commission Setup"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions

    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Commission Setup";

    layout
    {
        area(content)
        {
            group(Defaults)
            {
                field("Def. Commission Type";"Def. Commission Type")
                {
                }
                field("Def. Commission Basis";"Def. Commission Basis")
                {
                }
                field("Recog. Trigger Method";"Recog. Trigger Method")
                {
                    ToolTip = 'Select the event that creates the first logging of a commissionable sale';
                }
                field("Payable Trigger Method";"Payable Trigger Method")
                {
                    ToolTip = 'Select the event that makes the commissionable sale eligible for payment';
                }
                field(Disabled;Disabled)
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage();
    begin
        RESET;
        if not GET then begin
          INIT;
          INSERT;
        end;
    end;
}

