codeunit 80002 "CommissionWizardMgtTigCM"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions


    trigger OnRun();
    begin
        // see ???
    end;

    var
        CommSetup: Record "Commission Setup";
        CommPlan: Record "Commission Plan";
        CommPlanPayee: Record "Commission Plan Payee";
        CommPlanCalcLine: Record "Commission Plan Calculation";
        CommCustGroup: Record "Commission Customer Group";
        CommCustGroupMember: Record "Commission Cust. Group Member";
        CommCustSalesperson: Record "Commission Cust/Salesperson";
        Customer: Record Customer;
        Salesperson: Record "Salesperson/Purchaser";
        CommWizardStep: Record "Comm. Wizard Step";
        CommEntry: Record "Commission Setup Summary";
        Vendor: Record Vendor;
        HasCommSetup: Boolean;
        Text001: Label 'Setup Wizard has already been run.';
        Text002: Label 'Action not allowed. Commission transactions have already been posted.';
        VendorsCreated: Boolean;

    procedure CreateCommSetup(RecogTriggerMethod: Option Booking,Shipment,Invoice,Payment; PayableTriggerMethod: Option Booking,Shipment,Invoice,Payment);
    begin
        with CommSetup do begin
            INIT;
            VALIDATE("Def. Commission Type", "Def. Commission Type"::Percent);
            VALIDATE("Def. Commission Basis", "Def. Commission Basis"::"Line Margin");
            VALIDATE("Recog. Trigger Method", RecogTriggerMethod);
            VALIDATE("Payable Trigger Method", PayableTriggerMethod);
            INSERT(true);
        end;
    end;

    procedure DeleteSetupData();
    begin
        if not CommEntry.ISEMPTY then
            ERROR(Text002);
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

        with CommPlan do begin
            INIT;
            VALIDATE(Code, CommPlanCode);
            Description := Desc;
            VALIDATE("Source Type", "Source Type"::Customer);
            VALIDATE("Source Method", "Source Method"::Group); //for this function we always use a salesperson group
            "Source Method Code" := Code; //no validate as comm. cust. group not built yet
            VALIDATE("Unit Type", UnitType);
            VALIDATE("Unit Method", "Unit Method"::All);
            VALIDATE("Commission Type", "Commission Type"::Percent);
            VALIDATE("Commission Basis", "Commission Basis"::"Line Margin");
            VALIDATE("Recognition Trigger Method", CommSetup."Recog. Trigger Method");
            VALIDATE("Payable Trigger Method", CommSetup."Payable Trigger Method");
            VALIDATE("Pay On Invoice Discounts", PayOnDiscounts);
            INSERT(true);
            exit(Code);
        end;
    end;

    procedure CreateCommPlanPayee(CommPlanCode: Code[20]; SalespersonCode: Code[20]; DistributionMethod: Option Vendor,"NAV employee",Paychex,ADP,"Other 3rd party"; DistributionAccountNo: Code[20]);
    begin
        GetCommSetup;
        if CommSetup."Wizard Run" then
            ERROR(Text001);

        Salesperson.RESET;
        if SalespersonCode <> '' then
            Salesperson.SETRANGE(Code, SalespersonCode);
        if Salesperson.FINDSET then begin
            repeat
                with CommPlanPayee do begin
                    INIT;
                    VALIDATE("Commission Plan Code", CommPlanCode);
                    VALIDATE("Salesperson Code", Salesperson.Code);
                    VALIDATE("Distribution Method", DistributionMethod);
                    if VendorsCreated then
                        VALIDATE("Distribution Code", Salesperson.Code);
                    VALIDATE("Distribution Account No.", DistributionAccountNo);
                    INSERT(true);
                end;
            until Salesperson.NEXT = 0;
        end;
    end;

    procedure CreateCommPlanCalcLine(CommPlanCode: Code[20]; CommRate: Decimal);
    begin
        GetCommSetup;
        if CommSetup."Wizard Run" then
            ERROR(Text001);

        with CommPlanCalcLine do begin
            INIT;
            VALIDATE("Commission Plan Code", CommPlanCode);
            VALIDATE("Commission Rate", CommRate);
            INSERT(true);
        end;
    end;

    procedure CreateCommCustSalesperson();
    begin
        GetCommSetup;
        if CommSetup."Wizard Run" then
            ERROR(Text001);

        Customer.RESET;
        Salesperson.RESET;
        if Salesperson.FINDSET then begin
            repeat
                Customer.SETRANGE("Salesperson Code", Salesperson.Code);
                if Customer.FINDSET then begin
                    repeat
                        with CommCustSalesperson do begin
                            INIT;
                            VALIDATE("Customer No.", Customer."No.");
                            VALIDATE("Salesperson Code", Salesperson.Code);
                            INSERT(true);
                        end;
                    until Customer.NEXT = 0;
                end;
            until Salesperson.NEXT = 0;
        end;
    end;

    procedure CreateCommCustGroup(SalespersonCode: Code[20]);
    begin
        Customer.RESET;
        with Salesperson do begin
            RESET;
            if SalespersonCode <> '' then
                SETRANGE(Code, SalespersonCode);
            if Salesperson.FINDSET then begin
                repeat
                    CommCustGroup.INIT;
                    CommCustGroup.VALIDATE(Code, Salesperson.Code);
                    CommCustGroup.INSERT(true);
                    Customer.SETRANGE("Salesperson Code", Salesperson.Code);
                    if Customer.FINDSET then begin
                        repeat
                            CommCustGroupMember.INIT;
                            CommCustGroupMember.VALIDATE("Group Code", CommCustGroup.Code);
                            CommCustGroupMember.VALIDATE("Customer No.", Customer."No.");
                            CommCustGroupMember.INSERT(true);
                        until Customer.NEXT = 0;
                    end;
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

