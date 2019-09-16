page 80018 "Comm. Cust./Salespeople"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions

    Caption = 'Salespeople';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Commission Cust/Salesperson";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Salesperson Code";"Salesperson Code")
                {
                }
                field("Salesperson Name";"Salesperson Name")
                {
                }
                field("Split Pct.";"Split Pct.")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
        }
    }

    trigger OnClosePage();
    begin
        SynchCustomer;
    end;
}

