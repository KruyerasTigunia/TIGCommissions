page 80003 "Commission Plan Payees"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions

    PageType = List;
    SourceTable = "Commission Plan Payee";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Salesperson Code";"Salesperson Code")
                {

                    trigger OnValidate();
                    begin
                        CurrPage.UPDATE;
                    end;
                }
                field("Salesperson Name";"Salesperson Name")
                {
                }
                field("Distribution Method";"Distribution Method")
                {
                }
                field("Distribution Code";"Distribution Code")
                {

                    trigger OnValidate();
                    begin
                        CurrPage.UPDATE;
                    end;
                }
                field("Distribution Account No.";"Distribution Account No.")
                {
                }
                field("Distribution Name";"Distribution Name")
                {
                }
                field("Manager Level";"Manager Level")
                {
                }
                field("Manager Split Pct.";"Manager Split Pct.")
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnQueryClosePage(CloseAction : Action) : Boolean;
    begin
        if FIND('-') then begin
          SplitPctTotal := 0;
          repeat
            SplitPctTotal += "Manager Split Pct.";
          until NEXT = 0;
          if (SplitPctTotal <> 0) and (SplitPctTotal <> 100) then
            ERROR(Text001);
        end;
    end;

    var
        SplitPctTotal : Decimal;
        Text001 : TextConst ENU='Manager Split Pct. distribution must = 100 or 0.';
}

