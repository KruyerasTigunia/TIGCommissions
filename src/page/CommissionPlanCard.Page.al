page 80000 "CommissionPlanCardTigCM"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions

    PageType = Card;
    SourceTable = CommissionPlanTigCM;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Code)
                {
                }
                field(Description; Description)
                {
                }
                field("Manager Level"; "Manager Level")
                {
                }
                field("Source Type"; "Source Type")
                {
                }
                field("Source Method"; "Source Method")
                {
                }
                field("Source Method Code"; "Source Method Code")
                {
                }
                field("Unit Type"; "Unit Type")
                {
                }
                field("Unit Method"; "Unit Method")
                {
                }
                field("Unit Method Code"; "Unit Method Code")
                {
                }
                field("Commission Type"; "Commission Type")
                {
                }
                field("Commission Basis"; "Commission Basis")
                {
                }
                field("Recognition Trigger Method"; "Recognition Trigger Method")
                {
                    Editable = false;
                }
                field("Payable Trigger Method"; "Payable Trigger Method")
                {
                    Editable = false;
                }
                field("Pay On Invoice Discounts"; "Pay On Invoice Discounts")
                {
                    Visible = false;
                }
                field(Disabled; Disabled)
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
                    CommPlanCalc: Record CommissionPlanCalculationTigCM;
                    CommPlanCalcs: Page CommPlanCalculationsTigCM;
                begin
                    CLEAR(CommPlanCalc);
                    CommPlanCalc.SETRANGE("Commission Plan Code", Code);
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
                    CommPlanPayee: Record CommissionPlanPayeeTigCM;
                    CommPlanPayees: Page CommissionPlanPayeesTigCM;
                begin
                    CLEAR(CommPlanPayees);
                    CommPlanPayee.SETRANGE("Commission Plan Code", Code);
                    CommPlanPayees.SETTABLEVIEW(CommPlanPayee);
                    CommPlanPayees.RUNMODAL
                end;
            }
        }
    }
}

