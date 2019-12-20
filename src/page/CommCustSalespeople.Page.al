page 80018 "CommCustSalespeopleTigCM"
{
    Caption = 'Commission Customer Salespeople';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "CommCustomerSalespersonTigCM";
    DelayedInsert = true;

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

    trigger OnClosePage();
    begin
        SynchCustomer();
    end;
}