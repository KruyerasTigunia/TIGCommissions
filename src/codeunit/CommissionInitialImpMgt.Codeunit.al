codeunit 80004 "CommissionInitialImpMgtTigCM"
{
    var
        CommSetup: Record CommissionSetupTigCM;
        CommPlan: Record CommissionPlanTigCM;
        CommPlanPayee: Record CommissionPlanPayeeTigCM;
        CommPlanCalcLine: Record CommissionPlanCalculationTigCM;
        CommCustGroup: Record CommissionCustomerGroupTigCM;
        CommCustGroupMember: Record CommCustomerGroupMemberTigCM;
        CommCustSalesperson: Record "CommCustomerSalespersonTigCM";
        CommImport: Record CommissionInitialImportTigCM;
        CommWizardStep: Record CommWizardStepTigCM;
        Salesperson: Record "Salesperson/Purchaser";
        Vendor: Record Vendor;
        HasCommSetup: Boolean;
        VendorsCreated: Boolean;
        SetupWizardAlreadyRunErr: Label 'Setup Wizard has already been run.';

    procedure CreateCommSetup(RecogTriggerMethod: Option Booking,Shipment,Invoice,Payment; PayableTriggerMethod: Option Booking,Shipment,Invoice,Payment);
    begin
        with CommSetup do begin
            if not Get() then begin
                Init();
                Validate("Def. Commission Type", "Def. Commission Type"::Percent);
                Validate("Def. Commission Basis", "Def. Commission Basis"::"Line Margin");
                Validate("Recog. Trigger Method", RecogTriggerMethod);
                Validate("Payable Trigger Method", PayableTriggerMethod);
                Insert(true);
            end else begin
                Validate("Wizard Run", false);
                Modify();
            end;
        end;
    end;

    procedure DeleteSetupData();
    begin
        //IF NOT CommEntry.IsEmpty() THEN
        //  Error(Text002);
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

        if CommImport.FindSet() then begin
            repeat
                with CommPlan do begin
                    if not Get(CommImport."Comm. Code") then begin
                        Init();
                        Validate(Code, CommImport."Comm. Code");
                        Description := CommImport."Comm. Code";
                        Validate("Source Type", "Source Type"::Customer);
                        Validate("Source Method", "Source Method"::Group);
                        "Source Method Code" := CommImport."Comm. Code"; //no validate as comm. cust. group not built yet
                        Validate("Unit Type", UnitType);
                        Validate("Unit Method", "Unit Method"::All);
                        Validate("Commission Type", "Commission Type"::Percent);
                        Validate("Commission Basis", "Commission Basis"::"Line Margin");
                        Validate("Recognition Trigger Method", CommSetup."Recog. Trigger Method");
                        Validate("Payable Trigger Method", CommSetup."Payable Trigger Method");
                        //Validate("Pay On Invoice Discounts",PayOnDiscounts);
                        Insert(true);
                    end;
                end;
            until CommImport.Next() = 0;
        end;
    end;

    procedure CreateCommPlanPayee(CommPlanCode: Code[20]; SalespersonCode: Code[20]; DistributionMethod: Option Vendor,"NAV employee",Paychex,ADP,"Other 3rd party"; DistributionAccountNo: Code[20]);
    begin
        GetCommSetup();
        if CommSetup."Wizard Run" then
            Error(SetupWizardAlreadyRunErr);

        if CommImport.FindSet() then begin
            repeat
                with CommPlanPayee do begin
                    SetRange("Commission Plan Code", CommImport."Comm. Code");
                    SetRange("Salesperson Code", CommImport."Salesperson Code");
                    if not FindFirst() then begin
                        Init();
                        Validate("Commission Plan Code", CommImport."Comm. Code");
                        "Salesperson Code" := CommImport."Salesperson Code";
                        Validate("Distribution Method", DistributionMethod);
                        /*
                        IF VendorsCreated THEN
                          Validate("Distribution Code",Salesperson.Code);
                        Validate("Distribution Account No.",DistributionAccountNo);
                        */
                        Insert(true);

                        CreateCommPlanCalcLine(CommImport."Comm. Code", CommImport."Comm. Rate");
                    end;
                end;
            until CommImport.Next() = 0;
        end;

    end;

    procedure CreateCommPlanCalcLine(CommPlanCode: Code[20]; CommRate: Decimal);
    begin
        GetCommSetup();
        if CommSetup."Wizard Run" then
            Error(SetupWizardAlreadyRunErr);

        with CommPlanCalcLine do begin
            if not Get(CommPlanCode) then begin
                Init();
                Validate("Commission Plan Code", CommPlanCode);
                Validate("Commission Rate", CommRate);
                Insert(true);
            end;
        end;
    end;

    procedure CreateCommCustSalesperson();
    begin
        GetCommSetup();
        if CommSetup."Wizard Run" then
            Error(SetupWizardAlreadyRunErr);

        CommImport.Reset();
        if CommImport.FindSet() then begin
            repeat
                with CommCustSalesperson do begin
                    if not Get(CommImport."Customer No.", CommImport."Salesperson Code") then begin
                        Init();
                        Validate("Customer No.", CommImport."Customer No.");
                        //"Customer No." := CommImport."Customer No.";
                        "Salesperson Code" := CommImport."Salesperson Code";
                        Insert(true);
                    end;
                end;
            until CommImport.Next() = 0;
        end;
    end;

    procedure CreateCommCustGroup(SalespersonCode: Code[20]);
    begin
        with CommImport do begin
            if FindSet() then begin
                repeat
                    if not CommCustGroup.Get(CommImport."Comm. Code") then begin
                        CommCustGroup.Init();
                        CommCustGroup.Code := CommImport."Comm. Code";
                        CommCustGroup.Description := CommImport."Comm. Code";
                        CommCustGroup.Insert(true);
                    end;

                    CommCustGroupMember.Init();
                    CommCustGroupMember."Group Code" := CommImport."Comm. Code";
                    CommCustGroupMember.Validate("Customer No.", CommImport."Customer No.");
                    //CommCustGroupMember."Customer No." := CommImport."Customer No.";
                    CommCustGroupMember.Insert(true);
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