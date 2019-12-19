tableextension 80001 "SalesInvoiceHeaderTigCM" extends "Sales Invoice Header"
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