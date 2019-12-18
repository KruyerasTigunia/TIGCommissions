page 80001 "Commission Plan List"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions

    CardPageID = "Commission Plan Card";
    PageType = List;
    SourceTable = "Commission Plan";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field("Source Type";"Source Type")
                {
                }
                field("Source Method";"Source Method")
                {
                }
                field("Source Method Code";"Source Method Code")
                {
                }
                field("Unit Type";"Unit Type")
                {
                }
                field("Unit Method";"Unit Method")
                {
                }
                field("Unit Method Code";"Unit Method Code")
                {
                }
                field("Manager Level";"Manager Level")
                {
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            Description = 'Navigate';
            action("Calculation Lines")
            {
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;

                trigger OnAction();
                var
                    CommPlanCalc : Record "Commission Plan Calculation";
                    CommPlanCalcs : Page "Commission Plan Calculations";
                begin
                    CLEAR(CommPlanCalc);
                    CommPlanCalc.SETRANGE("Commission Plan Code",Code);
                    CommPlanCalcs.SETTABLEVIEW(CommPlanCalc);
                    CommPlanCalcs.RUNMODAL
                end;
            }
            action(Payees)
            {
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;

                trigger OnAction();
                var
                    CommPlanPayee : Record "Commission Plan Payee";
                    CommPlanPayees : Page "Commission Plan Payees";
                begin
                    CLEAR(CommPlanPayees);
                    CommPlanPayee.SETRANGE("Commission Plan Code",Code);
                    CommPlanPayees.SETTABLEVIEW(CommPlanPayee);
                    CommPlanPayees.RUNMODAL
                end;
            }
        }
    }
}

