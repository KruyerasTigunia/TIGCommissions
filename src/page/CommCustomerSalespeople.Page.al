page 80020 "CommCustomerSalespeopleTigCM"
{
    Caption = 'Commission Customer Salespeople';
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "CommCustomerSalespersonTigCM";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
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
                field("Split Pct."; "Split Pct.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Split Pct.';
                }
            }
        }
    }
}