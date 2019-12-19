table 80007 "CommCustomerGroupMemberTigCM"
{
    Caption = 'Commission Customer Group Member';
    DataClassification = CustomerContent;
    LookupPageId = CommissionCustGrpMembersTigCM;

    fields
    {
        field(10; "Group Code"; Code[20])
        {
            Caption = 'Group Code';
            DataClassification = CustomerContent;
            TableRelation = CommissionCustomerGroupTigCM.Code;
        }
        field(20; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
        }
        field(200; "Customer Name"; Text[50])
        {
            Caption = 'Customer Name';
            FieldClass = FlowField;
            CalcFormula = Lookup (Customer.Name WHERE("No." = FIELD("Customer No.")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Group Code", "Customer No.")
        {
            Clustered = true;
        }
        key(Key2; "Customer No.")
        {
        }
    }
}