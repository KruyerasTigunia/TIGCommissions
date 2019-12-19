table 80005 "CommCustomerSalespersonTigCM"
{
    Caption = 'Commission Customer Salesperson';
    DataClassification = CustomerContent;

    fields
    {
        field(10; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
        }
        field(20; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser".Code;
        }
        field(30; "Split Pct."; Decimal)
        {
            Caption = 'Split Percent';
            DataClassification = CustomerContent;
            InitValue = 100;
        }
        field(200; "Customer Name"; Text[50])
        {
            Caption = 'Customer Name';
            FieldClass = FlowField;
            CalcFormula = Lookup (Customer.Name WHERE("No." = FIELD("Customer No.")));
            Editable = false;
        }
        field(210; "Salesperson Name"; Text[50])
        {
            Caption = 'Salesperson Name';
            FieldClass = FlowField;
            CalcFormula = Lookup ("Salesperson/Purchaser".Name WHERE(Code = FIELD("Salesperson Code")));
            Editable = false;
        }
        field(1000; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
    }

    keys
    {
        key(PK; "Customer No.", "Salesperson Code")
        {
            Clustered = true;
        }
    }

    procedure SynchCustomer();
    var
        Customer: Record Customer;
        CustSalesperson: Record "CommCustomerSalespersonTigCM";
    begin
        //Keep customer record in synch, but only if no split commissions for this customer
        if Customer.Get("Customer No.") then begin
            CustSalesperson.SetRange("Customer No.", "Customer No.");
            if CustSalesperson.Count() < 2 then begin
                if Customer."Salesperson Code" <> "Salesperson Code" then begin
                    Customer.Validate("Salesperson Code", "Salesperson Code");
                    Customer.Modify(true);
                end;
            end;
        end;
    end;
}