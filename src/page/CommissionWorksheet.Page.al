page 80014 "CommissionWorksheetTigCM"
{
    Caption = 'Commission Worksheet';
    PageType = Worksheet;
    ApplicationArea = All;
    UsageCategory = Tasks;
    SourceTable = CommissionWksheetLineTigCM;
    PromotedActionCategories = 'Manage,Functions,Update,Post,Print,e,f';
    SaveValues = true;
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            group(Options)
            {
                field(BatchNameLbl; BatchName)
                {
                    Caption = 'Batch Name';
                    ApplicationArea = All;
                    Tooltip = 'Specifies the BatchName';

                    trigger OnValidate();
                    begin
                        FilterBatchName(BatchName);
                    end;
                }
            }
            repeater(Control1000000001)
            {
                field("Entry Type"; "Entry Type")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Entry Type';
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Posting Date';
                }
                field("Payout Date"; "Payout Date")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Payout Date';
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Customer No.';

                    trigger OnValidate();
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Customer Name"; "Customer Name")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Customer Name';
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Salesperson Code';

                    trigger OnValidate();
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Salesperson Name"; "Salesperson Name")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Salesperson Name';
                }
                field("Source Document No."; "Source Document No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Source Document No.';
                }
                field("Trigger Document No."; "Trigger Document No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Trigger Document No.';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Description';
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Amount';
                }
                field("Comm. Approval Entry No."; "Comm. Approval Entry No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Comm. Approval Entry No.';
                }
                field("Basis Amt. (Split)"; "Basis Amt. (Split)")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Basis Amt. (Split)';
                }
                field("Commission Plan Code"; "Commission Plan Code")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Commission Plan Code';
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
                ApplicationArea = All;
                ToolTip = 'Removes the filter on Batch Name';
                Image = ChangeBatch;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction();
                begin
                    FilterBatchName('');
                end;
            }
            action("Suggest Commissions")
            {
                ApplicationArea = All;
                ToolTip = 'Runs the Suggest Commissions process';
                Image = SuggestFinancialCharge;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction();
                var
                    SuggestComm: Report SuggestCommissionsTigCM;
                begin
                    Clear(SuggestComm);
                    SuggestComm.SetBatch(BatchName);
                    SuggestComm.RunModal();
                end;
            }
            action("Delete All Lines")
            {
                ApplicationArea = All;
                ToolTip = 'Deletes all Lines';
                Image = DeleteRow;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;

                trigger OnAction();
                begin
                    DeleteAllLines();
                end;
            }
            action("Delete Selected Line(s)")
            {
                ApplicationArea = All;
                ToolTip = 'Deletes the selected lines';
                Image = DeleteQtyToHandle;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;

                trigger OnAction();
                begin
                    DeleteSelectedLines();
                end;
            }
            action("Insert Adjustment Line")
            {
                ApplicationArea = All;
                ToolTip = 'Adds another adjustment Line';
                Image = AdjustItemCost;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;

                trigger OnAction();
                begin
                    InsertAdjustmentLine();
                end;
            }
            action(Post)
            {
                ApplicationArea = All;
                ToolTip = 'Posts the adjustment lines in the current Batch';
                Image = Post;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;

                trigger OnAction();
                begin
                    PostWorksheet();
                end;
            }
            action("Send to Excel")
            {
                ApplicationArea = All;
                ToolTip = 'Runs the Send to Excel process';
                Image = Excel;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;

                trigger OnAction();
                var
                    CommWkshtLine: Record CommissionWksheetLineTigCM;
                    CommToExcel: Report CommissionWkshttoExcelTigCM;
                begin
                    CommWkshtLine.SetRange("Batch Name", BatchName);
                    Clear(CommToExcel);
                    CommToExcel.SetSourceWorksheet(CommWkshtLine);
                    CommToExcel.RunModal();
                end;
            }
        }
    }

    trigger OnOpenPage();
    var
        CommissionDisabledErr: Label 'The Commission Add-on is disabled';
    begin
        CommSetup.Get();
        if CommSetup.Disabled then
            Error(CommissionDisabledErr);

        FilterBatchName(BatchName)
    end;

    var
        CommSetup: Record CommissionSetupTigCM;
        BatchName: Code[20];
        CancelledErr: Label 'Cancelled.';

    local procedure FilterBatchName(NewBatchName: Code[20]);
    begin
        if NewBatchName = '' then
            SetRange("Batch Name")
        else
            SetRange("Batch Name", NewBatchName);
        BatchName := NewBatchName;
        CurrPage.Update();
    end;

    local procedure DeleteAllLines();
    var
        CommWkshtLine: Record CommissionWksheetLineTigCM;
        DeleteAllLinesQst: Label 'Are you sure you want to delete all lines?';
    begin
        if not Confirm(DeleteAllLinesQst, false) then
            Error(CancelledErr);

        with CommWkshtLine do begin
            SetRange("Batch Name", BatchName);
            if FindSet() then begin
                repeat
                    SetBypassSystemCheck(true);
                    Delete(true);
                until Next() = 0;
                SetBypassSystemCheck(false);
                CurrPage.Update();
            end;
        end;
    end;

    local procedure DeleteSelectedLines();
    var
        CommWkshtLine: Record CommissionWksheetLineTigCM;
        DeleteSelectedLinesQst: Label 'Are you sure you want to delete the selected line(s)?';
    begin
        if not Confirm(DeleteSelectedLinesQst, false) then
            Error(CancelledErr);

        CurrPage.SetSelectionFilter(CommWkshtLine);
        OnDeleteCheckMatchingSet(CommWkshtLine);
        CurrPage.Update();
    end;

    local procedure InsertAdjustmentLine();
    var
        LineNo: Integer;
        MissingBatchNameErr: Label 'You must specify a Batch Name before making an adjustment.';
    begin
        if BatchName = '' then
            Error(MissingBatchNameErr);
        if FindLast() then
            LineNo := "Line No." + 10000
        else
            LineNo := 10000;
        Init();
        "Batch Name" := BatchName;
        "Line No." := LineNo;
        "Entry Type" := "Entry Type"::Adjustment;
        Insert(true);
    end;

    local procedure PostWorksheet();
    var
        CommPost: Codeunit CommissionPostTigCM;
    begin
        Clear(CommPost);
        CommPost.PostCommWorksheet(Rec);
    end;
}