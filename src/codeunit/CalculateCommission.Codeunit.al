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
        CommWkshtLine.RESET;
        CommWkshtLine.SETRANGE("Batch Name", BatchName2);
        if CommWkshtLine.FINDLAST then
            LineNo := CommWkshtLine."Line No." + 10000
        else
            LineNo := 10000;
        BatchName := BatchName2;
        PostingDate := PostingDate2;
        PayoutDate := PayoutDate2;
        Salesperson.RESET;
    end;

    procedure CalculateCommission(var CommApprovalEntry: Record CommApprovalEntryTigCM; BatchName2: Code[20]);
    begin
        CommPlan.GET(CommApprovalEntry."Commission Plan Code");
        BatchName := BatchName2;

        CommPlanCalc.SETRANGE("Commission Plan Code", CommApprovalEntry."Commission Plan Code");
        if CommPlanCalc.FINDSET then begin
            repeat
                //xxxIF (CommPlanCalc."Commission Rate" <> 0) OR (CommPlanCalc."Introductory Rate" <> 0) THEN BEGIN
                if 1 = 1 then begin
                    //Apply introductory rate if applicable
                    if CommPlanCalc."Introductory Rate" <> 0 then begin
                        CommPlanCalc.TESTFIELD("Intro Expires From First Sale");
                        CommRecogEntry.GET(CommApprovalEntry."Comm. Recog. Entry No.");
                        if CheckCustGetsIntroRate(CommApprovalEntry."Customer No.",
                                                  CommRecogEntry."Creation Date",
                                                  CommPlanCalc."Intro Expires From First Sale")
                        then
                            CommPlanCalc."Commission Rate" := CommPlanCalc."Introductory Rate";
                    end;
                    if ABS(CommApprovalEntry."Basis Qty. Approved") >= ABS(CommPlanCalc."Tier Amount/Qty.") then begin
                        //Exclude any existing worksheet lines. Flowfield to worksheet line by Comm. Approval Entry No.
                        CommApprovalEntry.CALCFIELDS("Basis Amt. (Wksht.)");
                        CalcCommAmt := ROUND((CommApprovalEntry."Basis Amt. Approved" -
                                              CommApprovalEntry."Basis Amt. (Wksht.)") *
                                             (CommPlanCalc."Commission Rate" / 100), 0.01);
                        PendingCommAmt := 0;
                        PendingBasisAmt := 0;
                        if CalcCommAmt <> 0 then begin
                            CommRecogEntry.GET(CommApprovalEntry."Comm. Recog. Entry No.");

                            if not CommPlan."Manager Level" then begin
                                CommCustSalesperson.SETRANGE("Customer No.", CommApprovalEntry."Customer No.");
                                if CommCustSalesperson.FINDSET then begin
                                    repeat
                                        //Salesperson can be passed in pre-filtered via SetSalespersonFilter()
                                        //so we just confirm this salesperson is in that set
                                        Salesperson.SETRANGE(Code, CommCustSalesperson."Salesperson Code");
                                        if Salesperson.FINDFIRST then begin
                                            CommPlanPayee.RESET;
                                            CommPlanPayee.SETRANGE("Commission Plan Code", CommApprovalEntry."Commission Plan Code");
                                            CommPlanPayee.SETRANGE("Salesperson Code", CommCustSalesperson."Salesperson Code");
                                            if CommPlanPayee.FINDFIRST then begin
                                                InsertCommWkshtLine(CommApprovalEntry,
                                                                    ROUND(CalcCommAmt * (CommCustSalesperson."Split Pct." / 100), 0.01),
                                                                    ROUND(CommRecogEntry."Basis Amt." * (CommCustSalesperson."Split Pct." / 100), 0.01),
                                                                    Salesperson.Code);
                                            end;
                                        end;
                                    until CommCustSalesperson.NEXT = 0;

                                    //Add rounding to last worksheet line
                                    if CalcCommAmt - PendingCommAmt <> 0 then begin
                                        CommWkshtLine.VALIDATE(Amount, CommWkshtLine.Amount + (CalcCommAmt - PendingCommAmt));
                                        CommWkshtLine.MODIFY;
                                    end;
                                end;
                            end else begin
                                //This section only applies to Manager Level plans where it is not required
                                //to specify a salesperson is attached to a specific customer
                                CommPlanPayee.RESET;
                                CommPlanPayee.SETRANGE("Commission Plan Code", CommApprovalEntry."Commission Plan Code");
                                CommPlanPayee.SETRANGE("Commission Plan Code", CommApprovalEntry."Commission Plan Code");
                                if CommPlanPayee.FINDSET then begin
                                    repeat
                                        InsertCommWkshtLine(CommApprovalEntry,
                                                            ROUND(CalcCommAmt * (CommPlanPayee."Manager Split Pct." / 100), 0.01),
                                                            ROUND(CommRecogEntry."Basis Amt." *
                                                            (CommPlanPayee."Manager Split Pct." / 100), 0.01),
                                                            CommPlanPayee."Salesperson Code");
                                    until CommPlanPayee.NEXT = 0;

                                    //Add rounding to last worksheet line. Includes either commission to pay
                                    //or that the entire basis amt. is accounted for
                                    if (CalcCommAmt - PendingCommAmt <> 0) or
                                       (CommRecogEntry."Basis Amt." <> PendingBasisAmt)
                                    then begin
                                        CommWkshtLine.VALIDATE(Amount, CommWkshtLine.Amount + (CalcCommAmt - PendingCommAmt));
                                        CommWkshtLine.VALIDATE("Basis Amt. (Split)", CommWkshtLine."Basis Amt. (Split)" + (CalcCommAmt - PendingCommAmt));
                                        CommWkshtLine.MODIFY;
                                    end;
                                end;
                            end;
                        end;
                    end;
                end;
            until CommPlanCalc.NEXT = 0;
        end;
    end;

    local procedure InsertCommWkshtLine(CommApprovalEntry: Record CommApprovalEntryTigCM; CommAmt: Decimal; BasisAmtSplit: Decimal; SalespersonCode: Code[20]);
    begin
        with CommWkshtLine do begin
            INIT;
            VALIDATE("Batch Name", BatchName);
            "Line No." := LineNo;
            "System Created" := true;
            VALIDATE("Entry Type", CommApprovalEntry."Entry Type");
            VALIDATE("Posting Date", PostingDate);
            VALIDATE("Payout Date", PayoutDate);
            VALIDATE("Customer No.", CommApprovalEntry."Customer No.");
            VALIDATE("Salesperson Code", SalespersonCode);
            VALIDATE("Source Document No.", CommApprovalEntry."Document No.");
            VALIDATE("Trigger Method", CommApprovalEntry."Trigger Method");
            VALIDATE("Trigger Document No.", CommApprovalEntry."Trigger Document No.");
            VALIDATE(Quantity, CommApprovalEntry."Basis Qty. Approved");
            VALIDATE(Amount, CommAmt);
            VALIDATE("Basis Amt. (Split)", BasisAmtSplit);
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
            INSERT;
            LineNo += 1;
            PendingCommAmt += CommAmt;
            PendingBasisAmt += BasisAmtSplit;
        end;
    end;

    procedure SetSalespersonFilter(var Salesperson2: Record "Salesperson/Purchaser");
    begin
        Salesperson.RESET;
        Salesperson.FILTERGROUP(2);
        Salesperson.COPYFILTERS(Salesperson2);
        Salesperson.FILTERGROUP(0);
    end;

    local procedure CheckCustGetsIntroRate(CustomerNo: Code[20]; RecogDate: Date; DatePeriod: DateFormula): Boolean;
    var
        SalesShptHeader: Record "Sales Shipment Header";
        NegDatePeriod: DateFormula;
    begin
        EVALUATE(NegDatePeriod, '-' + FORMAT(DatePeriod));
        SalesShptHeader.SETCURRENTKEY("Sell-to Customer No.");
        SalesShptHeader.SETRANGE("Sell-to Customer No.", CustomerNo);
        SalesShptHeader.SETFILTER("Posting Date", '<%1', CALCDATE(NegDatePeriod, RecogDate));
        exit(SalesShptHeader.FINDFIRST);
    end;
}

