page 80019 "Commission Salespeople"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions

    Caption = 'Commission Salespeople';
    CardPageID = "Salesperson/Purchaser Card";
    Editable = false;
    PageType = List;
    SourceTable = "Salesperson/Purchaser";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Code";Code)
                {
                    ApplicationArea = All;
                    ToolTipML = ENU='Specifies the code of the record.',
                                ESM='Especifica el código del registro.',
                                FRC='Spécifie le code de l''enregistrement.',
                                ENC='Specifies the code of the record.';
                }
                field(Name;Name)
                {
                    ApplicationArea = Suite,RelationshipMgmt;
                    ToolTipML = ENU='Specifies the name of the record.',
                                ESM='Especifica el nombre del registro.',
                                FRC='Spécifie le nom de l''enregistrement.',
                                ENC='Specifies the name of the record.';
                }
                field("E-Mail";"E-Mail")
                {
                }
                field("Phone No.";"Phone No.")
                {
                    ApplicationArea = Suite,RelationshipMgmt;
                    ToolTipML = ENU='Specifies the salesperson''s or purchaser''s telephone number.',
                                ESM='Especifica el número de teléfono del vendedor o el comprador.',
                                FRC='Spécifie le numéro de téléphone du représentant ou de l''acheteur.',
                                ENC='Specifies the salesperson''s or purchaser''s telephone number.';
                }
            }
            part(Customers;"Comm. Salespeople/Customers")
            {
                SubPageLink = "Salesperson Code"=FIELD(Code);
            }
            part(Plans;"Comm. Salespeople/Plans")
            {
                SubPageLink = "Salesperson Code"=FIELD(Code);
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Salesperson")
            {
                CaptionML = ENU='&Salesperson',
                            ESM='Ve&ndedor',
                            FRC='&Représentant',
                            ENC='&Salesperson';
                Image = SalesPerson;
                action("Tea&ms")
                {
                    CaptionML = ENU='Tea&ms',
                                ESM='E&quipos',
                                FRC='É&quipes',
                                ENC='Tea&ms';
                    Image = TeamSales;
                    RunObject = Page "Salesperson Teams";
                    RunPageLink = "Salesperson Code"=FIELD(Code);
                    RunPageView = SORTING("Salesperson Code");
                }
                action("Con&tacts")
                {
                    ApplicationArea = RelationshipMgmt;
                    CaptionML = ENU='Con&tacts',
                                ESM='Cont&actos',
                                FRC='C&ontacts',
                                ENC='Con&tacts';
                    Image = CustomerContact;
                    RunObject = Page "Contact List";
                    RunPageLink = "Salesperson Code"=FIELD(Code);
                    RunPageView = SORTING("Salesperson Code");
                    ToolTipML = ENU='View a list of contacts that are associated with the salesperson/purchaser.',
                                ESM='Permite ver una lista de contactos asociados con el vendedor o el comprador.',
                                FRC='Affichez une liste des contacts associés au représentant/à l''acheteur.',
                                ENC='View a list of contacts that are associated with the salesperson/purchaser.';
                }
                group(Dimensions)
                {
                    CaptionML = ENU='Dimensions',
                                ESM='Dimensiones',
                                FRC='Dimensions',
                                ENC='Dimensions';
                    Image = Dimensions;
                    action("Dimensions-Single")
                    {
                        CaptionML = ENU='Dimensions-Single',
                                    ESM='Dimensiones-Individual',
                                    FRC='Dimensions - Simples',
                                    ENC='Dimensions-Single';
                        Image = Dimensions;
                        RunObject = Page "Default Dimensions";
                        RunPageLink = "Table ID"=CONST(13),
                                      "No."=FIELD(Code);
                        ShortCutKey = 'Shift+Ctrl+D';
                        ToolTipML = ENU='View or edit the single set of dimensions that are set up for the selected record.',
                                    ESM='Permite ver o editar el grupo único de dimensiones configuradas para el registro seleccionado.',
                                    FRC='Affichez ou modifiez l''ensemble unique de dimensions paramétrées pour l''enregistrement sélectionné.',
                                    ENC='View or edit the single set of dimensions that are set up for the selected record.';
                    }
                    action("Dimensions-&Multiple")
                    {
                        AccessByPermission = TableData Dimension=R;
                        CaptionML = ENU='Dimensions-&Multiple',
                                    ESM='Dimensiones-&Múltiple',
                                    FRC='Dimensions - &Multiples',
                                    ENC='Dimensions-&Multiple';
                        Image = DimensionSets;
                        ToolTipML = ENU='View or edit dimensions for a group of records. You can assign dimension codes to transactions to distribute costs and analyze historical information.',
                                    ESM='Permite ver o editar dimensiones para un grupo de registros. Se pueden asignar códigos de dimensión a transacciones para distribuir los costos y analizar la información histórica.',
                                    FRC='Affichez ou modifiez les dimensions pour un groupe d''enregistrements. Vous pouvez affecter des codes dimension aux transactions dans le but de répartir les coûts et d''analyser les informations d''historique.',
                                    ENC='View or edit dimensions for a group of records. You can assign dimension codes to transactions to distribute costs and analyse historical information.';

                        trigger OnAction();
                        var
                            SalespersonPurchaser : Record "Salesperson/Purchaser";
                            DefaultDimMultiple : Page "Default Dimensions-Multiple";
                        begin
                            CurrPage.SETSELECTIONFILTER(SalespersonPurchaser);
                            DefaultDimMultiple.SetMultiSalesperson(SalespersonPurchaser);
                            DefaultDimMultiple.RUNMODAL;
                        end;
                    }
                }
                action(Statistics)
                {
                    ApplicationArea = RelationshipMgmt;
                    CaptionML = ENU='Statistics',
                                ESM='Estadísticas',
                                FRC='Statistiques',
                                ENC='Statistics';
                    Image = Statistics;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Salesperson Statistics";
                    RunPageLink = Code=FIELD(Code);
                    ShortCutKey = 'F7';
                    ToolTipML = ENU='View statistical information, such as the value of posted entries, for the record.',
                                ESM='Permite ver información estadística del registro, como el valor de los movimientos registrados.',
                                FRC='Affichez des statistiques, comme la valeur des écritures reportées, pour l''enregistrement.',
                                ENC='View statistical information, such as the value of posted entries, for the record.';
                }
                action("C&ampaigns")
                {
                    CaptionML = ENU='C&ampaigns',
                                ESM='&Campañas',
                                FRC='&Promotions',
                                ENC='C&ampaigns';
                    Image = Campaign;
                    RunObject = Page "Campaign List";
                    RunPageLink = "Salesperson Code"=FIELD(Code);
                    RunPageView = SORTING("Salesperson Code");
                }
                action("S&egments")
                {
                    ApplicationArea = RelationshipMgmt;
                    CaptionML = ENU='S&egments',
                                ESM='&Segmentos',
                                FRC='Se&gments',
                                ENC='S&egments';
                    Image = Segment;
                    RunObject = Page "Segment List";
                    RunPageLink = "Salesperson Code"=FIELD(Code);
                    RunPageView = SORTING("Salesperson Code");
                    ToolTipML = ENU='View a list of all segments.',
                                ESM='Permite ver una lista de todos los segmentos.',
                                FRC='Affichez la liste de tous les segments.',
                                ENC='View a list of all segments.';
                }
                separator(Separator22)
                {
                    CaptionML = ENU='',
                                ESM='',
                                FRC='',
                                ENC='';
                }
                action("Interaction Log E&ntries")
                {
                    ApplicationArea = RelationshipMgmt;
                    CaptionML = ENU='Interaction Log E&ntries',
                                ESM='Movs. &log interacción',
                                FRC='Écritures jour&nal interaction',
                                ENC='Interaction Log E&ntries';
                    Image = InteractionLog;
                    RunObject = Page "Interaction Log Entries";
                    RunPageLink = "Salesperson Code"=FIELD(Code);
                    RunPageView = SORTING("Salesperson Code");
                    ShortCutKey = 'Ctrl+F7';
                    ToolTipML = ENU='View a list of the interactions that you have logged, for example, when you create an interaction, print a cover sheet, a sales order, and so on.',
                                ESM='Permite ver una lista de las interacciones que ha registrado, por ejemplo, al crear una interacción o al imprimir una portada, un pedido de ventas, etc.',
                                FRC='Visualisez la liste des interactions que vous enregistrez lorsque, par exemple, vous créez une interaction, imprimez un bordereau d''envoi, un document de vente, etc.',
                                ENC='View a list of the interactions that you have logged, for example, when you create an interaction, print a cover sheet, a sales order, and so on.';
                }
                action("Postponed &Interactions")
                {
                    ApplicationArea = RelationshipMgmt;
                    CaptionML = ENU='Postponed &Interactions',
                                ESM='&Interacciones aplazadas',
                                FRC='&Interactions reportées',
                                ENC='Postponed &Interactions';
                    Image = PostponedInteractions;
                    RunObject = Page "Postponed Interactions";
                    RunPageLink = "Salesperson Code"=FIELD(Code);
                    RunPageView = SORTING("Salesperson Code");
                    ToolTipML = ENU='View postponed interactions for the salesperson/purchaser.',
                                ESM='Permite ver las interacciones aplazadas del vendedor o el comprador.',
                                FRC='Affichez les interactions reportées du représentant/de l''acheteur.',
                                ENC='View postponed interactions for the salesperson/purchaser.';
                }
                action("T&o-dos")
                {
                    CaptionML = ENU='T&o-dos',
                                ESM='&Tareas',
                                FRC='&Tâches',
                                ENC='T&o-dos';
                    Image = TaskList;
                    RunObject = Page "Task List";
                    RunPageLink = "Salesperson Code"=FIELD(Code),
                                  "System To-do Type"=FILTER(Organizer|"Salesperson Attendee");
                    RunPageView = SORTING("Salesperson Code");
                }
                group("Oppo&rtunities")
                {
                    CaptionML = ENU='Oppo&rtunities',
                                ESM='Opo&rtunidades',
                                FRC='Oppo&rtunités',
                                ENC='Oppo&rtunities';
                    Image = OpportunityList;
                    action(List)
                    {
                        ApplicationArea = RelationshipMgmt;
                        CaptionML = ENU='List',
                                    ESM='Lista',
                                    FRC='Liste',
                                    ENC='List';
                        Image = OpportunitiesList;
                        RunObject = Page "Opportunity List";
                        RunPageLink = "Salesperson Code"=FIELD(Code);
                        RunPageView = SORTING("Salesperson Code");
                        ToolTipML = ENU='View a list of all salespeople/purchasers.',
                                    ESM='Permite ver una lista de todos los vendedores o los compradores.',
                                    FRC='Affichez une liste de tous les représentants/acheteurs.',
                                    ENC='View a list of all salespeople/purchasers.';
                    }
                }
            }
            group(ActionGroupCRM)
            {
                CaptionML = ENU='Dynamics CRM',
                            ESM='Dynamics CRM',
                            FRC='Dynamics CRM',
                            ENC='Dynamics CRM';
                Visible = CRMIntegrationEnabled;
                action(CRMGotoSystemUser)
                {
                    ApplicationArea = All;
                    CaptionML = ENU='User',
                                ESM='Usuario',
                                FRC='Utilisateur',
                                ENC='User';
                    Image = CoupledUser;
                    ToolTipML = ENU='Open the coupled Microsoft Dynamics CRM system user.',
                                ESM='Permite abrir el usuario del sistema emparejado de Microsoft Dynamics CRM.',
                                FRC='Ouvrez l''utilisateur système Microsoft Dynamics CRM couplé.',
                                ENC='Open the coupled Microsoft Dynamics CRM system user.';

                    trigger OnAction();
                    var
                        CRMIntegrationManagement : Codeunit "CRM Integration Management";
                    begin
                        CRMIntegrationManagement.ShowCRMEntityFromRecordID(RECORDID);
                    end;
                }
                action(CRMSynchronizeNow)
                {
                    AccessByPermission = TableData "CRM Integration Record"=IM;
                    ApplicationArea = All;
                    CaptionML = ENU='Synchronize Now',
                                ESM='Sincronizar ahora',
                                FRC='Synchroniser maintenant',
                                ENC='Synchronize Now';
                    Image = Refresh;
                    ToolTipML = ENU='Send or get updated data to or from Microsoft Dynamics CRM.',
                                ESM='Permite enviar u obtener datos actualizados a Microsoft Dynamics CRM o desde Microsoft Dynamics CRM.',
                                FRC='Envoyez/recevez des données mises à jour à/de Microsoft Dynamics CRM.',
                                ENC='Send or get updated data to or from Microsoft Dynamics CRM.';

                    trigger OnAction();
                    var
                        SalespersonPurchaser : Record "Salesperson/Purchaser";
                        CRMIntegrationManagement : Codeunit "CRM Integration Management";
                        SalespersonPurchaserRecordRef : RecordRef;
                    begin
                        CurrPage.SETSELECTIONFILTER(SalespersonPurchaser);
                        SalespersonPurchaser.NEXT;

                        if SalespersonPurchaser.COUNT = 1 then
                          CRMIntegrationManagement.UpdateOneNow(SalespersonPurchaser.RECORDID)
                        else begin
                          SalespersonPurchaserRecordRef.GETTABLE(SalespersonPurchaser);
                          CRMIntegrationManagement.UpdateMultipleNow(SalespersonPurchaserRecordRef);
                        end
                    end;
                }
                group(Coupling)
                {
                    CaptionML = Comment='Coupling is a noun',
                                ENU='Coupling',
                                ESM='Emparejamiento',
                                FRC='Couplage',
                                ENC='Coupling';
                    Image = LinkAccount;
                    ToolTipML = ENU='Create, change, or delete a coupling between the Microsoft Dynamics NAV record and a Microsoft Dynamics CRM record.',
                                ESM='Crea, cambia o elimina un emparejamiento entre el registro de Microsoft Dynamics NAV y un registro de Microsoft Dynamics CRM.',
                                FRC='Créez, modifiez ou supprimez un couplage entre l''enregistrement Microsoft Dynamics NAV et un enregistrement Microsoft Dynamics CRM.',
                                ENC='Create, change, or delete a coupling between the Microsoft Dynamics NAV record and a Microsoft Dynamics CRM record.';
                    action(ManageCRMCoupling)
                    {
                        AccessByPermission = TableData "CRM Integration Record"=IM;
                        ApplicationArea = All;
                        CaptionML = ENU='Set Up Coupling',
                                    ESM='Configurar emparejamiento',
                                    FRC='Configurer le couplage',
                                    ENC='Set Up Coupling';
                        Image = LinkAccount;
                        ToolTipML = ENU='Create or modify the coupling to a Microsoft Dynamics CRM user.',
                                    ESM='Crea o modifica el emparejamiento con un usuario de Microsoft Dynamics CRM.',
                                    FRC='Créez ou modifiez le couplage avec un utilisateur Microsoft Dynamics CRM.',
                                    ENC='Create or modify the coupling to a Microsoft Dynamics CRM user.';

                        trigger OnAction();
                        var
                            CRMIntegrationManagement : Codeunit "CRM Integration Management";
                        begin
                            CRMIntegrationManagement.DefineCoupling(RECORDID);
                        end;
                    }
                    action(DeleteCRMCoupling)
                    {
                        AccessByPermission = TableData "CRM Integration Record"=IM;
                        ApplicationArea = All;
                        CaptionML = ENU='Delete Coupling',
                                    ESM='Eliminar emparejamiento',
                                    FRC='Supprimer le couplage',
                                    ENC='Delete Coupling';
                        Enabled = CRMIsCoupledToRecord;
                        Image = UnLinkAccount;
                        ToolTipML = ENU='Delete the coupling to a Microsoft Dynamics CRM user.',
                                    ESM='Elimina el emparejamiento con un usuario de Microsoft Dynamics CRM.',
                                    FRC='Supprimez le couplage avec un utilisateur Microsoft Dynamics CRM.',
                                    ENC='Delete the coupling to a Microsoft Dynamics CRM user.';

                        trigger OnAction();
                        var
                            CRMCouplingManagement : Codeunit "CRM Coupling Management";
                        begin
                            CRMCouplingManagement.RemoveCoupling(RECORDID);
                        end;
                    }
                }
            }
        }
        area(processing)
        {
            action("Manage Customers")
            {
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction();
                var
                    CommCustSalesperson : Record "Commission Cust/Salesperson";
                    CommCustSalespersons : Page "Comm. Salespeople/Customers";
                begin
                    CommCustSalesperson.RESET;
                    CommCustSalesperson.SETRANGE("Salesperson Code",Code);
                    CLEAR(CommCustSalespersons);
                    CommCustSalespersons.SETTABLEVIEW(CommCustSalesperson);
                    CommCustSalespersons.RUNMODAL;
                end;
            }
            action(CreateInteraction)
            {
                AccessByPermission = TableData Attachment=R;
                ApplicationArea = All;
                CaptionML = ENU='Create &Interaction',
                            ESM='Crear &interacción',
                            FRC='&Créer interaction',
                            ENC='Create &Interaction';
                Ellipsis = true;
                Image = CreateInteraction;
                Promoted = true;
                PromotedCategory = Process;
                ToolTipML = ENU='Use a batch job to help you create interactions for the involved salespeople or purchasers.',
                            ESM='Permite usar un trabajo por lotes para que resulte más sencillo crear interacciones para los vendedores o los compradores relacionados.',
                            FRC='Utilisez un traitement en lot pour créer des interactions pour les représentants et acheteurs concernés.',
                            ENC='Use a batch job to help you create interactions for the involved salespeople or purchasers.';
                Visible = CreateInteractionVisible;

                trigger OnAction();
                begin
                    CreateInteraction;
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord();
    var
        CRMCouplingManagement : Codeunit "CRM Coupling Management";
    begin
        if CRMIntegrationEnabled then
          CRMIsCoupledToRecord := CRMCouplingManagement.IsRecordCoupledToCRM(RECORDID);
    end;

    trigger OnInit();
    var
        SegmentLine : Record "Segment Line";
    begin
        CreateInteractionVisible := SegmentLine.READPERMISSION;
    end;

    trigger OnOpenPage();
    var
        CRMIntegrationManagement : Codeunit "CRM Integration Management";
    begin
        CRMIntegrationEnabled := CRMIntegrationManagement.IsCRMIntegrationEnabled;
    end;

    var
        [InDataSet]
        CreateInteractionVisible : Boolean;
        CRMIntegrationEnabled : Boolean;
        CRMIsCoupledToRecord : Boolean;
}

