tableextension 80003 "DetailedCustLedgEntryTigCM" extends "Detailed Cust. Ledg. Entry"
{
    fields
    {
        field(80000; CommissionCalculatedTigCM; Boolean)
        {
            Caption = 'Commission Calculated';
            DataClassification = CustomerContent;
        }
    }
}