page 80001 "CommissionPlanListTigCM"
{
    Caption = 'Commission Plan List';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = CommissionPlanTigCM;
    CardPageID = CommissionPlanCardTigCM;

    layout
    {
        area(content)
        {
            repeater(Group)
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
                field("Manager Level"; "Manager Level")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Manager Level';
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
                PromotedOnly = true;
                Promoted = true;
                PromotedIsBig = true;

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