tableextension 80002 "SalesCrMemoHeaderTigCM" extends "Sales Cr.Memo Header"
{
    fields
    {
        field(80000; CommissionCalculatedTigCM; Boolean)
        {
            Caption = 'Commission Calculated';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key80000; CommissionCalculatedTigCM) { }
    }
}