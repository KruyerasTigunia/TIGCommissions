table 80014 "CommissionWksheetLineTigCM"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions


    fields
    {
        field(10; "Batch Name"; Code[20])
        {
        }
        field(20; "Line No."; Integer)
        {
        }
        field(25; "Entry Type"; Option)
        {
            OptionMembers = Commission,Clawback,Advance,Adjustment;

            trigger OnValidate();
            begin
                if not "System Created" then
                    if "Entry Type" = "Entry Type"::Commission then
                        ERROR(Text007);
            end;
        }
        field(30; "Posting Date"; Date)
        {
        }
        field(40; "Payout Date"; Date)
        {
        }
        field(50; "Customer No."; Code[20])
        {
            TableRelation = Customer;
        }
        field(60; "Salesperson Code"; Code[20])
        {
            TableRelation = "Salesperson/Purchaser";

            trigger OnValidate();
            begin
                CheckPlanExists;
            end;
        }
        field(70; "Source Document No."; Code[20])
        {
        }
        field(80; Description; Text[50])
        {
        }
        field(85; Quantity; Decimal)
        {
            DecimalPlaces = 0 : 2;
        }
        field(90; Amount; Decimal)
        {

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
            Description = 'For no split will be 100% of Comm. Approval Entry, else % thereof split';

            trigger OnValidate();
            begin
                CheckIsCommissionEntryType(FIELDCAPTION("Basis Amt. (Split)"));
            end;
        }
        field(100; "Trigger Method"; Option)
        {
            OptionMembers = Booking,Shipment,Invoice,Payment,,,Credit;
        }
        field(110; "Trigger Document No."; Code[20])
        {

            trigger OnValidate();
            begin
                CheckIsCommissionEntryType(FIELDCAPTION("Trigger Document No."));
            end;
        }
        field(120; "Comm. Approval Entry No."; Integer)
        {
            TableRelation = CommApprovalEntryTigCM;

            trigger OnValidate();
            begin
                CheckIsCommissionEntryType(FIELDCAPTION("Comm. Approval Entry No."));
            end;
        }
        field(130; "System Created"; Boolean)
        {
        }
        field(140; "Commission Plan Code"; Code[20])
        {
            TableRelation = CommissionPlanTigCM;

            trigger OnValidate();
            begin
                CheckPlanExists;
            end;
        }
        field(1000; "Customer Name"; Text[50])
        {
            CalcFormula = Lookup (Customer.Name WHERE("No." = FIELD("Customer No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(1010; "Salesperson Name"; Text[50])
        {
            CalcFormula = Lookup ("Salesperson/Purchaser".Name WHERE(Code = FIELD("Salesperson Code")));
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Batch Name", "Line No.")
        {
        }
        key(Key2; "Salesperson Code", "Customer No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete();
    begin
        if not BypassSystemCheck then begin
            if "System Created" then
                ERROR(Text002 + ' ' + Text003);
        end;
    end;

    trigger OnModify();
    begin
        if not BypassSystemCheck then begin
            if "System Created" then
                ERROR(Text001 + ' ' + Text003);
        end;
    end;

    var
        Text001: Label 'System Created lines cannot be modified.';
        Text002: Label 'System Created lines cannot be deleted.';
        Text003: Label 'Use the functions available on this page instead.';
        Text004: Label 'You cannot delete a line and leave other lines related to the same Comm. Approval Entry record.\All records in the set must be deleted together. Do you want to continue?';
        Text005: Label 'Complete.';
        Text006: Label 'Delete cancelled.';
        CommPlanPayee: Record CommissionPlanPayeeTigCM;
        BypassSystemCheck: Boolean;
        Text007: Label 'Entry Type of Commission is not allowed for adjustment lines.';
        Text008: Label 'You cannot specify or change %1 on adjustment lines.';

    procedure OnDeleteCheckMatchingSet(var CommWkshtLine: Record CommissionWksheetLineTigCM);
    var
        CommWkshtLine2: Record CommissionWksheetLineTigCM;
    begin
        with CommWkshtLine do begin
            if not FINDSET then
                exit;

            repeat
                //Precheck for related lines and mark for deletion
                CommWkshtLine2.SETCURRENTKEY("Comm. Approval Entry No.");
                CommWkshtLine2.SETRANGE("Comm. Approval Entry No.", "Comm. Approval Entry No.");
                if CommWkshtLine2.COUNT > 1 then
                    if not CONFIRM(Text004) then
                        ERROR(Text006);
                CommWkshtLine2.FIND('-');
                repeat
                    CommWkshtLine2.MARK(true);
                until CommWkshtLine2.NEXT = 0;
            until NEXT = 0;

            //Actual deletion
            CommWkshtLine2.SETRANGE("Comm. Approval Entry No.");
            CommWkshtLine2.MARKEDONLY(true);
            if CommWkshtLine2.FIND('-') then begin
                repeat
                    CommWkshtLine2.SetBypassSystemCheck(true);
                    CommWkshtLine2.DELETE(true);
                    CommWkshtLine2.SetBypassSystemCheck(false);
                until CommWkshtLine2.NEXT = 0;
            end;
            MESSAGE(Text005);
        end;
    end;

    procedure SetBypassSystemCheck(NewBypassSystemCheck: Boolean);
    begin
        BypassSystemCheck := NewBypassSystemCheck;
    end;

    local procedure CheckIsCommissionEntryType(ChangedField: Text[50]);
    begin
        if "Entry Type" <> "Entry Type"::Commission then
            ERROR(STRSUBSTNO(Text008, ChangedField));
    end;

    local procedure CheckPlanExists();
    begin
        if CurrFieldNo = 0 then
            exit;
        if ("Commission Plan Code" <> '') and ("Salesperson Code" <> '') then
            CommPlanPayee.GET("Commission Plan Code", "Salesperson Code");
    end;
}

