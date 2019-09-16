table 80015 "Commission Setup"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions


    fields
    {
        field(10;"Primary Key";Code[10])
        {
            CaptionML = ENU='Primary Key',
                        ESM='Clave primaria',
                        FRC='Clé primaire',
                        ENC='Primary Key';
        }
        field(20;"Def. Commission Type";Option)
        {
            OptionCaption = 'Percent';
            OptionMembers = Percent,"Fixed";
        }
        field(30;"Def. Commission Basis";Option)
        {
            InitValue = "Line Amount";
            OptionCaption = ',,,Line Amount';
            OptionMembers = "Order Margin","Order Amount","Line Margin","Line Amount","Line Qty.";
        }
        field(40;"Recog. Trigger Method";Option)
        {
            InitValue = Shipment;
            OptionMembers = Booking,Shipment,Invoice,Payment;

            trigger OnValidate();
            begin
                if "Recog. Trigger Method" <> xRec."Recog. Trigger Method" then begin
                  if CommPlan.FINDSET then begin
                    repeat
                      CommPlan.VALIDATE("Recognition Trigger Method","Recog. Trigger Method");
                      CommPlan.MODIFY;
                    until CommPlan.NEXT = 0;
                  end;
                end;
            end;
        }
        field(50;"Payable Trigger Method";Option)
        {
            InitValue = Shipment;
            OptionMembers = Booking,Shipment,Invoice,Payment;

            trigger OnValidate();
            begin
                if "Payable Trigger Method" <> xRec."Payable Trigger Method" then begin
                  if CommPlan.FINDSET then begin
                    repeat
                      CommPlan.VALIDATE("Payable Trigger Method","Payable Trigger Method");
                      CommPlan.MODIFY;
                    until CommPlan.NEXT = 0;
                  end;
                end;
            end;
        }
        field(190;Disabled;Boolean)
        {
        }
        field(200;"Wizard Run";Boolean)
        {
        }
        field(210;"Initial Data Extract Date";Date)
        {
        }
    }

    keys
    {
        key(Key1;"Primary Key")
        {
        }
    }

    fieldgroups
    {
    }

    var
        CommPlan : Record "Commission Plan";
}

