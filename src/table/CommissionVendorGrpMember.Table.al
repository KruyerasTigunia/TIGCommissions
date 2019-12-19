table 80010 "CommissionVendorGrpMemberTigCM"
{
    Caption = 'Commission Vendor Group Member';
    DataClassification = CustomerContent;

    fields
    {
        field(10; "Commission Vendor Group Code"; Code[20])
        {
            Caption = '';
            DataClassification = CustomerContent;
            TableRelation = CommissionVendorGroupTigCM.Code;
        }
        field(20; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = Vendor."No.";
        }
    }

    keys
    {
        key(PK; "Commission Vendor Group Code", "Vendor No.")
        {
            Clustered = true;
        }
    }
}