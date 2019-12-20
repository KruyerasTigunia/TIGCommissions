page 80010 "CommissionVendGrpMembersTigCM"
{
    Caption = 'Commission Vendor Group Members';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = CommissionVendorGrpMemberTigCM;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Commission Vendor Group Code"; "Commission Vendor Group Code")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Commission Vendor Group Code';
                }
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Vendor No.';
                }
            }
        }
    }
}