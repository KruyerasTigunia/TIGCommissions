page 80020 "Comm. Salespeople/Customers"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions

    Caption = 'Customers';
    PageType = ListPart;
    SourceTable = "Commission Cust/Salesperson";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Customer No.";"Customer No.")
                {
                }
                field("Customer Name";"Customer Name")
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
    }

    var
        Text001 : TextConst ENU='Split Pct. distribution must = 100 or 0.';
        SplitPctTotal : Decimal;
}

