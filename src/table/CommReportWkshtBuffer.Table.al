table 80017 "CommReportWkshtBufferTigCM"
{
    Caption = 'Commission Report Worksheet Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(5; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = CustomerContent;
        }
        field(10; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(20; "Batch Name"; Code[20])
        {
            Caption = 'Batch Name';
            DataClassification = CustomerContent;
        }
        field(30; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
        }
        field(40; "Salesperson Name"; Text[50])
        {
            Caption = 'Salesperson Name';
            DataClassification = CustomerContent;
        }
        field(50; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            DataClassification = CustomerContent;
            OptionMembers = Commission,Clawback,Advance,Adjustment;
            OptionCaption = 'Commission,Clawback,Advance,Adjustment';
        }
        field(60; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
        }
        field(70; "Customer Name"; Text[50])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
        }
        field(80; "Document Type"; Option)
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order",,Adjustment;
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order,,Adjustment';
        }
        field(90; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(110; "Basis Amt. Recognized"; Decimal)
        {
            Caption = 'Basis Amount Recognized';
            DataClassification = CustomerContent;
        }
        field(130; "Basis Amt. Approved to Pay"; Decimal)
        {
            Caption = 'Basis Amt. Approved to Pay';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(140; "Comm. Amt. Paid"; Decimal)
        {
            Caption = 'Commission Amount Paid';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(150; "Approved Date"; Date)
        {
            Caption = 'Approved Date';
            DataClassification = CustomerContent;
        }
        field(160; "Run Date-Time"; DateTime)
        {
            Caption = 'Run Datetime';
            DataClassification = CustomerContent;
        }
        field(170; "Comm. Amt. Approved"; Decimal)
        {
            Caption = 'Commission Amount Approved';
            DataClassification = CustomerContent;
        }
        field(180; "External Document No."; Code[20])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
        }
        field(190; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(200; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
            DataClassification = CustomerContent;
        }
        field(210; "Posted Doc. No."; Code[20])
        {
            Caption = 'Posted Document No.';
            DataClassification = CustomerContent;
        }
        field(220; "Trigger Doc. No."; Code[20])
        {
            Caption = 'Trigger Document No.';
            DataClassification = CustomerContent;
        }
        field(1000; Level; Option)
        {
            Caption = 'Level';
            DataClassification = CustomerContent;
            OptionMembers = Detail,Summary;
            OptionCaption = 'Detail,Summary';
        }
    }

    keys
    {
        key(PK; "User ID", "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Batch Name", "Salesperson Code")
        {
        }
        key(Key3; "Salesperson Code", "Customer No.", "Document Type", "Document No.", Level)
        {
        }
    }
}