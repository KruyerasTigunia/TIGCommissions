page 80004 "CommissionCustomerGroupsTigCM"
{
    Caption = 'Commission Customer Groups';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    PromotedActionCategories = 'Manage,Functions,Update,Post,Print,Related Information,f';
    SourceTable = CommissionCustomerGroupTigCM;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Code';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Description';
                }
            }
        }
    }
    actions
    {
        area(navigation)
        {
            action(Members)
            {
                ApplicationArea = All;
                ToolTip = 'Opens the Commission Customer Group Members page';
                Image = CustomerList;
                RunObject = Page CommissionCustGrpMembersTigCM;
                RunPageLink = "Group Code" = field(Code);
            }
        }
    }
}