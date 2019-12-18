page 80005 "CommissionCustGrpMembersTigCM"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions

    DelayedInsert = true;
    PageType = List;
    SourceTable = CommCustomerGroupMemberTigCM;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Group Code"; "Group Code")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Customer No."; "Customer No.")
                {
                }
                field("Customer Name"; "Customer Name")
                {
                }
            }
        }
    }

    actions
    {
    }
}

