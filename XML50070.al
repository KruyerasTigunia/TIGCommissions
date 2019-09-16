xmlport 50070 "Comm. Initial Import"
{
    // version TIGCOMMCust

    FieldDelimiter = '<None>';
    FieldSeparator = '<TAB>';
    Format = VariableText;

    schema
    {
        textelement(ROOT)
        {
            tableelement("Comm. Initial Import";"Comm. Initial Import")
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
                begin
                    pcttext := COPYSTR(pcttext,1,STRLEN(pcttext)-1);
                    EVALUATE(Pct,pcttext);
                    //IF Pct = 0 THEN
                    //  EXIT;

                    //Combine accounts
                    if (salespersoncode = 'ENCHANT-SE') or (salespersoncode = 'ENCHANT-NE') then
                      salespersoncode := 'ENCHANT';

                    CommImport.INIT;
                    CommImport."Salesperson Code" := salespersoncode;
                    CommImport."Customer No." := CustCode;
                    CommImport."Comm. Rate" := Pct;
                    CommImport.INSERT;
                    exit;
                end;
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    trigger OnPostXmlPort();
    begin
        //Calculate commission plan codes
        CommImport.FINDSET;
        CommCode := CommImport."Salesperson Code" + '-' + FORMAT(CommImport."Comm. Rate");
        LastSalespersonCode := CommImport."Salesperson Code";
        LastRate := CommImport."Comm. Rate";
        repeat
          if CommImport."Salesperson Code" <> LastSalespersonCode then begin
            CommCode := CommImport."Salesperson Code" + '-' + FORMAT(CommImport."Comm. Rate");
          end;

          if CommImport."Comm. Rate" <> LastRate then begin
            CommCode := CommImport."Salesperson Code" + '-' + FORMAT(CommImport."Comm. Rate");
          end;

          CommImport."Comm. Code" := CommCode;
          CommImport.MODIFY;

          LastSalespersonCode := CommImport."Salesperson Code";
          LastRate := CommImport."Comm. Rate";
        until CommImport.NEXT = 0;

        //Create setups
        RecogTriggerMethod := RecogTriggerMethod::Shipment;
        PayableTriggerMethod := PayableTriggerMethod::Payment;
        DistributionMethod := DistributionMethod::Manual;
        UnitType := UnitType::Item;

        CommWizardMgt.DeleteSetupData;
        CommWizardMgt.CreateCommSetup(RecogTriggerMethod,PayableTriggerMethod);
        //CommWizardMgt.CreatePayableVendors;
        CommWizardMgt.CreateCommPlan('',UnitType::Item,'',false);
        CommWizardMgt.CreateCommPlanCalcLine(CommPlanCode,0);
        CommWizardMgt.CreateCommPlanPayee(CommPlanCode,'',DistributionMethod,'');
        CommWizardMgt.CreateCommCustGroup('');
        CommWizardMgt.CreateCommCustSalesperson;

        MESSAGE('Complete');
    end;

    trigger OnPreXmlPort();
    begin
        CommImport.DELETEALL;
    end;

    var
        CommImport : Record "Comm. Initial Import";
        CommWizardMgt : Codeunit "Comm. Initial Import Mgt.";
        Pct : Decimal;
        CommCode : Code[20];
        LastSalespersonCode : Code[20];
        LastRate : Decimal;
        Text001 : Label 'The Setup Wizard has already been run.';
        Text002 : Label 'Action Complete.';
        Text003 : Label 'You must specify a Global Commission Rate.';
        Text004 : Label 'Commission Setup not complete.';
        Text005 : Label 'You must perform this step manually.\%1\Is this step completed?';
        Text006 : Label 'Please return to this step and confirm when completed.';
        Text007 : Label 'You must complete the prior step first.';
        Text008 : Label 'Feature not enabled.';
        Text009 : Label 'Setups Complete.';
        Text010 : Label 'You must specify an Expense Account for invoice lines.';
        DistributionMethod : Option Vendor,"External Provider",Manual;
        RecogTriggerMethod : Option Booking,Shipment,Invoice,Payment;
        PayableTriggerMethod : Option Booking,Shipment,Invoice,Payment;
        CommPlanCode : Code[20];
        UnitType : Option " ","G/L Account",Item,Resource,"Fixed Asset","Charge (Item)",,All;
}

