codeunit 80001 "Commission Post"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions

    SingleInstance = true;

    trigger OnRun();
    begin
        
        //see ???
        /*
        test cr. memos and return orders
        remove basis amt. flowfield from comm ledger
        update recog entry during payment?
        neg application against pos or vice versa?
        finish CheckOnDeletePO()
        */

    end;

    var
        CommSetup : Record "Commission Setup";
        SalesLineTemp : Record "Sales Line" temporary;
        CommEntry : Record "Commission Setup Summary";
        CommEntryTemp : Record "Commission Setup Summary" temporary;
        CommRecogEntry : Record "Comm. Recognition Entry";
        RecognitionText : Label 'Recognition of %1 %2';
        CommRecogEntryTemp : Record "Comm. Recognition Entry" temporary;
        CommApprovalEntry : Record "Comm. Approval Entry";
        CommApprovalEntryTemp : Record "Comm. Approval Entry" temporary;
        CommPmtEntry : Record "Comm. Payment Entry";
        CommPmtEntryTemp : Record "Comm. Payment Entry" temporary;
        CommPlan : Record "Commission Plan";
        CommPlanPayee : Record "Commission Plan Payee";
        PurchHeader : Record "Purchase Header";
        PurchLine : Record "Purchase Line";
        PurchHeaderTemp : Record "Purchase Header" temporary;
        PurchLineTemp : Record "Purchase Line" temporary;
        SalesHeaderGlobalTemp : Record "Sales Header" temporary;
        EntryNo : Integer;
        RecogEntryNo : Integer;
        PmtEntryNo : Integer;
        ApprEntryNo : Integer;
        TriggerDocNo : Code[20];
        HasCommSetup : Boolean;
        Text001 : Label 'Nothing to Post.';
        EntryType : Option Commission,Clawback,Advance,Adjustment;
        Text002 : Label 'Confirm Posting?';
        Text003 : Label 'Posting Cancelled.';
        Text004 : Label 'You cannot post filtered records. Instead delete any lines you do not want to post.';
        Text005 : Label 'Posting Complete.';
        Text006 : Label 'The Commission Plan Payee is missing a Distribution Code. See Commission Plan %1, Salesperson %2.';
        Text007 : Label 'The Commission Plan Payee is missing a Distribution Account No. See Commission Plan %1, Salesperson %2.';
        Recognized : Boolean;
        TriggerMethod : Option Booking,Shipment,Invoice,Payment,,,Credit;
        Text008 : Label 'There are pending Commission Payment Entries related to this invoice. Are you sure you want to continue and delete this document?';
        Text009 : Label 'There are pending Commission Payment Entries related to this line. Are you sure you want to continue and delete this line?';
        Text010 : Label 'Delete cancelled.';
        Text011 : Label 'Batch Name:';
        Text012 : Label 'You must specify a Batch Name in the worksheet before posting.';
        Text013 : Label 'Commission Processing incomplete. Delete not allowed.';

    local procedure GetCommSetup();
    begin
        if not HasCommSetup then begin
          CommSetup.GET;
          HasCommSetup := true;
        end;
    end;

    local procedure GetCustPlans(var CommPlanTemp : Record "Commission Plan" temporary;CustomerNo : Code[20]) : Boolean;
    var
        CommPlan : Record "Commission Plan";
        CommCustGroupMember : Record "Commission Cust. Group Member";
    begin
        CommPlan.SETCURRENTKEY("Source Type","Source Method","Source Method Code");
        CommPlan.SETRANGE("Source Type",CommPlan."Source Type"::Customer);
        CommPlan.SETRANGE("Source Method",CommPlan."Source Method"::Specific);
        CommPlan.SETRANGE("Source Method Code",CustomerNo);
        CommPlan.SETRANGE("Manager Level",false);
        CommPlan.SETRANGE(Disabled,false);
        if CommPlan.FINDSET then begin
          repeat
            if PlanHasPayees(CommPlan.Code) then begin
              CommPlanTemp := CommPlan;
              CommPlanTemp.INSERT;
            end;
          until CommPlan.NEXT = 0;
        end;

        CommCustGroupMember.SETCURRENTKEY("Customer No.");
        CommCustGroupMember.SETRANGE("Customer No.",CustomerNo);
        if CommCustGroupMember.FINDFIRST then begin
          CommPlan.RESET;
          CommPlan.SETCURRENTKEY("Source Type","Source Method","Source Method Code");
          CommPlan.SETRANGE("Source Type",CommPlan."Source Type"::Customer);
          CommPlan.SETRANGE("Source Method",CommPlan."Source Method"::Group);
          CommPlan.SETRANGE("Source Method Code",CommCustGroupMember."Group Code");
          CommPlan.SETRANGE("Manager Level",false);
          CommPlan.SETRANGE(Disabled,false);
          if CommPlan.FINDSET then begin
            repeat
              if PlanHasPayees(CommPlan.Code) then begin
                CommPlanTemp := CommPlan;
                CommPlanTemp.INSERT;
              end;
            until CommPlan.NEXT = 0;
          end;
        end;

        //Find any plans for all customers
        CommPlan.RESET;
        CommPlan.SETCURRENTKEY("Source Type","Source Method","Source Method Code");
        CommPlan.SETRANGE("Source Type",CommPlan."Source Type"::Customer);
        CommPlan.SETRANGE("Source Method",CommPlan."Source Method"::All);
        CommPlan.SETRANGE("Manager Level",false);
        CommPlan.SETRANGE(Disabled,false);
        if CommPlan.FINDSET then begin
          repeat
            if PlanHasPayees(CommPlan.Code) then begin
              CommPlanTemp := CommPlan;
              CommPlanTemp.INSERT;
            end;
          until CommPlan.NEXT = 0;
        end;

        //Find any manager level plans
        CommPlan.RESET;
        CommPlan.SETCURRENTKEY("Source Type","Source Method","Source Method Code");
        CommPlan.SETRANGE("Source Type",CommPlan."Source Type"::Customer);
        CommPlan.SETRANGE("Manager Level",true);
        CommPlan.SETRANGE(Disabled,false);
        if CommPlan.FINDSET then begin
          repeat
            if (CommPlan."Source Method" = CommPlan."Source Method"::Specific) and
               (CommPlan."Source Method Code" = CustomerNo)
            then begin
              if PlanHasPayees(CommPlan.Code) then begin
                CommPlanTemp := CommPlan;
                CommPlanTemp.INSERT;
              end;
            end;
            if CommPlan."Source Method" = CommPlan."Source Method"::Group then begin
              if CustomerInGroup(CommPlan."Source Method Code",CustomerNo) then begin
                if PlanHasPayees(CommPlan.Code) then begin
                  CommPlanTemp := CommPlan;
                  CommPlanTemp.INSERT;
                end;
              end;
            end;
            if CommPlan."Source Method" = CommPlan."Source Method"::All then begin
              if PlanHasPayees(CommPlan.Code) then begin
                CommPlanTemp := CommPlan;
                CommPlanTemp.INSERT;
              end;
            end;
          until CommPlan.NEXT = 0;
        end;

        exit(CommPlanTemp.COUNT > 0);
    end;

    local procedure GetItemPlan(CustCommPlanTemp : Record "Commission Plan" temporary;var SalesLine : Record "Sales Line";var CommPlanCode : Code[20]) : Boolean;
    var
        CommPlan : Record "Commission Plan";
        CommUnitGroupMember : Record "Commission Unit Group Member";
    begin
        //Only include customer plans that apply to the item
        //More than 1 plan may apply. Use the most specific matching one first
        if CustCommPlanTemp."Unit Method" = CustCommPlanTemp."Unit Method"::Specific then begin
          exit((CustCommPlanTemp."Unit Type" = SalesLine.Type) and
               (CustCommPlanTemp."Unit Method Code" = SalesLine."No."));
        end else begin
          //Check for group match
          CommUnitGroupMember.SETCURRENTKEY(Type,"No.");
          CommUnitGroupMember.SETRANGE(Type,SalesLine.Type);
          CommUnitGroupMember.SETRANGE("No.",SalesLine."No.");
          if CommUnitGroupMember.FINDFIRST then begin
            if CustCommPlanTemp."Unit Type" = SalesLine.Type then begin
              if CustCommPlanTemp."Unit Method" = CustCommPlanTemp."Unit Method"::Group then
                exit(CustCommPlanTemp."Unit Method Code" = CommUnitGroupMember."Group Code");
            end;
          end;
        end;

        //Check for all nos. of same type match
        if (CustCommPlanTemp."Unit Method" = CustCommPlanTemp."Unit Method"::All) and
           (CustCommPlanTemp."Unit Type" = SalesLineTemp.Type)
        then
          exit(true);

        //Check for loosest match, ALL unit types
        if CustCommPlanTemp."Unit Type" = CustCommPlanTemp."Unit Type"::All then
          exit(true);
    end;

    local procedure CalcBaseQty(Qty : Decimal) : Decimal;
    begin
        with SalesLineTemp do begin
          TESTFIELD("Qty. per Unit of Measure");
          exit(ROUND(Qty * "Qty. per Unit of Measure",0.00001));
        end;
    end;

    local procedure CustomerInGroup(CommGroupCode : Code[20];CustomerNo : Code[20]) : Boolean;
    var
        CommCustGroupMember : Record "Commission Cust. Group Member";
    begin
        CommCustGroupMember.SETRANGE("Group Code",CommGroupCode);
        CommCustGroupMember.SETRANGE("Customer No.",CustomerNo);
        exit(CommCustGroupMember.FINDFIRST);
    end;

    local procedure PlanHasPayees(CommPlanCode2 : Code[20]) : Boolean;
    var
        CommPlanPayee : Record "Commission Plan Payee";
    begin
        CommPlanPayee.SETRANGE("Commission Plan Code",CommPlanCode2);
        CommPlanPayee.SETFILTER("Salesperson Code",'<>%1','');
        exit(CommPlanPayee.FINDFIRST);
    end;

    local procedure ResetCodeunit();
    begin
        //This codeunit is single instance so vars need reset after each run
        CLEARALL;
        CommEntryTemp.RESET;
        CommEntryTemp.DELETEALL;
        CommRecogEntryTemp.RESET;
        CommRecogEntryTemp.DELETEALL;
        CommApprovalEntryTemp.RESET;
        CommApprovalEntryTemp.DELETEALL;
        CommPmtEntryTemp.RESET;
        CommPmtEntryTemp.DELETEALL;
        SalesLineTemp.RESET;
        SalesLineTemp.DELETEALL;
        PurchHeaderTemp.RESET;
        PurchHeaderTemp.DELETEALL;
        PurchLineTemp.RESET;
        PurchLineTemp.DELETEALL;
    end;

    [EventSubscriber(ObjectType::Table, 38, 'OnBeforeDeleteEvent', '', false, false)]
    procedure OnPurchHeaderDelete(var Rec : Record "Purchase Header";RunTrigger : Boolean);
    var
        CommPmtEntry : Record "Comm. Payment Entry";
    begin
        if not RunTrigger then
          exit;

        with Rec do begin
          CommPmtEntry.SETCURRENTKEY("Payment Method","Payment Ref. No.","Payment Ref. Line No.");
          CommPmtEntry.SETRANGE("Payment Method",CommPmtEntry."Payment Method"::"Check as Vendor");
          CommPmtEntry.SETRANGE("Payment Ref. No.","No.");
          CommPmtEntry.SETRANGE(Posted,false);
          if CommPmtEntry.FINDFIRST then
            if not CONFIRM(Text008,false) then
              ERROR(Text010);

          CommPmtEntry.DELETEALL;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnBeforeModifyEvent', '', false, false)]
    procedure OnPurchLineModify(var Rec : Record "Purchase Line";var xRec : Record "Purchase Line";RunTrigger : Boolean);
    var
        CommPmtEntry : Record "Comm. Payment Entry";
    begin
        if not RunTrigger then
          exit;

        with Rec do begin
          CommPmtEntry.SETCURRENTKEY("Payment Method","Payment Ref. No.","Payment Ref. Line No.");
          CommPmtEntry.SETRANGE("Payment Method",CommPmtEntry."Payment Method"::"Check as Vendor");
          CommPmtEntry.SETRANGE("Payment Ref. No.","No.");
          CommPmtEntry.SETRANGE("Payment Ref. Line No.","Line No.");
          CommPmtEntry.SETRANGE(Posted,false);
          if CommPmtEntry.FINDFIRST then
            ERROR(Text004);
        end;
    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnDeletePOLine(var Rec : Record "Purchase Line";RunTrigger : Boolean);
    var
        CommPmtEntry : Record "Comm. Payment Entry";
        CommApprovalEntry : Record "Comm. Approval Entry";
        CommRecogEntry : Record "Comm. Recognition Entry";
    begin
        if not RunTrigger then
          exit;
        
        with Rec do begin
          CommPmtEntry.SETCURRENTKEY("Payment Method","Payment Ref. No.","Payment Ref. Line No.");
          CommPmtEntry.SETRANGE("Payment Method",CommPmtEntry."Payment Method"::"Check as Vendor");
          CommPmtEntry.SETRANGE("Payment Ref. No.","Document No.");
          CommPmtEntry.SETRANGE("Payment Ref. Line No.","Line No.");
          CommPmtEntry.SETRANGE(Posted,false);
          if CommPmtEntry.FINDFIRST then
            if not CONFIRM(Text009,false) then
              ERROR(Text010);
        
          CommPmtEntry.DELETEALL;
        end;
        /*???
        IF CommPmtEntry.FINDSET THEN BEGIN
          REPEAT
            //CommApprovalEntry.GET(CommPmtEntry.com
          UNTIL CommPmtEntry.NEXT = 0;
        END;
        */

    end;

    [EventSubscriber(ObjectType::Codeunit, 90, 'OnAfterPostPurchaseDoc', '', false, false)]
    local procedure UpdateCommPmtEntryPosted(var PurchaseHeader : Record "Purchase Header";var GenJnlPostLine : Codeunit "Gen. Jnl.-Post Line";PurchRcpHdrNo : Code[20];RetShptHdrNo : Code[20];PurchInvHdrNo : Code[20];PurchCrMemoHdrNo : Code[20]);
    var
        CommPmtEntry : Record "Comm. Payment Entry";
        CommPmtEntry2 : Record "Comm. Payment Entry";
        CommApprovalEntry : Record "Comm. Approval Entry";
    begin
        //Update Comm. Pmt. Entry, related Comm. Appr. Entry, and flag to prevent deletion
        CommPmtEntry.SETCURRENTKEY("Payment Method","Payment Ref. No.","Payment Ref. Line No.");
        CommPmtEntry.SETRANGE("Payment Method",CommPmtEntry."Payment Method"::"Check as Vendor");
        CommPmtEntry.SETRANGE("Payment Ref. No.",PurchaseHeader."No.");
        CommPmtEntry.SETRANGE(Posted,false);
        if CommPmtEntry.FINDSET then begin
          repeat
            CommPmtEntry2.GET(CommPmtEntry."Entry No.");
            CommPmtEntry2.Posted := true;
            CommPmtEntry2."Date Paid" := WORKDATE;
            if PurchInvHdrNo <> '' then
              CommPmtEntry2."Payment Ref. No." := PurchInvHdrNo;
            if PurchCrMemoHdrNo <> '' then
              CommPmtEntry2."Payment Ref. No." := PurchCrMemoHdrNo;
            CommPmtEntry2.MODIFY;

            CommApprovalEntry.GET(CommPmtEntry."Comm. Appr. Entry No.");
            if CommApprovalEntry.Open then begin
              CommApprovalEntry.Open := false;
              CommApprovalEntry.MODIFY;
            end;
          until CommPmtEntry.NEXT = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnBeforePostSalesDoc', '', false, false)]
    local procedure SetPrePostSalesLines(var SalesHeader : Record "Sales Header");
    var
        SalesLine : Record "Sales Line";
        Ship : Boolean;
        Invoice : Boolean;
    begin
        //We need to grab details from sales lines here that are not available in the AfterPost events
        ResetCodeunit;

        SalesHeader.CALCFIELDS(Amount);
        SalesHeaderGlobalTemp := SalesHeader;
        SalesHeaderGlobalTemp.Amount := SalesHeader.Amount;

        if (SalesHeaderGlobalTemp."Document Type" = SalesHeaderGlobalTemp."Document Type"::Invoice) or
           (SalesHeaderGlobalTemp."Document Type" = SalesHeaderGlobalTemp."Document Type"::"Return Order") or
           (SalesHeaderGlobalTemp."Document Type" = SalesHeaderGlobalTemp."Document Type"::"Credit Memo")
        then begin
          SalesHeaderGlobalTemp.Ship := true;
          SalesHeaderGlobalTemp.Invoice := true;
        end;
        Ship := false;
        Invoice := false;

        SalesLineTemp.RESET;
        SalesLineTemp.DELETEALL;
        SalesLine.SETRANGE("Document Type",SalesHeaderGlobalTemp."Document Type");
        SalesLine.SETRANGE("Document No.",SalesHeaderGlobalTemp."No.");
        SalesLine.SETFILTER(Quantity,'<>%1',0);
        if SalesLine.FINDSET then begin
          repeat
            if ((SalesHeaderGlobalTemp.Ship) and (SalesLine."Qty. to Ship" > 0)) or
               ((SalesHeaderGlobalTemp.Invoice) and (SalesLine."Qty. to Invoice" > 0))
            then begin
              SalesLineTemp := SalesLine;

              if (SalesHeaderGlobalTemp."Document Type" = SalesHeaderGlobalTemp."Document Type"::"Credit Memo") or
                 (SalesHeaderGlobalTemp."Document Type" = SalesHeaderGlobalTemp."Document Type"::"Return Order")
              then
                SalesLineTemp."Qty. to Ship" := SalesLineTemp."Return Qty. to Receive";

              SalesLineTemp.INSERT;
            end;
            if SalesLineTemp."Qty. to Ship" <> 0 then
              Ship := true;
            if SalesLineTemp."Qty. to Invoice" <> 0 then
              Invoice := true;
          until SalesLine.NEXT = 0;
        end;
        if not Ship then
          SalesHeaderGlobalTemp.Ship := false;
        if not Invoice then
          SalesHeaderGlobalTemp.Invoice := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, 414, 'OnAfterReleaseSalesDoc', '', false, false)]
    local procedure CheckRecognizeBooking(var SalesHeader : Record "Sales Header";PreviewMode : Boolean);
    var
        TriggerMethod : Option Booking,Shipment,Invoice,"Partial Pmt.","Full Pmt.";
        SalesLine : Record "Sales Line";
    begin
        //??? how to avoid dups for re-release
        //if nothing applied then delete CE and CRE
        //if applied then create new entries for difference (plus or minus)

        //xxx maybe for future
        exit;

        ResetCodeunit;
        SalesLineTemp.RESET;
        SalesLineTemp.DELETEALL;
        SalesLine.SETRANGE("Document Type",SalesHeader."Document Type");
        SalesLine.SETRANGE("Document No.",SalesHeader."No.");
        SalesLine.SETFILTER(Quantity,'<>%1',0);
        TriggerDocNo := SalesHeader."No.";
        if SalesLine.FINDSET then begin
          repeat
            SalesLineTemp := SalesLine;
            SalesLineTemp.INSERT;
          until SalesLine.NEXT = 0;
        end;
        CheckOKToRecognize(TriggerMethod::Booking);
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterPostSalesDoc', '', false, false)]
    local procedure CheckRecognizeShipment(var SalesHeader : Record "Sales Header";var GenJnlPostLine : Codeunit "Gen. Jnl.-Post Line";SalesShptHdrNo : Code[20];RetRcpHdrNo : Code[20];SalesInvHdrNo : Code[20];SalesCrMemoHdrNo : Code[20];var SalesInvHdr : Record "Sales Invoice Header";var SalesCrMemoHdr : Record "Sales Cr.Memo Header");
    begin
        GetCommSetup;
        if CommSetup.Disabled then
          exit;

        //Temp sales line was pre-filled in the SetPrePostSalesLines() function
        if not SalesHeaderGlobalTemp.Ship then
          exit;

        case SalesHeader."Document Type" of
          SalesHeader."Document Type"::Order,SalesHeader."Document Type"::Invoice : begin
            TriggerDocNo := SalesShptHdrNo;
          end;
          SalesHeader."Document Type"::"Credit Memo",SalesHeader."Document Type"::"Return Order" : begin
            TriggerDocNo := RetRcpHdrNo;
          end;
        end;

        CheckOKToRecognize(TriggerMethod::Shipment);
        //CU80 published event cannot call this directly as NAV cannot guarantee
        //the sequence subscriber events will fire in. Calling from here for control
        //so we know the recog entries were created first
        CheckApproveToPayPosting(SalesHeader,GenJnlPostLine,SalesShptHdrNo,
                                 RetRcpHdrNo,SalesInvHdrNo,SalesCrMemoHdrNo,
                                 SalesInvHdr,SalesCrMemoHdr);
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterPostSalesDoc', '', false, false)]
    local procedure CheckRecognizeInvoice(var SalesHeader : Record "Sales Header";var GenJnlPostLine : Codeunit "Gen. Jnl.-Post Line";SalesShptHdrNo : Code[20];RetRcpHdrNo : Code[20];SalesInvHdrNo : Code[20];SalesCrMemoHdrNo : Code[20];var SalesInvHdr : Record "Sales Invoice Header";var SalesCrMemoHdr : Record "Sales Cr.Memo Header");
    begin
        GetCommSetup;
        if CommSetup.Disabled then
          exit;

        //Temp sales line was pre-filled in the SetPrePostSalesLines() function
        if not SalesHeaderGlobalTemp.Invoice then
          exit;
        if Recognized then
          exit;

        case SalesHeader."Document Type" of
          SalesHeader."Document Type"::Order,SalesHeader."Document Type"::Invoice : begin
            TriggerDocNo := SalesShptHdrNo;
          end;
          SalesHeader."Document Type"::"Credit Memo",SalesHeader."Document Type"::"Return Order" : begin
            TriggerDocNo := RetRcpHdrNo;
          end;
        end;

        CheckOKToRecognize(TriggerMethod::Invoice);
        //CU80 published event cannot call this directly as NAV cannot guarantee
        //the sequence subscriber events will fire in. Calling from here for control
        //so we know the recog entries were created first
        CheckApproveToPayPosting(SalesHeader,GenJnlPostLine,SalesShptHdrNo,
                                 RetRcpHdrNo,SalesInvHdrNo,SalesCrMemoHdrNo,
                                 SalesInvHdr,SalesCrMemoHdr);
    end;

    procedure CheckOKToRecognize(TriggerMethod : Option Booking,Shipment,Invoice,Payment,,,Credit) : Boolean;
    var
        CommPlanTemp : Record "Commission Plan" temporary;
        SalesLineTemp2 : Record "Sales Line" temporary;
        CommPlanCode : Code[20];
    begin
        //Temp sales line was pre-filled in the SetPrePostSalesLines() function
        GetCommSetup;
        if CommSetup.Disabled then
          exit;
        
        //??? add partial or full payment logic in future
        
        SalesLineTemp.SETRANGE("Qty. to Ship");
        SalesLineTemp.SETRANGE("Qty. to Invoice");
        //SalesLineTemp.SETRANGE("Return Qty. to Receive");
        
        //IF (SalesHeaderGlobalTemp."Document Type" = SalesHeaderGlobalTemp."Document Type"::Order) OR
        //   (SalesHeaderGlobalTemp."Document Type" = SalesHeaderGlobalTemp."Document Type"::Invoice)
        //THEN BEGIN
          case TriggerMethod of
            TriggerMethod::Booking :
              SalesLineTemp.SETFILTER(Quantity,'<>%1',0);
            TriggerMethod::Shipment :
              SalesLineTemp.SETFILTER("Qty. to Ship",'<>%1',0);
            TriggerMethod::Invoice :
              SalesLineTemp.SETFILTER("Qty. to Invoice",'<>%1',0);
          end;
        //END;
        
        /*
        IF (SalesHeaderGlobalTemp."Document Type" = SalesHeaderGlobalTemp."Document Type"::"Credit Memo") OR
           (SalesHeaderGlobalTemp."Document Type" = SalesHeaderGlobalTemp."Document Type"::"Return Order")
        THEN BEGIN
          CASE TriggerMethod OF
            TriggerMethod::Booking :
              SalesLineTemp.SETFILTER(Quantity,'<>%1',0);
            TriggerMethod::Shipment :
              SalesLineTemp.SETFILTER("return qty. to receive",'<>%1',0);
            TriggerMethod::Invoice :
              SalesLineTemp.SETFILTER("Qty. to Invoice",'<>%1',0);
          END;
        END;
        */
        //xxx
        
        SalesLineTemp.FINDSET;
        if not SalesLineTemp.FINDSET then
          exit;
        
        GetCustPlans(CommPlanTemp,SalesLineTemp."Sell-to Customer No.");
        repeat
          if CommPlanTemp.FINDSET then begin
            repeat
              if CommPlanTemp."Recognition Trigger Method" = TriggerMethod then begin
                //Adjust quantity and amounts based on action
                SalesLineTemp2 := SalesLineTemp;
                if TriggerMethod = TriggerMethod::Shipment then begin
                  SalesLineTemp2.Amount := ROUND(SalesLineTemp.Amount *
                                          (SalesLineTemp."Qty. to Ship" / SalesLineTemp.Quantity),0.01);
                  SalesLineTemp2."Inv. Discount Amount" := ROUND(SalesLineTemp."Inv. Discount Amount" *
                                          (SalesLineTemp."Qty. to Ship" / SalesLineTemp.Quantity),0.01);
                  SalesLineTemp2.Quantity := SalesLineTemp."Qty. to Ship";
                end;
                if TriggerMethod = TriggerMethod::Invoice then begin
                  SalesLineTemp2.Amount := ROUND(SalesLineTemp.Amount *
                                          (SalesLineTemp."Qty. to Invoice" / SalesLineTemp.Quantity),0.01);
                  SalesLineTemp2."Inv. Discount Amount" := ROUND(SalesLineTemp."Inv. Discount Amount" *
                                          (SalesLineTemp."Qty. to Invoice" / SalesLineTemp.Quantity),0.01);
                  SalesLineTemp2.Quantity := SalesLineTemp."Qty. to Invoice";
                end;
        
                if GetItemPlan(CommPlanTemp,SalesLineTemp2,CommPlanCode) then begin
                  // If paying on invoice discounts add discount back to amount
                  if CommPlanTemp."Pay On Invoice Discounts" then
                    SalesLineTemp2.Amount += SalesLineTemp2."Inv. Discount Amount";
        
                  if (SalesLineTemp2."Document Type" = SalesLineTemp2."Document Type"::"Credit Memo") or
                     (SalesLineTemp2."Document Type" = SalesLineTemp2."Document Type"::"Return Order")
                  then begin
                    SalesLineTemp2.Quantity := -SalesLineTemp2.Quantity;
                    SalesLineTemp2.Amount := -SalesLineTemp2.Amount;
                  end;
        
                  if EntryNo = 0 then
                    InitCommEntry(SalesLineTemp2,CommPlanTemp.Code,TriggerDocNo,EntryType::Commission);
                  InitRecogEntry(SalesLineTemp2,CommPlanTemp.Code,TriggerDocNo);
                end;
              end;
            until CommPlanTemp.NEXT = 0;
          end;
        until SalesLineTemp.NEXT = 0;
        
        Recognized := true;
        if EntryNo > 0 then
          FinalizeEntries;

    end;

    local procedure CheckApproveToPayPosting(var SalesHeader : Record "Sales Header";var GenJnlPostLine : Codeunit "Gen. Jnl.-Post Line";SalesShptHdrNo : Code[20];RetRcpHdrNo : Code[20];SalesInvHdrNo : Code[20];SalesCrMemoHdrNo : Code[20];var SalesInvHdr : Record "Sales Invoice Header";var SalesCrMemoHdr : Record "Sales Cr.Memo Header");
    begin
        GetCommSetup;
        if CommSetup.Disabled then
          exit;

        //Temp sales line was pre-filled in the SetPrePostSalesLines() function
        case SalesHeaderGlobalTemp."Document Type" of
          SalesHeaderGlobalTemp."Document Type"::Order,
          SalesHeaderGlobalTemp."Document Type"::Invoice :
            begin
              TriggerDocNo := SalesShptHdrNo;
              if SalesHeaderGlobalTemp.Ship then
                CheckApproveToPay(TriggerMethod::Shipment);
              if SalesHeaderGlobalTemp.Invoice then
                CheckApproveToPay(TriggerMethod::Invoice);
            end;
          SalesHeaderGlobalTemp."Document Type"::"Credit Memo",
          SalesHeaderGlobalTemp."Document Type"::"Return Order" :
            begin
              TriggerDocNo := RetRcpHdrNo;
              if SalesHeaderGlobalTemp.Ship then
                CheckApproveToPay(TriggerMethod::Shipment);
              if SalesHeaderGlobalTemp.Invoice then
                CheckApproveToPay(TriggerMethod::Invoice);
            end;
        end;
    end;

    local procedure CheckApproveToPayPartPmt();
    var
        DetCustLedgEntry : Record "Detailed Cust. Ledg. Entry";
        CommRecogEntry2 : Record "Comm. Recognition Entry";
        RemAmtToApply : Decimal;
        AmtToApply : Decimal;
        QtyToApply : Decimal;
        AmtApplied : Decimal;
        BasisAmt : Decimal;
        LastTriggerDocNo : Code[20];
    begin
        /*
        GetCommSetup;
        IF CommSetup.Disabled THEN
          EXIT;
        
        //This function pulls payment and cr. memo application data
        //from the Det. Cust. Ledger Entry and applies it to any
        //recog. entries by document no.
        
        //xxx???
        //allow for unapply!!!!!
        
        TriggerMethod := TriggerMethod::"Partial Pmt.";
        CommApprovalEntry.RESET;
        CommApprovalEntry.SETCURRENTKEY("Det. Cust. Ledger Entry No.");
        IF NOT CommApprovalEntry.FINDLAST THEN
          CLEAR(CommApprovalEntry);
        
        WITH DetCustLedgEntry DO BEGIN
          SETCURRENTKEY("Initial Document Type","Entry Type","Customer No.",
                        "Currency Code","Initial Entry Global Dim. 1",
                        "Initial Entry Global Dim. 2","Posting Date");
          SETFILTER("Entry No.",'>%1',CommApprovalEntry."Det. Cust. Ledger Entry No.");
          SETRANGE("Initial Document Type","Initial Document Type"::Invoice);
          SETRANGE("Entry Type","Entry Type"::Application);
          SETFILTER("Document Type",'%1|%2',"Document Type"::Payment,"Document Type"::"Credit Memo");
          IF FINDSET THEN BEGIN
            CommApprovalEntry.LOCKTABLE;
            IF NOT CommApprovalEntry.FINDLAST THEN
              CLEAR(CommApprovalEntry);
            ApprEntryNo := CommApprovalEntry."Entry No.";
        
            REPEAT
              CommRecogEntryTemp.SETCURRENTKEY("Document No.","Document Line No.");
              //Create entries for what is approved to pay. this will flowfield up to
              //the commission entry for each matching recognition entry until
              //no qty. left to apply
              //This application logic is a bit tricky. 1 sales line being invoiced
              //can apply to multiple recognition entries for that same sales line
              //because we allow more than 1 commission plan to be in play for a
              //specific transaction. We have to apply the sales line qty. being
              //invoiced to ALL transactions in that SET before reducing the
              //remaining qty. to apply. The triggering document no. binds the set.
              CommRecogEntry.SETRANGE("Document No.",DetCustLedgEntry."Document No.");
              CommRecogEntry.SETRANGE("Entry Type",CommRecogEntry."Entry Type"::Commission);
              CommRecogEntry.SETRANGE(Open,TRUE);
              IF CommRecogEntry.FINDSET THEN BEGIN
                //Since payments don't specify what was paid for, we apply by amount
                //against the recognition entries until nothing left to apply
                RemAmtToApply := Amount;
                AmtApplied := 0;
                LastTriggerDocNo := CommRecogEntry."Trigger Document No.";
        
                REPEAT
                  CommPlan.GET(CommRecogEntry."Commission Plan Code");
                  IF CommPlan."Payable Trigger Method" = TriggerMethod THEN BEGIN
                    IF RemAmtToApply >= CommRecogEntry."Basis Amt. Remaining" THEN
                      AmtToApply := CommRecogEntry."Basis Amt. Remaining"
                    ELSE
                      AmtToApply := RemAmtToApply;
        
                    QtyToApply := ROUND((AmtToApply / CommRecogEntry."Basis Amt. Remaining") *
                                        CommRecogEntry."Basis Qty. Remaining",0.00001);
        
                    IF CommRecogEntry."Trigger Document No." <> LastTriggerDocNo THEN BEGIN
                      //New set
                      //Add any rounding to last entry per set (record pointer still on the last rec inserted)
                      IF BasisAmt - AmtApplied <> 0 THEN BEGIN
                        CommApprovalEntry."Basis Amt. Approved" += (BasisAmt - AmtApplied);
                        CommApprovalEntry."Amt. Remaining to Pay" := CommApprovalEntry."Basis Amt. Approved";
                        CommApprovalEntry.MODIFY;
                      END;
        
                      BasisAmt := 0;
                      AmtApplied := 0;
                    END;
        
                    BasisAmt += CommRecogEntry."Basis Amt.";
                    AmtApplied += AmtToApply;
        
                    IF RemAmtToApply <> 0 THEN BEGIN
                      CommApprovalEntry.INIT;
                      CommApprovalEntry."Entry No." := 0;
                      CommApprovalEntry."Entry Type" := CommRecogEntry."Entry Type";
                      CommApprovalEntry."Det. Cust. Ledger Entry No." := "Entry No.";
                      CommApprovalEntry."Comm. Recog. Entry No." := CommRecogEntry."Entry No.";
                      //CommApprovalEntry."Comm. Ledger Entry No." := CommRecogEntry."Comm. Ledger Entry No.";
                      CommApprovalEntry."Document Type" := CommRecogEntry."Document Type";
                      CommApprovalEntry."Document No." := CommRecogEntry."Document No.";
                      CommApprovalEntry."Document Line No." := CommRecogEntry."Document Line No.";
                      CommApprovalEntry."Customer No." := CommRecogEntry."Customer No.";
                      CommApprovalEntry."Unit Type" := CommRecogEntry."Unit Type";
                      CommApprovalEntry."Unit No." := CommRecogEntry."Unit No.";
                      CommApprovalEntry."Basis Qty. Approved" := QtyToApply;
                      CommApprovalEntry."Basis Amt. Approved" := AmtToApply;
                      CommApprovalEntry."Qty. Remaining to Pay" := QtyToApply;
                      CommApprovalEntry."Amt. Remaining to Pay" := AmtToApply;
                      CommApprovalEntry.Open := TRUE;
                      CommApprovalEntry."Commission Plan Code" := CommRecogEntry."Commission Plan Code";
                      CommApprovalEntry."Trigger Method" := TriggerMethod;
                      CommApprovalEntry."Trigger Document No." := "Document No.";
                      CommApprovalEntry."Released to Pay Date" := WORKDATE;
                      CommApprovalEntry."Released to Pay By" := USERID;
                      CommApprovalEntry.INSERT;
        
                      //Close recognition entry if appropriate
                      CommRecogEntry.CALCFIELDS("Basis Amt. Approved to Pay");
                      IF ABS(CommRecogEntry."Basis Amt.") - ABS(CommRecogEntry."Basis Amt. Approved to Pay") = 0
                      THEN BEGIN
                        CommRecogEntry2.GET(CommRecogEntry."Entry No.");
                        CommRecogEntry2.Open := FALSE;
                        CommRecogEntry2.MODIFY;
                      END;
        
                      //Maybe move to function later on
                      ApprEntryNo += 1;
                      CommApprovalEntryTemp.INIT;
                      CommApprovalEntryTemp."Entry No." := ApprEntryNo;
                      CommApprovalEntryTemp."Entry Type" := CommRecogEntry."Entry Type";
                      CommApprovalEntryTemp."Comm. Recog. Entry No." := CommRecogEntryTemp."Entry No.";
                      //CommApprovalEntryTemp."Comm. Ledger Entry No." := CommEntryTemp."Entry No.";
                      CommApprovalEntryTemp."Document Type" := CommRecogEntry."Document Type";
                      CommApprovalEntryTemp."Document No." := CommRecogEntry."Document No.";
                      CommApprovalEntryTemp."Document Line No." := CommRecogEntry."Document Line No.";
                      CommApprovalEntryTemp."Customer No." := CommRecogEntry."Customer No.";
                      CommApprovalEntryTemp."Unit Type" := CommRecogEntry."Unit Type";
                      CommApprovalEntryTemp."Unit No." := CommRecogEntry."Unit No.";
                      CommApprovalEntryTemp."Basis Amt. Approved" := CommApprovalEntry."Basis Amt. Approved";
                      CommApprovalEntryTemp."Amt. Remaining to Pay" := 0;
                      CommApprovalEntryTemp."Basis Qty. Approved" := 1;
                      CommApprovalEntryTemp."Qty. Remaining to Pay" := 0;
                      CommApprovalEntryTemp."Commission Plan Code" := CommRecogEntry."Commission Plan Code";
                      CommApprovalEntryTemp."Trigger Method" := CommRecogEntry."Trigger Method";
                      CommApprovalEntryTemp."Trigger Document No." := CommRecogEntry."Trigger Document No.";
                      CommApprovalEntryTemp."Released to Pay Date" := WORKDATE;
                      CommApprovalEntryTemp."Released to Pay By" := USERID;
                      CommApprovalEntryTemp.INSERT;
                    END;
                  END;
                UNTIL (CommRecogEntry.NEXT = 0) OR (RemAmtToApply = 0);
              END;
            UNTIL NEXT = 0;
          END;
        END;
        */

    end;

    procedure CheckApproveToPay(TriggerMethod : Option Booking,Shipment,Invoice,Payment,,,Credit) : Boolean;
    var
        CommPlanTemp : Record "Commission Plan" temporary;
        CommRecogEntry2 : Record "Comm. Recognition Entry";
        CommApprovalEntry2 : Record "Comm. Approval Entry";
        CommPlanCode : Code[20];
        QtyToApply : Decimal;
        RemQtyToApply : Decimal;
        AmtToApply : Decimal;
        AmtApplied : Decimal;
        BasisAmt : Decimal;
        LastTriggerDocNo : Code[20];
    begin
        //Only commisson entry types are in play here.
        //Any adjustment types create the comm. entry, comm. recog. entry, and comm. pmt. entry
        //as a matched set and will not process in this function
        GetCommSetup;
        if CommSetup.Disabled then
          exit;

        //Temp sales line was pre-filled in the SetPrePostSalesLines() function
        SalesLineTemp.SETRANGE("Qty. to Ship");
        SalesLineTemp.SETRANGE("Qty. to Invoice");
        case TriggerMethod of
          TriggerMethod::Shipment :
            SalesLineTemp.SETFILTER("Qty. to Ship",'<>%1',0);
          TriggerMethod::Invoice :
            SalesLineTemp.SETFILTER("Qty. to Invoice",'<>%1',0);
        end;
        //??? add partial or full payment logic in future

        CommRecogEntryTemp.SETCURRENTKEY("Document No.","Document Line No.");
        if not SalesLineTemp.FINDSET then
          exit;

        repeat
          //Create entries for what is approved to pay. this will flowfield up to
          //the commission entry for each matching recognition entry until
          //no qty. left to apply
          //This application logic is a bit tricky. 1 sales line being invoiced
          //can apply to multiple recognition entries for that same sales line
          //because we allow more than 1 commission plan to be in play for a
          //specific transaction. We have to apply the sales line qty. being
          //invoiced to ALL transactions in that SET before reducing the
          //remaining qty. to apply. The triggering document no. binds the set.
          CommRecogEntry.SETRANGE("Document No.",SalesLineTemp."Document No.");
          CommRecogEntry.SETRANGE("Document Line No.",SalesLineTemp."Line No.");
          CommRecogEntry.SETRANGE("Unit Type",SalesLineTemp.Type);
          CommRecogEntry.SETRANGE("Unit No.",SalesLineTemp."No.");
          CommRecogEntry.SETRANGE("Entry Type",CommRecogEntry."Entry Type"::Commission);
          CommRecogEntry.SETRANGE(Open,true);
          if CommRecogEntry.FINDSET then begin
            if TriggerMethod = TriggerMethod::Shipment then
              QtyToApply  := SalesLineTemp."Qty. to Ship"
            else
              QtyToApply  := SalesLineTemp."Qty. to Invoice";
            RemQtyToApply := QtyToApply;
            LastTriggerDocNo := CommRecogEntry."Trigger Document No.";
            repeat
              CommPlan.GET(CommRecogEntry."Commission Plan Code");
              if CommPlan."Payable Trigger Method" = TriggerMethod then begin
                if CommRecogEntry."Basis Qty." <= RemQtyToApply then
                  QtyToApply := CommRecogEntry."Basis Qty."
                else
                  QtyToApply := RemQtyToApply;
                AmtToApply := ROUND(CommRecogEntry."Basis Amt." * (QtyToApply / CommRecogEntry."Basis Qty."),0.01);

                if CommRecogEntry."Trigger Document No." <> LastTriggerDocNo then begin
                  //New set
                  //Add any rounding to last entry per set (record pointer still on the last rec inserted)
                  if BasisAmt - AmtApplied <> 0 then begin
                    CommApprovalEntry."Basis Amt. Approved" += (BasisAmt - AmtApplied);
                    CommApprovalEntry."Amt. Remaining to Pay" := CommApprovalEntry."Basis Amt. Approved";
                    CommApprovalEntry.MODIFY;
                  end;

                  BasisAmt := 0;
                  AmtApplied := 0;
                  RemQtyToApply -= QtyToApply;
                end;

                BasisAmt += CommRecogEntry."Basis Amt.";
                AmtApplied += AmtToApply;

                if RemQtyToApply <> 0 then begin
                  CommApprovalEntry.INIT;
                  CommApprovalEntry."Entry No." := 0;
                  CommApprovalEntry."Entry Type" := CommRecogEntry."Entry Type";
                  CommApprovalEntry."Comm. Recog. Entry No." := CommRecogEntry."Entry No.";
                  CommApprovalEntry."Comm. Ledger Entry No." := CommRecogEntry."Comm. Ledger Entry No.";
                  CommApprovalEntry."Document Type" := CommRecogEntry."Document Type";
                  CommApprovalEntry."Document No." := CommRecogEntry."Document No.";
                  CommApprovalEntry."Document Line No." := CommRecogEntry."Document Line No.";
                  CommApprovalEntry."Customer No." := CommRecogEntry."Customer No.";
                  CommApprovalEntry."Unit Type" := CommRecogEntry."Unit Type";
                  CommApprovalEntry."Unit No." := CommRecogEntry."Unit No.";
                  CommApprovalEntry."Basis Qty. Approved" := QtyToApply;
                  CommApprovalEntry."Basis Amt. Approved" := AmtToApply;
                  CommApprovalEntry."Qty. Remaining to Pay" := QtyToApply;
                  CommApprovalEntry."Amt. Remaining to Pay" := AmtToApply;
                  CommApprovalEntry.Open := true;
                  CommApprovalEntry."Commission Plan Code" := CommRecogEntry."Commission Plan Code";
                  CommApprovalEntry."Trigger Method" := TriggerMethod;
                  CommApprovalEntry."Trigger Document No." := TriggerDocNo;
                  CommApprovalEntry."Released to Pay Date" := WORKDATE;
                  CommApprovalEntry."Released to Pay By" := USERID;
                  CommApprovalEntry.INSERT;

                  //Close recognition entry if appropriate
                  CommRecogEntry.CALCFIELDS("Basis Qty. Approved to Pay");
                  if ABS(CommRecogEntry."Basis Qty.") - ABS(CommRecogEntry."Basis Qty. Approved to Pay") = 0
                  then begin
                    CommRecogEntry2.GET(CommRecogEntry."Entry No.");
                    CommRecogEntry2.Open := false;
                    CommRecogEntry2.MODIFY;
                  end;
                end;
              end;
            until (CommRecogEntry.NEXT = 0) or (RemQtyToApply = 0);
          end;
        until SalesLineTemp.NEXT = 0;
    end;

    procedure PostCommWorksheet(var CommWkshtLine : Record "Comm. Worksheet Line");
    var
        CommWkshtLine2 : Record "Comm. Worksheet Line";
        DocNo : Code[20];
        PurchLineNo : Integer;
        LineAmt : Decimal;
    begin
        GetCommSetup;
        if CommSetup.Disabled then
          exit;

        if not CONFIRM(Text002,false) then
          ERROR(Text003);
        ResetCodeunit;
        CommWkshtLine2 := CommWkshtLine;
        CommWkshtLine2.COPYFILTERS(CommWkshtLine);
        //Ensure user did not filter on any fields
        if FORMAT(CommWkshtLine2.GETFILTERS) <> 'Batch Name: ' + FORMAT(CommWkshtLine.GETFILTER("Batch Name"))
        then
          ERROR(Text004);

        with CommWkshtLine2 do begin
          CommWkshtLine2.SETCURRENTKEY("Batch Name","Salesperson Code","Line No.");
          if not FINDSET then
            ERROR(Text001);

          //Ensure only a single batch is being posted
          if "Batch Name" = '' then
            ERROR(Text012);

          //Check lines
          repeat
            TESTFIELD("Posting Date");
            TESTFIELD("Payout Date");
            TESTFIELD("Customer No.");
            TESTFIELD("Salesperson Code");
            TESTFIELD("Commission Plan Code");
            TESTFIELD("Source Document No.");
            CommPlanPayee.GET("Commission Plan Code","Salesperson Code");
            if CommPlanPayee."Distribution Method" = CommPlanPayee."Distribution Method"::Vendor then begin
              if CommPlanPayee."Distribution Code" = '' then
                ERROR(STRSUBSTNO(Text006,"Commission Plan Code","Salesperson Code"));
              if CommPlanPayee."Distribution Account No." = '' then
                ERROR(STRSUBSTNO(Text007,"Commission Plan Code","Salesperson Code"));
            end;
          until NEXT = 0;

          //Post lines
          DocNo := 'TEMP001';
          FINDSET;
          repeat
            CLEAR(CommPlan);
            CLEAR(CommApprovalEntry);
            CommPlan.GET("Commission Plan Code");
            CommPlanPayee.GET("Commission Plan Code","Salesperson Code");
            CALCFIELDS("Customer Name");

            if "System Created" then begin
              if not CommApprovalEntry.GET("Comm. Approval Entry No.") then
                CLEAR(CommApprovalEntry);
            end else begin
              //Create related entries for adjustment lines
              //Use fake Sales Line as common vehicle
              SalesLineTemp.INIT;
              SalesLineTemp."Document No." := CommWkshtLine2."Source Document No.";
              SalesLineTemp."Sell-to Customer No." := CommWkshtLine2."Customer No.";
              SalesLineTemp.Description := Description;
              SalesLineTemp.Amount := Amount;
              if Amount >= 0 then
                SalesLineTemp.Quantity := 1
              else
                SalesLineTemp.Quantity := -1;

              //Create full set of related records
              InitCommEntry(SalesLineTemp,CommPlan.Code,'',"Entry Type");
              InitRecogEntry(SalesLineTemp,CommPlan.Code,'');
              InitApprovalEntry(CommWkshtLine2);
            end;

            //create purch invoice per vendor no./salesperson
            //one line per payment entry
            if CommPlanPayee."Distribution Method" = CommPlanPayee."Distribution Method"::Vendor
            then begin
              PurchHeaderTemp.SETRANGE("Buy-from Vendor No.",CommPlanPayee."Distribution Code");
              if not PurchHeaderTemp.FINDFIRST then begin
                PurchHeaderTemp."Document Type" := PurchHeaderTemp."Document Type"::Invoice;
                PurchHeaderTemp."No." := DocNo;
                PurchHeaderTemp."Buy-from Vendor No." := CommPlanPayee."Distribution Code";
                PurchHeaderTemp."Document Date" := CommWkshtLine2."Payout Date";
                PurchHeaderTemp."Posting Date" := CommWkshtLine2."Posting Date";
                PurchHeaderTemp.INSERT;
                DocNo := INCSTR(DocNo);
              end;

              PurchLineTemp.SETRANGE("Document Type",PurchHeaderTemp."Document Type");
              PurchLineTemp.SETRANGE("Document No.",PurchHeaderTemp."No.");
              if PurchLineTemp.FINDLAST then
                PurchLineNo := PurchLineTemp."Line No." + 10000
              else
                PurchLineNo := 10000;
              PurchLineTemp."Document Type" := PurchHeaderTemp."Document Type";
              PurchLineTemp."Document No." := PurchHeaderTemp."No.";
              PurchLineTemp."Line No." := PurchLineNo;
              PurchLineTemp.Type := PurchLine.Type::"G/L Account";
              PurchLineTemp."No." := CommPlanPayee."Distribution Account No.";
              PurchLineTemp.Quantity := 1;
              PurchLineTemp."Direct Unit Cost" := Amount;
              PurchLineTemp.Description := Description;
              PurchLineTemp."Description 2" := FORMAT("Batch Name") + ': ' + FORMAT("Payout Date");
              PurchLineTemp.INSERT;
            end;

            if "System Created" then
              InitPaymentEntry(CommWkshtLine2,CommApprovalEntry,
                           CommPlanPayee."Distribution Method",
                           PurchHeaderTemp."No.",
                           PurchLineTemp."Line No.")
            else
              InitPaymentEntry(CommWkshtLine2,CommApprovalEntryTemp,
                           CommPlanPayee."Distribution Method",
                           PurchHeaderTemp."No.",
                           PurchLineTemp."Line No.");
          until NEXT = 0;

          PurchHeaderTemp.RESET;
          if PurchHeaderTemp.FINDSET then begin
            repeat
              //If total is negative change doc type to cr. memo
              LineAmt := 0;
              PurchLineTemp.RESET;
              PurchLineTemp.SETRANGE("Document Type",PurchHeaderTemp."Document Type");
              PurchLineTemp.SETRANGE("Document No.",PurchHeaderTemp."No.");
              PurchLineTemp.FINDSET;
              repeat
                LineAmt += PurchLineTemp."Direct Unit Cost";
              until PurchLineTemp.NEXT = 0;

              PurchHeader.INIT;
              if LineAmt < 0 then
                PurchHeader.VALIDATE("Document Type",PurchHeader."Document Type"::"Credit Memo")
              else
                PurchHeader.VALIDATE("Document Type",PurchHeaderTemp."Document Type");
              PurchHeader."No." := '';
              PurchHeader.INSERT(true);
              PurchHeader.VALIDATE("Buy-from Vendor No.",PurchHeaderTemp."Buy-from Vendor No.");
              PurchHeader.VALIDATE("Document Date",PurchHeaderTemp."Document Date");
              PurchHeader.VALIDATE("Posting Date",PurchHeaderTemp."Posting Date");
              if LineAmt >= 0 then
                PurchHeader."Vendor Invoice No." := PurchHeader."No."
              else
                PurchHeader."Vendor Cr. Memo No." := PurchHeader."No.";
              PurchHeader.MODIFY(true);

              PurchLineTemp.RESET;
              PurchLineTemp.SETRANGE("Document Type",PurchHeaderTemp."Document Type");
              PurchLineTemp.SETRANGE("Document No.",PurchHeaderTemp."No.");
              PurchLineTemp.FINDSET;
              repeat
                PurchLine.INIT;
                PurchLine.VALIDATE("Document Type",PurchHeader."Document Type");
                PurchLine.VALIDATE("Document No.",PurchHeader."No.");
                PurchLine."Line No." := PurchLineTemp."Line No.";
                PurchLine.INSERT(true);
                PurchLine.VALIDATE(Type,PurchLineTemp.Type);
                PurchLine.VALIDATE("No.",PurchLineTemp."No.");
                PurchLine.VALIDATE(Quantity,ABS(PurchLineTemp.Quantity));
                PurchLine.VALIDATE("Direct Unit Cost",PurchLineTemp."Direct Unit Cost");
                PurchLine.Description := PurchLineTemp.Description;
                PurchLine."Description 2" := PurchLineTemp."Description 2";
                PurchLine.MODIFY(true);

                //Update payment links to the real document no.
                CommPmtEntryTemp.SETCURRENTKEY("Payment Method","Payment Ref. No.","Payment Ref. Line No.");
                CommPmtEntryTemp.SETRANGE("Payment Method",CommPmtEntryTemp."Payment Method"::"Check as Vendor");
                CommPmtEntryTemp.SETRANGE("Payment Ref. No.",PurchLineTemp."Document No.");
                CommPmtEntryTemp.SETRANGE("Payment Ref. Line No.",PurchLineTemp."Line No.");
                while CommPmtEntryTemp.FINDFIRST do begin
                  CommPmtEntryTemp."Payment Ref. No." := PurchLine."Document No.";
                  CommPmtEntryTemp."Payment Ref. Line No." := PurchLine."Line No.";
                  CommPmtEntryTemp.MODIFY;
                end;
              until PurchLineTemp.NEXT = 0;
            until PurchHeaderTemp.NEXT = 0;
          end;

          FinalizeEntries;
          DELETEALL;
          MESSAGE(Text005);
        end;
    end;

    local procedure InitCommEntry(var SalesLine : Record "Sales Line";CommPlanCode : Code[20];TriggerDocNo2 : Code[20];EntryType2 : Option Commission,Clawback,Advance,Adjustment);
    begin
        /*depricate - NOT needed
        IF NOT CommPlan.GET(CommPlanCode) THEN
          CLEAR(CommPlan);
        IF EntryNo = 0 THEN
          EntryNo := 1;
        
        CommEntryTemp.INIT;
        CommEntryTemp."User ID" := userid;
        CommEntryTemp."entry no." := EntryNo;
        CommEntryTemp."Entry No." := EntryType2;
        CommEntryTemp."Document Type" := SalesLine."Document Type";
        CommEntryTemp."Customer No." := SalesLine."Document No.";
        CommEntryTemp."Comm. Plan Code" := WORKDATE;
        CommEntryTemp."Commission Rate" := USERID;
        CommEntryTemp."Customer No." := SalesLine."Sell-to Customer No.";
        CommEntryTemp.Open := TRUE;
        CommEntryTemp."Trigger Method" := CommPlan."Recognition Trigger Method";
        CommEntryTemp."Trigger Document No." := TriggerDocNo2;
        IF EntryType2 = EntryType2::Commission THEN BEGIN
          CommEntryTemp."Salesperson Code" := STRSUBSTNO(RecognitionText,SalesLine."Document Type",SalesLine."Document No.");
          CommEntryTemp."Original Amt." := SalesHeaderGlobalTemp.Amount;
        END ELSE BEGIN
          CommEntryTemp."Document Type" := CommEntryTemp."Document Type"::"7";
          CommEntryTemp."Salesperson Code" := SalesLine.Description;
          CommEntryTemp.Open := FALSE;
        END;
        CommEntryTemp.INSERT;
        EntryNo += 1;
        */

    end;

    local procedure InitRecogEntry(var SalesLine : Record "Sales Line";CommPlanCode : Code[20];TriggerDocNo2 : Code[20]);
    begin
        /*depricate - NOT needed
        RecogEntryNo += 1;
        IF NOT CommPlan.GET(CommPlanCode) THEN
          CLEAR(CommPlan);
        
        CommRecogEntryTemp.INIT;
        CommRecogEntryTemp."Entry No." := RecogEntryNo;
        CommRecogEntryTemp."Comm. Ledger Entry No." := CommEntryTemp."User ID";
        CommRecogEntryTemp."Entry Type" := CommEntryTemp."Entry No.";
        CommRecogEntryTemp. "Document Type" := CommEntryTemp."Document Type";
        CommRecogEntryTemp."Document No." := CommEntryTemp."Customer No.";
        CommRecogEntryTemp."Document Line No." := SalesLine."Line No.";
        CommRecogEntryTemp."Customer No." := CommEntryTemp."Customer No.";
        CommRecogEntryTemp."Unit Type" := SalesLine.Type;
        CommRecogEntryTemp."Unit No." := SalesLine."No.";
        CommRecogEntryTemp."Basis Qty." := SalesLine.Quantity;
        CommRecogEntryTemp."Basis Amt." := SalesLine.Amount;
        CommRecogEntryTemp.Open := TRUE;
        CommRecogEntryTemp."Commission Plan Code" := CommPlanCode;
        CommRecogEntryTemp."Trigger Method" := CommPlan."Recognition Trigger Method";
        CommRecogEntryTemp."Trigger Document No." := TriggerDocNo2;
        CommRecogEntryTemp."Creation Date" := WORKDATE;
        CommRecogEntryTemp."Created By" := USERID;
        IF CommEntryTemp."Entry No." <> CommEntryTemp."Entry No."::"0" THEN
          CommRecogEntryTemp.Open := FALSE;
        CommRecogEntryTemp.INSERT;
        */

    end;

    local procedure InitApprovalEntry(CommWkshtLine2 : Record "Comm. Worksheet Line");
    begin
        ApprEntryNo += 1;
        CommApprovalEntryTemp.INIT;
        CommApprovalEntryTemp."Entry No." := ApprEntryNo;
        CommApprovalEntryTemp."Entry Type" := CommRecogEntryTemp."Entry Type";
        CommApprovalEntryTemp."Comm. Recog. Entry No." := CommRecogEntryTemp."Entry No.";
        CommApprovalEntryTemp."Document Type" := CommRecogEntryTemp."Document Type";
        CommApprovalEntryTemp."Document No." := CommRecogEntryTemp."Document No.";
        CommApprovalEntryTemp."Document Line No." := CommRecogEntryTemp."Document Line No.";
        CommApprovalEntryTemp."Customer No." := CommRecogEntryTemp."Customer No.";
        CommApprovalEntryTemp."Unit Type" := CommRecogEntryTemp."Unit Type";
        CommApprovalEntryTemp."Unit No." := CommRecogEntryTemp."Unit No.";
        CommApprovalEntryTemp."Basis Amt. Approved" := CommWkshtLine2.Amount;
        CommApprovalEntryTemp."Amt. Remaining to Pay" := CommWkshtLine2.Amount;
        if CommWkshtLine2.Amount >= 0 then begin
          CommApprovalEntryTemp."Basis Qty. Approved" := 1;
          CommApprovalEntryTemp."Qty. Remaining to Pay" := 1;
        end else begin
          CommApprovalEntryTemp."Basis Qty. Approved" := -1;
          CommApprovalEntryTemp."Qty. Remaining to Pay" := -1;
        end;
        CommApprovalEntryTemp."Commission Plan Code" := CommRecogEntryTemp."Commission Plan Code";
        CommApprovalEntryTemp."Trigger Method" := CommRecogEntryTemp."Trigger Method";
        CommApprovalEntryTemp."Trigger Document No." := CommRecogEntry."Trigger Document No.";
        CommApprovalEntryTemp."Released to Pay Date" := WORKDATE;
        CommApprovalEntryTemp."Released to Pay By" := USERID;
        CommApprovalEntryTemp.INSERT;
    end;

    local procedure InitPaymentEntry(CommWkshtLine : Record "Comm. Worksheet Line";CommApprovalEntry : Record "Comm. Approval Entry";DistributionMethod : Option Vendor,External,Manual;PaymentRefNo : Code[20];PaymentLineNo : Integer);
    begin
        PmtEntryNo += 1;
        CommPmtEntryTemp.INIT;
        CommPmtEntryTemp."Entry No." := PmtEntryNo;
        CommPmtEntryTemp."Entry Type" := CommWkshtLine."Entry Type";
        CommPmtEntryTemp."Comm. Recog. Entry No." := CommApprovalEntry."Comm. Recog. Entry No.";
        CommPmtEntryTemp."Comm. Ledger Entry No." := CommApprovalEntry."Comm. Ledger Entry No.";
        CommPmtEntryTemp."Comm. Appr. Entry No." := CommWkshtLine."Comm. Approval Entry No.";
        CommPmtEntryTemp."Batch Name" := CommWkshtLine."Batch Name";
        CommPmtEntryTemp."Posting Date" := CommWkshtLine."Posting Date";
        CommPmtEntryTemp."Payout Date" := CommWkshtLine."Payout Date";
        CommPmtEntryTemp."Salesperson Code" := CommWkshtLine."Salesperson Code";
        CommPmtEntryTemp."Document No." := CommWkshtLine."Source Document No.";
        CommPmtEntryTemp.Quantity := CommWkshtLine.Quantity;
        CommPmtEntryTemp.Amount := CommWkshtLine.Amount;
        CommPmtEntryTemp."Customer No." := CommWkshtLine."Customer No.";
        CommPmtEntryTemp."Created Date" := TODAY;
        CommPmtEntryTemp."Created By" := USERID;
        CommPmtEntryTemp."Unit Type" := CommApprovalEntry."Unit Type";
        CommPmtEntryTemp."Unit No." := CommApprovalEntry."Unit No.";
        CommPmtEntryTemp."Commission Plan Code" := CommApprovalEntry."Commission Plan Code";
        CommPmtEntryTemp."Trigger Method" := CommApprovalEntry."Trigger Method";
        CommPmtEntryTemp."Trigger Document No." := CommApprovalEntry."Trigger Document No.";
        CommPmtEntryTemp."Released to Pay" := true;
        CommPmtEntryTemp."Released to Pay Date" := WORKDATE;
        CommPmtEntryTemp."Released to Pay By" := USERID;
        CommPmtEntryTemp."Payment Method" := DistributionMethod;
        CommPmtEntryTemp."Payment Ref. No." := PaymentRefNo;
        CommPmtEntryTemp."Payment Ref. Line No." := PaymentLineNo;
        CommPmtEntryTemp.Description := CommWkshtLine.Description;
        CommPmtEntryTemp.INSERT;
    end;

    local procedure FinalizeEntries();
    begin
        //We only maintain 1 comm. ledger entry per document
        //If called from outside the commission worksheet
        //we are creating all these related temp records.
        //IF we are calling from within the worksheet for
        //adjustment type lines we also create these entries.
        //However, if called from the worksheet for
        //commission type lines we do NOT create these
        //related temp entries as they already exist. We
        //only create the pmt. temp entries. In this
        //condition we don't handle these records here,
        //instead we create the pmt. entries directly from
        //the InitPaymentEntry() function.
        /*depricate - NOT needed. Creating entries from history, NOT posting
        CommEntryTemp.RESET;
        IF CommEntryTemp.FINDSET THEN BEGIN
          REPEAT
            CommEntry.SETCURRENTKEY("Document Type","Customer No.");
            CommEntry.SETRANGE("Document Type",CommEntryTemp."Document Type");
            CommEntry.SETRANGE("Customer No.",CommEntryTemp."Customer No.");
            IF NOT CommEntry.FINDFIRST THEN BEGIN
              CommEntry.RESET;
              CommEntry.LOCKTABLE;
              IF CommEntry.FINDLAST THEN
                EntryNo := CommEntry."User ID" + 1
              ELSE
                EntryNo := 1;
              CommEntry := CommEntryTemp;
              CommEntry."User ID" := EntryNo;
              CommEntry.INSERT;
            END;
        
            //Related recognition entries
            CommRecogEntryTemp.RESET;
            CommRecogEntryTemp.SETRANGE("Comm. Ledger Entry No.",CommEntryTemp."User ID");
            IF CommRecogEntryTemp.FINDSET THEN BEGIN
              REPEAT
                CommRecogEntry := CommRecogEntryTemp;
                CommRecogEntry."Entry No." := 0;
                CommRecogEntry."Comm. Ledger Entry No." := CommEntry."User ID";
                CommRecogEntry.INSERT;
        
                //Related approval entries
                //Only has records if called from commission worksheet adjustment lines
                CommApprovalEntryTemp.RESET;
                CommApprovalEntryTemp.SETRANGE("Comm. Ledger Entry No.",CommEntryTemp."User ID");
                CommApprovalEntryTemp.SETRANGE("Comm. Recog. Entry No.",CommRecogEntryTemp."Entry No.");
                IF CommApprovalEntryTemp.FINDSET THEN BEGIN
                  REPEAT
                    CommApprovalEntry := CommApprovalEntryTemp;
                    CommApprovalEntry."Entry No." := 0;
                    CommApprovalEntry."Comm. Ledger Entry No." := CommEntry."User ID";
                    CommApprovalEntry."Comm. Recog. Entry No." := CommRecogEntry."Entry No.";
                    CommApprovalEntry.INSERT;
                  UNTIL CommApprovalEntryTemp.NEXT = 0;
                END;
        
                //Related payment entries
                //Only has records if called from commission worksheet for adjustment lines
                //This will only find adjustment lines where the related entries were
                //created to match on the fly. It will find commission type entries down
                //further after the comm. entry loop
                CommPmtEntryTemp.RESET;
                CommPmtEntryTemp.SETRANGE("Comm. Ledger Entry No.",CommEntryTemp."User ID");
                CommPmtEntryTemp.SETRANGE("Comm. Recog. Entry No.",CommRecogEntryTemp."Entry No.");
                CommPmtEntryTemp.SETFILTER("Entry Type",'<>%1',CommPmtEntryTemp."Entry Type"::Commission);
                IF CommPmtEntryTemp.FINDSET THEN BEGIN
                  REPEAT
                    CommPmtEntry := CommPmtEntryTemp;
                    CommPmtEntry."Entry No." := 0;
                    CommPmtEntry."Comm. Ledger Entry No." := CommEntry."User ID";
                    CommPmtEntry."Comm. Recog. Entry No." := CommRecogEntry."Entry No.";
                    CommPmtEntry.INSERT;
                  UNTIL CommPmtEntryTemp.NEXT = 0;
                END;
              UNTIL CommRecogEntryTemp.NEXT = 0;
            END;
          UNTIL CommEntryTemp.NEXT = 0;
        END;
        */
        
        //Only has records if called from commission worksheet for adjustment lines
        //and will ONLY find entries NOT in the filtered loop above
        CommPmtEntryTemp.RESET;
        CommPmtEntryTemp.SETRANGE("Entry Type",CommPmtEntryTemp."Entry Type"::Commission);
        if CommPmtEntryTemp.FINDSET then begin
          repeat
            CommPmtEntry := CommPmtEntryTemp;
            CommPmtEntry."Entry No." := 0;
            CommPmtEntry.INSERT;
        
            //xxx done somewhere else?
            CommApprovalEntry.GET(CommPmtEntry."Comm. Appr. Entry No.");
            //CommApprovalEntry.CALCFIELDS("Amt. Paid");
            //CommApprovalEntry."Amt. Remaining to Pay" :=
            //                  CommApprovalEntry."Basis Amt. Approved" - CommApprovalEntry."Amt. Paid";
            CommApprovalEntry."Qty. Paid" := CommApprovalEntry."Basis Qty. Approved";
            CommApprovalEntry.Open := false;
            CommApprovalEntry.MODIFY;
          until CommPmtEntryTemp.NEXT = 0;
        end;

    end;

    [EventSubscriber(ObjectType::Table, 110, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnSalesShptHeaderDelete(var Rec : Record "Sales Shipment Header";RunTrigger : Boolean);
    begin
        if not RunTrigger then
          exit;

        GetCommSetup;

        if CommSetup."Recog. Trigger Method" = CommSetup."Recog. Trigger Method"::Shipment then begin
          if Rec."Commission Calculated" < Rec."Commission Calculated"::"1" then
            ERROR(Text013);
        end;

        if CommSetup."Payable Trigger Method" = CommSetup."Payable Trigger Method"::Shipment then begin
          if not Rec."Commission Calculated" then
            ERROR(Text013);
        end;
    end;

    [EventSubscriber(ObjectType::Table, 112, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnSalesInvHeaderDelete(var Rec : Record "Sales Invoice Header";RunTrigger : Boolean);
    begin
        if not RunTrigger then
          exit;

        GetCommSetup;

        if CommSetup."Recog. Trigger Method" = CommSetup."Recog. Trigger Method"::Invoice then begin
          if not Rec."Commission Calculated" then
            ERROR(Text013);
        end;

        if CommSetup."Payable Trigger Method" = CommSetup."Payable Trigger Method"::Invoice then begin
          if not Rec."Commission Calculated" then
            ERROR(Text013);
        end;
    end;

    [EventSubscriber(ObjectType::Table, 114, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnSalesCRMemoHeaderDelete(var Rec : Record "Sales Cr.Memo Header";RunTrigger : Boolean);
    begin
        if not RunTrigger then
          exit;

        GetCommSetup;

        if CommSetup."Recog. Trigger Method" = CommSetup."Recog. Trigger Method"::Invoice then begin
          if not Rec."Commission Calculated" then
            ERROR(Text013);
        end;

        if CommSetup."Payable Trigger Method" = CommSetup."Payable Trigger Method"::Invoice then begin
          if not Rec."Commission Calculated" then
            ERROR(Text013);
        end;
    end;
}

