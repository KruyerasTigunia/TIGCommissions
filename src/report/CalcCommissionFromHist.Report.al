report 80002 "CalcCommissionFromHistTigCM"
{
    Caption = 'Calculate Commission from History';
    ApplicationArea = All;
    UsageCategory = Tasks;
    ProcessingOnly = true;

    dataset
    {
        dataitem("Sales Shipment Header"; "Sales Shipment Header")
        {
            DataItemTableView = sorting(CommissionCalculatedTigCM, "Posting Date");

            trigger OnAfterGetRecord();
            begin
                CreateCommEntriesFromHist.AnalyzeShipments("Sales Shipment Header");
                RemRecs -= 1;
                Window.Update(1, RemRecs);
            end;

            trigger OnPreDataItem();
            begin
                SetRange(CommissionCalculatedTigCM, false);
                SetFilter("Posting Date", '>%1', TheStartDate);

                if (CommSetup."Recog. Trigger Method" <> CommSetup."Recog. Trigger Method"::Shipment) and
                   (CommSetup."Payable Trigger Method" <> CommSetup."Payable Trigger Method"::Shipment)
                then
                    CurrReport.Break();

                RemRecs := Count();
                Window.Open(AnalyzingShipmentsLbl, RemRecs);
            end;
        }
        dataitem("Sales Invoice Header"; "Sales Invoice Header")
        {
            DataItemTableView = sorting(CommissionCalculatedTigCM, "Posting Date");

            trigger OnAfterGetRecord();
            begin
                SalesInvHeader := "Sales Invoice Header";
                CreateCommEntriesFromHist.AnalyzeInvoices(SalesInvHeader);
                RemRecs -= 1;
                Window.Update(1, RemRecs);
            end;

            trigger OnPreDataItem();
            begin
                SetRange(CommissionCalculatedTigCM, false);
                SetFilter("Posting Date", '>%1', TheStartDate);

                if (CommSetup."Recog. Trigger Method" <> CommSetup."Recog. Trigger Method"::Invoice) and
                   (CommSetup."Payable Trigger Method" <> CommSetup."Payable Trigger Method"::Invoice)
                then
                    CurrReport.Break();

                CLEAR(Window);
                RemRecs := Count();
                Window.Open(AnalyzingInvoicesLbl, RemRecs);
            end;
        }
        dataitem("Sales Cr.Memo Header"; "Sales Cr.Memo Header")
        {
            DataItemTableView = sorting(CommissionCalculatedTigCM, "Posting Date");

            trigger OnAfterGetRecord();
            begin
                CreateCommEntriesFromHist.AnalyzeCrMemos("Sales Cr.Memo Header");
                RemRecs -= 1;
                Window.Update(1, RemRecs);
            end;

            trigger OnPreDataItem();
            begin
                SetRange(CommissionCalculatedTigCM, false);
                SetFilter("Posting Date", '>%1', TheStartDate);

                //if (CommSetup."Recog. Trigger Method" <> CommSetup."Recog. Trigger Method"::Invoice) and
                //   (CommSetup."Payable Trigger Method" <> CommSetup."Payable Trigger Method"::Invoice)
                //then
                //  CurrReport.Break;

                Clear(Window);
                RemRecs := Count();
                Window.Open(AnalyzingCMsLbl, RemRecs);
            end;
        }
        dataitem("Detailed Cust. Ledg. Entry"; "Detailed Cust. Ledg. Entry")
        {
            DataItemTableView = sorting(CommissionCalculatedTigCM, "Posting Date");

            trigger OnAfterGetRecord();
            begin
                CreateCommEntriesFromHist.AnalyzePayments("Detailed Cust. Ledg. Entry");
                RemRecs -= 1;
                Window.Update(1, RemRecs);
            end;

            trigger OnPreDataItem();
            begin
                SetRange(CommissionCalculatedTigCM, false);
                SetRange("Document Type", "Document Type"::Payment);
                SetRange("Entry Type", "Entry Type"::Application);
                SetRange("Initial Document Type", "Initial Document Type"::Invoice);
                SetFilter("Posting Date", '>%1', TheStartDate);

                if CommSetup."Payable Trigger Method" <> CommSetup."Payable Trigger Method"::Payment then
                    CurrReport.Break();

                Clear(Window);
                RemRecs := Count();
                Window.Open(AnalyzingPaymentsLbl, RemRecs);
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                field(StartDate; TheStartDate)
                {
                    Caption = 'Initial Start Date';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Initial Start Date';
                    Visible = StartDateVisible;
                }
            }
        }

        trigger OnOpenPage();
        begin
            StartDateVisible := FirstRunTime;
        end;
    }

    trigger OnInitReport();
    begin
        //If running this for the first time, let the user filter the dataset
        //to reduce initial run time
        //"sales shipment header".setrange("commission calculated",true);
        if "Sales Shipment Header".IsEmpty() and (TheStartDate = 0D) then
            Error(InitialStartDateErr)
        else
            FirstRunTime := true;
    end;

    trigger OnPostReport();
    begin
        //Prevent this report from seeing old data for runs after initial one
        CommSetup."Initial Data Extract Date" := TheStartDate + 1;
        CommSetup.Modify();

        Clear(Window);
        Message(CompleteMsg);
    end;

    trigger OnPreReport();
    begin
        CommSetup.Get();
        if not FirstRunTime then
            TheStartDate := CommSetup."Initial Data Extract Date"
        else
            TheStartDate -= 1;

        cre.DeleteAll(); //xxx
        cae.DeleteAll(); //xxx
        cpe.DeleteAll(); //xxx
        "Sales Shipment Header".ModifyAll(CommissionCalculatedTigCM, false); //xxx
        "Sales Invoice Header".ModifyAll(CommissionCalculatedTigCM, false); //xxx
        "Sales Cr.Memo Header".ModifyAll(CommissionCalculatedTigCM, false); //xxx
        "Detailed Cust. Ledg. Entry".ModifyAll(CommissionCalculatedTigCM, false); //xxx
    end;

    var
        CommSetup: Record CommissionSetupTigCM;
        SalesInvHeader: Record "Sales Invoice Header";
        cre: Record CommRecognitionEntryTigCM;
        cpe: Record CommissionPaymentEntryTigCM;
        cae: Record CommApprovalEntryTigCM;
        CreateCommEntriesFromHist: Codeunit CreateCommEntriesFromHistTigCM;
        Window: Dialog;
        TheStartDate: Date;
        [InDataSet]
        StartDateVisible: Boolean;
        FirstRunTime: Boolean;
        RemRecs: Integer;
        InitialStartDateErr: Label 'This is the first time you are running this report.\In order to reduce the processing time please\specify an Initial Start Date.';
        CompleteMsg: Label 'Complete.';
        AnalyzingShipmentsLbl: Label 'Analyzing Shipments #1######';
        AnalyzingInvoicesLbl: Label 'Analyzing Invoices #1######';
        AnalyzingCMsLbl: Label 'Analyzing Credit Memos #1######';
        AnalyzingPaymentsLbl: Label 'Analyzing Payments #1######';
}