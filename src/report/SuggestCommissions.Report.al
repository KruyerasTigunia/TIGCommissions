report 80000 "SuggestCommissionsTigCM"
{
    Caption = 'Suggest Commissions';
    ApplicationArea = All;
    UsageCategory = Tasks;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Customer; Customer)
        {
            RequestFilterFields = "No.";

            trigger OnPreDataItem();
            begin
                //Filtering only
                CurrReport.Break();
            end;
        }
        dataitem("Salesperson/Purchaser"; "Salesperson/Purchaser")
        {
            RequestFilterFields = "Code";

            trigger OnPreDataItem();
            begin
                //Filtering only
                CurrReport.Break();
            end;
        }
        dataitem("Comm. Approval Entry"; CommApprovalEntryTigCM)
        {
            DataItemTableView = sorting("Customer No.", Open) where(Open = const(true));

            trigger OnPreDataItem();
            begin
                Customer.CopyFilter("No.", "Customer No.");
                SuggestCommissions.InitCalculation(BatchName, PostingDate, PayoutDate);
                SuggestCommissions.SetSalespersonFilter("Salesperson/Purchaser");
            end;

            trigger OnAfterGetRecord();
            begin
                //Factor in pending worksheet lines and pending payment entries
                CalcFields("Basis Qty. (Wksht.)", "Qty. Paid");
                //Allow for credit memos
                if Abs("Basis Qty. Approved") <= Abs(("Basis Qty. (Wksht.)" + "Qty. Paid")) then
                    CurrReport.Skip();

                SuggestCommissions.CalculateCommission("Comm. Approval Entry", BatchName);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                field(PostingDateLbl; PostingDate)
                {
                    Caption = 'Posting Date';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Posting Date';
                }
                field(PayoutDateLbl; PayoutDate)
                {
                    Caption = 'Payout Date';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Payout Date';
                }
            }
        }
    }

    trigger OnPostReport();
    begin
        Message(CompleteMsg);
    end;

    trigger OnPreReport();
    begin
        if BatchName = '' then
            Error(BatchNameErr);
        if PostingDate = 0D then
            Error(PostingDateErr);
        if PayoutDate = 0D then
            Error(PayoutDateErr);
    end;

    var
        SuggestCommissions: Codeunit CalculateCommissionTigCM;
        BatchName: Code[20];
        PostingDate: Date;
        PayoutDate: Date;
        BatchNameErr: Label 'You must specify a Batch Name';
        PostingDateErr: Label 'You must specify Posting Date';
        PayoutDateErr: Label 'You must specify Payout Date';
        CompleteMsg: Label 'Complete';

    procedure SetBatch(NewBatchName: Code[20]);
    begin
        BatchName := NewBatchName;
    end;
}