codeunit 50007 "CommissionInitialImpMgtTigCM"
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
        Vendor: Record Vendor;
        HasCommSetup: Boolean;
        Text001: Label 'Setup Wizard has already been run.';
        Text002: Label 'Action not allowed. Commission transactions have already been posted.';
        VendorsCreated: Boolean;
        "***Custom***": Integer;
        CommImport: Record CommissionInitialImportTigCM;

    procedure CreateCommSetup(RecogTriggerMethod: Option Booking,Shipment,Invoice,Payment; PayableTriggerMethod: Option Booking,Shipment,Invoice,Payment);
    begin
        with CommSetup do begin
            if not GET then begin
                INIT;
                VALIDATE("Def. Commission Type", "Def. Commission Type"::Percent);
                VALIDATE("Def. Commission Basis", "Def. Commission Basis"::"Line Margin");
                VALIDATE("Recog. Trigger Method", RecogTriggerMethod);
                VALIDATE("Payable Trigger Method", PayableTriggerMethod);
                INSERT(true);
            end else begin
                VALIDATE("Wizard Run", false);
                MODIFY;
            end;
        end;
    end;

    procedure DeleteSetupData();
    begin
        //IF NOT CommEntry.ISEMPTY THEN
        //  ERROR(Text002);
        GetCommSetup;
        if CommSetup."Wizard Run" then
            ERROR(Text001);

        CommSetup.DELETEALL(true);
        CommPlan.RESET;
        CommPlan.DELETEALL(true);
        CommPlanPayee.RESET;
        CommPlanPayee.DELETEALL(true);
        CommPlanCalcLine.RESET;
        CommPlanCalcLine.DELETEALL(true);
        CommCustGroup.RESET;
        CommCustGroup.DELETEALL(true);
        CommCustGroupMember.RESET;
        CommCustGroupMember.DELETEALL(true);
        CommCustSalesperson.RESET;
        CommCustSalesperson.DELETEALL(true);
        DeleteCommWizardSteps;
    end;

    procedure CreatePayableVendors();
    begin
        Salesperson.RESET;
        if Salesperson.FINDSET then begin
            repeat
                with Vendor do begin
                    if not GET(Salesperson.Code) then begin
                        INIT;
                        VALIDATE("No.", Salesperson.Code);
                        VALIDATE(Name, Salesperson.Name);
                        //VALIDATE(Address
                        //VALIDATE("Address 2"
                        //VALIDATE(City
                        //VALIDATE(County
                        //VALIDATE("Post Code"
                        //VALIDATE("Country/Region Code"
                        VALIDATE("Phone No.", Salesperson."Phone No.");
                        VALIDATE("E-Mail", Salesperson."E-Mail");
                        INSERT(true);
                    end;
                end;
            until Salesperson.NEXT = 0;
            VendorsCreated := true;
        end;
    end;

    procedure CreateCommPlan(CommPlanCode: Code[20]; UnitType: Integer; Desc: Text[50]; PayOnDiscounts: Boolean): Code[20];
    begin
        GetCommSetup;
        if CommSetup."Wizard Run" then
            ERROR(Text001);

        if CommImport.FINDSET then begin
            repeat
                with CommPlan do begin
                    if not GET(CommImport."Comm. Code") then begin
                        INIT;
                        VALIDATE(Code, CommImport."Comm. Code");
                        Description := CommImport."Comm. Code";
                        VALIDATE("Source Type", "Source Type"::Customer);
                        VALIDATE("Source Method", "Source Method"::Group);
                        "Source Method Code" := CommImport."Comm. Code"; //no validate as comm. cust. group not built yet
                        VALIDATE("Unit Type", UnitType);
                        VALIDATE("Unit Method", "Unit Method"::All);
                        VALIDATE("Commission Type", "Commission Type"::Percent);
                        VALIDATE("Commission Basis", "Commission Basis"::"Line Margin");
                        VALIDATE("Recognition Trigger Method", CommSetup."Recog. Trigger Method");
                        VALIDATE("Payable Trigger Method", CommSetup."Payable Trigger Method");
                        //VALIDATE("Pay On Invoice Discounts",PayOnDiscounts);
                        INSERT(true);
                    end;
                end;
            until CommImport.NEXT = 0;
        end;
    end;

    procedure CreateCommPlanPayee(CommPlanCode: Code[20]; SalespersonCode: Code[20]; DistributionMethod: Option Vendor,"NAV employee",Paychex,ADP,"Other 3rd party"; DistributionAccountNo: Code[20]);
    begin
        GetCommSetup;
        if CommSetup."Wizard Run" then
            ERROR(Text001);

        if CommImport.FINDSET then begin
            repeat
                with CommPlanPayee do begin
                    SETRANGE("Commission Plan Code", CommImport."Comm. Code");
                    SETRANGE("Salesperson Code", CommImport."Salesperson Code");
                    if not FINDFIRST then begin
                        INIT;
                        VALIDATE("Commission Plan Code", CommImport."Comm. Code");
                        "Salesperson Code" := CommImport."Salesperson Code";
                        VALIDATE("Distribution Method", DistributionMethod);
                        /*
                        IF VendorsCreated THEN
                          VALIDATE("Distribution Code",Salesperson.Code);
                        VALIDATE("Distribution Account No.",DistributionAccountNo);
                        */
                        INSERT(true);

                        CreateCommPlanCalcLine(CommImport."Comm. Code", CommImport."Comm. Rate");
                    end;
                end;
            until CommImport.NEXT = 0;
        end;

    end;

    procedure CreateCommPlanCalcLine(CommPlanCode: Code[20]; CommRate: Decimal);
    begin
        GetCommSetup;
        if CommSetup."Wizard Run" then
            ERROR(Text001);

        with CommPlanCalcLine do begin
            if not GET(CommPlanCode) then begin
                INIT;
                VALIDATE("Commission Plan Code", CommPlanCode);
                VALIDATE("Commission Rate", CommRate);
                INSERT(true);
            end;
        end;
    end;

    procedure CreateCommCustSalesperson();
    begin
        GetCommSetup;
        if CommSetup."Wizard Run" then
            ERROR(Text001);

        CommImport.RESET;
        if CommImport.FINDSET then begin
            repeat
                with CommCustSalesperson do begin
                    if not GET(CommImport."Customer No.", CommImport."Salesperson Code") then begin
                        INIT;
                        VALIDATE("Customer No.", CommImport."Customer No.");
                        //"Customer No." := CommImport."Customer No.";
                        "Salesperson Code" := CommImport."Salesperson Code";
                        INSERT(true);
                    end;
                end;
            until CommImport.NEXT = 0;
        end;
    end;

    procedure CreateCommCustGroup(SalespersonCode: Code[20]);
    begin
        with CommImport do begin
            if FINDSET then begin
                repeat
                    if not CommCustGroup.GET(CommImport."Comm. Code") then begin
                        CommCustGroup.INIT;
                        CommCustGroup.Code := CommImport."Comm. Code";
                        CommCustGroup.Description := CommImport."Comm. Code";
                        CommCustGroup.INSERT(true);
                    end;

                    CommCustGroupMember.INIT;
                    CommCustGroupMember."Group Code" := CommImport."Comm. Code";
                    CommCustGroupMember.VALIDATE("Customer No.", CommImport."Customer No.");
                    //CommCustGroupMember."Customer No." := CommImport."Customer No.";
                    CommCustGroupMember.INSERT(true);
                until NEXT = 0;
            end;
        end;
    end;

    local procedure GetCommSetup();
    begin
        if not HasCommSetup then begin
            if CommSetup.GET then
                HasCommSetup := true;
        end;
    end;

    procedure DeleteCommWizardSteps();
    begin
        CommWizardStep.DELETEALL(true);
    end;

    procedure InsertCommWizardStep(Description: Text[250]; ActionCode: Code[20]; OfferHelp: Boolean);
    var
        EntryNo: Integer;
    begin
        with CommWizardStep do begin
            if FINDLAST then
                EntryNo := "Entry No." + 1
            else
                EntryNo := 1;

            INIT;
            "Entry No." := EntryNo;
            "Action Msg." := Description;
            "Action Code" := ActionCode;
            if OfferHelp then
                Help := '*';
            INSERT;
        end;
    end;
}

