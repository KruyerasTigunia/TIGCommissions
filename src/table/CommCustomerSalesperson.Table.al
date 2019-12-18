table 80005 "CommCustomerSalespersonTigCM"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions


    fields
    {
        field(10; "Customer No."; Code[20])
        {
            TableRelation = Customer;
        }
        field(20; "Salesperson Code"; Code[20])
        {
            TableRelation = "Salesperson/Purchaser";
        }
        field(30; "Split Pct."; Decimal)
        {
            InitValue = 100;
        }
        field(200; "Customer Name"; Text[50])
        {
            CalcFormula = Lookup (Customer.Name WHERE("No." = FIELD("Customer No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(210; "Salesperson Name"; Text[50])
        {
            CalcFormula = Lookup ("Salesperson/Purchaser".Name WHERE(Code = FIELD("Salesperson Code")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(1000; "Date Filter"; Date)
        {
            FieldClass = FlowFilter;
        }
    }

    keys
    {
        key(Key1; "Customer No.", "Salesperson Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Customer: Record Customer;
        CustSalesperson: Record "CommCustomerSalespersonTigCM";

    procedure SynchCustomer();
    begin
        //Keep customer record in synch, but only if no split commissions for this customer
        if Customer.GET("Customer No.") then begin
            CustSalesperson.SETRANGE("Customer No.", "Customer No.");
            if CustSalesperson.COUNT < 2 then begin
                if Customer."Salesperson Code" <> "Salesperson Code" then begin
                    Customer.VALIDATE("Salesperson Code", "Salesperson Code");
                    Customer.MODIFY(true);
                end;
            end;
        end;
    end;
}

