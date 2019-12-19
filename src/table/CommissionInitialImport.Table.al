table 50045 "CommissionInitialImportTigCM"
{
    Caption = 'Commission Initial Import';
    DataClassification = CustomerContent;

    fields
    {
        field(10; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser".Code;
        }
        field(20; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
        }
        field(30; "Comm. Rate"; Decimal)
        {
            Caption = 'Commission Rate';
            DataClassification = CustomerContent;
        }
        field(50; "Comm. Code"; Code[20])
        {
            Caption = 'Commission Code';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Salesperson Code", "Comm. Rate", "Customer No.")
        {
            Clustered = true;
        }
    }
}