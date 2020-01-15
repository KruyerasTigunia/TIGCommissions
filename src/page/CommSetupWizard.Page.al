page 80022 "CommSetupWizardTigCM"
{
    Caption = 'Commission Setup Wizard';
    ApplicationArea = All;
    UsageCategory = Administration;
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
                field(CommissionModelLbl; CommissionModel)
                {
                    Caption = 'Commission Model';
                    ApplicationArea = All;
                    Tooltip = 'Specifies the CommissionModel';
                    OptionCaption = 'Current salesperson rates,One rate for all,Varies per customer,Varies per customer group,Varies per item,Varies per item group,Varies per customer and item,Varies per customer and item group,Varies per customer group and item,Varies per customer group and item group';

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
                field(GlobalCommRateLbl; GlobalCommRate)
                {
                    Caption = 'Global Commission Rate';
                    ApplicationArea = All;
                    Tooltip = 'Specifies the GlobalCommRate';
                    Editable = GlobalRateEditable;
                }
                field(DistributionMethodLbl; DistributionMethod)
                {
                    Caption = 'How are commissions paid';
                    ApplicationArea = All;
                    Tooltip = 'Specifies the DistributionMethod';
                    OptionCaption = 'Vendor,External Provider,Manual';

                    trigger OnValidate();
                    var
                        FeatureNotEnabledErr: Label 'Feature not enabled.';
                    begin
                        if DistributionMethod = DistributionMethod::"External Provider" then
                            Error(FeatureNotEnabledErr);
                    end;
                }
                field(CreatePayableVendorsLbl; CreatePayableVendors)
                {
                    Caption = 'Create Payable Vendor per salesperson';
                    ApplicationArea = All;
                    Tooltip = 'Specifies the CreatePayableVendors';
                }
                field(DistributionAccountNoLbl; DistributionAccountNo)
                {
                    Caption = 'Expense Account for vendor invoice lines';
                    ApplicationArea = All;
                    Tooltip = 'Specifies the DistributionAccountNo';
                    LookupPageID = "G/L Account List";
                    TableRelation = "G/L Account"."No.";
                }
            }
            group(Salespeople)
            {
                Caption = 'Managers and Commission Splits';
                field(PayManagersLbl; PayManagers)
                {
                    Caption = 'Pay Managers';
                    ApplicationArea = All;
                    Tooltip = 'Specifies the PayManagers';

                    trigger OnValidate();
                    begin
                        if PayManagers then begin
                            MgrOptionsEditable := true;
                        end else begin
                            MgrSplitMgr := false;
                            RepSplitMgr := false;
                            MgrOptionsEditable := false;
                        end;
                    end;
                }
                field(RepSplitLbl; RepSplit)
                {
                    Caption = 'Do salespeople split commissions with other salespeople';
                    ApplicationArea = All;
                    Tooltip = 'Specifies the RepSplit';
                }
                field("<RepSplitMgr>"; RepSplitMgr)
                {
                    Caption = 'Do salespeople split commissions with managers';
                    ApplicationArea = All;
                    ToolTip = 'If manager commissions are paid independently from salespeople, this should be NO';
                    Editable = MgrOptionsEditable;
                }
                field(MgrSplitMgrLbl; MgrSplitMgr)
                {
                    Caption = 'Do managers split commissions with other managers';
                    ApplicationArea = All;
                    Tooltip = 'Specifies the MgrSplitMgr';
                    Editable = MgrOptionsEditable;
                }
            }
            part(RecommendedActions; CommWizardStepsTigCM)
            {
                Caption = 'Recommended Actions:';
                ApplicationArea = All;
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
                Caption = 'Suggest Actions';
                ApplicationArea = All;
                ToolTip = 'Suggest Actions';
                Image = Suggest;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction();
                begin
                    SuggestActions();
                end;
            }
            action("Carry Out Action Step")
            {
                Caption = 'Carry Out Action Step';
                ApplicationArea = All;
                ToolTip = 'Carry Out Action Step';
                Image = CarryOutActionMessage;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction();
                begin
                    CarryoutAction();
                end;
            }
        }
    }

    var
        CommSetup: Record CommissionSetupTigCM;
        Salesperson: Record "Salesperson/Purchaser";
        CommWizardStep: Record CommWizardStepTigCM;
        CommWizardStep2: Record CommWizardStepTigCM;
        CommWizardMgt: Codeunit CommissionWizardMgtTigCM;
        CommSetupPage: Page CommissionSetupTigCM;
        CommissionModel: Option "Current salesperson rates","One rate for all","Varies per customer","Varies per customer group","Varies per item","Varies per item group","Varies per customer and item","Varies per customer and item group","Varies per customer group and item","Varies per customer group and item group";
        DistributionMethod: Option Vendor,"External Provider",Manual;
        UnitType: Option " ","G/L Account",Item,Resource,"Fixed Asset","Charge (Item)",,All;
        PayOnInvDiscounts: Boolean;
        RepSplit: Boolean;
        [InDataSet]
        PayManagers: Boolean;
        MgrSplitMgr: Boolean;
        RepSplitMgr: Boolean;
        CreatePayableVendors: Boolean;
        [InDataSet]
        MgrOptionsEditable: Boolean;
        [InDataSet]
        GlobalRateEditable: Boolean;
        [InDataSet]
        ActionsVisible: Boolean;
        DistributionAccountNo: Code[20];
        CommPlanCode: Code[20];
        GlobalCommRate: Decimal;
        CommPlanRate: Decimal;
        WizardAlreadyRunErr: Label 'The Setup Wizard has already been run.';

    trigger OnOpenPage();
    begin
        ActionsVisible := CommWizardStep.Count() > 0;
        GlobalRateEditable := CommissionModel = CommissionModel::"One rate for all";
        MgrOptionsEditable := PayManagers;
    end;

    local procedure SuggestActions();
    var
        MissingGlobalCommissionRateErr: Label 'You must specify a Global Commission Rate.';
        MissingExpenseAcctErr: Label 'You must specify an Expense Account for invoice lines.';
    begin
        if CommSetup.Get() then
            if CommSetup."Wizard Run" then
                Error(WizardAlreadyRunErr);

        if DistributionMethod = DistributionMethod::Vendor then
            if CreatePayableVendors then
                if DistributionAccountNo = '' then
                    Error(MissingExpenseAcctErr);

        ActionsVisible := true;
        CommWizardMgt.DeleteSetupData();

        //Common actions
        CommWizardMgt.InsertCommWizardStep('Create Commission Setup', 'COMMSETUP', false);
        CommWizardMgt.InsertCommWizardStep('Create 1 Commission Customer Group per rep and add ' +
                      'their customers to that group. Based on existing assignment of reps to customers',
                      'COMMCUSTGROUP', false);

        if PayManagers then
            CommWizardMgt.InsertCommWizardStep('Manually confirm all managers are setup as a Salesperson ' +
                          'before continuing', 'CONFIRM', false);

        if DistributionMethod = DistributionMethod::Vendor then
            if CreatePayableVendors then
                CommWizardMgt.InsertCommWizardStep('Create 1 payable vendor per salesperson', 'CREATEVENDOR', false);

        case CommissionModel of
            CommissionModel::"Current salesperson rates":
                begin
                    CommWizardMgt.InsertCommWizardStep('Confirm all salespeople have a Commission Rate on their card',
                                  'CONFIRM', true);
                    CommWizardMgt.InsertCommWizardStep('Create 1 Commission Plan per salesperson using their current rate',
                                  'COMMPLANREP', false);
                end;
            CommissionModel::"One rate for all":
                begin
                    if GlobalCommRate = 0 then
                        Error(MissingGlobalCommissionRateErr);
                    CommWizardMgt.InsertCommWizardStep(StrSubstNo('Create 1 Commission Plan per salesperson using global ' +
                                  'rate of %1%.', GlobalCommRate), 'COMMPLANGLOBAL', false);
                end;
            CommissionModel::"Varies per customer group":
                begin
                    CommWizardMgt.InsertCommWizardStep('Sorry, we are unable to automatically configure things for you. ' +
                                  'Please consult your Tigunia resource for assistance.', '', false);
                end;
            CommissionModel::"Varies per item group":
                begin
                    CommWizardMgt.InsertCommWizardStep('Sorry, we are unable to automatically configure things for you. ' +
                                  'Please consult your Tigunia resource for assistance.', '', false);
                end;
            CommissionModel::"Varies per customer":
                begin
                    CommWizardMgt.InsertCommWizardStep('Sorry, we are unable to automatically configure things for you. ' +
                                  'Please consult your Tigunia resource for assistance.', '', false);
                end;
            CommissionModel::"Varies per item":
                begin
                    CommWizardMgt.InsertCommWizardStep('Sorry, we are unable to automatically configure things for you. ' +
                                  'Please consult your Tigunia resource for assistance.', '', false);
                end;
            CommissionModel::"Varies per customer and item":
                begin
                    CommWizardMgt.InsertCommWizardStep('Sorry, we are unable to automatically configure things for you. ' +
                                  'Please consult your Tigunia resource for assistance.', '', false);
                end;
            CommissionModel::"Varies per customer and item group":
                begin
                    CommWizardMgt.InsertCommWizardStep('Sorry, we are unable to automatically configure things for you. ' +
                                  'Please consult your Tigunia resource for assistance.', '', false);
                end;
            CommissionModel::"Varies per customer group and item":
                begin
                    CommWizardMgt.InsertCommWizardStep('Sorry, we are unable to automatically configure things for you. ' +
                                  'Please consult your Tigunia resource for assistance.', '', false);
                end;
            CommissionModel::"Varies per customer group and item group":
                begin
                    CommWizardMgt.InsertCommWizardStep('Sorry, we are unable to automatically configure things for you. ' +
                                  'Please consult your Tigunia resource for assistance.', '', false);
                end;
        end;

        CommWizardMgt.InsertCommWizardStep('Create Customer/Salesperson relations.',
                      'COMMCUSTSALESPERSON', false);

        //Inform user to mark manager plans
        if PayManagers then
            CommWizardMgt.InsertCommWizardStep('Manually confirm all comm. plans for managers are marked as ' +
                          'manager level', 'CONFIRM', true);

        //Inform user has to manually create splits
        if RepSplit then
            CommWizardMgt.InsertCommWizardStep('You must manually define salesperson split setups.', 'CONFIRM', true);
        if MgrSplitMgr then
            CommWizardMgt.InsertCommWizardStep('You must manually define the manager split setups.', 'CONFIRM', true);
        if RepSplitMgr then
            CommWizardMgt.InsertCommWizardStep('You must manually define salesperson/manager splits.', 'CONFIRM', true);

        //Inform user has to define the payable vendor for each comm plan payee
        if DistributionMethod = DistributionMethod::Vendor then
            if not CreatePayableVendors then begin
                CommWizardMgt.InsertCommWizardStep('You must manually assign a payable vendor to each ' +
                              'Comm. Plan Payee', 'CONFIRM', true);
                CommWizardMgt.InsertCommWizardStep('You must manually assign an expense account to each ' +
                              'Comm. Plan Payee', 'CONFIRM', true);
            end;
    end;

    local procedure CarryoutAction();
    var
        ActionCompleteMsg: Label 'Action Complete.';
        SetupNotCompleteErr: Label 'Commission Setup not complete.';
        StepCompleteQst: Label 'You must perform this step manually.\%1\Is this step completed?';
        ReturnToStepErr: Label 'Please return to this step and confirm when completed.';
        PriorStepFirstErr: Label 'You must complete the prior step first.';
        SetupCompleteMsg: Label 'Setup is Complete.';
    begin
        if CommSetup.Get() then
            if CommSetup."Wizard Run" then
                Error(WizardAlreadyRunErr);

        if not CommWizardStep.Get(CurrPage.RecommendedActions.Page.GetEntryNo()) then
            exit;

        if CommWizardStep."Entry No." > 1 then begin
            CommWizardStep2.Get(CommWizardStep."Entry No." - 1);
            if not CommWizardStep2.Complete then
                Error(PriorStepFirstErr);
        end;

        if not CommWizardStep.Complete then begin
            case CommWizardStep."Action Code" of
                'COMMSETUP':
                    begin
                        CommSetupPage.LookupMode(true);
                        if not (CommSetupPage.RunModal() = Action::LookupOK) then
                            Error(SetupNotCompleteErr);
                    end;
                'CREATEVENDOR':
                    begin
                        CommWizardMgt.CreatePayableVendors();
                    end;
                'COMMPLANREP', 'COMMPLANGLOBAL':
                    begin
                        Salesperson.Reset();
                        if Salesperson.FindSet() then begin
                            repeat
                                if CommWizardStep."Action Code" = 'COMMPLANGLOBAL' then
                                    CommPlanRate := GlobalCommRate
                                else
                                    CommPlanRate := Salesperson."Commission %";

                                CommPlanCode := CommWizardMgt.CreateCommPlan(Salesperson.Code, UnitType::Item,
                                                Salesperson.Name, PayOnInvDiscounts);
                                CommWizardMgt.CreateCommPlanCalcLine(CommPlanCode, CommPlanRate);
                                CommWizardMgt.CreateCommPlanPayee(CommPlanCode, Salesperson.Code, DistributionMethod, DistributionAccountNo);
                            until Salesperson.Next() = 0;
                        end;
                    end;
                'COMMCUSTGROUP':
                    begin
                        CommWizardMgt.CreateCommCustGroup('');
                    end;
                'COMMCUSTSALESPERSON':
                    begin
                        CommWizardMgt.CreateCommCustSalesperson();
                    end;
                'CONFIRM':
                    begin
                        if not Confirm(StepCompleteQst, false, CommWizardStep."Action Msg.") then
                            Error(ReturnToStepErr);
                    end;
            end;

            CommWizardStep.Complete := true;
            CommWizardStep.Modify();
            Message(ActionCompleteMsg);

            //Mark setup as complete
            CommWizardStep2.FindLast();
            if CommWizardStep2."Entry No." = CommWizardStep."Entry No." then begin
                CommSetup.Get();
                CommSetup.Validate("Wizard Run", true);
                CommSetup.Modify(true);
                Message(SetupCompleteMsg);
                CommWizardMgt.DeleteCommWizardSteps();
            end;
        end;
    end;
}