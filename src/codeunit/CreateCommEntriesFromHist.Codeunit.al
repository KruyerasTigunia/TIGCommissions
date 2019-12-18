codeunit 80003 "CreateCommEntriesFromHistTigCM"
{
    var
        CommSetup: Record CommissionSetupTigCM;
        RecogEntry: Record CommRecognitionEntryTigCM;
        ApprovalEntry: Record CommApprovalEntryTigCM;
        PaymentEntry: Record CommissionPaymentEntryTigCM;
        PaymentEntry2: Record CommissionPaymentEntryTigCM;
        CommPlan: Record CommissionPlanTigCM;
        CommPlanPayee: Record CommissionPlanPayeeTigCM;
        SalesLineTemp: Record "Sales Line" temporary;
        PurchHeaderTemp: Record "Purchase Header" temporary;
        PurchLineTemp: Record "Purchase Line" temporary;
        TriggerMethod: Option Booking,Shipment,Invoice,Payment,,,Credit;
        CustomerNo: Code[20];
        UnitNo: Code[20];
        EntryNo: Integer;
        HasCommSetup: Boolean;
        RecognitionMode: Boolean;
        ApprovalMode: Boolean;
        CalcSetupMode: Boolean;
        EntryType: Option Commission,Clawback,Advance,Adjustment;
        UnitType: Option " ","G/L Account",Item,Resource,"Fixed Asset","Charge (Item)";
        NoPlanForCustomerErr: Label 'No Commission Plan found for Customer %1';
        NoPlanForInvCMLineErr: Label 'No Commission Plan found for Customer %1, %2 %3';
        CreditLbl: Label 'CREDIT';
        CompleteMsg: Label 'Complete.';

    local procedure GetCommSetup();
    begin
        if not HasCommSetup then begin
            CommSetup.Get();
            HasCommSetup := true;
        end;
    end;

    procedure CheckTriggers(TriggerMethod: Option Booking,Shipment,Invoice,Payment,,,Credit; var CommPlanCode: Code[20]; LineType: Option " ","G/L Account",Item,Resource,"Fixed Asset","Charge (Item)") FailureCode: Code[20];
    var
        CommPlanTemp: Record CommissionPlanTigCM temporary;
    begin
        GetCommSetup();
        RecognitionMode := false;
        ApprovalMode := false;
        CommPlanCode := '';

        GetCustPlans(CommPlanTemp, CustomerNo);
        if not CommPlanTemp.FindSet() then
            exit('NOCUSTPLAN');

        if CalcSetupMode then begin
            CommPlanCode := CommPlanTemp.Code;
            exit;
        end;

        //Credit memo/return order invoice posting ALWAYS processes
        if TriggerMethod = TriggerMethod::Credit then begin
            CommPlanCode := CreditLbl;
            RecognitionMode := true;
            ApprovalMode := true;
            exit;
        end;

        if CommSetup."Recog. Trigger Method" = TriggerMethod then begin
            if GetItemPlan(CommPlanTemp, CommPlanCode) then begin
                RecognitionMode := true;
            end else
                exit('NOITEMPLAN');
        end;

        if CommSetup."Payable Trigger Method" = TriggerMethod then begin
            if GetItemPlan(CommPlanTemp, CommPlanCode) then begin
                ApprovalMode := true;
            end else
                exit('NOITEMPLAN');
        end;

        if (RecognitionMode) or (ApprovalMode) then
            exit('');
    end;

    procedure AnalyzeShipments(SalesShptHeader: Record "Sales Shipment Header");
    var
        SalesShptHeader2: Record "Sales Shipment Header";
        ItemLedgEntry: Record "Item Ledger Entry";
        SalesShptLine: Record "Sales Shipment Line";
        CommPlanCode: Code[20];
        BasisAmt: Decimal;
    begin
        ResetCodeunit();

        SalesShptLine.SetRange("Document No.", SalesShptHeader."No.");
        //xxxSalesShptLine.SetFilter(Type,'%1|%2',SalesShptLine.Type::"G/L Account",
        //                        SalesShptLine.Type::Item);
        SalesShptLine.SetFilter(Type, '%1', SalesShptLine.Type::Item);

        SalesShptLine.SetFilter("No.", '<>%1', '');
        SalesShptLine.SetFilter(Quantity, '<>%1', 0);
        if SalesShptLine.FindSet() then begin
            repeat
                CustomerNo := SalesShptLine."Sell-to Customer No.";
                UnitType := SalesShptLine.Type;
                UnitNo := SalesShptLine."No.";

                case CheckTriggers(TriggerMethod::Shipment, CommPlanCode, SalesShptLine.Type) of
                    'NOCUSTPLAN':
                        Error(NoPlanForCustomerErr, SalesShptLine."Sell-to Customer No.");
                    'NOITEMPLAN':
                        Error(NoPlanForInvCMLineErr,
                              SalesShptLine."Sell-to Customer No.",
                              FORMAT(SalesShptLine.Type),
                              SalesShptLine."No.");
                end;

                if (RecognitionMode) or (ApprovalMode) then begin
                    //No extended amount on shipment line. Get entry
                    //for this and other stuff
                    if SalesShptLine.Type = SalesShptLine.Type::Item then begin
                        ItemLedgEntry.SetCurrentKey("Document No.", "Document Type", "Document Line No.");
                        ItemLedgEntry.SetRange("Document Type", ItemLedgEntry."Document Type"::"Sales Shipment");
                        ItemLedgEntry.SetRange("Document No.", SalesShptLine."Document No.");
                        ItemLedgEntry.SetRange("Document Line No.", SalesShptLine."Line No.");
                        ItemLedgEntry.FindFirst();
                    end else
                        Clear(ItemLedgEntry);

                    BasisAmt := Round(SalesShptLine.Quantity * SalesShptLine."Unit Price", 0.01);

                    SalesLineTemp.Init();
                    SalesLineTemp.TransferFields(SalesShptLine);
                    SalesLineTemp."Document Type" := SalesLineTemp."Document Type"::Order;
                    SalesLineTemp."Document No." := SalesShptLine."Order No.";
                    SalesLineTemp."Line No." := SalesShptLine."Order Line No.";
                    SalesLineTemp.Amount := BasisAmt;
                    SalesLineTemp."Purchase Order No." :=
                        CopyStr(SalesShptHeader."External Document No.", 1, MaxStrLen(SalesLineTemp."Purchase Order No."));

                    if RecognitionMode then
                        InsertRecogEntry(SalesLineTemp, CommPlanCode, EntryType::Commission,
                                         SalesShptLine."Document No.",
                                         TriggerMethod::Shipment,
                                         ItemLedgEntry."Entry No.",
                                         SalesShptHeader."Posting Date", SalesShptLine."Document No.");
                    if ApprovalMode then
                        InsertApprovalEntry(SalesLineTemp, SalesShptLine."Document No.",
                                            TriggerMethod::Shipment, 0, SalesShptHeader."Posting Date",
                                            SalesShptLine."Document No.");
                end;
            until SalesShptLine.Next() = 0;
        end;

        SalesShptHeader2.Get(SalesShptHeader."No.");
        SalesShptHeader2.CommissionCalculatedTigCM := true;
        SalesShptHeader2.Modify();
    end;

    procedure AnalyzeInvoices(SalesInvHeader: Record "Sales Invoice Header");
    var
        SalesInvHeader2: Record "Sales Invoice Header";
        SalesShptHeader: Record "Sales Shipment Header";
        ValueEntry: Record "Value Entry";
        ItemLedgEntry: Record "Item Ledger Entry";
        SalesInvLine: Record "Sales Invoice Line";
        CommPlanCode: Code[20];
    begin
        ResetCodeunit();

        SalesInvLine.SetRange("Document No.", SalesInvHeader."No.");
        //xxxSalesInvLine.SetFilter(Type,'%1|%2',SalesInvLine.Type::"G/L Account",
        //                       SalesInvLine.Type::Item);
        SalesInvLine.SetFilter(Type, '%1', SalesInvLine.Type::Item);
        SalesInvLine.SetFilter("No.", '<>%1', '');
        SalesInvLine.SetFilter(Quantity, '<>%1', 0);
        if SalesInvLine.FindSet() then begin
            repeat
                CustomerNo := SalesInvLine."Sell-to Customer No.";
                UnitType := SalesInvLine.Type;
                UnitNo := SalesInvLine."No.";

                case CheckTriggers(TriggerMethod::Invoice, CommPlanCode, SalesInvLine.Type) of
                    'NOCUSTPLAN':
                        Error(NoPlanForCustomerErr, SalesInvLine."Sell-to Customer No.");
                    'NOITEMPLAN':
                        Error(NoPlanForInvCMLineErr,
                         SalesInvLine."Sell-to Customer No.",
                         FORMAT(SalesInvLine.Type),
                         SalesInvLine."No.");
                end;

                if (RecognitionMode) or (ApprovalMode) then begin
                    if SalesInvLine.Type = SalesInvLine.Type::Item then begin
                        ValueEntry.SetCurrentKey("Document No.");
                        ValueEntry.SetRange("Document No.", SalesInvHeader."No.");
                        ValueEntry.SetRange("Document Line No.", SalesInvLine."Line No.");
                        ValueEntry.SetRange("Posting Date", SalesInvHeader."Posting Date");
                        ValueEntry.FindFirst();
                        ItemLedgEntry.Get(ValueEntry."Item Ledger Entry No.");
                    end else
                        Clear(ItemLedgEntry);

                    SalesLineTemp.Init();
                    SalesLineTemp.TransferFields(SalesInvLine);
                    if SalesInvHeader."Order No." <> '' then begin
                        SalesLineTemp."Document Type" := SalesLineTemp."Document Type"::Order;
                        SalesLineTemp."Document No." := SalesInvHeader."Order No.";
                        SalesLineTemp."Line No." := SalesInvLine."Shipment Line No.";
                    end else begin
                        if not SalesShptHeader.Get(ItemLedgEntry."Document No.") then
                            Clear(SalesShptHeader);
                        SalesLineTemp."Document Type" := SalesLineTemp."Document Type"::Invoice;
                        SalesLineTemp."Document No." := SalesShptHeader."Order No.";
                        SalesLineTemp."Line No." := ItemLedgEntry."Document Line No.";
                    end;

                    //Last resort catch-all for doc references
                    if SalesLineTemp."Document No." = '' then
                        SalesLineTemp."Document No." := SalesInvHeader."No.";
                    if SalesLineTemp."Line No." = 0 then
                        SalesLineTemp."Line No." := SalesInvLine."Line No.";

                    SalesLineTemp."Purchase Order No." :=
                        CopyStr(SalesInvHeader."External Document No.", 1, MaxStrLen(SalesLineTemp."Purchase Order No."));

                    if RecognitionMode then
                        InsertRecogEntry(SalesLineTemp, CommPlanCode, EntryType::Commission,
                                         SalesInvLine."Document No.",
                                         TriggerMethod::Invoice,
                                         ItemLedgEntry."Entry No.",
                                         SalesInvHeader."Posting Date", SalesInvLine."Document No.");
                    if ApprovalMode then
                        InsertApprovalEntry(SalesLineTemp, SalesInvLine."Document No.",
                                            TriggerMethod::Invoice, 0, SalesInvHeader."Posting Date",
                                            SalesInvLine."Document No.");
                end;
            until SalesInvLine.Next() = 0;
        end;

        SalesInvHeader2.Get(SalesInvHeader."No.");
        SalesInvHeader2.CommissionCalculatedTigCM := true;
        SalesInvHeader2.Modify();
    end;

    procedure AnalyzeCrMemos(SalesCrMemoHeader: Record "Sales Cr.Memo Header");
    var
        SalesCrMemoHeader2: Record "Sales Cr.Memo Header";
        ItemLedgEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        CommPlanCode: Code[20];
    begin
        ResetCodeunit();

        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetFilter(Type, '%1|%2', SalesCrMemoLine.Type::"G/L Account",
                                  SalesCrMemoLine.Type::Item);
        SalesCrMemoLine.SetFilter("No.", '<>%1', '');
        SalesCrMemoLine.SetFilter(Quantity, '<>%1', 0);
        if SalesCrMemoLine.FindSet() then begin
            repeat
                CustomerNo := SalesCrMemoLine."Sell-to Customer No.";
                UnitType := SalesCrMemoLine.Type;
                UnitNo := SalesCrMemoLine."No.";

                case CheckTriggers(TriggerMethod::Credit, CommPlanCode, SalesCrMemoLine.Type) of
                    'NOCUSTPLAN':
                        Error(NoPlanForCustomerErr, SalesCrMemoLine."Sell-to Customer No.");
                    'NOITEMPLAN':
                        Error(NoPlanForInvCMLineErr,
                              SalesCrMemoLine."Sell-to Customer No.",
                              FORMAT(SalesCrMemoLine.Type),
                              SalesCrMemoLine."No.");
                end;

                if (RecognitionMode) or (ApprovalMode) then begin
                    if SalesCrMemoLine.Type = SalesCrMemoLine.Type::Item then begin
                        ValueEntry.SetCurrentKey("Document No.");
                        ValueEntry.SetRange("Document No.", SalesCrMemoLine."Document No.");
                        ValueEntry.SetRange("Document Line No.", SalesCrMemoLine."Line No.");
                        ValueEntry.SetRange("Posting Date", SalesCrMemoHeader."Posting Date");
                        ValueEntry.FindFirst();
                        ItemLedgEntry.Get(ValueEntry."Item Ledger Entry No.");
                    end else
                        Clear(ItemLedgEntry);

                    SalesLineTemp.Init();
                    SalesLineTemp.TransferFields(SalesCrMemoLine);
                    if SalesCrMemoHeader."Pre-Assigned No." <> '' then begin
                        SalesLineTemp."Document Type" := SalesLineTemp."Document Type"::"Credit Memo";
                        SalesLineTemp."Document No." := SalesCrMemoHeader."Pre-Assigned No.";
                    end else begin
                        SalesLineTemp."Document Type" := SalesLineTemp."Document Type"::"Return Order";
                        SalesLineTemp."Document No." := SalesCrMemoHeader."Return Order No.";
                    end;
                    SalesLineTemp."Line No." := ItemLedgEntry."Document Line No.";

                    //Last resort catch-all for doc references
                    if SalesLineTemp."Document No." = '' then
                        SalesLineTemp."Document No." := SalesCrMemoHeader."No.";
                    if SalesLineTemp."Line No." = 0 then
                        SalesLineTemp."Line No." := SalesCrMemoLine."Line No.";

                    SalesLineTemp.Quantity := -SalesLineTemp.Quantity;
                    SalesLineTemp.Amount := -SalesLineTemp.Amount;
                    SalesLineTemp."Purchase Order No." :=
                        CopyStr(SalesCrMemoHeader."External Document No.", 1, MaxStrLen(SalesLineTemp."Purchase Order No."));

                    if RecognitionMode then
                        InsertRecogEntry(SalesLineTemp, CommPlanCode, EntryType::Commission,
                                         SalesCrMemoLine."Document No.",
                                         TriggerMethod::Credit,
                                         ItemLedgEntry."Entry No.",
                                         SalesCrMemoHeader."Posting Date", SalesCrMemoLine."Document No.");
                    if ApprovalMode then
                        InsertApprovalEntry(SalesLineTemp, SalesCrMemoLine."Document No.",
                                            TriggerMethod::Credit, 0, SalesCrMemoHeader."Posting Date",
                                            SalesCrMemoLine."Document No.");
                end;
            until SalesCrMemoLine.Next() = 0;
        end;

        SalesCrMemoHeader2.Get(SalesCrMemoHeader."No.");
        SalesCrMemoHeader2.CommissionCalculatedTigCM := true;
        SalesCrMemoHeader2.Modify();
    end;

    procedure AnalyzePayments(DetCustLedgEntry: Record "Detailed Cust. Ledg. Entry");
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        DetCustLedgEntry2: Record "Detailed Cust. Ledg. Entry";
        SalesInvHeader: Record "Sales Invoice Header";
        ValueEntry: Record "Value Entry";
        SalesInvLine: Record "Sales Invoice Line";
        ItemLedgEntry: Record "Item Ledger Entry";
        SalesShptHeader: Record "Sales Shipment Header";
        CommWkshtLineTemp: Record CommissionWksheetLineTigCM temporary;
        CommCustSalesperson: Record "CommCustomerSalespersonTigCM";
        CommPlanCode: Code[20];
        DocNo: Code[20];
    begin
        ResetCodeunit();
        DocNo := '';

        CustLedgEntry.Get(DetCustLedgEntry."Applied Cust. Ledger Entry No.");
        //Beginning balance entries may not have a matching posted invoice
        if not SalesInvHeader.Get(CustLedgEntry."Document No.") then
            exit;

        if SalesInvHeader."No." = 'USPIN-18-01391' then
            Error('xxx');
        SalesInvLine.SetRange("Document No.", CustLedgEntry."Document No.");
        SalesInvLine.SetFilter(Type, '%1|%2', SalesInvLine.Type::"G/L Account",
                               SalesInvLine.Type::Item);
        SalesInvLine.SetFilter("No.", '<>%1', '');
        SalesInvLine.SetFilter(Quantity, '<>%1', 0);
        if SalesInvLine.FindSet() then begin
            repeat
                CustomerNo := SalesInvLine."Sell-to Customer No.";
                UnitType := SalesInvLine.Type;
                UnitNo := SalesInvLine."No.";

                CheckTriggers(TriggerMethod::Payment, CommPlanCode, SalesInvLine.Type);

                if ApprovalMode then begin
                    if SalesInvLine.Type = SalesInvLine.Type::Item then begin
                        ValueEntry.SetCurrentKey("Document No.");
                        ValueEntry.SetRange("Document No.", SalesInvHeader."No.");
                        ValueEntry.SetRange("Document Line No.", SalesInvLine."Line No.");
                        ValueEntry.SetRange("Posting Date", SalesInvHeader."Posting Date");
                        ValueEntry.FindFirst();
                        ItemLedgEntry.Get(ValueEntry."Item Ledger Entry No.");
                        DocNo := ItemLedgEntry."Document No.";
                    end else
                        Clear(ItemLedgEntry);
                    if not SalesShptHeader.Get(ItemLedgEntry."Document No.") then
                        Clear(SalesShptHeader);

                    //Use the preferred, originating document no. if possible
                    SalesLineTemp.Init();
                    SalesLineTemp.TransferFields(SalesInvLine);
                    SalesLineTemp."Document No." := '';

                    if SalesShptHeader."Order No." <> '' then begin
                        SalesLineTemp."Document Type" := SalesLineTemp."Document Type"::Order;
                        SalesLineTemp."Document No." := SalesShptHeader."Order No.";
                        SalesLineTemp."Line No." := SalesInvLine."Line No.";
                    end;

                    if (SalesLineTemp."Document No." = '') and (SalesInvHeader."Order No." <> '')
                    then begin
                        SalesLineTemp."Document Type" := SalesLineTemp."Document Type"::Order;
                        SalesLineTemp."Document No." := SalesInvHeader."Order No.";
                        SalesLineTemp."Line No." := SalesInvLine."Line No.";
                    end;

                    if (SalesLineTemp."Document No." = '') and (SalesInvHeader."Pre-Assigned No." <> '')
                    then begin
                        SalesLineTemp."Document Type" := SalesLineTemp."Document Type"::Invoice;
                        SalesLineTemp."Document No." := SalesInvHeader."Pre-Assigned No.";
                        SalesLineTemp."Line No." := SalesInvLine."Line No.";
                    end;

                    if SalesLineTemp."Document No." = '' then begin
                        SalesLineTemp."Document Type" := SalesLineTemp."Document Type"::Order;
                        SalesLineTemp."Document No." := ItemLedgEntry."Document No.";
                        SalesLineTemp."Line No." := SalesInvLine."Line No.";
                    end;

                    if DocNo = '' then
                        DocNo := DetCustLedgEntry."Document No.";

                    if SalesLineTemp."Document No." = '' then
                        SalesLineTemp."Document No." := DocNo;

                    SalesLineTemp."Purchase Order No." :=
                        CopyStr(SalesInvHeader."External Document No.", 1, MaxStrLen(SalesLineTemp."Purchase Order No."));
                    if SalesLineTemp."Purchase Order No." = '' then
                        SalesLineTemp."Purchase Order No." :=
                            CopyStr(SalesShptHeader."External Document No.", 1, MaxStrLen(SalesLineTemp."Purchase Order No."));

                    if RecognitionMode then
                        InsertRecogEntry(SalesLineTemp, CommPlanCode, EntryType::Commission,
                                         DetCustLedgEntry."Document No.",
                                         TriggerMethod::Payment,
                                         ItemLedgEntry."Entry No.",
                                         SalesShptHeader."Posting Date", SalesInvHeader."No.");

                    if ApprovalMode then
                        InsertApprovalEntry(SalesLineTemp, DetCustLedgEntry."Document No.", TriggerMethod::Payment,
                                            DetCustLedgEntry."Entry No.", DetCustLedgEntry."Posting Date",
                                            SalesInvHeader."No.");

                    //Get salesperson code
                    CommCustSalesperson.SetRange("Customer No.", SalesInvHeader."Sell-to Customer No.");
                    CommCustSalesperson.FindFirst();

                    //Create initialization payment entries
                    CommWkshtLineTemp.Init();
                    CommWkshtLineTemp."Batch Name" := 'INIT';
                    //CommWkshtLineTemp."Line No."
                    CommWkshtLineTemp."Entry Type" := CommWkshtLineTemp."Entry Type"::Commission;
                    CommWkshtLineTemp."Posting Date" := DetCustLedgEntry."Posting Date";
                    CommWkshtLineTemp."Payout Date" := DetCustLedgEntry."Posting Date";
                    CommWkshtLineTemp."Customer No." := DetCustLedgEntry."Customer No.";
                    CommWkshtLineTemp."Salesperson Code" := CommCustSalesperson."Salesperson Code";
                    CommWkshtLineTemp."Source Document No." := DocNo;
                    CommWkshtLineTemp.Description := 'Commission Payment Initialize';
                    CommWkshtLineTemp.Quantity := SalesInvLine.Quantity;
                    CommWkshtLineTemp.Amount := SalesInvLine.Amount;//xxx
                    CommWkshtLineTemp."Basis Amt. (Split)" := SalesInvLine.Amount;
                    CommWkshtLineTemp."Trigger Method" := CommWkshtLineTemp."Trigger Method"::Payment;
                    CommWkshtLineTemp."Trigger Document No." := DetCustLedgEntry."Document No.";
                    CommWkshtLineTemp."Comm. Approval Entry No." := ApprovalEntry."Entry No.";
                    CommWkshtLineTemp."System Created" := true;
                    CommWkshtLineTemp."Commission Plan Code" := CommPlanCode;


                    InsertPaymentEntry(CommWkshtLineTemp, ApprovalEntry, 2, '',
                                       0, SalesInvHeader."No."); //blank and 0 are for purch inv., 2 = paid manually
                end;
            until SalesInvLine.Next() = 0;
        end;

        DetCustLedgEntry2.Get(DetCustLedgEntry."Entry No.");
        DetCustLedgEntry2.CommissionCalculatedTigCM := true;
        DetCustLedgEntry2.Modify();
    end;

    procedure CalcSetupSummary(var CommSetupSummary: Record CommissionSetupSummaryTigCM);
    var
        Customer: Record Customer;
        CommPlanCalc: Record CommissionPlanCalculationTigCM;
        CommCustSalesperson: Record "CommCustomerSalespersonTigCM";
        CommSetupSummary2: Record CommissionSetupSummaryTigCM;
        CommPlanCode: Code[20];
        MyEntryNo: Integer;
    begin
        ResetCodeunit();
        CalcSetupMode := true;

        CommSetupSummary.Reset();
        CommSetupSummary.SetRange("User ID", UserId());
        CommSetupSummary.DeleteAll(true);

        if Customer.FindSet() then begin
            repeat
                CustomerNo := Customer."No.";

                CommCustSalesperson.SetRange("Customer No.", Customer."No.");
                if not CommCustSalesperson.FindFirst() then
                    Clear(CommCustSalesperson);

                //Write initial record for customer
                MyEntryNo += 1;
                CommSetupSummary.Init();
                CommSetupSummary."User ID" := CopyStr(UserId(), 1, 50);
                CommSetupSummary."Entry No." := MyEntryNo;
                CommSetupSummary."Customer No." := Customer."No.";
                CommSetupSummary."Cust. Salesperson Code" := CommCustSalesperson."Salesperson Code";
                CommSetupSummary.Insert();

                //Credit trigger always fires, 2 is for items
                case CheckTriggers(TriggerMethod::Credit, CommPlanCode, 2) of
                    'NOCUSTPLAN':
                        ;//no action
                    'NOITEMPLAN':
                        ;//no action
                    else begin
                            //We have a plan, write record for each payee
                            CommPlan.Get(CommPlanCode);
                            CommPlanCalc.SetRange("Commission Plan Code", CommPlanCode);
                            if CommPlanCalc.FindFirst() then begin
                                CommPlanPayee.SetRange("Commission Plan Code", CommPlanCode);
                                if CommPlanPayee.FindSet() then begin
                                    repeat
                                        /*
                                        CommSetupSummary.Init();
                                        CommSetupSummary."User ID" := CopyStr(UserId(),1,50);
                                        CommSetupSummary."Entry No." := EntryNo;
                                        CommSetupSummary."Customer No." := Customer."No.";
                                        CommSetupSummary."pay Salesperson Code" := CommPlanPayee."Salesperson Code";
                                        CommSetupSummary."Comm. Plan Code" := CommPlanCode;
                                        CommSetupSummary."Commission Rate" := CommPlanCalc."Commission Rate";
                                        CommSetupSummary.Insert();
                                        EntryNo += 1;
                                        */
                                        MyEntryNo += 1;
                                        CommSetupSummary2 := CommSetupSummary;
                                        CommSetupSummary2."Entry No." := MyEntryNo;
                                        CommSetupSummary2."Pay Salesperson Code" := CommPlanPayee."Salesperson Code";
                                        CommSetupSummary2."Comm. Plan Code" := CommPlanCode;
                                        CommSetupSummary2."Commission Rate" := CommPlanCalc."Commission Rate";
                                        CommSetupSummary2.Insert();

                                    until CommPlanPayee.Next() = 0;
                                end;
                            end;
                        end;
                end;
            until Customer.Next() = 0;
        end;
        MESSAGE(CompleteMsg);

    end;

    local procedure GetCustPlans(var CommPlanTemp: Record CommissionPlanTigCM temporary; CustomerNo: Code[20]): Boolean;
    var
        MyCommPlan: Record CommissionPlanTigCM;
        CommCustGroupMember: Record CommCustomerGroupMemberTigCM;
    begin
        MyCommPlan.SetCurrentKey("Source Type", "Source Method", "Source Method Code");
        MyCommPlan.SetRange("Source Type", MyCommPlan."Source Type"::Customer);
        MyCommPlan.SetRange("Source Method", MyCommPlan."Source Method"::Specific);
        MyCommPlan.SetRange("Source Method Code", CustomerNo);
        MyCommPlan.SetRange("Manager Level", false);
        MyCommPlan.SetRange(Disabled, false);
        if MyCommPlan.FindSet() then begin
            repeat
                //IF PlanHasPayees(CommPlan.Code) THEN BEGIN
                CommPlanTemp := MyCommPlan;
                CommPlanTemp.Insert();
            //END;
            until MyCommPlan.Next() = 0;
        end;

        CommCustGroupMember.SetCurrentKey("Customer No.");
        CommCustGroupMember.SetRange("Customer No.", CustomerNo);
        if CommCustGroupMember.FindFirst() then begin
            MyCommPlan.Reset();
            MyCommPlan.SetCurrentKey("Source Type", "Source Method", "Source Method Code");
            MyCommPlan.SetRange("Source Type", MyCommPlan."Source Type"::Customer);
            MyCommPlan.SetRange("Source Method", MyCommPlan."Source Method"::Group);
            MyCommPlan.SetRange("Source Method Code", CommCustGroupMember."Group Code");
            MyCommPlan.SetRange("Manager Level", false);
            MyCommPlan.SetRange(Disabled, false);
            if MyCommPlan.FindSet() then begin
                repeat
                    //IF PlanHasPayees(CommPlan.Code) THEN BEGIN
                    if not CommPlanTemp.Get(MyCommPlan.Code) then begin
                        CommPlanTemp := MyCommPlan;
                        CommPlanTemp.Insert();
                    end;
                //END;
                until MyCommPlan.Next() = 0;
            end;
        end;

        //Find any plans for all customers
        MyCommPlan.Reset();
        MyCommPlan.SetCurrentKey("Source Type", "Source Method", "Source Method Code");
        MyCommPlan.SetRange("Source Type", MyCommPlan."Source Type"::Customer);
        MyCommPlan.SetRange("Source Method", MyCommPlan."Source Method"::All);
        MyCommPlan.SetRange("Manager Level", false);
        MyCommPlan.SetRange(Disabled, false);
        if MyCommPlan.FindSet() then begin
            repeat
                //IF PlanHasPayees(CommPlan.Code) THEN BEGIN
                if not CommPlanTemp.Get(MyCommPlan.Code) then begin
                    CommPlanTemp := MyCommPlan;
                    CommPlanTemp.Insert();
                end;
            //END;
            until MyCommPlan.Next() = 0;
        end;

        //Find any manager level plans
        MyCommPlan.Reset();
        MyCommPlan.SetCurrentKey("Source Type", "Source Method", "Source Method Code");
        MyCommPlan.SetRange("Source Type", MyCommPlan."Source Type"::Customer);
        MyCommPlan.SetRange("Manager Level", true);
        MyCommPlan.SetRange(Disabled, false);
        if MyCommPlan.FindSet() then begin
            repeat
                if (MyCommPlan."Source Method" = MyCommPlan."Source Method"::Specific) and
                   (MyCommPlan."Source Method Code" = CustomerNo)
                then begin
                    //IF PlanHasPayees(CommPlan.Code) THEN BEGIN
                    if not CommPlanTemp.Get(MyCommPlan.Code) then begin
                        CommPlanTemp := MyCommPlan;
                        CommPlanTemp.Insert();
                    end;
                    //END;
                end;
                if MyCommPlan."Source Method" = MyCommPlan."Source Method"::Group then begin
                    if CustomerInGroup(MyCommPlan."Source Method Code", CustomerNo) then begin
                        //IF PlanHasPayees(CommPlan.Code) THEN BEGIN
                        if not CommPlanTemp.Get(MyCommPlan.Code) then begin
                            CommPlanTemp := MyCommPlan;
                            CommPlanTemp.Insert();
                        end;
                        //END;
                    end;
                end;
                if MyCommPlan."Source Method" = MyCommPlan."Source Method"::All then begin
                    //IF PlanHasPayees(CommPlan.Code) THEN BEGIN
                    if not CommPlanTemp.Get(MyCommPlan.Code) then begin
                        CommPlanTemp := MyCommPlan;
                        CommPlanTemp.Insert();
                    end;
                    //END;
                end;
            until MyCommPlan.Next() = 0;
        end;

        exit(CommPlanTemp.Count() > 0);
    end;

    local procedure GetItemPlan(var CustCommPlanTemp: Record CommissionPlanTigCM temporary; var CommPlanCode: Code[20]): Boolean;
    var
        CommUnitGroupMember: Record CommissionUnitGroupMemberTigCM;
    begin
        CustCommPlanTemp.SetCurrentKey("Source Method Sort");
        CustCommPlanTemp.FindSet();

        //Only include customer plans that apply to the item
        //More than 1 plan may apply. Use the most specific matching one first
        if CustCommPlanTemp."Unit Method" = CustCommPlanTemp."Unit Method"::Specific then begin
            CommPlanCode := CustCommPlanTemp.Code;
            exit((CustCommPlanTemp."Unit Method" = UnitType) and
                 (CustCommPlanTemp."Unit Method Code" = UnitNo))
        end else begin
            //Check for group match
            CommUnitGroupMember.SetCurrentKey(Type, "No.");
            CommUnitGroupMember.SetRange(Type, UnitType);
            CommUnitGroupMember.SetRange("No.", UnitNo);
            if CommUnitGroupMember.FindFirst() then begin
                if CustCommPlanTemp."Unit Type" = UnitType then begin
                    if CustCommPlanTemp."Unit Method" = CustCommPlanTemp."Unit Method"::Group then begin
                        CommPlanCode := CustCommPlanTemp.Code;
                        exit(CustCommPlanTemp."Unit Method Code" = CommUnitGroupMember."Group Code");
                    end;
                end;
            end;
        end;

        //Check for all nos. of same type match
        if (CustCommPlanTemp."Unit Method" = CustCommPlanTemp."Unit Method"::All) and
           (CustCommPlanTemp."Unit Type" = UnitType)
        then begin
            CommPlanCode := CustCommPlanTemp.Code;
            exit(true);
        end;

        //Check for loosest match, ALL unit types
        if CustCommPlanTemp."Unit Type" = CustCommPlanTemp."Unit Type"::All then begin
            CommPlanCode := CustCommPlanTemp.Code;
            exit(true);
        end;
    end;

    local procedure CustomerInGroup(CommGroupCode: Code[20]; CustomerNo: Code[20]): Boolean;
    var
        CommCustGroupMember: Record CommCustomerGroupMemberTigCM;
    begin
        CommCustGroupMember.SetRange("Group Code", CommGroupCode);
        CommCustGroupMember.SetRange("Customer No.", CustomerNo);
        //exit(CommCustGroupMember.FindFirst());
        exit(not CommCustGroupMember.IsEmpty());
    end;

    local procedure PlanHasPayees(CommPlanCode2: Code[20]): Boolean;
    var
        MyCommPlanPayee: Record CommissionPlanPayeeTigCM;
    begin
        MyCommPlanPayee.SetRange("Commission Plan Code", CommPlanCode2);
        MyCommPlanPayee.SetFilter("Salesperson Code", '<>%1', '');
        //exit(MyCommPlanPayee.FindFirst());
        exit(not MyCommPlanPayee.IsEmpty());
    end;

    [EventSubscriber(ObjectType::Codeunit, 90, 'OnAfterPostPurchaseDoc', '', false, false)]
    local procedure UpdateCommPmtEntryPosted(var PurchaseHeader: Record "Purchase Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PurchRcpHdrNo: Code[20]; RetShptHdrNo: Code[20]; PurchInvHdrNo: Code[20]; PurchCrMemoHdrNo: Code[20]);
    begin
        //Update Comm. Pmt. Entry, related Comm. Appr. Entry, and flag to prevent deletion
        PaymentEntry.SetCurrentKey("Payment Method", "Payment Ref. No.", "Payment Ref. Line No.");
        PaymentEntry.SetRange("Payment Method", PaymentEntry."Payment Method"::"Check as Vendor");
        PaymentEntry.SetRange("Payment Ref. No.", PurchaseHeader."No.");
        PaymentEntry.SetRange(Posted, false);
        if PaymentEntry.FindSet() then begin
            repeat
                PaymentEntry2.Get(PaymentEntry."Entry No.");
                PaymentEntry2.Posted := true;
                PaymentEntry2."Date Paid" := WorkDate();
                if PurchInvHdrNo <> '' then
                    PaymentEntry2."Payment Ref. No." := PurchInvHdrNo;
                if PurchCrMemoHdrNo <> '' then
                    PaymentEntry2."Payment Ref. No." := PurchCrMemoHdrNo;
                PaymentEntry2.Modify();

                ApprovalEntry.Get(PaymentEntry."Comm. Appr. Entry No.");
                if ApprovalEntry.Open then begin
                    ApprovalEntry.Open := false;
                    ApprovalEntry.Modify();
                end;
            until PaymentEntry.Next() = 0;
        end;
    end;

    local procedure InsertRecogEntry(SalesLine: Record "Sales Line" temporary; CommPlanCode: Code[20]; EntryType2: Option Commission,Clawback,Advance,Adjustment; TriggerDocNo2: Code[20]; TriggerMethod2: Option Booking,Shipment,Invoice,Payment,,,Credit; ItemLedgEntryNo: Integer; PostingDate: Date; PostedDocNo: Code[20]);
    begin
        if not CommPlan.Get(CommPlanCode) then
            Clear(CommPlan);

        RecogEntry.Init();
        RecogEntry."Entry No." := 0;
        RecogEntry."Item Ledger Entry No." := ItemLedgEntryNo;
        RecogEntry."Entry Type" := EntryType2;
        RecogEntry."Document Type" := SalesLine."Document Type";
        RecogEntry."Document No." := SalesLine."Document No.";
        RecogEntry."Document Line No." := SalesLine."Line No.";
        RecogEntry."Customer No." := SalesLine."Sell-to Customer No.";
        RecogEntry."Unit Type" := SalesLine.Type;
        RecogEntry."Unit No." := SalesLine."No.";
        RecogEntry."Basis Qty." := SalesLine.Quantity;
        RecogEntry."Basis Amt." := SalesLine.Amount;
        RecogEntry.Open := true;
        RecogEntry."Commission Plan Code" := CommPlanCode;
        RecogEntry."Trigger Method" := TriggerMethod2;
        RecogEntry."Trigger Document No." := TriggerDocNo2;
        RecogEntry."Trigger Posting Date" := PostingDate;
        RecogEntry."Creation Date" := WorkDate();
        RecogEntry."Created By" := CopyStr(UserId(), 1, MaxStrLen(RecogEntry."Created By"));
        RecogEntry."External Document No." := SalesLine."Purchase Order No.";
        RecogEntry.Description := CopyStr(SalesLine.Description, 1, MaxStrLen(RecogEntry.Description));
        RecogEntry."Description 2" := SalesLine."Description 2";
        RecogEntry."Reason Code" := SalesLine."Return Reason Code";
        RecogEntry."Posted Doc. No." := PostedDocNo;
        if RecogEntry."Entry Type" <> RecogEntry."Entry Type"::Commission then
            RecogEntry.Open := false;
        RecogEntry.Insert();
    end;

    local procedure InsertApprovalEntry(SalesLineTemp: Record "Sales Line" temporary; TriggerDocNo2: Code[20]; TriggerMethod2: Option Booking,Shipment,Invoice,Payment,,,Credit; DetCustLedgEntryNo: Integer; PostingDate: Date; PostedDocNo: Code[20]);
    var
        RecogEntry2: Record CommRecognitionEntryTigCM;
        RecogEntry3: Record CommRecognitionEntryTigCM;
        QtyToApply: Decimal;
        RemQtyToApply: Decimal;
        AmtToApply: Decimal;
        AmtApplied: Decimal;
        BasisAmt: Decimal;
        LastTriggerDocNo: Code[20];
    begin
        //Create entries for what is approved to pay. this will look to
        //the the recognition entries until no qty. left to apply
        //This application logic is a bit tricky. 1 sales line being invoiced
        //can apply to multiple recognition entries for that same sales line
        //because we allow more than 1 commission plan to be in play for a
        //specific transaction. We have to apply the sales line qty. being
        //invoiced to ALL transactions in that "set" before reducing the
        //remaining qty. to apply. The triggering document no. binds the set.
        GetLastEntryNo();

        if not (SalesLineTemp."Document Type" in [SalesLineTemp."Document Type"::"Credit Memo",
                                             SalesLineTemp."Document Type"::"Return Order"])
        then begin
            RecogEntry2.SetCurrentKey("Document No.", "Document Line No.");
            RecogEntry2.SetRange("Document No.", SalesLineTemp."Document No.");
            RecogEntry2.SetRange("Document Line No.", SalesLineTemp."Line No.");
            RecogEntry2.SetRange("Unit Type", SalesLineTemp.Type);
            RecogEntry2.SetRange("Unit No.", SalesLineTemp."No.");
            RecogEntry2.SetRange("Entry Type", RecogEntry."Entry Type"::Commission);
            RecogEntry2.SetRange(Open, true);

            if RecogEntry2.FindSet() then begin
                QtyToApply := SalesLineTemp.Quantity;
                RemQtyToApply := QtyToApply;
                LastTriggerDocNo := RecogEntry2."Trigger Document No.";

                repeat
                    CommPlan.Get(RecogEntry2."Commission Plan Code");
                    if CommSetup."Payable Trigger Method" = TriggerMethod2 then begin
                        if RecogEntry2."Basis Qty." <= RemQtyToApply then
                            QtyToApply := RecogEntry2."Basis Qty."
                        else
                            QtyToApply := RemQtyToApply;
                        AmtToApply := Round(RecogEntry2."Basis Amt." * (QtyToApply / RecogEntry2."Basis Qty."), 0.01);

                        if RecogEntry2."Trigger Document No." <> LastTriggerDocNo then begin
                            //New set, add any rounding to last entry per set (record pointer still on the last rec inserted)
                            if BasisAmt - AmtApplied <> 0 then begin
                                ApprovalEntry."Basis Amt. Approved" += (BasisAmt - AmtApplied);
                                ApprovalEntry."Amt. Remaining to Pay" := ApprovalEntry."Basis Amt. Approved";
                                ApprovalEntry.Modify();
                            end;

                            BasisAmt := 0;
                            AmtApplied := 0;
                            RemQtyToApply -= QtyToApply;
                        end;

                        BasisAmt += RecogEntry2."Basis Amt.";
                        AmtApplied += AmtToApply;

                        if RemQtyToApply <> 0 then begin
                            ApprovalEntry.Init();
                            ApprovalEntry."Entry No." := EntryNo;
                            ApprovalEntry."Entry Type" := RecogEntry2."Entry Type";
                            ApprovalEntry."Comm. Recog. Entry No." := RecogEntry2."Entry No.";
                            ApprovalEntry."Det. Cust. Ledger Entry No." := DetCustLedgEntryNo;
                            ApprovalEntry."Document Type" := RecogEntry2."Document Type";
                            ApprovalEntry."Document No." := RecogEntry2."Document No.";
                            ApprovalEntry."Document Line No." := RecogEntry2."Document Line No.";
                            ApprovalEntry."Customer No." := RecogEntry2."Customer No.";
                            ApprovalEntry."Unit Type" := RecogEntry2."Unit Type";
                            ApprovalEntry."Unit No." := RecogEntry2."Unit No.";
                            ApprovalEntry."Basis Qty. Approved" := QtyToApply;
                            ApprovalEntry."Basis Amt. Approved" := AmtToApply;
                            ApprovalEntry."Qty. Remaining to Pay" := QtyToApply;
                            ApprovalEntry."Amt. Remaining to Pay" := AmtToApply;
                            ApprovalEntry.Open := true;
                            ApprovalEntry."Commission Plan Code" := RecogEntry2."Commission Plan Code";
                            ApprovalEntry."Trigger Method" := TriggerMethod2;
                            ApprovalEntry."Trigger Document No." := TriggerDocNo2;
                            ApprovalEntry."Trigger Posting Date" := PostingDate;
                            ApprovalEntry."Released to Pay Date" := WorkDate();
                            ApprovalEntry."Released to Pay By" := CopyStr(UserId(), 1, MaxStrLen(ApprovalEntry."Released to Pay By"));
                            ApprovalEntry."External Document No." := SalesLineTemp."Purchase Order No.";//RecogEntry2."External Document No.";
                            ApprovalEntry.Description := RecogEntry2.Description;
                            ApprovalEntry."Description 2" := RecogEntry2."Description 2";
                            ApprovalEntry."Reason Code" := RecogEntry2."Reason Code";
                            ApprovalEntry."Posted Doc. No." := PostedDocNo;
                            ApprovalEntry.Insert();
                            EntryNo += 1;

                            //Close recognition entry if appropriate
                            RecogEntry2.CALCFIELDS("Basis Qty. Approved to Pay");
                            if ABS(RecogEntry2."Basis Qty.") - ABS(RecogEntry2."Basis Qty. Approved to Pay") = 0
                            then begin
                                RecogEntry3.Get(RecogEntry2."Entry No.");
                                RecogEntry3.Open := false;
                                RecogEntry3.Modify();
                            end;
                        end;
                    end;
                until (RecogEntry2.Next() = 0) or (RemQtyToApply = 0);
            end;
        end else begin
            //Credit documents will not be applied to prior invoice documents.
            //They will simply create their own entries
            RecogEntry2.SetCurrentKey("Document No.", "Document Line No.");
            RecogEntry2.SetRange("Document No.", SalesLineTemp."Document No.");
            RecogEntry2.SetRange("Document Line No.", SalesLineTemp."Line No.");
            RecogEntry2.SetRange("Unit Type", SalesLineTemp.Type);
            RecogEntry2.SetRange("Unit No.", SalesLineTemp."No.");
            RecogEntry2.SetRange("Entry Type", RecogEntry."Entry Type"::Commission);
            RecogEntry2.SetRange(Open, true);
            RecogEntry2.FindFirst();

            ApprovalEntry.Init();
            ApprovalEntry."Entry No." := EntryNo;
            ApprovalEntry."Entry Type" := RecogEntry2."Entry Type";
            ApprovalEntry."Comm. Recog. Entry No." := RecogEntry2."Entry No.";
            ApprovalEntry."Det. Cust. Ledger Entry No." := DetCustLedgEntryNo;
            ApprovalEntry."Document Type" := RecogEntry2."Document Type";
            ApprovalEntry."Document No." := RecogEntry2."Document No.";
            ApprovalEntry."Document Line No." := RecogEntry2."Document Line No.";
            ApprovalEntry."Customer No." := RecogEntry2."Customer No.";
            ApprovalEntry."Unit Type" := SalesLineTemp.Type;
            ApprovalEntry."Unit No." := SalesLineTemp."No.";
            ApprovalEntry."Basis Qty. Approved" := SalesLineTemp.Quantity;
            ApprovalEntry."Basis Amt. Approved" := SalesLineTemp.Amount;
            ApprovalEntry."Qty. Remaining to Pay" := SalesLineTemp.Quantity;
            ApprovalEntry."Amt. Remaining to Pay" := SalesLineTemp.Amount;
            ApprovalEntry.Open := true;
            ApprovalEntry."Commission Plan Code" := RecogEntry2."Commission Plan Code";
            ApprovalEntry."Trigger Method" := TriggerMethod2;
            ApprovalEntry."Trigger Document No." := TriggerDocNo2;
            ApprovalEntry."Trigger Posting Date" := PostingDate;
            ApprovalEntry."Released to Pay Date" := WorkDate();
            ApprovalEntry."Released to Pay By" := CopyStr(UserId(), 1, MaxStrLen(ApprovalEntry."Released to Pay By"));
            ApprovalEntry."External Document No." := RecogEntry2."External Document No.";
            ApprovalEntry.Description := RecogEntry2.Description;
            ApprovalEntry."Description 2" := RecogEntry2."Description 2";
            ApprovalEntry."Reason Code" := RecogEntry2."Reason Code";
            ApprovalEntry."Posted Doc. No." := PostedDocNo;
            ApprovalEntry.Insert();
            EntryNo += 1;

            RecogEntry2.Open := false;
            RecogEntry2.Modify();
        end;
    end;

    local procedure InsertPaymentEntry(CommWkshtLine: Record CommissionWksheetLineTigCM; ApprovalEntry: Record CommApprovalEntryTigCM; DistributionMethod: Option Vendor,"External Provider",Manual; PaymentRefNo: Code[20]; PaymentLineNo: Integer; PostedDocNo: Code[20]);
    begin
        PaymentEntry.Init();
        PaymentEntry."Entry No." := 0;
        PaymentEntry."Entry Type" := CommWkshtLine."Entry Type";
        PaymentEntry."Comm. Recog. Entry No." := ApprovalEntry."Comm. Recog. Entry No.";
        PaymentEntry."Comm. Ledger Entry No." := ApprovalEntry."Comm. Ledger Entry No.";
        PaymentEntry."Comm. Appr. Entry No." := CommWkshtLine."Comm. Approval Entry No.";
        PaymentEntry."Batch Name" := CommWkshtLine."Batch Name";
        PaymentEntry."Posting Date" := CommWkshtLine."Posting Date";
        PaymentEntry."Payout Date" := CommWkshtLine."Payout Date";
        PaymentEntry."Salesperson Code" := CommWkshtLine."Salesperson Code";
        PaymentEntry."Document No." := CommWkshtLine."Source Document No.";
        PaymentEntry.Quantity := CommWkshtLine.Quantity;
        PaymentEntry.Amount := CommWkshtLine.Amount;
        PaymentEntry."Customer No." := CommWkshtLine."Customer No.";
        PaymentEntry."Created Date" := Today();
        PaymentEntry."Created By" := CopyStr(UserId(), 1, MaxStrLen(PaymentEntry."Created By"));
        PaymentEntry."Unit Type" := ApprovalEntry."Unit Type";
        PaymentEntry."Unit No." := ApprovalEntry."Unit No.";
        PaymentEntry."Commission Plan Code" := ApprovalEntry."Commission Plan Code";
        PaymentEntry."Trigger Method" := ApprovalEntry."Trigger Method";
        PaymentEntry."Trigger Document No." := ApprovalEntry."Trigger Document No.";
        PaymentEntry."Released to Pay" := true;
        PaymentEntry."Released to Pay Date" := WorkDate();
        PaymentEntry."Released to Pay By" := CopyStr(UserId(), 1, MaxStrLen(PaymentEntry."Released to Pay By"));
        PaymentEntry."Payment Method" := DistributionMethod;
        PaymentEntry."Payment Ref. No." := PaymentRefNo;
        PaymentEntry."Payment Ref. Line No." := PaymentLineNo;
        PaymentEntry.Description := CommWkshtLine.Description;
        PaymentEntry."Posted Doc. No." := PostedDocNo;
        PaymentEntry.Insert();
    end;

    local procedure ResetCodeunit();
    begin
        ClearAll();
        SalesLineTemp.Reset();
        SalesLineTemp.DeleteAll();
        PurchHeaderTemp.Reset();
        PurchHeaderTemp.DeleteAll();
        PurchLineTemp.Reset();
        PurchLineTemp.DeleteAll();
    end;

    local procedure GetLastEntryNo();
    var
        ApprovalEntry2: Record CommApprovalEntryTigCM;
    begin
        if EntryNo = 0 then begin
            if ApprovalEntry2.FindLast() then
                EntryNo := ApprovalEntry2."Entry No." + 1
            else
                EntryNo := 1;
        end;
    end;
}

