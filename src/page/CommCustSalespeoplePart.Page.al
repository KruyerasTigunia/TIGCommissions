page 80025 "CommCustSalespeoplePartTigCM"
{
    Caption = 'Commission Customer Salespeople Listpart';
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "CommCustomerSalespersonTigCM";
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Salesperson Code';
                }
                field("Salesperson Name"; "Salesperson Name")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Salesperson Name';
                }
                field("Split Pct."; "Split Pct.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Split Pct.';
                }
            }
        }
    }
}