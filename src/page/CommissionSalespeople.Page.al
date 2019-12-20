page 80019 "CommissionSalespeopleTigCM"
{
    Caption = 'Commission Salespeople';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Salesperson/Purchaser";
    CardPageID = "Salesperson/Purchaser Card";
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the code of the record.';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the name of the record.';
                }
                field("E-Mail"; "E-Mail")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the E-Mail';
                }
                field("Phone No."; "Phone No.")
                {
                    Tooltip = 'Specifies the salesperson''s or purchaser''s telephone number.';
                    ApplicationArea = All;
                }
            }
            part(Customers; "CommCustomerSalespeopleTigCM")
            {
                ApplicationArea = All;
                SubPageLink = "Salesperson Code" = field(Code);
            }
            part(Plans; CommSalespeoplePlansTigCM)
            {
                ApplicationArea = All;
                SubPageLink = "Salesperson Code" = field(Code);
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Salesperson")
            {
                Caption = '&Salesperson';
                Image = SalesPerson;
                action("Tea&ms")
                {
                    Caption = 'Tea&ms';
                    ApplicationArea = All;
                    ToolTip = 'Opens the Salespeople page';
                    Image = TeamSales;
                    RunObject = Page "Salesperson Teams";
                    RunPageLink = "Salesperson Code" = field(Code);
                    RunPageView = sorting("Salesperson Code");
                }
                action("Con&tacts")
                {
                    Caption = 'Con&tacts';
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'View a list of contacts that are associated with the salesperson/purchaser.';
                    Image = CustomerContact;
                    RunObject = Page "Contact List";
                    RunPageLink = "Salesperson Code" = field(Code);
                    RunPageView = sorting("Salesperson Code");
                }
                group(Dimensions)
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    action("Dimensions-Single")
                    {
                        Caption = 'Dimensions-Single';
                        ApplicationArea = All;
                        ToolTip = 'View or edit the single set of dimensions that are set up for the selected record.';
                        Image = Dimensions;
                        RunObject = Page "Default Dimensions";
                        RunPageLink = "Table ID" = const(13),
                                      "No." = field(Code);
                        ShortCutKey = 'Shift+Ctrl+D';
                    }
                    action("Dimensions-&Multiple")
                    {
                        Caption = 'Dimensions-&Multiple';
                        ApplicationArea = All;
                        ToolTip = 'View or edit dimensions for a group of records. You can assign dimension codes to transactions to distribute costs and analyze historical information.';
                        Image = DimensionSets;
                        AccessByPermission = TableData Dimension = R;

                        trigger OnAction();
                        var
                            SalespersonPurchaser: Record "Salesperson/Purchaser";
                            DefaultDimMultiple: Page "Default Dimensions-Multiple";
                        begin
                            CurrPage.SETSELECTIONFILTER(SalespersonPurchaser);
                            //TODO figure out what this is supposed to be -> commented out
                            //DefaultDimMultiple.SetMultiSalesperson(SalespersonPurchaser);
                            DefaultDimMultiple.RunModal();
                        end;
                    }
                }
                action(Statistics)
                {
                    Caption = 'Statistics';
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'View statistical information, such as the value of posted entries, for the record.';
                    Image = Statistics;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Salesperson Statistics";
                    RunPageLink = Code = field(Code);
                    ShortCutKey = 'F7';
                }
                action("C&ampaigns")
                {
                    Caption = 'C&ampaigns';
                    ApplicationArea = All;
                    ToolTip = 'Opens the Campaign List';
                    Image = Campaign;
                    RunObject = Page "Campaign List";
                    RunPageLink = "Salesperson Code" = field(Code);
                    RunPageView = sorting("Salesperson Code");
                }
                action("S&egments")
                {
                    Caption = 'S&egments';
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'View a list of all segments.';
                    Image = Segment;
                    RunObject = Page "Segment List";
                    RunPageLink = "Salesperson Code" = field(Code);
                    RunPageView = sorting("Salesperson Code");
                }
                separator(Separator22)
                {
                    Caption = '';
                }
                action("Interaction Log E&ntries")
                {
                    Caption = 'Interaction Log E&ntries';
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'View a list of the interactions that you have logged, for example, when you create an interaction, print a cover sheet, a sales order, and so on.';
                    Image = InteractionLog;
                    RunObject = Page "Interaction Log Entries";
                    RunPageLink = "Salesperson Code" = field(Code);
                    RunPageView = sorting("Salesperson Code");
                    ShortCutKey = 'Ctrl+F7';
                }
                action("Postponed &Interactions")
                {
                    Caption = 'Postponed &Interactions';
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'View postponed interactions for the salesperson/purchaser.';
                    Image = PostponedInteractions;
                    RunObject = Page "Postponed Interactions";
                    RunPageLink = "Salesperson Code" = field(Code);
                    RunPageView = sorting("Salesperson Code");
                }
                action("T&o-dos")
                {
                    Caption = 'T&o-dos';
                    ApplicationArea = All;
                    ToolTip = 'Opens the Task List';
                    Image = TaskList;
                    RunObject = Page "Task List";
                    RunPageLink = "Salesperson Code" = field(Code),
                                  "System To-do Type" = filter(Organizer | "Salesperson Attendee");
                    RunPageView = sorting("Salesperson Code");
                }
                group("Oppo&rtunities")
                {
                    Caption = 'Oppo&rtunities';
                    action(List)
                    {
                        Caption = 'List';
                        ApplicationArea = RelationshipMgmt;
                        ToolTip = 'View a list of all salespeople/purchasers.';
                        Image = OpportunitiesList;
                        RunObject = Page "Opportunity List";
                        RunPageLink = "Salesperson Code" = field(Code);
                        RunPageView = sorting("Salesperson Code");
                    }
                }
            }
            group(ActionGroupCRM)
            {
                Caption = 'Dynamics CRM';
                Visible = CRMIntegrationEnabled;
                action(CRMGotoSystemUser)
                {
                    Caption = 'User';
                    ApplicationArea = All;
                    ToolTip = 'Open the coupled Microsoft Dynamics CRM system user.';
                    Image = CoupledUser;

                    trigger OnAction();
                    var
                        CRMIntegrationManagement: Codeunit "CRM Integration Management";
                    begin
                        CRMIntegrationManagement.ShowCRMEntityFromRecordID(RecordId());
                    end;
                }
                action(CRMSynchronizeNow)
                {
                    Caption = 'Synchronize Now';
                    ApplicationArea = All;
                    ToolTip = 'Send or get updated data to or from Microsoft Dynamics CRM.';
                    Image = Refresh;
                    AccessByPermission = TableData "CRM Integration Record" = IM;

                    trigger OnAction();
                    var
                        SalespersonPurchaser: Record "Salesperson/Purchaser";
                        CRMIntegrationManagement: Codeunit "CRM Integration Management";
                        SalespersonPurchaserRecordRef: RecordRef;
                    begin
                        CurrPage.SetSelectionFilter(SalespersonPurchaser);
                        SalespersonPurchaser.Next();

                        if SalespersonPurchaser.Count() = 1 then
                            CRMIntegrationManagement.UpdateOneNow(SalespersonPurchaser.RecordId())
                        else begin
                            SalespersonPurchaserRecordRef.GetTable(SalespersonPurchaser);
                            CRMIntegrationManagement.UpdateMultipleNow(SalespersonPurchaserRecordRef);
                        end
                    end;
                }
                group(Coupling)
                {
                    Caption = 'Coupling';
                    action(ManageCRMCoupling)
                    {
                        Caption = 'Set Up Coupling';
                        ApplicationArea = All;
                        ToolTip = 'Create or modify the coupling to a Microsoft Dynamics CRM user.';
                        Image = LinkAccount;
                        AccessByPermission = TableData "CRM Integration Record" = IM;

                        trigger OnAction();
                        var
                            CRMIntegrationManagement: Codeunit "CRM Integration Management";
                        begin
                            CRMIntegrationManagement.DefineCoupling(RecordId());
                        end;
                    }
                    action(DeleteCRMCoupling)
                    {
                        Caption = 'Delete Coupling';
                        ApplicationArea = All;
                        ToolTip = 'Delete the coupling to a Microsoft Dynamics CRM user.';
                        Image = UnLinkAccount;
                        Enabled = CRMIsCoupledToRecord;
                        AccessByPermission = TableData "CRM Integration Record" = IM;

                        trigger OnAction();
                        var
                            CRMCouplingManagement: Codeunit "CRM Coupling Management";
                        begin
                            CRMCouplingManagement.RemoveCoupling(RecordId());
                        end;
                    }
                }
            }
        }
        area(processing)
        {
            action("Manage Customers")
            {
                Caption = 'Manage Customers';
                ApplicationArea = All;
                ToolTip = 'Opens the customer list';
                Image = CustomerList;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction();
                var
                    CommCustSalesperson: Record "CommCustomerSalespersonTigCM";
                    CommCustSalespersons: Page "CommCustomerSalespeopleTigCM";
                begin
                    CommCustSalesperson.Reset();
                    CommCustSalesperson.SetRange("Salesperson Code", Code);
                    Clear(CommCustSalespersons);
                    CommCustSalespersons.SetTableView(CommCustSalesperson);
                    CommCustSalespersons.RunModal()
                end;
            }
            action(CreateInteraction)
            {
                Caption = 'Create &Interaction';
                ApplicationArea = All;
                ToolTip = 'Use a batch job to help you create interactions for the involved salespeople or purchasers.';
                Image = CreateInteraction;
                AccessByPermission = TableData Attachment = R;
                Ellipsis = true;
                Promoted = true;
                PromotedCategory = Process;
                Visible = CreateInteractionVisible;

                trigger OnAction();
                begin
                    CreateInteraction();
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord();
    var
        CRMCouplingManagement: Codeunit "CRM Coupling Management";
    begin
        if CRMIntegrationEnabled then
            CRMIsCoupledToRecord := CRMCouplingManagement.IsRecordCoupledToCRM(RecordId());
    end;

    trigger OnInit();
    var
        SegmentLine: Record "Segment Line";
    begin
        CreateInteractionVisible := SegmentLine.ReadPermission();
    end;

    trigger OnOpenPage();
    var
        CRMIntegrationManagement: Codeunit "CRM Integration Management";
    begin
        CRMIntegrationEnabled := CRMIntegrationManagement.IsCRMIntegrationEnabled();
    end;

    var
        [InDataSet]
        CreateInteractionVisible: Boolean;
        CRMIntegrationEnabled: Boolean;
        CRMIsCoupledToRecord: Boolean;
}