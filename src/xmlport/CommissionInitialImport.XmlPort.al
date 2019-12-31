xmlport 80000 "CommissionInitialImportTigCM"
{
    FieldDelimiter = '<None>';
    FieldSeparator = '<TAB>';
    Format = VariableText;

    schema
    {
        textelement(ROOT)
        {
            tableelement(CommissionInitialImportTigCM; CommissionInitialImportTigCM)
            {
                AutoSave = false;
                XmlName = 'Item';
                textelement(salespersoncode)
                {
                    MinOccurs = Zero;
                    XmlName = 'SalespersonCode';
                }
                textelement(CustCode)
                {
                }
                textelement(pcttext)
                {
                    MinOccurs = Zero;
                    XmlName = 'PctText';
                }

                trigger OnBeforeInsertRecord();
                var
                    Pct: Decimal;
                begin
                    pcttext := CopyStr(pcttext, 1, STRLEN(pcttext) - 1);
                    Evaluate(Pct, pcttext);

                    //FIXME - seems like a hard coded values for individual implementation
                    //        should not be part of an app -> should be fixed in data
                    if (salespersoncode = 'ENCHANT-SE') or (salespersoncode = 'ENCHANT-NE') then
                        salespersoncode := 'ENCHANT';

                    CommImport.Init();
                    CommImport."Salesperson Code" := salespersoncode;
                    CommImport."Customer No." := CustCode;
                    CommImport."Comm. Rate" := Pct;
                    CommImport.Insert();
                end;
            }
        }
    }

    var
        CommImport: Record CommissionInitialImportTigCM;

    trigger OnPostXmlPort();
    var
        CommissionInitialImportMgt: Codeunit CommissionInitialImpMgtTigCM;
        CommCode: Code[20];
        CommPlanCode: Code[20];
        LastSalespersonCode: Code[20];
        LastRate: Decimal;
        DistributionMethod: Option Vendor,"External Provider",Manual;
        RecogTriggerMethod: Option Booking,Shipment,Invoice,Payment;
        PayableTriggerMethod: Option Booking,Shipment,Invoice,Payment;
        UnitType: Option " ","G/L Account",Item,Resource,"Fixed Asset","Charge (Item)",,All;
        CompleteMsg: Label 'Complete';
    begin
        //Calculate commission plan codes
        CommImport.FindSet();
        CommCode := CopyStr(CommImport."Salesperson Code" + '-' + Format(CommImport."Comm. Rate"), 1, MaxStrLen(CommCode));
        LastSalespersonCode := CommImport."Salesperson Code";
        LastRate := CommImport."Comm. Rate";
        repeat
            if not ((CommImport."Salesperson Code" = LastSalespersonCode) and
                    (CommImport."Comm. Rate" = LastRate)) then begin
                CommCode := CopyStr(CommImport."Salesperson Code" + '-' + Format(CommImport."Comm. Rate"), 1, MaxStrLen(CommCode));
            end;

            CommImport."Comm. Code" := CommCode;
            CommImport.Modify();

            LastSalespersonCode := CommImport."Salesperson Code";
            LastRate := CommImport."Comm. Rate";
        until CommImport.Next() = 0;

        //Create setups
        RecogTriggerMethod := RecogTriggerMethod::Shipment;
        PayableTriggerMethod := PayableTriggerMethod::Payment;
        DistributionMethod := DistributionMethod::Manual;
        UnitType := UnitType::Item;

        CommissionInitialImportMgt.DeleteSetupData();
        CommissionInitialImportMgt.CreateCommSetup(RecogTriggerMethod, PayableTriggerMethod);
        //CommWizardMgt.CreatePayableVendors;
        CommissionInitialImportMgt.CreateCommPlan('', UnitType::Item, '', false);
        CommissionInitialImportMgt.CreateCommPlanCalcLine(CommPlanCode, 0);
        CommissionInitialImportMgt.CreateCommPlanPayee(CommPlanCode, '', DistributionMethod, '');
        CommissionInitialImportMgt.CreateCommCustGroup('');
        CommissionInitialImportMgt.CreateCommCustSalesperson();

        Message(CompleteMsg);
    end;

    trigger OnPreXmlPort();
    begin
        CommImport.Reset();
        CommImport.DeleteAll();
    end;
}