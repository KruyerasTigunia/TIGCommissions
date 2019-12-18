table 80016 "Comm. Approval Entry"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions

    DrillDownPageID = "Comm. Approval Entries";
    LookupPageID = "Comm. Approval Entries";

    fields
    {
        field(10;"Entry No.";Integer)
        {
        }
        field(15;"Entry Type";Option)
        {
            OptionMembers = Commission,Clawback,Advance,Adjustment;
        }
        field(19;"Det. Cust. Ledger Entry No.";Integer)
        {
            TableRelation = "Detailed Cust. Ledg. Entry";
        }
        field(20;"Comm. Recog. Entry No.";Integer)
        {
            TableRelation = "Comm. Recognition Entry";
        }
        field(25;"Comm. Ledger Entry No.";Integer)
        {
            Description = 'DEPR';
            TableRelation = "Commission Setup Summary";
        }
        field(28;"Document Type";Option)
        {
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order",,Adjustment;
        }
        field(30;"Document No.";Code[20])
        {
        }
        field(35;"Document Line No.";Integer)
        {
        }
        field(40;"Customer No.";Code[20])
        {
            TableRelation = Customer;
        }
        field(50;"Unit Type";Option)
        {
            OptionMembers = ,"G/L Account",Item,Resource;
        }
        field(60;"Unit No.";Code[20])
        {
        }
        field(70;"Basis Qty. Approved";Decimal)
        {
            DecimalPlaces = 0:2;
        }
        field(90;"Qty. Paid";Decimal)
        {
            CalcFormula = Min("Comm. Payment Entry".Quantity WHERE ("Comm. Appr. Entry No."=FIELD("Entry No.")));
            DecimalPlaces = 0:2;
            FieldClass = FlowField;
        }
        field(100;"Qty. Remaining to Pay";Decimal)
        {
            DecimalPlaces = 0:2;
            Description = 'DEPR';
        }
        field(110;"Basis Amt. Approved";Decimal)
        {
        }
        field(120;"Comm. Amt. Paid";Decimal)
        {
            CalcFormula = Sum("Comm. Payment Entry".Amount WHERE ("Comm. Appr. Entry No."=FIELD("Entry No.")));
            FieldClass = FlowField;
        }
        field(130;"Amt. Remaining to Pay";Decimal)
        {
            Description = 'DEPR';
        }
        field(140;Open;Boolean)
        {
        }
        field(150;"Commission Plan Code";Code[20])
        {
            TableRelation = "Commission Plan";
        }
        field(160;"Trigger Method";Option)
        {
            OptionMembers = Booking,Shipment,Invoice,Payment,,,Credit;
        }
        field(170;"Trigger Document No.";Code[20])
        {
        }
        field(180;"Trigger Posting Date";Date)
        {
        }
        field(190;"Released to Pay Date";Date)
        {
        }
        field(200;"Released to Pay By";Code[50])
        {
            TableRelation = User."User Name";
        }
        field(210;"Basis Amt. (Wksht.)";Decimal)
        {
            CalcFormula = Sum("Comm. Worksheet Line"."Basis Amt. (Split)" WHERE ("Comm. Approval Entry No."=FIELD("Entry No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(220;"Basis Qty. (Wksht.)";Decimal)
        {
            CalcFormula = Sum("Comm. Worksheet Line".Quantity WHERE ("Comm. Approval Entry No."=FIELD("Entry No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(250;"External Document No.";Code[20])
        {
        }
        field(260;Description;Text[50])
        {
        }
        field(270;"Description 2";Text[50])
        {
        }
        field(280;"Reason Code";Code[20])
        {
        }
        field(290;"Posted Doc. No.";Code[20])
        {
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Comm. Recog. Entry No.")
        {
            SumIndexFields = "Basis Qty. Approved","Qty. Remaining to Pay","Basis Amt. Approved","Amt. Remaining to Pay";
        }
        key(Key3;"Comm. Ledger Entry No.")
        {
            SumIndexFields = "Basis Amt. Approved","Amt. Remaining to Pay";
        }
        key(Key4;"Customer No.","Document Type","Document No.","Document Line No.")
        {
        }
        key(Key5;"Document Type","Document No.","Document Line No.")
        {
            SumIndexFields = "Basis Qty. Approved","Qty. Remaining to Pay","Basis Amt. Approved","Amt. Remaining to Pay";
        }
        key(Key6;"Customer No.",Open)
        {
        }
        key(Key7;"Customer No.","Trigger Posting Date","Document Type","Document No.")
        {
            SumIndexFields = "Basis Qty. Approved","Qty. Remaining to Pay","Basis Amt. Approved","Amt. Remaining to Pay";
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown;"Entry No.","Entry Type","Document No.")
        {
        }
    }
}

