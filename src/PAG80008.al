page 80008 "Commission Customers"
{
    // version TIGCOMM1.0

    CardPageID = "Customer Card";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = Customer;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Editable = false;
                field("No.";"No.")
                {
                }
                field(Name;Name)
                {
                }
                field("Search Name";"Search Name")
                {
                }
                field(Address;Address)
                {
                }
                field(City;City)
                {
                }
                field(County;County)
                {
                }
                field("Post Code";"Post Code")
                {
                }
            }
            part(Salespeople;"Comm. Cust./Salespeople")
            {
                SubPageLink = "Customer No."=FIELD("No.");
                UpdatePropagation = Both;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Edit Salespeople")
            {
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction();
                var
                    CommCustSalesperson : Record "Commission Cust/Salesperson";
                    CommCustSalespersons : Page "Comm. Cust./Salespeople";
                begin
                    CommCustSalesperson.RESET;
                    CommCustSalesperson.SETRANGE("Customer No.","No.");
                    CLEAR(CommCustSalespersons);
                    CommCustSalespersons.SETTABLEVIEW(CommCustSalesperson);
                    CommCustSalespersons.RUNMODAL;
                end;
            }
        }
    }
}

