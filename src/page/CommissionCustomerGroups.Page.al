page 80004 "CommissionCustomerGroupsTigCM"
{
    PageType = List;
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
                RunObject = Page CommissionCustGrpMembersTigCM;
                RunPageLink = "Group Code" = field(Code);
            }
        }
    }
}