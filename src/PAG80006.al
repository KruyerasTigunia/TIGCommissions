page 80006 "Commission Unit Groups"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions

    PageType = List;
    PromotedActionCategories = 'Manage,Functions,Update,Post,Print,Related Information,f';
    SourceTable = CommissionUnitGroupTigCM;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                }
                field(Description; Description)
                {
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
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;
                RunObject = Page "Commission Unit Group Members";
                RunPageLink = "Group Code" = FIELD(Code);
            }
        }
    }
}

