page 80002 "CommPlanCalculationsTigCM"
{
    Caption = 'Commission Calculations';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = CommissionPlanCalculationTigCM;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Commission Plan Code"; "Commission Plan Code")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Commission Plan Code';
                    Editable = false;
                    Visible = false;
                }
                field("Tier Amount/Qty."; "Tier Amount/Qty.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Tier Amount/Qty.';
                    Visible = false;
                }
                field("Commission Rate"; "Commission Rate")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Commission Rate';
                }
                field("Introductory Rate"; "Introductory Rate")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Introductory Rate';
                }
                field("Intro Expires From First Sale"; "Intro Expires From First Sale")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Intro Expires From First Sale';
                }
                field(Retroactive; Retroactive)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Retroactive';
                    Editable = false;
                    Visible = false;
                }
            }
        }
    }
}