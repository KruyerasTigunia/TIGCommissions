page 80018 "CommCustSalespeopleTigCM"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions

    Caption = 'Salespeople';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "CommCustomerSalespersonTigCM";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Salesperson Code"; "Salesperson Code")
                {
                }
                field("Salesperson Name"; "Salesperson Name")
                {
                }
                field("Split Pct."; "Split Pct.")
                {
                }
            }
        }
    }

    trigger OnClosePage();
    begin
        SynchCustomer();
    end;
}

