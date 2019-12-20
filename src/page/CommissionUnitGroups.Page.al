page 80006 "CommissionUnitGroupsTigCM"
{
    Caption = 'Commission Unit Groups';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
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
                ToolTip = 'Opens the Members page';
                Image = ContactPerson;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page CommissionUnitGrpMembersTigCM;
                RunPageLink = "Group Code" = field(Code);
            }
        }
    }
}