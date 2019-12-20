page 80009 "CommissionVendorGroupsTigCM"
{
    Caption = 'Commission Vendor Groups';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = CommissionVendorGroupTigCM;

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
}