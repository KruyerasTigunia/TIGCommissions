page 80005 "CommissionCustGrpMembersTigCM"
{
    Caption = 'Commission Customer Group Members';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = CommCustomerGroupMemberTigCM;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Group Code"; "Group Code")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Group Code';
                    Editable = false;
                    Visible = false;
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Customer No.';
                }
                field("Customer Name"; "Customer Name")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Customer Name';
                }
            }
        }
    }
}