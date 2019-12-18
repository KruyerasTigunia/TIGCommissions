codeunit 80002 "CommissionWizardMgtTigCM"
{
    var
        CommSetup: Record CommissionSetupTigCM;
        CommPlan: Record CommissionPlanTigCM;
        CommPlanPayee: Record CommissionPlanPayeeTigCM;
        CommPlanCalcLine: Record CommissionPlanCalculationTigCM;
        CommCustGroup: Record CommissionCustomerGroupTigCM;
        CommCustGroupMember: Record CommCustomerGroupMemberTigCM;
        CommCustSalesperson: Record "CommCustomerSalespersonTigCM";
        Customer: Record Customer;
        Salesperson: Record "Salesperson/Purchaser";
        CommWizardStep: Record CommWizardStepTigCM;
        CommEntry: Record CommissionSetupSummaryTigCM;
        Vendor: Record Vendor;
        HasCommSetup: Boolean;
        VendorsCreated: Boolean;
        SetupWizardAlreadyRunErr: Label 'Setup Wizard has already been run.';
        ActionNotAllowedErr: Label 'Action not allowed. Commission transactions have already been posted.';

    procedure CreateCommSetup(RecogTriggerMethod: Option Booking,Shipment,Invoice,Payment; PayableTriggerMethod: Option Booking,Shipment,Invoice,Payment);
    begin
        with CommSetup do begin
            Init();
            Validate("Def. Commission Type", "Def. Commission Type"::Percent);
            Validate("Def. Commission Basis", "Def. Commission Basis"::"Line Margin");
            Validate("Recog. Trigger Method", RecogTriggerMethod);
            Validate("Payable Trigger Method", PayableTriggerMethod);
            Insert(true);
        end;
    end;

    procedure DeleteSetupData();
    begin
        if not CommEntry.IsEmpty() then
            Error(ActionNotAllowedErr);
        GetCommSetup();
        if CommSetup."Wizard Run" then
            Error(SetupWizardAlreadyRunErr);

        CommSetup.DeleteAll(true);
        CommPlan.Reset();
        CommPlan.DeleteAll(true);
        CommPlanPayee.Reset();
        CommPlanPayee.DeleteAll(true);
        CommPlanCalcLine.Reset();
        CommPlanCalcLine.DeleteAll(true);
        CommCustGroup.Reset();
        CommCustGroup.DeleteAll(true);
        CommCustGroupMember.Reset();
        CommCustGroupMember.DeleteAll(true);
        CommCustSalesperson.Reset();
        CommCustSalesperson.DeleteAll(true);
        DeleteCommWizardSteps();
    end;

    procedure CreatePayableVendors();
    begin
        Salesperson.Reset();
        if Salesperson.FindSet() then begin
            repeat
                with Vendor do begin
                    if not Get(Salesperson.Code) then begin
                        Init();
                        Validate("No.", Salesperson.Code);
                        Validate(Name, Salesperson.Name);
                        //Validate(Address
                        //Validate("Address 2"
                        //Validate(City
                        //Validate(County
                        //Validate("Post Code"
                        //Validate("Country/Region Code"
                        Validate("Phone No.", Salesperson."Phone No.");
                        Validate("E-Mail", Salesperson."E-Mail");
                        Insert(true);
                    end;
                end;
            until Salesperson.Next() = 0;
            VendorsCreated := true;
        end;
    end;

    procedure CreateCommPlan(CommPlanCode: Code[20]; UnitType: Integer; Desc: Text[50]; PayOnDiscounts: Boolean): Code[20];
    begin
        GetCommSetup();
        if CommSetup."Wizard Run" then
            Error(SetupWizardAlreadyRunErr);

        with CommPlan do begin
            Init();
            Validate(Code, CommPlanCode);
            Description := Desc;
            Validate("Source Type", "Source Type"::Customer);
            Validate("Source Method", "Source Method"::Group); //for this function we always use a salesperson group
            "Source Method Code" := Code; //no validate as comm. cust. group not built yet
            Validate("Unit Type", UnitType);
            Validate("Unit Method", "Unit Method"::All);
            Validate("Commission Type", "Commission Type"::Percent);
            Validate("Commission Basis", "Commission Basis"::"Line Margin");
            Validate("Recognition Trigger Method", CommSetup."Recog. Trigger Method");
            Validate("Payable Trigger Method", CommSetup."Payable Trigger Method");
            Validate("Pay On Invoice Discounts", PayOnDiscounts);
            Insert(true);
            exit(Code);
        end;
    end;

    procedure CreateCommPlanPayee(CommPlanCode: Code[20]; SalespersonCode: Code[20]; DistributionMethod: Option Vendor,"NAV employee",Paychex,ADP,"Other 3rd party"; DistributionAccountNo: Code[20]);
    begin
        GetCommSetup();
        if CommSetup."Wizard Run" then
            Error(SetupWizardAlreadyRunErr);

        Salesperson.Reset();
        if SalespersonCode <> '' then
            Salesperson.SetRange(Code, SalespersonCode);
        if Salesperson.FindSet() then begin
            repeat
                with CommPlanPayee do begin
                    Init();
                    Validate("Commission Plan Code", CommPlanCode);
                    Validate("Salesperson Code", Salesperson.Code);
                    Validate("Distribution Method", DistributionMethod);
                    if VendorsCreated then
                        Validate("Distribution Code", Salesperson.Code);
                    Validate("Distribution Account No.", DistributionAccountNo);
                    Insert(true);
                end;
            until Salesperson.Next() = 0;
        end;
    end;

    procedure CreateCommPlanCalcLine(CommPlanCode: Code[20]; CommRate: Decimal);
    begin
        GetCommSetup();
        if CommSetup."Wizard Run" then
            Error(SetupWizardAlreadyRunErr);

        with CommPlanCalcLine do begin
            Init();
            Validate("Commission Plan Code", CommPlanCode);
            Validate("Commission Rate", CommRate);
            Insert(true);
        end;
    end;

    procedure CreateCommCustSalesperson();
    begin
        GetCommSetup();
        if CommSetup."Wizard Run" then
            Error(SetupWizardAlreadyRunErr);

        Customer.Reset();
        Salesperson.Reset();
        if Salesperson.FindSet() then begin
            repeat
                Customer.SetRange("Salesperson Code", Salesperson.Code);
                if Customer.FindSet() then begin
                    repeat
                        with CommCustSalesperson do begin
                            Init();
                            Validate("Customer No.", Customer."No.");
                            Validate("Salesperson Code", Salesperson.Code);
                            Insert(true);
                        end;
                    until Customer.Next() = 0;
                end;
            until Salesperson.Next() = 0;
        end;
    end;

    procedure CreateCommCustGroup(SalespersonCode: Code[20]);
    begin
        Customer.Reset();
        with Salesperson do begin
            Reset();
            if SalespersonCode <> '' then
                SetRange(Code, SalespersonCode);
            if Salesperson.FindSet() then begin
                repeat
                    CommCustGroup.Init();
                    CommCustGroup.Validate(Code, Salesperson.Code);
                    CommCustGroup.Insert(true);
                    Customer.SetRange("Salesperson Code", Salesperson.Code);
                    if Customer.FindSet() then begin
                        repeat
                            CommCustGroupMember.Init();
                            CommCustGroupMember.Validate("Group Code", CommCustGroup.Code);
                            CommCustGroupMember.Validate("Customer No.", Customer."No.");
                            CommCustGroupMember.Insert(true);
                        until Customer.Next() = 0;
                    end;
                until Next() = 0;
            end;
        end;
    end;

    local procedure GetCommSetup();
    begin
        if not HasCommSetup then begin
            if CommSetup.Get() then
                HasCommSetup := true;
        end;
    end;

    procedure DeleteCommWizardSteps();
    begin
        CommWizardStep.DeleteAll(true);
    end;

    procedure InsertCommWizardStep(Description: Text[250]; ActionCode: Code[20]; OfferHelp: Boolean);
    var
        EntryNo: Integer;
    begin
        with CommWizardStep do begin
            if FindLast() then
                EntryNo := "Entry No." + 1
            else
                EntryNo := 1;

            Init();
            "Entry No." := EntryNo;
            "Action Msg." := Description;
            "Action Code" := ActionCode;
            if OfferHelp then
                Help := '*';
            Insert();
        end;
    end;
}

