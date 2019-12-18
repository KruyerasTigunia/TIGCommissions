page 80002 "Commission Plan Calculations"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions

    PageType = List;
    SourceTable = "Commission Plan Calculation";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Commission Plan Code";"Commission Plan Code")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Tier Amount/Qty.";"Tier Amount/Qty.")
                {
                    Visible = false;
                }
                field("Commission Rate";"Commission Rate")
                {
                }
                field("Introductory Rate";"Introductory Rate")
                {
                }
                field("Intro Expires From First Sale";"Intro Expires From First Sale")
                {
                }
                field(Retroactive;Retroactive)
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
