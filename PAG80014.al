page 80014 "Commission Worksheet"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions

    InsertAllowed = false;
    PageType = Worksheet;
    PromotedActionCategories = 'Manage,Functions,Update,Post,Print,e,f';
    SaveValues = true;
    SourceTable = "Comm. Worksheet Line";

    layout
    {
        area(content)
        {
            group(Options)
            {
                field(BatchName;BatchName)
                {
                    Caption = 'Batch Name';

                    trigger OnValidate();
                    begin
                        ValidateBatchName(BatchName);
                    end;
                }
            }
            repeater(Control1000000001)
            {
                field("Entry Type";"Entry Type")
                {
                }
                field("Posting Date";"Posting Date")
                {
                }
                field("Payout Date";"Payout Date")
                {
                }
                field("Customer No.";"Customer No.")
                {

                    trigger OnValidate();
                    begin
                        CurrPage.UPDATE;
                    end;
                }
                field("Customer Name";"Customer Name")
                {
                }
                field("Salesperson Code";"Salesperson Code")
                {

                    trigger OnValidate();
                    begin
                        CurrPage.UPDATE;
                    end;
                }
                field("Salesperson Name";"Salesperson Name")
                {
                }
                field("Source Document No.";"Source Document No.")
                {
                }
                field("Trigger Document No.";"Trigger Document No.")
                {
                }
                field(Description;Description)
                {
                }
                field(Amount;Amount)
                {
                }
                field("Comm. Approval Entry No.";"Comm. Approval Entry No.")
                {
                }
                field("Basis Amt. (Split)";"Basis Amt. (Split)")
                {
                }
                field("Commission Plan Code";"Commission Plan Code")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Show All Batches")
            {
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction();
                begin
                    ValidateBatchName('');
                end;
            }
            action("Suggest Commissions")
            {
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction();
                var
                    SuggestComm : Report "Suggest Commissions";
                begin
                    CLEAR(SuggestComm);
                    SuggestComm.SetBatch(BatchName);
                    SuggestComm.RUNMODAL;
                end;
            }
            action("Delete All Lines")
            {
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;

                trigger OnAction();
                begin
                    DeleteAllLines;
                end;
            }
            action("Delete Selected Line(s)")
            {
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;

                trigger OnAction();
                begin
                    DeleteSelectedLines;
                end;
            }
            action("Insert Adjustment Line")
            {
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;

                trigger OnAction();
                begin
                    InsertAdjustmentLine;
                end;
            }
            action(Post)
            {
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;

                trigger OnAction();
                begin
                    PostWorksheet;
                end;
            }
            action("Send to Excel")
            {
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;

                trigger OnAction();
                var
                    CommWkshtLine : Record "Comm. Worksheet Line";
                    CommToExcel : Report "Commission Wksht. to Excel";
                begin
                    CommWkshtLine.SETRANGE("Batch Name",BatchName);
                    CLEAR(CommToExcel);
                    CommToExcel.SetSourceWorksheet(CommWkshtLine);
                    CommToExcel.RUNMODAL;
                end;
            }
        }
    }

    trigger OnOpenPage();
    begin
        CommSetup.GET;
        if CommSetup.Disabled then
          ERROR(Text005);

        ValidateBatchName(BatchName)
    end;

    var
        CommSetup : Record "Commission Setup";
        CommFunctions : Codeunit "Calculate Commission";
        BatchName : Code[20];
        Text001 : Label 'Are you sure you want to delete all lines?';
        Text002 : Label 'Are you sure you want to delete the selected line(s)?';
        Text003 : Label 'Cancelled.';
        Text004 : Label 'You must specify a Batch Name before making an adjustment.';
        Text005 : Label 'The Commission Add-on is disabled';

    local procedure ValidateBatchName(NewBatchName : Code[20]);
    begin
        if NewBatchName = '' then
          SETRANGE("Batch Name")
        else
          SETRANGE("Batch Name",NewBatchName);
        BatchName := NewBatchName;
        CurrPage.UPDATE;
    end;

    local procedure DeleteAllLines();
    var
        CommWkshtLine : Record "Comm. Worksheet Line";
    begin
        if not CONFIRM(Text001,false) then
          ERROR(Text003);

        with CommWkshtLine do begin
          SETRANGE("Batch Name",BatchName);
          if FINDSET then begin
            repeat
              SetBypassSystemCheck(true);
              DELETE(true);
            until NEXT = 0;
            SetBypassSystemCheck(false);
            CurrPage.UPDATE;
          end;
        end;
    end;

    local procedure DeleteSelectedLines();
    var
        CommWkshtLine : Record "Comm. Worksheet Line";
    begin
        if not CONFIRM(Text002,false) then
          ERROR(Text003);

        CurrPage.SETSELECTIONFILTER(CommWkshtLine);
        OnDeleteCheckMatchingSet(CommWkshtLine);
        CurrPage.UPDATE;
    end;

    local procedure InsertAdjustmentLine();
    var
        LineNo : Integer;
    begin
        if BatchName = '' then
          ERROR(Text004);
        if FINDLAST then
          LineNo := "Line No." + 10000
        else
          LineNo := 10000;
        INIT;
        "Batch Name" := BatchName;
        "Line No." := LineNo;
        "Entry Type" := "Entry Type"::Adjustment;
        INSERT(true);
    end;

    local procedure PostWorksheet();
    var
        CommPost : Codeunit "Commission Post";
    begin
        CLEAR(CommPost);
        CommPost.PostCommWorksheet(Rec);
    end;
}

