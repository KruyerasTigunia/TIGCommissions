table 80014 "CommissionWksheetLineTigCM"
{
    Caption = 'Commission Worksheet Line';
    DataClassification = CustomerContent;

    fields
    {
        field(10; "Batch Name"; Code[20])
        {
            Caption = 'Batch name';
            DataClassification = CustomerContent;
        }
        field(20; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(25; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            DataClassification = CustomerContent;
            OptionMembers = Commission,Clawback,Advance,Adjustment;
            OptionCaption = 'Commission,Clawback,Advance,Adjustment';

            trigger OnValidate();
            var
                CommissionNotAllowedErr: Label 'Entry Type of Commission is not allowed for adjustment lines.';
            begin
                if not "System Created" then
                    if "Entry Type" = "Entry Type"::Commission then
                        Error(CommissionNotAllowedErr);
            end;
        }
        field(30; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(40; "Payout Date"; Date)
        {
            Caption = 'Payout Date';
            DataClassification = CustomerContent;
        }
        field(50; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
        }
        field(60; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser".Code;

            trigger OnValidate();
            begin
                CheckPlanExists();
            end;
        }
        field(70; "Source Document No."; Code[20])
        {
            Caption = 'Source Document No.';
            DataClassification = CustomerContent;
        }
        field(80; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(85; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
        }
        field(90; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;

            trigger OnValidate();
            begin
                if "Entry Type" <> "Entry Type"::Commission then begin
                    if Amount >= 0 then
                        Quantity := 1
                    else
                        Quantity := -1;
                end;
            end;
        }
        field(95; "Basis Amt. (Split)"; Decimal)
        {
            Caption = 'Basis Amount (Split)';
            DataClassification = CustomerContent;
            Description = 'For no split will be 100% of Comm. Approval Entry, else % thereof split';

            trigger OnValidate();
            begin
                CheckIsCommissionEntryType(CopyStr(FieldCaption("Basis Amt. (Split)"), 1, 50));
            end;
        }
        field(100; "Trigger Method"; Option)
        {
            Caption = 'Trigger Method';
            DataClassification = CustomerContent;
            OptionMembers = Booking,Shipment,Invoice,Payment,,,Credit;
            OptionCaption = 'Booking,Shipment,Invoice,Payment,,,Credit';
        }
        field(110; "Trigger Document No."; Code[20])
        {
            Caption = 'Trigger Document No.';
            DataClassification = CustomerContent;

            trigger OnValidate();
            begin
                CheckIsCommissionEntryType(CopyStr(FieldCaption("Trigger Document No."), 1, 50));
            end;
        }
        field(120; "Comm. Approval Entry No."; Integer)
        {
            Caption = 'Commission Approval entry No.';
            DataClassification = CustomerContent;
            TableRelation = CommApprovalEntryTigCM."Entry No.";

            trigger OnValidate();
            begin
                CheckIsCommissionEntryType(CopyStr(FieldCaption("Comm. Approval Entry No."), 1, 50));
            end;
        }
        field(130; "System Created"; Boolean)
        {
            Caption = 'System Created';
            DataClassification = CustomerContent;
        }
        field(140; "Commission Plan Code"; Code[20])
        {
            Caption = 'Commission Plan Code';
            DataClassification = CustomerContent;
            TableRelation = CommissionPlanTigCM.Code;

            trigger OnValidate();
            begin
                CheckPlanExists();
            end;
        }
        field(1000; "Customer Name"; Text[50])
        {
            Caption = 'Customer Name';
            FieldClass = FlowField;
            CalcFormula = Lookup (Customer.Name where("No." = field("Customer No.")));
            Editable = false;
        }
        field(1010; "Salesperson Name"; Text[50])
        {
            Caption = 'Salesperson Name';
            FieldClass = FlowField;
            CalcFormula = Lookup ("Salesperson/Purchaser".Name where(Code = field("Salesperson Code")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Batch Name", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Salesperson Code", "Customer No.")
        {
        }
    }

    var
        BypassSystemCheck: Boolean;
        CantBeModifiedErr: Label 'System Created lines cannot be modified.';
        CantBeDeletedErr: Label 'System Created lines cannot be deleted.';
        UseFunctionMsg: Label 'Use the functions available on this page instead.';

    trigger OnDelete();
    begin
        if not BypassSystemCheck then begin
            if "System Created" then
                Error(CantBeDeletedErr + ' ' + UseFunctionMsg);
        end;
    end;

    trigger OnModify();
    begin
        if not BypassSystemCheck then begin
            if "System Created" then
                Error(CantBeModifiedErr + ' ' + UseFunctionMsg);
        end;
    end;

    procedure OnDeleteCheckMatchingSet(var CommWkshtLine: Record CommissionWksheetLineTigCM);
    var
        CommWkshtLine2: Record CommissionWksheetLineTigCM;
        DeleteAllApprEntriesQst: Label 'You cannot delete a line and leave other lines related to the same Comm. Approval Entry record.\All records in the set must be deleted together. Do you want to continue?';
        CompleteMsg: Label 'Complete.';
        DeleteCancelledErr: Label 'Delete cancelled.';
    begin
        with CommWkshtLine do begin
            if not FindSet() then
                exit;

            repeat
                //Precheck for related lines and mark for deletion
                CommWkshtLine2.SetCurrentKey("Comm. Approval Entry No.");
                CommWkshtLine2.SetRange("Comm. Approval Entry No.", "Comm. Approval Entry No.");
                if CommWkshtLine2.Count() > 1 then
                    if not Confirm(DeleteAllApprEntriesQst) then
                        Error(DeleteCancelledErr);
                CommWkshtLine2.FindSet();
                repeat
                    CommWkshtLine2.Mark(true);
                until CommWkshtLine2.Next() = 0;
            until Next() = 0;

            //Actual deletion
            CommWkshtLine2.SetRange("Comm. Approval Entry No.");
            CommWkshtLine2.MarkedOnly(true);
            if CommWkshtLine2.FindSet() then begin
                repeat
                    CommWkshtLine2.SetBypassSystemCheck(true);
                    CommWkshtLine2.DELETE(true);
                    CommWkshtLine2.SetBypassSystemCheck(false);
                until CommWkshtLine2.Next() = 0;
            end;
            Message(CompleteMsg);
        end;
    end;

    procedure SetBypassSystemCheck(NewBypassSystemCheck: Boolean);
    begin
        BypassSystemCheck := NewBypassSystemCheck;
    end;

    local procedure CheckIsCommissionEntryType(ChangedField: Text[50]);
    var
        ChangeErr: Label 'You cannot specify or change %1 on adjustment lines.';
    begin
        if "Entry Type" <> "Entry Type"::Commission then
            Error(StrSubstNo(ChangeErr, ChangedField));
    end;

    local procedure CheckPlanExists();
    var
        CommPlanPayee: Record CommissionPlanPayeeTigCM;
    begin
        if CurrFieldNo = 0 then
            exit;
        if ("Commission Plan Code" <> '') and ("Salesperson Code" <> '') then
            CommPlanPayee.Get("Commission Plan Code", "Salesperson Code");
    end;
}

