page 80003 "CommissionPlanPayeesTigCM"
{
    Caption = 'Commission Plan Payees';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = CommissionPlanPayeeTigCM;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Salesperson Code';

                    trigger OnValidate();
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Salesperson Name"; "Salesperson Name")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Salesperson Name';
                }
                field("Distribution Method"; "Distribution Method")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Distribution Method';
                }
                field("Distribution Code"; "Distribution Code")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Distribution Code';

                    trigger OnValidate();
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Distribution Account No."; "Distribution Account No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Distribution Account No.';
                }
                field("Distribution Name"; "Distribution Name")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Distribution Name';
                }
                field("Manager Level"; "Manager Level")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Manager Level';
                }
                field("Manager Split Pct."; "Manager Split Pct.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Manager Split Pct.';
                }
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean;
    var
        SplitPctTotal: Decimal;
        SplitPercentErr: Label 'Manager Split Pct. distribution must = 100 or 0.';
    begin
        if FindSet() then begin
            SplitPctTotal := 0;
            repeat
                SplitPctTotal += "Manager Split Pct.";
            until Next() = 0;
            if not ((SplitPctTotal = 0) or (SplitPctTotal = 100)) then
                Error(SplitPercentErr);
        end;
    end;
}