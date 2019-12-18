page 80009 "Commission Vendor Groups"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions

    PageType = List;
    SourceTable = "Commission Vendor Group";

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
            }
        }
    }

    actions
    {
    }
}

