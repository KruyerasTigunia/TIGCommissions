report 80002 "CalcCommissionFromHistTigCM"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Royalties

    ProcessingOnly = true;

    dataset
    {
        dataitem("Sales Shipment Header"; "Sales Shipment Header")
        {
            DataItemTableView = SORTING("Commission Calculated", "Posting Date");

            trigger OnAfterGetRecord();
            begin
                CreateCommEntriesFromHist.AnalyzeShipments("Sales Shipment Header");
                RemRecs -= 1;
                Window.UPDATE(1, RemRecs);
            end;

            trigger OnPreDataItem();
            begin
                SETRANGE("Commission Calculated", false);
                SETFILTER("Posting Date", '>%1', StartDate);

                if (CommSetup."Recog. Trigger Method" <> CommSetup."Recog. Trigger Method"::Shipment) and
                   (CommSetup."Payable Trigger Method" <> CommSetup."Payable Trigger Method"::Shipment)
                then
                    CurrReport.BREAK;

                RemRecs := COUNT;
                Window.OPEN(Text003, RemRecs);
            end;
        }
        dataitem("Sales Invoice Header"; "Sales Invoice Header")
        {
            DataItemTableView = SORTING("Commission Calculated", "Posting Date");

            trigger OnAfterGetRecord();
            begin
                SalesInvHeader := "Sales Invoice Header";
                CreateCommEntriesFromHist.AnalyzeInvoices(SalesInvHeader);
                RemRecs -= 1;
                Window.UPDATE(1, RemRecs);
            end;

            trigger OnPreDataItem();
            begin
                SETRANGE("Commission Calculated", false);
                SETFILTER("Posting Date", '>%1', StartDate);

                if (CommSetup."Recog. Trigger Method" <> CommSetup."Recog. Trigger Method"::Invoice) and
                   (CommSetup."Payable Trigger Method" <> CommSetup."Payable Trigger Method"::Invoice)
                then
                    CurrReport.BREAK;

                CLEAR(Window);
                RemRecs := COUNT;
                Window.OPEN(Text004, RemRecs);
            end;
        }
        dataitem("Sales Cr.Memo Header"; "Sales Cr.Memo Header")
        {
            DataItemTableView = SORTING("Commission Calculated", "Posting Date");

            trigger OnAfterGetRecord();
            begin
                CreateCommEntriesFromHist.AnalyzeCrMemos("Sales Cr.Memo Header");
                RemRecs -= 1;
                Window.UPDATE(1, RemRecs);
            end;

            trigger OnPreDataItem();
            begin
                SETRANGE("Commission Calculated", false);
                SETFILTER("Posting Date", '>%1', StartDate);

                //IF (CommSetup."Recog. Trigger Method" <> CommSetup."Recog. Trigger Method"::Invoice) AND
                //   (CommSetup."Payable Trigger Method" <> CommSetup."Payable Trigger Method"::Invoice)
                //THEN
                //  CurrReport.BREAK;

                CLEAR(Window);
                RemRecs := COUNT;
                Window.OPEN(Text005, RemRecs);
            end;
        }
        dataitem("Detailed Cust. Ledg. Entry"; "Detailed Cust. Ledg. Entry")
        {
            DataItemTableView = SORTING("Commission Calculated", "Posting Date");

            trigger OnAfterGetRecord();
            begin
                CreateCommEntriesFromHist.AnalyzePayments("Detailed Cust. Ledg. Entry");
                RemRecs -= 1;
                Window.UPDATE(1, RemRecs);
            end;

            trigger OnPreDataItem();
            begin
                SETRANGE("Commission Calculated", false);
                SETRANGE("Document Type", "Document Type"::Payment);
                SETRANGE("Entry Type", "Entry Type"::Application);
                SETRANGE("Initial Document Type", "Initial Document Type"::Invoice);
                SETFILTER("Posting Date", '>%1', StartDate);

                if CommSetup."Payable Trigger Method" <> CommSetup."Payable Trigger Method"::Payment then
                    CurrReport.BREAK;

                CLEAR(Window);
                RemRecs := COUNT;
                Window.OPEN(Text006, RemRecs);
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field(StartDate; StartDate)
                {
                    Caption = 'Initial Start Date';
                    Visible = StartDateVisible;
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage();
        begin
            StartDateVisible := FirstRunTime;
        end;
    }

    labels
    {
    }

    trigger OnInitReport();
    begin
        //If running this for the first time, let the user filter the dataset
        //to reduce initial run time
        //"sales shipment header".setrange("commission calculated",true);
        if "Sales Shipment Header".ISEMPTY and (StartDate = 0D) then
            ERROR(Text001)
        else
            FirstRunTime := true;
    end;

    trigger OnPostReport();
    begin
        //Prevent this report from seeing old data for runs after initial one
        CommSetup."Initial Data Extract Date" := StartDate + 1;
        CommSetup.MODIFY;

        CLEAR(Window);
        MESSAGE(Text002);
    end;

    trigger OnPreReport();
    begin
        CommSetup.GET;
        if not FirstRunTime then
            StartDate := CommSetup."Initial Data Extract Date"
        else
            StartDate -= 1;

        cre.DELETEALL; //xxx
        cae.DELETEALL; //xxx
        cpe.DELETEALL; //xxx
        "Sales Shipment Header".MODIFYALL("Commission Calculated", false); //xxx
        "Sales Invoice Header".MODIFYALL("Commission Calculated", false); //xxx
        "Sales Cr.Memo Header".MODIFYALL("Commission Calculated", false); //xxx
        "Detailed Cust. Ledg. Entry".MODIFYALL("Commission Calculated", false); //xxx
    end;

    var
        CommSetup: Record "Commission Setup";
        SalesInvHeader: Record "Sales Invoice Header";
        CreateCommEntriesFromHist: Codeunit CreateCommEntriesFromHistTigCM;
        StartDate: Date;
        [InDataSet]
        StartDateVisible: Boolean;
        Text001: Label 'This is the first time you are running this report.\In order to reduce the processing time please\specify an Initial Start Date.';
        Text002: Label 'Complete.';
        FirstRunTime: Boolean;
        Window: Dialog;
        RemRecs: Integer;
        Text003: Label 'Analyzing Shipments #1######';
        Text004: Label 'Analyzing Invoices #1######';
        Text005: Label 'Analyzing Credit Memos #1######';
        cre: Record "Comm. Recognition Entry";
        cae: Record "Comm. Approval Entry";
        Text006: Label 'Analyzing Payments #1######';
        cpe: Record "Comm. Payment Entry";
}

