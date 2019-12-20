page 50089 "CommSetupSummaryTigCM"
{
    Caption = 'Commission Setup Summary';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = CommissionSetupSummaryTigCM;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    SaveValues = true;

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
                field("Cust. Salesperson Code"; "Cust. Salesperson Code")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Cust. Salesperson Code';
                }
                field("Pay Salesperson Code"; "Pay Salesperson Code")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Pay Salesperson Code';
                }
                field("Salesperson Name"; "Salesperson Name")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Salesperson Name';
                }
                field("Comm. Plan Code"; "Comm. Plan Code")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Comm. Plan Code';
                }
                field("Commission Rate"; "Commission Rate")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Commission Rate';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Calculate Setup")
            {
                //FIXME figure out what this means
                Caption = 'Calculate Setup';
                ApplicationArea = All;
                ToolTip = 'Calculates the setup';
                Image = CalculateSimulation;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction();
                var
                    CreateCommEntries: Codeunit CreateCommEntriesFromHistTigCM;
                begin
                    CreateCommEntries.CalcSetupSummary(Rec);
                    CurrPage.Update(false);
                    if FindFirst() then;
                end;
            }
        }
    }

    trigger OnOpenPage();
    begin
        Reset();
        SetRange("User ID", UserId());
    end;
}

