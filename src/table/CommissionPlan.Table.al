table 80000 "CommissionPlanTigCM"
{
    DrillDownPageID = CommissionPlanListTigCM;
    LookupPageID = CommissionPlanListTigCM;

    fields
    {
        field(10; "Code"; Code[20])
        {
        }
        field(20; Description; Text[50])
        {
        }
        field(30; "Manager Level"; Boolean)
        {

            trigger OnValidate();
            begin
                UpdatePlanPayees;
            end;
        }
        field(40; "Source Type"; Option)
        {
            OptionMembers = Customer,Vendor;

            trigger OnValidate();
            begin
                if "Source Type" = "Source Type"::Vendor then
                    ERROR(FeatureNotEnabled);

                if "Source Type" <> xRec."Source Type" then begin
                    CLEAR("Source Method");
                    CLEAR("Source Method Code");
                    CLEAR("Unit Method");
                    CLEAR("Unit Method Code");
                    CLEAR("Commission Type");
                    CLEAR("Commission Basis");
                    CLEAR("Recognition Trigger Method");
                    CLEAR("Payable Trigger Method");
                end;
            end;
        }
        field(50; "Source Method"; Option)
        {
            OptionMembers = All,Group,Specific;

            trigger OnValidate();
            begin
                if "Source Method" <> xRec."Source Method" then
                    CLEAR("Source Method Code");

                case "Source Method" of
                    "Source Method"::All:
                        "Source Method Sort" := 0;
                    "Source Method"::Group:
                        "Source Method Sort" := -1;
                    "Source Method"::Specific:
                        "Source Method Sort" := -2
                end;
            end;
        }
        field(60; "Source Method Code"; Code[20])
        {
            TableRelation = IF ("Source Type" = CONST(Customer),
                                "Source Method" = CONST(Specific)) Customer."No."
            ELSE
            IF ("Source Type" = CONST(Customer),
                                         "Source Method" = CONST(Group)) CommissionCustomerGroupTigCM.Code
            ELSE
            IF ("Source Type" = CONST(Vendor),
                                                  "Source Method" = CONST(Specific)) Vendor."No."
            ELSE
            IF ("Source Type" = CONST(Vendor),
                                                           "Source Method" = CONST(Group)) CommissionVendorGroupTigCM.Code;
        }
        field(70; "Unit Type"; Option)
        {
            OptionMembers = " ","G/L Account",Item,Resource,"Fixed Asset","Charge (Item)",,All;

            trigger OnValidate();
            begin
                if "Unit Type" <> xRec."Unit Type" then begin
                    CLEAR("Unit Method");
                    CLEAR("Unit Method Code");
                end;
            end;
        }
        field(80; "Unit Method"; Option)
        {
            OptionMembers = All,Group,Specific;

            trigger OnValidate();
            begin
                if "Unit Method" <> xRec."Unit Method" then
                    CLEAR("Unit Method Code");
            end;
        }
        field(90; "Unit Method Code"; Code[20])
        {
            TableRelation = IF ("Unit Type" = CONST("G/L Account"),
                                "Unit Method" = CONST(Specific)) "G/L Account"."No."
            ELSE
            IF ("Unit Type" = CONST(Item),
                                         "Unit Method" = CONST(Specific)) Item."No."
            ELSE
            IF ("Unit Type" = CONST(Resource),
                                                  "Unit Method" = CONST(Specific)) Resource."No."
            ELSE
            IF ("Unit Method" = CONST(Group)) CommissionUnitGroupTigCM.Code;
        }
        field(100; "Commission Type"; Option)
        {
            OptionCaption = 'Percent';
            OptionMembers = Percent,"Fixed";

            trigger OnValidate();
            begin
                if "Commission Type" = "Commission Type"::Fixed then
                    ERROR(FeatureNotEnabled);

                if "Commission Type" <> xRec."Commission Type" then
                    CLEAR("Commission Basis");
            end;
        }
        field(110; "Commission Basis"; Option)
        {
            OptionCaption = ',,,Line Amount';
            OptionMembers = "Order Margin","Order Amount","Line Margin","Line Amount","Line Qty.";
        }
        field(120; "Recognition Trigger Method"; Option)
        {
            OptionMembers = Booking,Shipment,Invoice,Payment;

            trigger OnValidate();
            begin
                if "Recognition Trigger Method" <> xRec."Recognition Trigger Method" then
                    "Payable Trigger Method" := "Recognition Trigger Method";
            end;
        }
        field(130; "Payable Trigger Method"; Option)
        {
            OptionMembers = Booking,Shipment,Invoice,Payment;

            trigger OnValidate();
            begin
                if "Payable Trigger Method" < "Recognition Trigger Method" then
                    ERROR(Text001);
            end;
        }
        field(140; "Pay On Invoice Discounts"; Boolean)
        {

            trigger OnValidate();
            begin
                if "Pay On Invoice Discounts" then
                    ERROR(FeatureNotEnabled);
            end;
        }
        field(200; Disabled; Boolean)
        {
        }
        field(1000; "Source Method Sort"; Integer)
        {
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
        key(Key2; "Unit Type", "Unit Method", "Unit Method Code", "Source Type", "Source Method", "Source Method Code")
        {
        }
        key(Key3; "Source Type", "Source Method", "Source Method Code")
        {
        }
        key(Key4; "Source Method Sort")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete();
    begin
        if EntriesExist then
            ERROR(Text003);

        CommPlanPayee.SETRANGE("Commission Plan Code", Code);
        CommPlanPayee.DELETEALL(true);
        CommPlanCalc.SETRANGE("Commission Plan Code", Code);
        CommPlanCalc.DELETEALL(true);
    end;

    trigger OnInsert();
    begin
        InitDefaultValues;
    end;

    var
        FeatureNotEnabled: Label 'Feature not enabled.';
        Text001: Label 'Payable Trigger Method cannot be before Recognition Trigger Method.';
        CommPlanPayee: Record CommissionPlanPayeeTigCM;
        CommPlanCalc: Record CommissionPlanCalculationTigCM;
        Text003: Label 'Entries exist. Delete not allowed. Disable this plan instead.';

    local procedure InitDefaultValues();
    var
        CommSetup: Record CommissionSetupTigCM;
    begin
        CommSetup.GET;
        VALIDATE("Commission Type", CommSetup."Def. Commission Type");
        VALIDATE("Commission Basis", CommSetup."Def. Commission Basis");
        VALIDATE("Recognition Trigger Method", CommSetup."Recog. Trigger Method");
        VALIDATE("Payable Trigger Method", CommSetup."Payable Trigger Method");
    end;

    local procedure UpdatePlanPayees();
    var
        CommPlanPayee: Record CommissionPlanPayeeTigCM;
    begin
        if not "Manager Level" then begin
            CommPlanPayee.SETRANGE("Commission Plan Code", Code);
            CommPlanPayee.MODIFYALL("Manager Split Pct.", 0);
        end;
    end;

    local procedure EntriesExist(): Boolean;
    var
        CommRecogEntry: Record CommRecognitionEntryTigCM;
    begin
        CommRecogEntry.SETCURRENTKEY("Commission Plan Code");
        CommRecogEntry.SETRANGE("Commission Plan Code", Code);
        exit(not CommRecogEntry.ISEMPTY);
    end;
}

