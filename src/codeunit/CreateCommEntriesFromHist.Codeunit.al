codeunit 80003 "CreateCommEntriesFromHistTigCM"
{
    var
        CommSetup: Record CommissionSetupTigCM;
        CommEntry: Record CommissionSetupSummaryTigCM;
        RecogEntry: Record CommRecognitionEntryTigCM;
        ApprovalEntry: Record CommApprovalEntryTigCM;
        PaymentEntry: Record CommissionPaymentEntryTigCM;
        PaymentEntry2: Record CommissionPaymentEntryTigCM;
        CommPlan: Record CommissionPlanTigCM;
        CommPlanPayee: Record CommissionPlanPayeeTigCM;
        SalesLineTemp: Record "Sales Line" temporary;
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        PurchHeaderTemp: Record "Purchase Header" temporary;
        PurchLineTemp: Record "Purchase Line" temporary;
        TriggerMethod: Option Booking,Shipment,Invoice,Payment,,,Credit;
        HasCommSetup: Boolean;
        CustomerNo: Code[20];
        EntryType: Option Commission,Clawback,Advance,Adjustment;
        UnitType: Option " ","G/L Account",Item,Resource,"Fixed Asset","Charge (Item)";
        UnitNo: Code[20];
        RecognitionText: Label 'Recognition of %1 %2';
        Text001: Label 'Nothing to Post.';
        Text002: Label 'Confirm Posting?';
        Text003: Label 'Posting Cancelled.';
        Text004: Label 'You cannot post filtered records. Instead delete any lines you do not want to post.';
        Text005: Label 'Posting Complete.';
        Text006: Label 'The Commission Plan Payee is missing a Distribution Code. See Commission Plan %1, Salesperson %2.';
        Text007: Label 'The Commission Plan Payee is missing a Distribution Account No. See Commission Plan %1, Salesperson %2.';
        Text008: Label 'There are pending Commission Payment Entries related to this invoice. Are you sure you want to continue and delete this document?';
        Text009: Label 'There are pending Commission Payment Entries related to this line. Are you sure you want to continue and delete this line?';
        Text010: Label 'Delete cancelled.';
        Text011: Label 'Batch Name:';
        Text012: Label 'You must specify a Batch Name in the worksheet before posting.';
        RecognitionMode: Boolean;
        ApprovalMode: Boolean;
        EntryNo: Integer;
        Text013: Label 'No Commission Plan found for Customer %1';
        Text014: Label 'No Commission Plan found for Customer %1, %2 %3';
        Text015: Label 'CREDIT';
        CalcSetupMode: Boolean;
        Text016: Label 'Complete.';

    local procedure GetCommSetup();
    begin
        if not HasCommSetup then begin
            CommSetup.GET;
            HasCommSetup := true;
        end;
    end;

    procedure CheckTriggers(TriggerMethod: Option Booking,Shipment,Invoice,Payment,,,Credit; var CommPlanCode: Code[20]; LineType: Option " ","G/L Account",Item,Resource,"Fixed Asset","Charge (Item)") FailureCode: Code[20];
    var
        CommPlanTemp: Record CommissionPlanTigCM temporary;
    begin
        GetCommSetup;
        RecognitionMode := false;
        ApprovalMode := false;
        CommPlanCode := '';

        GetCustPlans(CommPlanTemp, CustomerNo);
        if not CommPlanTemp.FINDSET then
            exit('NOCUSTPLAN');

        if CalcSetupMode then begin
            CommPlanCode := CommPlanTemp.Code;
            exit;
        end;

        //Credit memo/return order invoice posting ALWAYS processes
        if TriggerMethod = TriggerMethod::Credit then begin
            CommPlanCode := Text015;
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
        ResetCodeunit;

        SalesShptLine.SETRANGE("Document No.", SalesShptHeader."No.");
        //xxxSalesShptLine.SETFILTER(Type,'%1|%2',SalesShptLine.Type::"G/L Account",
        //                        SalesShptLine.Type::Item);
        SalesShptLine.SETFILTER(Type, '%1', SalesShptLine.Type::Item);

        SalesShptLine.SETFILTER("No.", '<>%1', '');
        SalesShptLine.SETFILTER(Quantity, '<>%1', 0);
        if SalesShptLine.FINDSET then begin
            repeat
                CustomerNo := SalesShptLine."Sell-to Customer No.";
                UnitType := SalesShptLine.Type;
                UnitNo := SalesShptLine."No.";

                case CheckTriggers(TriggerMethod::Shipment, CommPlanCode, SalesShptLine.Type) of
                    'NOCUSTPLAN':
                        ERROR(Text013, SalesShptLine."Sell-to Customer No.");
                    'NOITEMPLAN':
                        ERROR(Text014,
                              SalesShptLine."Sell-to Customer No.",
                              FORMAT(SalesShptLine.Type),
                              SalesShptLine."No.");
                end;

                if (RecognitionMode) or (ApprovalMode) then begin
                    //No extended amount on shipment line. Get entry
                    //for this and other stuff
                    if SalesShptLine.Type = SalesShptLine.Type::Item then begin
                        ItemLedgEntry.SETCURRENTKEY("Document No.", "Document Type", "Document Line No.");
                        ItemLedgEntry.SETRANGE("Document Type", ItemLedgEntry."Document Type"::"Sales Shipment");
                        ItemLedgEntry.SETRANGE("Document No.", SalesShptLine."Document No.");
                        ItemLedgEntry.SETRANGE("Document Line No.", SalesShptLine."Line No.");
                        ItemLedgEntry.FINDFIRST;
                    end else
                        CLEAR(ItemLedgEntry);

                    BasisAmt := ROUND(SalesShptLine.Quantity * SalesShptLine."Unit Price", 0.01);

                    SalesLineTemp.INIT;
                    SalesLineTemp.TRANSFERFIELDS(SalesShptLine);
                    SalesLineTemp."Document Type" := SalesLineTemp."Document Type"::Order;
                    SalesLineTemp."Document No." := SalesShptLine."Order No.";
                    SalesLineTemp."Line No." := SalesShptLine."Order Line No.";
                    SalesLineTemp.Amount := BasisAmt;
                    SalesLineTemp."Purchase Order No." := SalesShptHeader."External Document No.";

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
            until SalesShptLine.NEXT = 0;
        end;

        SalesShptHeader2 := SalesShptHeader;
        SalesShptHeader2."Commission Calculated" := true;
        SalesShptHeader2.MODIFY;
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
        ResetCodeunit;

        SalesInvLine.SETRANGE("Document No.", SalesInvHeader."No.");
        //xxxSalesInvLine.SETFILTER(Type,'%1|%2',SalesInvLine.Type::"G/L Account",
        //                       SalesInvLine.Type::Item);
        SalesInvLine.SETFILTER(Type, '%1', SalesInvLine.Type::Item);
        SalesInvLine.SETFILTER("No.", '<>%1', '');
        SalesInvLine.SETFILTER(Quantity, '<>%1', 0);
        if SalesInvLine.FINDSET then begin
            repeat
                CustomerNo := SalesInvLine."Sell-to Customer No.";
                UnitType := SalesInvLine.Type;
                UnitNo := SalesInvLine."No.";

                case CheckTriggers(TriggerMethod::Invoice, CommPlanCode, SalesInvLine.Type) of
                    'NOCUSTPLAN':
                        ERROR(Text013, SalesInvLine."Sell-to Customer No.");
                    'NOITEMPLAN':
                        ERROR(Text014,
                         SalesInvLine."Sell-to Customer No.",
                         FORMAT(SalesInvLine.Type),
                         SalesInvLine."No.");
                end;

                if (RecognitionMode) or (ApprovalMode) then begin
                    if SalesInvLine.Type = SalesInvLine.Type::Item then begin
                        ValueEntry.SETCURRENTKEY("Document No.");
                        ValueEntry.SETRANGE("Document No.", SalesInvHeader."No.");
                        ValueEntry.SETRANGE("Document Line No.", SalesInvLine."Line No.");
                        ValueEntry.SETRANGE("Posting Date", SalesInvHeader."Posting Date");
                        ValueEntry.FINDFIRST;
                        ItemLedgEntry.GET(ValueEntry."Item Ledger Entry No.");
                    end else
                        CLEAR(ItemLedgEntry);

                    SalesLineTemp.INIT;
                    SalesLineTemp.TRANSFERFIELDS(SalesInvLine);
                    if SalesInvHeader."Order No." <> '' then begin
                        SalesLineTemp."Document Type" := SalesLineTemp."Document Type"::Order;
                        SalesLineTemp."Document No." := SalesInvHeader."Order No.";
                        SalesLineTemp."Line No." := SalesInvLine."Shipment Line No.";
                    end else begin
                        if not SalesShptHeader.GET(ItemLedgEntry."Document No.") then
                            CLEAR(SalesShptHeader);
                        SalesLineTemp."Document Type" := SalesLineTemp."Document Type"::Invoice;
                        SalesLineTemp."Document No." := SalesShptHeader."Order No.";
                        SalesLineTemp."Line No." := ItemLedgEntry."Document Line No.";
                    end;

                    //Last resort catch-all for doc references
                    if SalesLineTemp."Document No." = '' then
                        SalesLineTemp."Document No." := SalesInvHeader."No.";
                    if SalesLineTemp."Line No." = 0 then
                        SalesLineTemp."Line No." := SalesInvLine."Line No.";

                    SalesLineTemp."Purchase Order No." := SalesInvHeader."External Document No.";

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
            until SalesInvLine.NEXT = 0;
        end;

        SalesInvHeader2 := SalesInvHeader;
        SalesInvHeader2."Commission Calculated" := true;
        SalesInvHeader2.MODIFY;
    end;

    procedure AnalyzeCrMemos(SalesCrMemoHeader: Record "Sales Cr.Memo Header");
    var
        SalesCrMemoHeader2: Record "Sales Cr.Memo Header";
        ItemLedgEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        CommPlanCode: Code[20];
        CommPlanTemp: Record CommissionPlanTigCM temporary;
    begin
        ResetCodeunit;

        SalesCrMemoLine.SETRANGE("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SETFILTER(Type, '%1|%2', SalesCrMemoLine.Type::"G/L Account",
                                  SalesCrMemoLine.Type::Item);
        SalesCrMemoLine.SETFILTER("No.", '<>%1', '');
        SalesCrMemoLine.SETFILTER(Quantity, '<>%1', 0);
        if SalesCrMemoLine.FINDSET then begin
            repeat
                CustomerNo := SalesCrMemoLine."Sell-to Customer No.";
                UnitType := SalesCrMemoLine.Type;
                UnitNo := SalesCrMemoLine."No.";

                case CheckTriggers(TriggerMethod::Credit, CommPlanCode, SalesCrMemoLine.Type) of
                    'NOCUSTPLAN':
                        ERROR(Text013, SalesCrMemoLine."Sell-to Customer No.");
                    'NOITEMPLAN':
                        ERROR(Text014,
                              SalesCrMemoLine."Sell-to Customer No.",
                              FORMAT(SalesCrMemoLine.Type),
                              SalesCrMemoLine."No.");
                end;

                if (RecognitionMode) or (ApprovalMode) then begin
                    if SalesCrMemoLine.Type = SalesCrMemoLine.Type::Item then begin
                        ValueEntry.SETCURRENTKEY("Document No.");
                        ValueEntry.SETRANGE("Document No.", SalesCrMemoLine."Document No.");
                        ValueEntry.SETRANGE("Document Line No.", SalesCrMemoLine."Line No.");
                        ValueEntry.SETRANGE("Posting Date", SalesCrMemoHeader."Posting Date");
                        ValueEntry.FINDFIRST;
                        ItemLedgEntry.GET(ValueEntry."Item Ledger Entry No.");
                    end else
                        CLEAR(ItemLedgEntry);

                    SalesLineTemp.INIT;
                    SalesLineTemp.TRANSFERFIELDS(SalesCrMemoLine);
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
                    SalesLineTemp."Purchase Order No." := SalesCrMemoHeader."External Document No.";

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
            until SalesCrMemoLine.NEXT = 0;
        end;

        SalesCrMemoHeader2 := SalesCrMemoHeader;
        SalesCrMemoHeader2."Commission Calculated" := true;
        SalesCrMemoHeader2.MODIFY;
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
        ResetCodeunit;
        DocNo := '';

        CustLedgEntry.GET(DetCustLedgEntry."Applied Cust. Ledger Entry No.");
        //Beginning balance entries may not have a matching posted invoice
        if not SalesInvHeader.GET(CustLedgEntry."Document No.") then
            exit;

        if SalesInvHeader."No." = 'USPIN-18-01391' then
            ERROR('xxx');
        SalesInvLine.SETRANGE("Document No.", CustLedgEntry."Document No.");
        SalesInvLine.SETFILTER(Type, '%1|%2', SalesInvLine.Type::"G/L Account",
                               SalesInvLine.Type::Item);
        SalesInvLine.SETFILTER("No.", '<>%1', '');
        SalesInvLine.SETFILTER(Quantity, '<>%1', 0);
        if SalesInvLine.FINDSET then begin
            repeat
                CustomerNo := SalesInvLine."Sell-to Customer No.";
                UnitType := SalesInvLine.Type;
                UnitNo := SalesInvLine."No.";

                CheckTriggers(TriggerMethod::Payment, CommPlanCode, SalesInvLine.Type);

                if ApprovalMode then begin
                    if SalesInvLine.Type = SalesInvLine.Type::Item then begin
                        ValueEntry.SETCURRENTKEY("Document No.");
                        ValueEntry.SETRANGE("Document No.", SalesInvHeader."No.");
                        ValueEntry.SETRANGE("Document Line No.", SalesInvLine."Line No.");
                        ValueEntry.SETRANGE("Posting Date", SalesInvHeader."Posting Date");
                        ValueEntry.FINDFIRST;
                        ItemLedgEntry.GET(ValueEntry."Item Ledger Entry No.");
                        DocNo := ItemLedgEntry."Document No.";
                    end else
                        CLEAR(ItemLedgEntry);
                    if not SalesShptHeader.GET(ItemLedgEntry."Document No.") then
                        CLEAR(SalesShptHeader);

                    //Use the preferred, originating document no. if possible
                    SalesLineTemp.INIT;
                    SalesLineTemp.TRANSFERFIELDS(SalesInvLine);
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

                    SalesLineTemp."Purchase Order No." := SalesInvHeader."External Document No.";
                    if SalesLineTemp."Purchase Order No." = '' then
                        SalesLineTemp."Purchase Order No." := SalesShptHeader."External Document No.";

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
                    CommCustSalesperson.SETRANGE("Customer No.", SalesInvHeader."Sell-to Customer No.");
                    CommCustSalesperson.FINDFIRST;

                    //Create initialization payment entries
                    CommWkshtLineTemp.INIT;
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
            until SalesInvLine.NEXT = 0;
        end;

        DetCustLedgEntry2 := DetCustLedgEntry;
        DetCustLedgEntry2."Commission Calculated" := true;
        DetCustLedgEntry2.MODIFY;
    end;

    procedure CalcSetupSummary(var CommSetupSummary: Record CommissionSetupSummaryTigCM);
    var
        Customer: Record Customer;
        CommPlanCalc: Record CommissionPlanCalculationTigCM;
        CommCustSalesperson: Record "CommCustomerSalespersonTigCM";
        CommSetupSummary2: Record CommissionSetupSummaryTigCM;
        CommPlanCode: Code[20];
        EntryNo: Integer;
    begin
        ResetCodeunit;
        CalcSetupMode := true;

        CommSetupSummary.RESET;
        CommSetupSummary.SETRANGE("User ID", USERID);
        CommSetupSummary.DELETEALL(true);

        if Customer.FINDSET then begin
            repeat
                CustomerNo := Customer."No.";

                CommCustSalesperson.SETRANGE("Customer No.", Customer."No.");
                if not CommCustSalesperson.FINDFIRST then
                    CLEAR(CommCustSalesperson);

                //Write initial record for customer
                EntryNo += 1;
                CommSetupSummary.INIT;
                CommSetupSummary."User ID" := USERID;
                CommSetupSummary."Entry No." := EntryNo;
                CommSetupSummary."Customer No." := Customer."No.";
                CommSetupSummary."Cust. Salesperson Code" := CommCustSalesperson."Salesperson Code";
                CommSetupSummary.INSERT;

                //Credit trigger always fires, 2 is for items
                case CheckTriggers(TriggerMethod::Credit, CommPlanCode, 2) of
                    'NOCUSTPLAN':
                        ;//no action
                    'NOITEMPLAN':
                        ;//no action
                    else begin
                            //We have a plan, write record for each payee
                            CommPlan.GET(CommPlanCode);
                            CommPlanCalc.SETRANGE("Commission Plan Code", CommPlanCode);
                            if CommPlanCalc.FINDFIRST then begin
                                CommPlanPayee.SETRANGE("Commission Plan Code", CommPlanCode);
                                if CommPlanPayee.FINDSET then begin
                                    repeat
                                        /*
                                        CommSetupSummary.INIT;
                                        CommSetupSummary."User ID" := USERID;
                                        CommSetupSummary."Entry No." := EntryNo;
                                        CommSetupSummary."Customer No." := Customer."No.";
                                        CommSetupSummary."pay Salesperson Code" := CommPlanPayee."Salesperson Code";
                                        CommSetupSummary."Comm. Plan Code" := CommPlanCode;
                                        CommSetupSummary."Commission Rate" := CommPlanCalc."Commission Rate";
                                        CommSetupSummary.INSERT;
                                        EntryNo += 1;
                                        */
                                        EntryNo += 1;
                                        CommSetupSummary2 := CommSetupSummary;
                                        CommSetupSummary2."Entry No." := EntryNo;
                                        CommSetupSummary2."Pay Salesperson Code" := CommPlanPayee."Salesperson Code";
                                        CommSetupSummary2."Comm. Plan Code" := CommPlanCode;
                                        CommSetupSummary2."Commission Rate" := CommPlanCalc."Commission Rate";
                                        CommSetupSummary2.INSERT;

                                    until CommPlanPayee.NEXT = 0;
                                end;
                            end;
                        end;
                end;
            until Customer.NEXT = 0;
        end;
        MESSAGE(Text016);

    end;

    local procedure GetCustPlans(var CommPlanTemp: Record CommissionPlanTigCM temporary; CustomerNo: Code[20]): Boolean;
    var
        CommPlan: Record CommissionPlanTigCM;
        CommCustGroupMember: Record CommCustomerGroupMemberTigCM;
    begin
        CommPlan.SETCURRENTKEY("Source Type", "Source Method", "Source Method Code");
        CommPlan.SETRANGE("Source Type", CommPlan."Source Type"::Customer);
        CommPlan.SETRANGE("Source Method", CommPlan."Source Method"::Specific);
        CommPlan.SETRANGE("Source Method Code", CustomerNo);
        CommPlan.SETRANGE("Manager Level", false);
        CommPlan.SETRANGE(Disabled, false);
        if CommPlan.FINDSET then begin
            repeat
                //IF PlanHasPayees(CommPlan.Code) THEN BEGIN
                CommPlanTemp := CommPlan;
                CommPlanTemp.INSERT;
            //END;
            until CommPlan.NEXT = 0;
        end;

        CommCustGroupMember.SETCURRENTKEY("Customer No.");
        CommCustGroupMember.SETRANGE("Customer No.", CustomerNo);
        if CommCustGroupMember.FINDFIRST then begin
            CommPlan.RESET;
            CommPlan.SETCURRENTKEY("Source Type", "Source Method", "Source Method Code");
            CommPlan.SETRANGE("Source Type", CommPlan."Source Type"::Customer);
            CommPlan.SETRANGE("Source Method", CommPlan."Source Method"::Group);
            CommPlan.SETRANGE("Source Method Code", CommCustGroupMember."Group Code");
            CommPlan.SETRANGE("Manager Level", false);
            CommPlan.SETRANGE(Disabled, false);
            if CommPlan.FINDSET then begin
                repeat
                    //IF PlanHasPayees(CommPlan.Code) THEN BEGIN
                    if not CommPlanTemp.GET(CommPlan.Code) then begin
                        CommPlanTemp := CommPlan;
                        CommPlanTemp.INSERT;
                    end;
                //END;
                until CommPlan.NEXT = 0;
            end;
        end;

        //Find any plans for all customers
        CommPlan.RESET;
        CommPlan.SETCURRENTKEY("Source Type", "Source Method", "Source Method Code");
        CommPlan.SETRANGE("Source Type", CommPlan."Source Type"::Customer);
        CommPlan.SETRANGE("Source Method", CommPlan."Source Method"::All);
        CommPlan.SETRANGE("Manager Level", false);
        CommPlan.SETRANGE(Disabled, false);
        if CommPlan.FINDSET then begin
            repeat
                //IF PlanHasPayees(CommPlan.Code) THEN BEGIN
                if not CommPlanTemp.GET(CommPlan.Code) then begin
                    CommPlanTemp := CommPlan;
                    CommPlanTemp.INSERT;
                end;
            //END;
            until CommPlan.NEXT = 0;
        end;

        //Find any manager level plans
        CommPlan.RESET;
        CommPlan.SETCURRENTKEY("Source Type", "Source Method", "Source Method Code");
        CommPlan.SETRANGE("Source Type", CommPlan."Source Type"::Customer);
        CommPlan.SETRANGE("Manager Level", true);
        CommPlan.SETRANGE(Disabled, false);
        if CommPlan.FINDSET then begin
            repeat
                if (CommPlan."Source Method" = CommPlan."Source Method"::Specific) and
                   (CommPlan."Source Method Code" = CustomerNo)
                then begin
                    //IF PlanHasPayees(CommPlan.Code) THEN BEGIN
                    if not CommPlanTemp.GET(CommPlan.Code) then begin
                        CommPlanTemp := CommPlan;
                        CommPlanTemp.INSERT;
                    end;
                    //END;
                end;
                if CommPlan."Source Method" = CommPlan."Source Method"::Group then begin
                    if CustomerInGroup(CommPlan."Source Method Code", CustomerNo) then begin
                        //IF PlanHasPayees(CommPlan.Code) THEN BEGIN
                        if not CommPlanTemp.GET(CommPlan.Code) then begin
                            CommPlanTemp := CommPlan;
                            CommPlanTemp.INSERT;
                        end;
                        //END;
                    end;
                end;
                if CommPlan."Source Method" = CommPlan."Source Method"::All then begin
                    //IF PlanHasPayees(CommPlan.Code) THEN BEGIN
                    if not CommPlanTemp.GET(CommPlan.Code) then begin
                        CommPlanTemp := CommPlan;
                        CommPlanTemp.INSERT;
                    end;
                    //END;
                end;
            until CommPlan.NEXT = 0;
        end;

        exit(CommPlanTemp.COUNT > 0);
    end;

    local procedure GetItemPlan(var CustCommPlanTemp: Record CommissionPlanTigCM temporary; var CommPlanCode: Code[20]): Boolean;
    var
        CommPlan: Record CommissionPlanTigCM;
        CommUnitGroupMember: Record CommissionUnitGroupMemberTigCM;
    begin
        CustCommPlanTemp.SETCURRENTKEY("Source Method Sort");
        CustCommPlanTemp.FINDSET;

        //Only include customer plans that apply to the item
        //More than 1 plan may apply. Use the most specific matching one first
        if CustCommPlanTemp."Unit Method" = CustCommPlanTemp."Unit Method"::Specific then begin
            CommPlanCode := CustCommPlanTemp.Code;
            exit((CustCommPlanTemp."Unit Method" = UnitType) and
                 (CustCommPlanTemp."Unit Method Code" = UnitNo))
        end else begin
            //Check for group match
            CommUnitGroupMember.SETCURRENTKEY(Type, "No.");
            CommUnitGroupMember.SETRANGE(Type, UnitType);
            CommUnitGroupMember.SETRANGE("No.", UnitNo);
            if CommUnitGroupMember.FINDFIRST then begin
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
        CommCustGroupMember.SETRANGE("Group Code", CommGroupCode);
        CommCustGroupMember.SETRANGE("Customer No.", CustomerNo);
        exit(CommCustGroupMember.FINDFIRST);
    end;

    local procedure PlanHasPayees(CommPlanCode2: Code[20]): Boolean;
    var
        CommPlanPayee: Record CommissionPlanPayeeTigCM;
    begin
        CommPlanPayee.SETRANGE("Commission Plan Code", CommPlanCode2);
        CommPlanPayee.SETFILTER("Salesperson Code", '<>%1', '');
        exit(CommPlanPayee.FINDFIRST);
    end;

    [EventSubscriber(ObjectType::Codeunit, 90, 'OnAfterPostPurchaseDoc', '', false, false)]
    local procedure UpdateCommPmtEntryPosted(var PurchaseHeader: Record "Purchase Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PurchRcpHdrNo: Code[20]; RetShptHdrNo: Code[20]; PurchInvHdrNo: Code[20]; PurchCrMemoHdrNo: Code[20]);
    var
        CommPmtEntry: Record CommissionPaymentEntryTigCM;
        CommPmtEntry2: Record CommissionPaymentEntryTigCM;
        CommApprovalEntry: Record CommApprovalEntryTigCM;
    begin
        //Update Comm. Pmt. Entry, related Comm. Appr. Entry, and flag to prevent deletion
        PaymentEntry.SETCURRENTKEY("Payment Method", "Payment Ref. No.", "Payment Ref. Line No.");
        PaymentEntry.SETRANGE("Payment Method", PaymentEntry."Payment Method"::"Check as Vendor");
        PaymentEntry.SETRANGE("Payment Ref. No.", PurchaseHeader."No.");
        PaymentEntry.SETRANGE(Posted, false);
        if PaymentEntry.FINDSET then begin
            repeat
                PaymentEntry2.GET(PaymentEntry."Entry No.");
                PaymentEntry2.Posted := true;
                PaymentEntry2."Date Paid" := WORKDATE;
                if PurchInvHdrNo <> '' then
                    PaymentEntry2."Payment Ref. No." := PurchInvHdrNo;
                if PurchCrMemoHdrNo <> '' then
                    PaymentEntry2."Payment Ref. No." := PurchCrMemoHdrNo;
                PaymentEntry2.MODIFY;

                ApprovalEntry.GET(PaymentEntry."Comm. Appr. Entry No.");
                if ApprovalEntry.Open then begin
                    ApprovalEntry.Open := false;
                    ApprovalEntry.MODIFY;
                end;
            until PaymentEntry.NEXT = 0;
        end;
    end;

    local procedure InsertRecogEntry(SalesLine: Record "Sales Line" temporary; CommPlanCode: Code[20]; EntryType2: Option Commission,Clawback,Advance,Adjustment; TriggerDocNo2: Code[20]; TriggerMethod2: Option Booking,Shipment,Invoice,Payment,,,Credit; ItemLedgEntryNo: Integer; PostingDate: Date; PostedDocNo: Code[20]);
    begin
        if not CommPlan.GET(CommPlanCode) then
            CLEAR(CommPlan);

        RecogEntry.INIT;
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
        RecogEntry."Creation Date" := WORKDATE;
        RecogEntry."Created By" := USERID;
        RecogEntry."External Document No." := SalesLine."Purchase Order No.";
        RecogEntry.Description := SalesLine.Description;
        RecogEntry."Description 2" := SalesLine."Description 2";
        RecogEntry."Reason Code" := SalesLine."Return Reason Code";
        RecogEntry."Posted Doc. No." := PostedDocNo;
        if RecogEntry."Entry Type" <> RecogEntry."Entry Type"::Commission then
            RecogEntry.Open := false;
        RecogEntry.INSERT;
    end;

    local procedure InsertApprovalEntry(SalesLineTemp: Record "Sales Line" temporary; TriggerDocNo2: Code[20]; TriggerMethod2: Option Booking,Shipment,Invoice,Payment,,,Credit; DetCustLedgEntryNo: Integer; PostingDate: Date; PostedDocNo: Code[20]);
    var
        RecogEntry2: Record CommRecognitionEntryTigCM;
        RecogEntry3: Record CommRecognitionEntryTigCM;
        CommPlanTemp: Record CommissionPlanTigCM temporary;
        CommApprovalEntry2: Record CommApprovalEntryTigCM;
        CommPlanCode: Code[20];
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
        GetLastEntryNo;

        if not (SalesLineTemp."Document Type" in [SalesLineTemp."Document Type"::"Credit Memo",
                                             SalesLineTemp."Document Type"::"Return Order"])
        then begin
            RecogEntry2.SETCURRENTKEY("Document No.", "Document Line No.");
            RecogEntry2.SETRANGE("Document No.", SalesLineTemp."Document No.");
            RecogEntry2.SETRANGE("Document Line No.", SalesLineTemp."Line No.");
            RecogEntry2.SETRANGE("Unit Type", SalesLineTemp.Type);
            RecogEntry2.SETRANGE("Unit No.", SalesLineTemp."No.");
            RecogEntry2.SETRANGE("Entry Type", RecogEntry."Entry Type"::Commission);
            RecogEntry2.SETRANGE(Open, true);

            if RecogEntry2.FINDSET then begin
                QtyToApply := SalesLineTemp.Quantity;
                RemQtyToApply := QtyToApply;
                LastTriggerDocNo := RecogEntry2."Trigger Document No.";

                repeat
                    CommPlan.GET(RecogEntry2."Commission Plan Code");
                    if CommSetup."Payable Trigger Method" = TriggerMethod2 then begin
                        if RecogEntry2."Basis Qty." <= RemQtyToApply then
                            QtyToApply := RecogEntry2."Basis Qty."
                        else
                            QtyToApply := RemQtyToApply;
                        AmtToApply := ROUND(RecogEntry2."Basis Amt." * (QtyToApply / RecogEntry2."Basis Qty."), 0.01);

                        if RecogEntry2."Trigger Document No." <> LastTriggerDocNo then begin
                            //New set, add any rounding to last entry per set (record pointer still on the last rec inserted)
                            if BasisAmt - AmtApplied <> 0 then begin
                                ApprovalEntry."Basis Amt. Approved" += (BasisAmt - AmtApplied);
                                ApprovalEntry."Amt. Remaining to Pay" := ApprovalEntry."Basis Amt. Approved";
                                ApprovalEntry.MODIFY;
                            end;

                            BasisAmt := 0;
                            AmtApplied := 0;
                            RemQtyToApply -= QtyToApply;
                        end;

                        BasisAmt += RecogEntry2."Basis Amt.";
                        AmtApplied += AmtToApply;

                        if RemQtyToApply <> 0 then begin
                            ApprovalEntry.INIT;
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
                            ApprovalEntry."Released to Pay Date" := WORKDATE;
                            ApprovalEntry."Released to Pay By" := USERID;
                            ApprovalEntry."External Document No." := SalesLineTemp."Purchase Order No.";//RecogEntry2."External Document No.";
                            ApprovalEntry.Description := RecogEntry2.Description;
                            ApprovalEntry."Description 2" := RecogEntry2."Description 2";
                            ApprovalEntry."Reason Code" := RecogEntry2."Reason Code";
                            ApprovalEntry."Posted Doc. No." := PostedDocNo;
                            ApprovalEntry.INSERT;
                            EntryNo += 1;

                            //Close recognition entry if appropriate
                            RecogEntry2.CALCFIELDS("Basis Qty. Approved to Pay");
                            if ABS(RecogEntry2."Basis Qty.") - ABS(RecogEntry2."Basis Qty. Approved to Pay") = 0
                            then begin
                                RecogEntry3.GET(RecogEntry2."Entry No.");
                                RecogEntry3.Open := false;
                                RecogEntry3.MODIFY;
                            end;
                        end;
                    end;
                until (RecogEntry2.NEXT = 0) or (RemQtyToApply = 0);
            end;
        end else begin
            //Credit documents will not be applied to prior invoice documents.
            //They will simply create their own entries
            RecogEntry2.SETCURRENTKEY("Document No.", "Document Line No.");
            RecogEntry2.SETRANGE("Document No.", SalesLineTemp."Document No.");
            RecogEntry2.SETRANGE("Document Line No.", SalesLineTemp."Line No.");
            RecogEntry2.SETRANGE("Unit Type", SalesLineTemp.Type);
            RecogEntry2.SETRANGE("Unit No.", SalesLineTemp."No.");
            RecogEntry2.SETRANGE("Entry Type", RecogEntry."Entry Type"::Commission);
            RecogEntry2.SETRANGE(Open, true);
            RecogEntry2.FINDFIRST;

            ApprovalEntry.INIT;
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
            ApprovalEntry."Released to Pay Date" := WORKDATE;
            ApprovalEntry."Released to Pay By" := USERID;
            ApprovalEntry."External Document No." := RecogEntry2."External Document No.";
            ApprovalEntry.Description := RecogEntry2.Description;
            ApprovalEntry."Description 2" := RecogEntry2."Description 2";
            ApprovalEntry."Reason Code" := RecogEntry2."Reason Code";
            ApprovalEntry."Posted Doc. No." := PostedDocNo;
            ApprovalEntry.INSERT;
            EntryNo += 1;

            RecogEntry2.Open := false;
            RecogEntry2.MODIFY;
        end;
    end;

    local procedure InsertPaymentEntry(CommWkshtLine: Record CommissionWksheetLineTigCM; ApprovalEntry: Record CommApprovalEntryTigCM; DistributionMethod: Option Vendor,"External Provider",Manual; PaymentRefNo: Code[20]; PaymentLineNo: Integer; PostedDocNo: Code[20]);
    begin
        PaymentEntry.INIT;
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
        PaymentEntry."Created Date" := TODAY;
        PaymentEntry."Created By" := USERID;
        PaymentEntry."Unit Type" := ApprovalEntry."Unit Type";
        PaymentEntry."Unit No." := ApprovalEntry."Unit No.";
        PaymentEntry."Commission Plan Code" := ApprovalEntry."Commission Plan Code";
        PaymentEntry."Trigger Method" := ApprovalEntry."Trigger Method";
        PaymentEntry."Trigger Document No." := ApprovalEntry."Trigger Document No.";
        PaymentEntry."Released to Pay" := true;
        PaymentEntry."Released to Pay Date" := WORKDATE;
        PaymentEntry."Released to Pay By" := USERID;
        PaymentEntry."Payment Method" := DistributionMethod;
        PaymentEntry."Payment Ref. No." := PaymentRefNo;
        PaymentEntry."Payment Ref. Line No." := PaymentLineNo;
        PaymentEntry.Description := CommWkshtLine.Description;
        PaymentEntry."Posted Doc. No." := PostedDocNo;
        PaymentEntry.INSERT;
    end;

    local procedure ResetCodeunit();
    begin
        CLEARALL;
        SalesLineTemp.RESET;
        SalesLineTemp.DELETEALL;
        PurchHeaderTemp.RESET;
        PurchHeaderTemp.DELETEALL;
        PurchLineTemp.RESET;
        PurchLineTemp.DELETEALL;
    end;

    local procedure GetLastEntryNo();
    var
        ApprovalEntry2: Record CommApprovalEntryTigCM;
    begin
        if EntryNo = 0 then begin
            if ApprovalEntry2.FINDLAST then
                EntryNo := ApprovalEntry2."Entry No." + 1
            else
                EntryNo := 1;
        end;
    end;
}

