page 80010 "CommissionVendGrpMembersTigCM"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions

    PageType = List;
    SourceTable = CommissionVendorGrpMemberTigCM;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Commission Vendor Group Code"; "Commission Vendor Group Code")
                {
                }
                field("Vendor No."; "Vendor No.")
                {
                }
            }
        }
    }

    actions
    {
    }
}
