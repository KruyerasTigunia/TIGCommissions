report 80000 "SuggestCommissionsTigCM"
{
    // version TIGCOMM1.0

    ProcessingOnly = true;

    dataset
    {
        dataitem(Customer; Customer)
        {
            RequestFilterFields = "No.";

            trigger OnPreDataItem();
            begin
                //Filtering only
                CurrReport.BREAK;
            end;
        }
        dataitem("Salesperson/Purchaser"; "Salesperson/Purchaser")
        {
            RequestFilterFields = "Code";

            trigger OnPreDataItem();
            begin
                //Filtering only
                CurrReport.BREAK;
            end;
        }
        dataitem("Comm. Approval Entry"; "Comm. Approval Entry")
        {
            DataItemTableView = SORTING("Customer No.", Open) WHERE(Open = CONST(true));

            trigger OnAfterGetRecord();
            begin
                //Factor in pending worksheet lines and pending payment entries
                CALCFIELDS("Basis Qty. (Wksht.)", "Qty. Paid");
                //Allow for credit memos
                if ABS("Basis Qty. Approved") <= ABS(("Basis Qty. (Wksht.)" + "Qty. Paid")) then
                    CurrReport.SKIP;

                SuggestCommissions.CalculateCommission("Comm. Approval Entry", BatchName);
            end;

            trigger OnPreDataItem();
            begin
                Customer.COPYFILTER("No.", "Customer No.");
                SuggestCommissions.InitCalculation(BatchName, PostingDate, PayoutDate);
                SuggestCommissions.SetSalespersonFilter("Salesperson/Purchaser");
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
                field(PostingDate; PostingDate)
                {
                    Caption = 'Posting Date';
                }
                field(PayoutDate; PayoutDate)
                {
                    Caption = 'Payout Date';
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPostReport();
    begin
        MESSAGE(Text004);
    end;

    trigger OnPreReport();
    begin
        if BatchName = '' then
            ERROR(Text001);
        if PostingDate = 0D then
            ERROR(Text002);
        if PayoutDate = 0D then
            ERROR(Text003);
    end;

    var
        SuggestCommissions: Codeunit CalculateCommissionTigCM;
        BatchName: Code[20];
        Text001: Label 'You must specify a Batch Name';
        PostingDate: Date;
        PayoutDate: Date;
        Text002: Label 'You must specify Posting Date';
        Text003: Label 'You must specify Payout Date';
        Text004: Label 'Complete';

    procedure SetBatch(NewBatchName: Code[20]);
    begin
        BatchName := NewBatchName;
    end;
}

