table 80000 "CommissionPlanTigCM"
{
    Caption = 'Commission Plan';
    DataClassification = CustomerContent;
    DrillDownPageID = CommissionPlanListTigCM;
    LookupPageID = CommissionPlanListTigCM;

    fields
    {
        field(10; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(20; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(30; "Manager Level"; Boolean)
        {
            Caption = 'Manager Level';
            DataClassification = CustomerContent;

            trigger OnValidate();
            begin
                UpdatePlanPayees();
            end;
        }
        field(40; "Source Type"; Option)
        {
            Caption = 'Source Type';
            DataClassification = CustomerContent;
            OptionMembers = Customer,Vendor;
            OptionCaption = 'Customer,Vendor';

            trigger OnValidate();
            begin
                if "Source Type" = "Source Type"::Vendor then
                    Error(FeatureNotEnabledErr);

                if "Source Type" <> xRec."Source Type" then begin
                    Clear("Source Method");
                    Clear("Source Method Code");
                    Clear("Unit Method");
                    Clear("Unit Method Code");
                    Clear("Commission Type");
                    Clear("Commission Basis");
                    Clear("Recognition Trigger Method");
                    Clear("Payable Trigger Method");
                end;
            end;
        }
        field(50; "Source Method"; Option)
        {
            Caption = 'Source Method';
            DataClassification = CustomerContent;
            OptionMembers = All,Group,Specific;
            OptionCaption = 'All,Group,Specific';

            trigger OnValidate();
            begin
                if "Source Method" <> xRec."Source Method" then
                    Clear("Source Method Code");

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
            Caption = 'Source Method Code';
            DataClassification = CustomerContent;
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
            Caption = 'Unit Type';
            DataClassification = CustomerContent;
            OptionMembers = " ","G/L Account",Item,Resource,"Fixed Asset","Charge (Item)",,All;
            OptionCaption = ' ,G/L Account,Item,Resource,Fixed Asset,Charge (Item),,All';

            trigger OnValidate();
            begin
                if "Unit Type" <> xRec."Unit Type" then begin
                    Clear("Unit Method");
                    Clear("Unit Method Code");
                end;
            end;
        }
        field(80; "Unit Method"; Option)
        {
            Caption = 'Unit Method';
            DataClassification = CustomerContent;
            OptionMembers = All,Group,Specific;
            OptionCaption = 'All,Group,Specific';

            trigger OnValidate();
            begin
                if "Unit Method" <> xRec."Unit Method" then
                    Clear("Unit Method Code");
            end;
        }
        field(90; "Unit Method Code"; Code[20])
        {
            Caption = 'Unit Method Code';
            DataClassification = CustomerContent;
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
            Caption = 'Commission Type';
            DataClassification = CustomerContent;
            OptionMembers = Percent,"Fixed";
            OptionCaption = 'Percent,Fixed';

            trigger OnValidate();
            begin
                if "Commission Type" = "Commission Type"::Fixed then
                    Error(FeatureNotEnabledErr);

                if "Commission Type" <> xRec."Commission Type" then
                    Clear("Commission Basis");
            end;
        }
        field(110; "Commission Basis"; Option)
        {
            Caption = 'Commission Basis';
            DataClassification = CustomerContent;
            OptionMembers = "Order Margin","Order Amount","Line Margin","Line Amount","Line Qty.";
            OptionCaption = ',,,Line Amount';
            InitValue = "Line Amount";
        }
        field(120; "Recognition Trigger Method"; Option)
        {
            Caption = 'Recognition Trigger Method';
            DataClassification = CustomerContent;
            OptionMembers = Booking,Shipment,Invoice,Payment;
            OptionCaption = 'Booking,Shipment,Invoice,Payment';

            trigger OnValidate();
            begin
                if "Recognition Trigger Method" <> xRec."Recognition Trigger Method" then
                    "Payable Trigger Method" := "Recognition Trigger Method";
            end;
        }
        field(130; "Payable Trigger Method"; Option)
        {
            Caption = 'Payable Trigger Method';
            DataClassification = CustomerContent;
            OptionMembers = Booking,Shipment,Invoice,Payment;
            OptionCaption = 'Booking,Shipment,Invoice,Payment';

            trigger OnValidate();
            begin
                if "Payable Trigger Method" < "Recognition Trigger Method" then
                    Error(PayableBeforeRecogTriggerErr);
            end;
        }
        field(140; "Pay On Invoice Discounts"; Boolean)
        {
            Caption = 'Pay On Invoice Discounts';
            DataClassification = CustomerContent;

            trigger OnValidate();
            begin
                if "Pay On Invoice Discounts" then
                    Error(FeatureNotEnabledErr);
            end;
        }
        field(200; Disabled; Boolean)
        {
            Caption = 'Disabled';
            DataClassification = CustomerContent;
        }
        field(1000; "Source Method Sort"; Integer)
        {
            Caption = 'Source Method Sort';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
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

    var
        CommPlanPayee: Record CommissionPlanPayeeTigCM;
        CommPlanCalc: Record CommissionPlanCalculationTigCM;
        FeatureNotEnabledErr: Label 'Feature not enabled.';
        PayableBeforeRecogTriggerErr: Label 'Payable Trigger Method cannot be before Recognition Trigger Method.';
        DeleteNotAllowedErr: Label 'Entries exist. Delete not allowed. Disable this plan instead.';

    trigger OnDelete();
    begin
        if EntriesExist() then
            Error(DeleteNotAllowedErr);

        CommPlanPayee.SetRange("Commission Plan Code", Code);
        CommPlanPayee.DeleteAll(true);
        CommPlanCalc.SetRange("Commission Plan Code", Code);
        CommPlanCalc.DeleteAll(true);
    end;

    trigger OnInsert();
    begin
        InitDefaultValues();
    end;

    local procedure InitDefaultValues();
    var
        CommSetup: Record CommissionSetupTigCM;
    begin
        CommSetup.Get();
        Validate("Commission Type", CommSetup."Def. Commission Type");
        Validate("Commission Basis", CommSetup."Def. Commission Basis");
        Validate("Recognition Trigger Method", CommSetup."Recog. Trigger Method");
        Validate("Payable Trigger Method", CommSetup."Payable Trigger Method");
    end;

    local procedure UpdatePlanPayees();
    var
        MyCommPlanPayee: Record CommissionPlanPayeeTigCM;
    begin
        if not "Manager Level" then begin
            MyCommPlanPayee.SetRange("Commission Plan Code", Code);
            MyCommPlanPayee.ModifyAll("Manager Split Pct.", 0);
        end;
    end;

    local procedure EntriesExist(): Boolean;
    var
        CommRecogEntry: Record CommRecognitionEntryTigCM;
    begin
        CommRecogEntry.SetCurrentKey("Commission Plan Code");
        CommRecogEntry.SetRange("Commission Plan Code", Code);
        exit(not CommRecogEntry.IsEmpty());
    end;
}