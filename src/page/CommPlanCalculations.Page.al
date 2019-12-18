page 80002 "CommPlanCalculationsTigCM"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions

    PageType = List;
    SourceTable = CommissionPlanCalculationTigCM;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Commission Plan Code"; "Commission Plan Code")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Tier Amount/Qty."; "Tier Amount/Qty.")
                {
                    Visible = false;
                }
                field("Commission Rate"; "Commission Rate")
                {
                }
                field("Introductory Rate"; "Introductory Rate")
                {
                }
                field("Intro Expires From First Sale"; "Intro Expires From First Sale")
                {
                }
                field(Retroactive; Retroactive)
                {
                    Editable = false;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }
}

