page 80005 "Commission Cust. Group Members"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions

    DelayedInsert = true;
    PageType = List;
    SourceTable = "Commission Cust. Group Member";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Group Code";"Group Code")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Customer No.";"Customer No.")
                {
                }
                field("Customer Name";"Customer Name")
                {
                }
            }
        }
    }

    actions
    {
    }
}

