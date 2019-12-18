page 80022 "Comm. Setup Wizard"
{
    // version TIGCOMM1.1

    // TIGCOMM1.0 Commissions

    Caption = 'Commission Setup Wizard';
    DeleteAllowed = false;
    InsertAllowed = false;
    SaveValues = true;

    layout
    {
        area(content)
        {
            group(Instructions)
            {
                InstructionalText = 'Answer all questions. Click Suggest Actions. Review actions at bottom of page. Click Carry out Action Step for each action to create setups. Hover mouse over fields for more information if available. Be sure to re-run Suggest Actions if you make additional changes.';
            }
            group(GlobalSettings)
            {
                Caption = 'Global Settings';
                field(CommissionModel;CommissionModel)
                {
                    Caption = 'Commission Model';

                    trigger OnValidate();
                    begin
                        if CommissionModel = CommissionModel::"One rate for all" then
                          GlobalRateEditable := true
                        else begin
                          GlobalCommRate := 0;
                          GlobalRateEditable := false;
                        end;
                    end;
                }
                field(GlobalCommRate;GlobalCommRate)
                {
                    Caption = 'Global Commission Rate';
                    Editable = GlobalRateEditable;
                }
                field(DistributionMethod;DistributionMethod)
                {
                    Caption = 'How are commissions paid';

                    trigger OnValidate();
                    begin
                        if DistributionMethod = DistributionMethod::"External Provider" then
                          ERROR(Text008);
                    end;
                }
                field(CreatePayableVendors;CreatePayableVendors)
                {
                    Caption = 'Create Payable Vendor per salesperson';
                }
                field(DistributionAccountNo;DistributionAccountNo)
                {
                    Caption = 'Expense Account for vendor invoice lines';
                    LookupPageID = "G/L Account List";
                    TableRelation = "G/L Account"."No.";
                }
            }
            group(Salespeople)
            {
                Caption = 'Managers and Commission Splits';
                field(PayManagers;PayManagers)
                {
                    Caption = 'Pay Managers';

                    trigger OnValidate();
                    begin
                        if PayManagers = PayManagers::Yes then
                          MgrOptionsEditable := true
                        else begin
                          MgrSplitMgr := MgrSplitMgr::No;
                          RepSplitMgr := RepSplitMgr::No;
                          MgrOptionsEditable := false;
                        end;
                    end;
                }
                field(RepSplit;RepSplit)
                {
                    Caption = 'Do salespeople split commissions with other salespeople';
                }
                field("<RepSplitMgr>";RepSplitMgr)
                {
                    Caption = 'Do salespeople split commissions with managers';
                    Editable = MgrOptionsEditable;
                    ToolTip = 'If manager commissions are paid independently from salespeople, this should be NO';
                }
                field(MgrSplitMgr;MgrSplitMgr)
                {
                    Caption = 'Do managers split commissions with other managers';
                    Editable = MgrOptionsEditable;
                }
            }
            part(RecommendedActions;"Comm. Wizard Steps")
            {
                Caption = 'Recommended Actions:';
                Visible = ActionsVisible;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Suggest Actions")
            {
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction();
                begin
                    SuggestActions;
                end;
            }
            action("Carry Out Action Step")
            {
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction();
                begin
                    CarryoutAction;
                end;
            }
        }
    }

    trigger OnOpenPage();
    begin
        ActionsVisible := CommWizardStep.COUNT > 0;
        GlobalRateEditable := CommissionModel = CommissionModel::"One rate for all";
        MgrOptionsEditable := PayManagers = PayManagers::Yes;
    end;

    var
        CommSetup : Record "Commission Setup";
        Salesperson : Record "Salesperson/Purchaser";
        CommWizardStep : Record "Comm. Wizard Step";
        CommWizardStep2 : Record "Comm. Wizard Step";
        CommWizardMgt : Codeunit "Comm. Wizard Management";
        CommSetupPage : Page "Commission Setup";
        CommissionModel : Option "Current salesperson rates","One rate for all","Varies per customer","Varies per customer group","Varies per item","Varies per item group","Varies per customer and item","Varies per customer and item group","Varies per customer group and item","Varies per customer group and item group";
        DistributionMethod : Option Vendor,"External Provider",Manual;
        CreatePayableVendors : Option Yes,No;
        DistributionAccountNo : Code[20];
        PayOnInvDiscounts : Option No,Yes;
        [InDataSet]
        GlobalRateEditable : Boolean;
        GlobalCommRate : Decimal;
        UseSalespersonRate : Option Yes,No;
        RepSplit : Option No,Yes;
        [InDataSet]
        PayManagers : Option No,Yes;
        [InDataSet]
        MgrOptionsEditable : Boolean;
        MgrSplitMgr : Option No,Yes;
        RepSplitMgr : Option No,Yes;
        [InDataSet]
        ActionsVisible : Boolean;
        Text001 : Label 'The Setup Wizard has already been run.';
        RecogTriggerMethod : Option Booking,Shipment,Invoice,Payment;
        PayableTriggerMethod : Option Booking,Shipment,Invoice,Payment;
        CommPlanCode : Code[20];
        UnitType : Option " ","G/L Account",Item,Resource,"Fixed Asset","Charge (Item)",,All;
        Text002 : Label 'Action Complete.';
        Text003 : Label 'You must specify a Global Commission Rate.';
        Text004 : Label 'Commission Setup not complete.';
        Text005 : Label 'You must perform this step manually.\%1\Is this step completed?';
        Text006 : Label 'Please return to this step and confirm when completed.';
        Text007 : Label 'You must complete the prior step first.';
        Text008 : Label 'Feature not enabled.';
        Text009 : Label 'Setups Complete.';
        CommPlanRate : Decimal;
        Text010 : Label 'You must specify an Expense Account for invoice lines.';

    local procedure SuggestActions();
    begin
        if CommSetup.GET then
          if CommSetup."Wizard Run" then
            ERROR(Text001);

        if DistributionMethod = DistributionMethod::Vendor then
          if CreatePayableVendors = CreatePayableVendors::Yes then
            if DistributionAccountNo = '' then
              ERROR(Text010);

        ActionsVisible := true;
        CommWizardMgt.DeleteSetupData;

        //Common actions
        CommWizardMgt.InsertCommWizardStep('Create Commission Setup','COMMSETUP',false);
        CommWizardMgt.InsertCommWizardStep('Create 1 Commission Customer Group per rep and add ' +
                      'their customers to that group. Based on existing assignment of reps to customers',
                      'COMMCUSTGROUP',false);

        if PayManagers = PayManagers::Yes then
          CommWizardMgt.InsertCommWizardStep('Manually confirm all managers are setup as a Salesperson ' +
                        'before continuing','CONFIRM',false);

        if DistributionMethod = DistributionMethod::Vendor then
          if CreatePayableVendors = CreatePayableVendors::Yes then
            CommWizardMgt.InsertCommWizardStep('Create 1 payable vendor per salesperson','CREATEVENDOR',false);

        case CommissionModel of
          CommissionModel::"Current salesperson rates" :
            begin
              CommWizardMgt.InsertCommWizardStep('Confirm all salespeople have a Commission Rate on their card',
                            'CONFIRM',true);
              CommWizardMgt.InsertCommWizardStep('Create 1 Commission Plan per salesperson using their current rate',
                            'COMMPLANREP',false);
            end;
          CommissionModel::"One rate for all" :
            begin
              if GlobalCommRate = 0 then
                ERROR(Text003);
              CommWizardMgt.InsertCommWizardStep(STRSUBSTNO('Create 1 Commission Plan per salesperson using global ' +
                            'rate of %1%.',GlobalCommRate),'COMMPLANGLOBAL',false);
            end;
          CommissionModel::"Varies per customer group" :
            begin
              CommWizardMgt.InsertCommWizardStep('Sorry, we are unable to automatically configure things for you. ' +
                            'Please consult your Tigunia resource for assistance.','',false);
            end;
          CommissionModel::"Varies per item group" :
            begin
              CommWizardMgt.InsertCommWizardStep('Sorry, we are unable to automatically configure things for you. ' +
                            'Please consult your Tigunia resource for assistance.','',false);
            end;
          CommissionModel::"Varies per customer" :
            begin
              CommWizardMgt.InsertCommWizardStep('Sorry, we are unable to automatically configure things for you. ' +
                            'Please consult your Tigunia resource for assistance.','',false);
            end;
          CommissionModel::"Varies per item" :
            begin
              CommWizardMgt.InsertCommWizardStep('Sorry, we are unable to automatically configure things for you. ' +
                            'Please consult your Tigunia resource for assistance.','',false);
            end;
          CommissionModel::"Varies per customer and item" :
            begin
              CommWizardMgt.InsertCommWizardStep('Sorry, we are unable to automatically configure things for you. ' +
                            'Please consult your Tigunia resource for assistance.','',false);
            end;
          CommissionModel::"Varies per customer and item group" :
            begin
              CommWizardMgt.InsertCommWizardStep('Sorry, we are unable to automatically configure things for you. ' +
                            'Please consult your Tigunia resource for assistance.','',false);
            end;
          CommissionModel::"Varies per customer group and item" :
            begin
              CommWizardMgt.InsertCommWizardStep('Sorry, we are unable to automatically configure things for you. ' +
                            'Please consult your Tigunia resource for assistance.','',false);
            end;
          CommissionModel::"Varies per customer group and item group" :
            begin
              CommWizardMgt.InsertCommWizardStep('Sorry, we are unable to automatically configure things for you. ' +
                            'Please consult your Tigunia resource for assistance.','',false);
            end;
        end;

        CommWizardMgt.InsertCommWizardStep('Create Customer/Salesperson relations.',
                      'COMMCUSTSALESPERSON',false);

        //Inform user to mark manager plans
        if PayManagers = PayManagers::Yes then
          CommWizardMgt.InsertCommWizardStep('Manually confirm all comm. plans for managers are marked as ' +
                        'manager level','CONFIRM',true);

        //Inform user has to manually create splits
        if RepSplit = RepSplit::Yes then
          CommWizardMgt.InsertCommWizardStep('You must manually define salesperson split setups.','CONFIRM',true);
        if MgrSplitMgr = MgrSplitMgr::Yes then
          CommWizardMgt.InsertCommWizardStep('You must manually define the manager split setups.','CONFIRM',true);
        if RepSplitMgr = RepSplitMgr::Yes then
          CommWizardMgt.InsertCommWizardStep('You must manually define salesperson/manager splits.','CONFIRM',true);

        //Inform user has to define the payable vendor for each comm plan payee
        if DistributionMethod = DistributionMethod::Vendor then
          if CreatePayableVendors = CreatePayableVendors::No then begin
            CommWizardMgt.InsertCommWizardStep('You must manually assign a payable vendor to each ' +
                          'Comm. Plan Payee','CONFIRM',true);
            CommWizardMgt.InsertCommWizardStep('You must manually assign an expense account to each ' +
                          'Comm. Plan Payee','CONFIRM',true);
        end;
    end;

    local procedure CarryoutAction();
    begin
        if CommSetup.GET then
          if CommSetup."Wizard Run" then
            ERROR(Text001);

        if not CommWizardStep.GET(CurrPage.RecommendedActions.PAGE.GetEntryNo) then
          exit;

        if CommWizardStep."Entry No." > 1 then begin
          CommWizardStep2.GET(CommWizardStep."Entry No."-1);
          if not CommWizardStep2.Complete then
            ERROR(Text007);
        end;

        if not CommWizardStep.Complete then begin
          case CommWizardStep."Action Code" of
            'COMMSETUP' :
              begin
                CommSetupPage.LOOKUPMODE(true);
                if not (CommSetupPage.RUNMODAL = ACTION::LookupOK) then
                  ERROR(Text004);
              end;
            'CREATEVENDOR' :
              begin
                CommWizardMgt.CreatePayableVendors;
              end;
            'COMMPLANREP','COMMPLANGLOBAL' :
              begin
                Salesperson.RESET;
                if Salesperson.FINDSET then begin
                  repeat
                    if CommWizardStep."Action Code" = 'COMMPLANGLOBAL' then
                      CommPlanRate := GlobalCommRate
                    else
                      CommPlanRate := Salesperson."Commission %";

                    CommPlanCode := CommWizardMgt.CreateCommPlan(Salesperson.Code,UnitType::Item,
                                    Salesperson.Name,PayOnInvDiscounts = PayOnInvDiscounts::Yes);
                    CommWizardMgt.CreateCommPlanCalcLine(CommPlanCode,CommPlanRate);
                    CommWizardMgt.CreateCommPlanPayee(CommPlanCode,Salesperson.Code,DistributionMethod,DistributionAccountNo);
                  until Salesperson.NEXT = 0;
                end;
              end;
            'COMMCUSTGROUP' :
              begin
                CommWizardMgt.CreateCommCustGroup('');
              end;
            'COMMCUSTSALESPERSON' :
              begin
                CommWizardMgt.CreateCommCustSalesperson;
              end;
            'CONFIRM' :
              begin
                if not CONFIRM(Text005,false,CommWizardStep."Action Msg.") then
                  ERROR(Text006);
              end;
          end;

          CommWizardStep.Complete := true;
          CommWizardStep.MODIFY;
          MESSAGE(Text002);

          //Mark setup as complete
          CommWizardStep2.FINDLAST;
          if CommWizardStep2."Entry No." = CommWizardStep."Entry No." then begin
            CommSetup.GET;
            CommSetup.VALIDATE("Wizard Run",true);
            CommSetup.MODIFY(true);
            MESSAGE(Text009);
            CommWizardMgt.DeleteCommWizardSteps;
          end;
        end;
    end;
}

