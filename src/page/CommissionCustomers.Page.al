page 80008 "CommissionCustomersTigCM"
{
    //FIXME - wrong design
    //TODO - create a new listpart to show on the CommCustSalespeopleTigCM page
    //TODO - Change this to a page extension, and put the action on the regular Customer List
    Caption = 'Commission Customers';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = Customer;
    CardPageID = "Customer Card";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    RefreshOnActivate = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Editable = false;
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the No.';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Name';
                }
                field("Search Name"; "Search Name")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Search Name';
                }
                field(Address; Address)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Address';
                }
                field(City; City)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the City';
                }
                field(County; County)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the County';
                }
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Post Code';
                }
            }
            part(Salespeople; CommCustSalespeoplePartTigCM)
            {
                ApplicationArea = All;
                SubPageLink = "Customer No." = field("No.");
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
                ApplicationArea = All;
                ToolTip = 'Opens the Salespeople page for editing';
                Image = SalesPerson;
                PromotedOnly = true;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction();
                var
                    CommCustSalesperson: Record "CommCustomerSalespersonTigCM";
                    CommCustSalespersons: Page CommCustSalespeopleTigCM;
                begin
                    CommCustSalesperson.Reset();
                    CommCustSalesperson.SetRange("Customer No.", "No.");
                    CLEAR(CommCustSalespersons);
                    CommCustSalespersons.SetTableView(CommCustSalesperson);
                    CommCustSalespersons.RunModal();
                end;
            }
        }
    }
}

