page 50089 "Comm. Setup Summary"
{
    // version WCT,TIGCOMM1.0

    // TIGCOMM1.0 Commissions

    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SaveValues = true;
    SourceTable = CommissionSetupSummaryTigCM;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Customer No."; "Customer No.")
                {
                }
                field("Customer Name"; "Customer Name")
                {
                }
                field("Cust. Salesperson Code"; "Cust. Salesperson Code")
                {
                }
                field("Pay Salesperson Code"; "Pay Salesperson Code")
                {
                }
                field("Salesperson Name"; "Salesperson Name")
                {
                }
                field("Comm. Plan Code"; "Comm. Plan Code")
                {
                }
                field("Commission Rate"; "Commission Rate")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Calculate Setup")
            {
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction();
                var
                    CreateCommEntries: Codeunit CreateCommEntriesFromHistTigCM;
                begin
                    CreateCommEntries.CalcSetupSummary(Rec);
                    CurrPage.UPDATE(false);
                    if FINDFIRST then;
                end;
            }
        }
    }

    trigger OnOpenPage();
    begin
        RESET;
        SETRANGE("User ID", USERID);
    end;
}

