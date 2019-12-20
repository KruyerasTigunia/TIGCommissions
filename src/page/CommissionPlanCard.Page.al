page 80000 "CommissionPlanCardTigCM"
{
    Caption = 'Commission Plan Card';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = CommissionPlanTigCM;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Code';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Description';
                }
                field("Manager Level"; "Manager Level")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Manager Level';
                }
                field("Source Type"; "Source Type")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Source Type';
                }
                field("Source Method"; "Source Method")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Source Method';
                }
                field("Source Method Code"; "Source Method Code")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Source Method Code';
                }
                field("Unit Type"; "Unit Type")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Unit Type';
                }
                field("Unit Method"; "Unit Method")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Unit Method';
                }
                field("Unit Method Code"; "Unit Method Code")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Unit Method Code';
                }
                field("Commission Type"; "Commission Type")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Commission Type';
                }
                field("Commission Basis"; "Commission Basis")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Commission Basis';
                }
                field("Recognition Trigger Method"; "Recognition Trigger Method")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Recognition Trigger Method';
                    Editable = false;
                }
                field("Payable Trigger Method"; "Payable Trigger Method")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Payable Trigger Method';
                    Editable = false;
                }
                field("Pay On Invoice Discounts"; "Pay On Invoice Discounts")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Pay On Invoice Discounts';
                    Visible = false;
                }
                field(Disabled; Disabled)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Disabled';
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
                ApplicationArea = All;
                ToolTip = 'Opens the Calculation Lines page';
                Image = CalculateSimulation;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction();
                var
                    CommPlanCalc: Record CommissionPlanCalculationTigCM;
                    CommPlanCalcs: Page CommPlanCalculationsTigCM;
                begin
                    Clear(CommPlanCalc);
                    CommPlanCalc.SetRange("Commission Plan Code", Code);
                    CommPlanCalcs.SetTableView(CommPlanCalc);
                    CommPlanCalcs.RunModal();
                end;
            }
            action(Payees)
            {
                ApplicationArea = All;
                ToolTip = 'Opens the Payees page';
                Image = PaymentDays;
                Promoted = true;
                PromotedIsBig = true;

                trigger OnAction();
                var
                    CommPlanPayee: Record CommissionPlanPayeeTigCM;
                    CommPlanPayees: Page CommissionPlanPayeesTigCM;
                begin
                    Clear(CommPlanPayees);
                    CommPlanPayee.SetRange("Commission Plan Code", Code);
                    CommPlanPayees.SetTableView(CommPlanPayee);
                    CommPlanPayees.RunModal();
                end;
            }
        }
    }
}