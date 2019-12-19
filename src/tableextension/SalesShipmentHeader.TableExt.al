tableextension 80000 "SalesShipmentHeaderTigCM" extends "Sales Shipment Header"
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