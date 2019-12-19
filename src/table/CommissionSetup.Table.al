table 80015 "CommissionSetupTigCM"
{
    Caption = 'Commission Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(10; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(20; "Def. Commission Type"; Option)
        {
            Caption = 'Default Commission Type';
            DataClassification = CustomerContent;
            OptionMembers = Percent,"Fixed";
            OptionCaption = 'Percent';
        }
        field(30; "Def. Commission Basis"; Option)
        {
            Caption = 'Default Commission Basis';
            DataClassification = CustomerContent;
            OptionMembers = "Order Margin","Order Amount","Line Margin","Line Amount","Line Qty.";
            OptionCaption = ',,,Line Amount';
            InitValue = "Line Amount";
        }
        field(40; "Recog. Trigger Method"; Option)
        {
            Caption = 'Recognition Trigger Method';
            DataClassification = CustomerContent;
            OptionMembers = Booking,Shipment,Invoice,Payment;
            OptionCaption = 'Booking,Shipment,Invoice,Payment';
            InitValue = Shipment;

            trigger OnValidate();
            begin
                if "Recog. Trigger Method" <> xRec."Recog. Trigger Method" then begin
                    if CommPlan.FindSet() then begin
                        repeat
                            CommPlan.Validate("Recognition Trigger Method", "Recog. Trigger Method");
                            CommPlan.Modify();
                        until CommPlan.Next() = 0;
                    end;
                end;
            end;
        }
        field(50; "Payable Trigger Method"; Option)
        {
            Caption = 'Payable Trigger Method';
            DataClassification = CustomerContent;
            OptionMembers = Booking,Shipment,Invoice,Payment;
            OptionCaption = 'Booking,Shipment,Invoice,Payment';
            InitValue = Shipment;

            trigger OnValidate();
            begin
                if "Payable Trigger Method" <> xRec."Payable Trigger Method" then begin
                    if CommPlan.FindSet() then begin
                        repeat
                            CommPlan.Validate("Payable Trigger Method", "Payable Trigger Method");
                            CommPlan.Modify();
                        until CommPlan.Next() = 0;
                    end;
                end;
            end;
        }
        field(190; Disabled; Boolean)
        {
            Caption = 'Disabled';
            DataClassification = CustomerContent;
        }
        field(200; "Wizard Run"; Boolean)
        {
            Caption = 'Wizard Run';
            DataClassification = CustomerContent;
        }
        field(210; "Initial Data Extract Date"; Date)
        {
            Caption = 'Initial Data Extract Date';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    var
        CommPlan: Record CommissionPlanTigCM;
}