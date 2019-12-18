codeunit 80000 "CalculateCommissionTigCM"
{
    var
        CommPlan: Record CommissionPlanTigCM;
        CommPlanCalc: Record CommissionPlanCalculationTigCM;
        CommPlanPayee: Record CommissionPlanPayeeTigCM;
        CommCustSalesperson: Record "CommCustomerSalespersonTigCM";
        CommWkshtLine: Record CommissionWksheetLineTigCM;
        CommRecogEntry: Record CommRecognitionEntryTigCM;
        Salesperson: Record "Salesperson/Purchaser";
        CalcCommAmt: Decimal;
        PendingCommAmt: Decimal;
        PendingBasisAmt: Decimal;
        BatchName: Code[20];
        LineNo: Integer;
        PostingDate: Date;
        PayoutDate: Date;
        DocTypeDesc: Text[30];

    procedure InitCalculation(BatchName2: Code[20]; PostingDate2: Date; PayoutDate2: Date);
    begin
        CommWkshtLine.Reset();
        CommWkshtLine.SetRange("Batch Name", BatchName2);
        if CommWkshtLine.FindLast() then
            LineNo := CommWkshtLine."Line No." + 10000
        else
            LineNo := 10000;
        BatchName := BatchName2;
        PostingDate := PostingDate2;
        PayoutDate := PayoutDate2;
        Salesperson.Reset();
    end;

    procedure CalculateCommission(var CommApprovalEntry: Record CommApprovalEntryTigCM; BatchName2: Code[20]);
    begin
        CommPlan.Get(CommApprovalEntry."Commission Plan Code");
        BatchName := BatchName2;

        CommPlanCalc.SetRange("Commission Plan Code", CommApprovalEntry."Commission Plan Code");
        if CommPlanCalc.FindSet() then begin
            repeat
                //xxxIF (CommPlanCalc."Commission Rate" <> 0) OR (CommPlanCalc."Introductory Rate" <> 0) THEN BEGIN
                if 1 = 1 then begin
                    //Apply introductory rate if applicable
                    if CommPlanCalc."Introductory Rate" <> 0 then begin
                        CommPlanCalc.TestField("Intro Expires From First Sale");
                        CommRecogEntry.Get(CommApprovalEntry."Comm. Recog. Entry No.");
                        if CheckCustGetsIntroRate(CommApprovalEntry."Customer No.",
                                                  CommRecogEntry."Creation Date",
                                                  CommPlanCalc."Intro Expires From First Sale")
                        then
                            CommPlanCalc."Commission Rate" := CommPlanCalc."Introductory Rate";
                    end;
                    if ABS(CommApprovalEntry."Basis Qty. Approved") >= ABS(CommPlanCalc."Tier Amount/Qty.") then begin
                        //Exclude any existing worksheet lines. Flowfield to worksheet line by Comm. Approval Entry No.
                        CommApprovalEntry.CalcFields("Basis Amt. (Wksht.)");
                        CalcCommAmt := Round((CommApprovalEntry."Basis Amt. Approved" -
                                              CommApprovalEntry."Basis Amt. (Wksht.)") *
                                             (CommPlanCalc."Commission Rate" / 100), 0.01);
                        PendingCommAmt := 0;
                        PendingBasisAmt := 0;
                        if CalcCommAmt <> 0 then begin
                            CommRecogEntry.Get(CommApprovalEntry."Comm. Recog. Entry No.");

                            if not CommPlan."Manager Level" then begin
                                CommCustSalesperson.SetRange("Customer No.", CommApprovalEntry."Customer No.");
                                if CommCustSalesperson.FindSet() then begin
                                    repeat
                                        //Salesperson can be passed in pre-filtered via SetSalespersonFilter()
                                        //so we just confirm this salesperson is in that set
                                        Salesperson.SetRange(Code, CommCustSalesperson."Salesperson Code");
                                        if Salesperson.FindFirst() then begin
                                            CommPlanPayee.Reset();
                                            CommPlanPayee.SetRange("Commission Plan Code", CommApprovalEntry."Commission Plan Code");
                                            CommPlanPayee.SetRange("Salesperson Code", CommCustSalesperson."Salesperson Code");
                                            if CommPlanPayee.FindFirst() then begin
                                                InsertCommWkshtLine(CommApprovalEntry,
                                                                    Round(CalcCommAmt * (CommCustSalesperson."Split Pct." / 100), 0.01),
                                                                    Round(CommRecogEntry."Basis Amt." * (CommCustSalesperson."Split Pct." / 100), 0.01),
                                                                    Salesperson.Code);
                                            end;
                                        end;
                                    until CommCustSalesperson.Next() = 0;

                                    //Add rounding to last worksheet line
                                    if CalcCommAmt - PendingCommAmt <> 0 then begin
                                        CommWkshtLine.Validate(Amount, CommWkshtLine.Amount + (CalcCommAmt - PendingCommAmt));
                                        CommWkshtLine.Modify();
                                    end;
                                end;
                            end else begin
                                //This section only applies to Manager Level plans where it is not required
                                //to specify a salesperson is attached to a specific customer
                                CommPlanPayee.Reset();
                                CommPlanPayee.SetRange("Commission Plan Code", CommApprovalEntry."Commission Plan Code");
                                CommPlanPayee.SetRange("Commission Plan Code", CommApprovalEntry."Commission Plan Code");
                                if CommPlanPayee.FindSet() then begin
                                    repeat
                                        InsertCommWkshtLine(CommApprovalEntry,
                                                            Round(CalcCommAmt * (CommPlanPayee."Manager Split Pct." / 100), 0.01),
                                                            Round(CommRecogEntry."Basis Amt." *
                                                            (CommPlanPayee."Manager Split Pct." / 100), 0.01),
                                                            CommPlanPayee."Salesperson Code");
                                    until CommPlanPayee.Next() = 0;

                                    //Add rounding to last worksheet line. Includes either commission to pay
                                    //or that the entire basis amt. is accounted for
                                    if (CalcCommAmt - PendingCommAmt <> 0) or
                                       (CommRecogEntry."Basis Amt." <> PendingBasisAmt)
                                    then begin
                                        CommWkshtLine.Validate(Amount, CommWkshtLine.Amount + (CalcCommAmt - PendingCommAmt));
                                        CommWkshtLine.Validate("Basis Amt. (Split)", CommWkshtLine."Basis Amt. (Split)" + (CalcCommAmt - PendingCommAmt));
                                        CommWkshtLine.Modify();
                                    end;
                                end;
                            end;
                        end;
                    end;
                end;
            until CommPlanCalc.Next() = 0;
        end;
    end;

    local procedure InsertCommWkshtLine(CommApprovalEntry: Record CommApprovalEntryTigCM; CommAmt: Decimal; BasisAmtSplit: Decimal; SalespersonCode: Code[20]);
    begin
        with CommWkshtLine do begin
            Init();
            Validate("Batch Name", BatchName);
            "Line No." := LineNo;
            "System Created" := true;
            Validate("Entry Type", CommApprovalEntry."Entry Type");
            Validate("Posting Date", PostingDate);
            Validate("Payout Date", PayoutDate);
            Validate("Customer No.", CommApprovalEntry."Customer No.");
            Validate("Salesperson Code", SalespersonCode);
            Validate("Source Document No.", CommApprovalEntry."Document No.");
            Validate("Trigger Method", CommApprovalEntry."Trigger Method");
            Validate("Trigger Document No.", CommApprovalEntry."Trigger Document No.");
            Validate(Quantity, CommApprovalEntry."Basis Qty. Approved");
            Validate(Amount, CommAmt);
            Validate("Basis Amt. (Split)", BasisAmtSplit);
            "Comm. Approval Entry No." := CommApprovalEntry."Entry No.";

            case CommApprovalEntry."Document Type" of
                CommApprovalEntry."Document Type"::Adjustment:
                    DocTypeDesc := 'ADJ:';
                CommApprovalEntry."Document Type"::"Blanket Order":
                    DocTypeDesc := 'BLKT:';
                CommApprovalEntry."Document Type"::"Credit Memo":
                    DocTypeDesc := 'CM:';
                CommApprovalEntry."Document Type"::Invoice:
                    DocTypeDesc := 'INV:';
                CommApprovalEntry."Document Type"::Order:
                    DocTypeDesc := 'ORD:';
                CommApprovalEntry."Document Type"::"Return Order":
                    DocTypeDesc := 'RO:';
            end;
            Description := FORMAT(CommApprovalEntry."Customer No.") + '/ ' + DocTypeDesc +
                           ' ' + FORMAT(CommApprovalEntry."Document No.");
            "Commission Plan Code" := CommApprovalEntry."Commission Plan Code";
            Insert();
            LineNo += 1;
            PendingCommAmt += CommAmt;
            PendingBasisAmt += BasisAmtSplit;
        end;
    end;

    procedure SetSalespersonFilter(var Salesperson2: Record "Salesperson/Purchaser");
    begin
        Salesperson.Reset();
        Salesperson.FilterGroup(2);
        Salesperson.CopyFilters(Salesperson2);
        Salesperson.FilterGroup(0);
    end;

    local procedure CheckCustGetsIntroRate(CustomerNo: Code[20]; RecogDate: Date; DatePeriod: DateFormula): Boolean;
    var
        SalesShptHeader: Record "Sales Shipment Header";
        NegDatePeriod: DateFormula;
    begin
        EVALUATE(NegDatePeriod, '-' + FORMAT(DatePeriod));
        SalesShptHeader.SetCurrentKey("Sell-to Customer No.");
        SalesShptHeader.SetRange("Sell-to Customer No.", CustomerNo);
        SalesShptHeader.SetFilter("Posting Date", '<%1', CALCDATE(NegDatePeriod, RecogDate));
        //exit(SalesShptHeader.FindFirst());
        exit(not SalesShptHeader.IsEmpty());
    end;
}

