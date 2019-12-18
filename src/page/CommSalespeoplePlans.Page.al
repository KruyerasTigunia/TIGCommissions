page 80021 "CommSalespeoplePlansTigCM"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions

    Caption = 'Plans';
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
                }
                field("Comm. Plan Description"; "Comm. Plan Description")
                {
                }
                field("Distribution Method"; "Distribution Method")
                {
                }
                field("Distribution Code"; "Distribution Code")
                {
                }
                field("Distribution Name"; "Distribution Name")
                {
                }
                field("Distribution Account No."; "Distribution Account No.")
                {
                }
                field("Manager Level"; "Manager Level")
                {
                }
                field("Manager Split Pct."; "Manager Split Pct.")
                {
                }
            }
        }
    }

    actions
    {
    }

    var
        Text001: TextConst ENU = 'Split Pct. distribution must = 100 or 0.';
        SplitPctTotal: Decimal;
}

