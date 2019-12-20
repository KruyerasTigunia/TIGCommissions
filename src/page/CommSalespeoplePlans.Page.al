page 80021 "CommSalespeoplePlansTigCM"
{
    Caption = 'Plans';
    UsageCategory = None;
    PageType = ListPart;
    SourceTable = CommissionPlanPayeeTigCM;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Commission Plan Code"; "Commission Plan Code")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Commission Plan Code';
                }
                field("Comm. Plan Description"; "Comm. Plan Description")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Comm. Plan Description';
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
                }
                field("Distribution Name"; "Distribution Name")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Distribution Name';
                }
                field("Distribution Account No."; "Distribution Account No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Distribution Account No.';
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
}