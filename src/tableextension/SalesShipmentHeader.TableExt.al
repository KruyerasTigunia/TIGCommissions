tableextension 50000 blah extends "Sales Shipment Header"
{
    fields
    {
        field(2;"Sell-to Customer No.";Code[20])
        {
            CaptionML = ENU='Sell-to Customer No.',
                        ESM='Venta a-Nº cliente',
                        FRC='N° client (débiteur)',
                        ENC='Sell-to Customer No.';
            NotBlank = true;
            TableRelation = Customer;
        }
        field(3;"No.";Code[20])
        {
            CaptionML = ENU='No.',
                        ESM='Nº',
                        FRC='N°',
                        ENC='No.';
        }
        field(4;"Bill-to Customer No.";Code[20])
        {
            CaptionML = ENU='Bill-to Customer No.',
                        ESM='Factura-a Nº cliente',
                        FRC='Nº client facturé',
                        ENC='Bill-to Customer No.';
            NotBlank = true;
            TableRelation = Customer;
        }
        field(5;"Bill-to Name";Text[50])
        {
            CaptionML = ENU='Name',
                        ESM='Fact. a-Nombre',
                        FRC='Nom client facturé',
                        ENC='Name';
        }
        field(6;"Bill-to Name 2";Text[50])
        {
            CaptionML = ENU='Name 2',
                        ESM='Fact. a-Nombre 2',
                        FRC='Nom client facturé 2',
                        ENC='Name 2';
        }
        field(7;"Bill-to Address";Text[50])
        {
            CaptionML = ENU='Address',
                        ESM='Fact. a-Dirección',
                        FRC='Adresse facturation',
                        ENC='Address';
        }
        field(8;"Bill-to Address 2";Text[50])
        {
            CaptionML = ENU='Address 2',
                        ESM='Fact. a-Colonia',
                        FRC='Adresse de facturation 2',
                        ENC='Address 2';
        }
        field(9;"Bill-to City";Text[30])
        {
            CaptionML = ENU='City',
                        ESM='Fact. a-Municipio/Ciudad',
                        FRC='Ville facturation',
                        ENC='City';
            TableRelation = "Post Code".City;
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(10;"Bill-to Contact";Text[50])
        {
            CaptionML = ENU='Contact',
                        ESM='Fact. a-Atención',
                        FRC='Contact facturation',
                        ENC='Contact';
        }
        field(11;"Your Reference";Text[35])
        {
            CaptionML = ENU='Customer PO No.',
                        ESM='Su/Ntra. ref.',
                        FRC='Votre référence',
                        ENC='Your Reference';
        }
        field(12;"Ship-to Code";Code[10])
        {
            CaptionML = ENU='Ship-to Code',
                        ESM='Cód. dirección envío cliente',
                        FRC='Code de livraison',
                        ENC='Ship-to Code';
            TableRelation = "Ship-to Address".Code WHERE ("Customer No."=FIELD("Sell-to Customer No."));
        }
        field(13;"Ship-to Name";Text[50])
        {
            CaptionML = ENU='Ship-to Name',
                        ESM='Envío a-Nombre',
                        FRC='Nom du destinataire',
                        ENC='Ship-to Name';
        }
        field(14;"Ship-to Name 2";Text[50])
        {
            CaptionML = ENU='Ship-to Name 2',
                        ESM='Envío a-Nombre 2',
                        FRC='Nom du destinataire 2',
                        ENC='Ship-to Name 2';
        }
        field(15;"Ship-to Address";Text[50])
        {
            CaptionML = ENU='Ship-to Address',
                        ESM='Dirección de envío',
                        FRC='Adresse (destinataire)',
                        ENC='Ship-to Address';
        }
        field(16;"Ship-to Address 2";Text[50])
        {
            CaptionML = ENU='Ship-to Address 2',
                        ESM='Envío a-Colonia 2',
                        FRC='Adresse de livraison 2',
                        ENC='Ship-to Address 2';
        }
        field(17;"Ship-to City";Text[30])
        {
            CaptionML = ENU='Ship-to City',
                        ESM='Envío a-Municipio/Ciudad',
                        FRC='Ville (destinataire)',
                        ENC='Ship-to City';
            TableRelation = "Post Code".City;
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(18;"Ship-to Contact";Text[50])
        {
            CaptionML = ENU='Ship-to Contact',
                        ESM='Envío a-Atención',
                        FRC='Contact destinataire',
                        ENC='Ship-to Contact';
        }
        field(19;"Order Date";Date)
        {
            CaptionML = ENU='Order Date',
                        ESM='Fecha pedido',
                        FRC='Date commande',
                        ENC='Order Date';
        }
        field(20;"Posting Date";Date)
        {
            CaptionML = ENU='Posting Date',
                        ESM='Fecha registro',
                        FRC='Date de report',
                        ENC='Posting Date';
        }
        field(21;"Shipment Date";Date)
        {
            CaptionML = ENU='Shipment Date',
                        ESM='Fecha envío',
                        FRC='Date de livraison',
                        ENC='Shipment Date';
        }
        field(22;"Posting Description";Text[50])
        {
            CaptionML = ENU='Posting Description',
                        ESM='Texto de registro',
                        FRC='Description du report',
                        ENC='Posting Description';
        }
        field(23;"Payment Terms Code";Code[10])
        {
            CaptionML = ENU='Payment Terms Code',
                        ESM='Cód. términos pago',
                        FRC='Code modalités de paiement',
                        ENC='Payment Terms Code';
            TableRelation = "Payment Terms";
        }
        field(24;"Due Date";Date)
        {
            CaptionML = ENU='Due Date',
                        ESM='Fecha vencimiento',
                        FRC='Date d''échéance',
                        ENC='Due Date';
        }
        field(25;"Payment Discount %";Decimal)
        {
            CaptionML = ENU='Payment Discount %',
                        ESM='% Dto. P.P.',
                        FRC='% escompte de paiement',
                        ENC='Payment Discount %';
            DecimalPlaces = 0:5;
            MaxValue = 100;
            MinValue = 0;
        }
        field(26;"Pmt. Discount Date";Date)
        {
            CaptionML = ENU='Pmt. Discount Date',
                        ESM='Fecha dto. P.P.',
                        FRC='Date escompte de paiement',
                        ENC='Pmt. Discount Date';
        }
        field(27;"Shipment Method Code";Code[10])
        {
            CaptionML = ENU='Shipment Method Code',
                        ESM='Cód. método de envío',
                        FRC='Code méthode de livraison',
                        ENC='Shipment Method Code';
            TableRelation = "Shipment Method";
        }
        field(28;"Location Code";Code[10])
        {
            CaptionML = ENU='Location Code',
                        ESM='Cód. almacén',
                        FRC='Code d''emplacement',
                        ENC='Location Code';
            TableRelation = Location WHERE ("Use As In-Transit"=CONST(false));
        }
        field(29;"Shortcut Dimension 1 Code";Code[20])
        {
            CaptionClass = '1,2,1';
            CaptionML = ENU='Shortcut Dimension 1 Code',
                        ESM='Cód. dim. acceso dir. 1',
                        FRC='Code raccourci de dimension 1',
                        ENC='Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(1));
        }
        field(30;"Shortcut Dimension 2 Code";Code[20])
        {
            CaptionClass = '1,2,2';
            CaptionML = ENU='Shortcut Dimension 2 Code',
                        ESM='Cód. dim. acceso dir. 2',
                        FRC='Code raccourci de dimension 2',
                        ENC='Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(2));
        }
        field(31;"Customer Posting Group";Code[20])
        {
            CaptionML = ENU='Customer Posting Group',
                        ESM='Grupo contable cliente',
                        FRC='Paramètre report client',
                        ENC='Customer Posting Group';
            Editable = false;
            TableRelation = "Customer Posting Group";
        }
        field(32;"Currency Code";Code[10])
        {
            CaptionML = ENU='Currency Code',
                        ESM='Cód. divisa',
                        FRC='Code devise',
                        ENC='Currency Code';
            Editable = false;
            TableRelation = Currency;
        }
        field(33;"Currency Factor";Decimal)
        {
            CaptionML = ENU='Currency Factor',
                        ESM='Factor divisa',
                        FRC='Facteur devise',
                        ENC='Currency Factor';
            DecimalPlaces = 0:15;
            MinValue = 0;
        }
        field(34;"Customer Price Group";Code[10])
        {
            CaptionML = ENU='Customer Price Group',
                        ESM='Grupo precio cliente',
                        FRC='Groupe de prix du client',
                        ENC='Customer Price Group';
            TableRelation = "Customer Price Group";
        }
        field(35;"Prices Including VAT";Boolean)
        {
            CaptionML = ENU='Prices Including Tax',
                        ESM='Precios IVA incluido',
                        FRC='Prix incluant la TVA',
                        ENC='Prices Including Tax';
        }
        field(37;"Invoice Disc. Code";Code[20])
        {
            CaptionML = ENU='Invoice Disc. Code',
                        ESM='Cód. dto. factura',
                        FRC='Code escompte facture',
                        ENC='Invoice Disc. Code';
        }
        field(40;"Customer Disc. Group";Code[20])
        {
            CaptionML = ENU='Customer Disc. Group',
                        ESM='Grupo dto. cliente',
                        FRC='Groupe d''escompte du client',
                        ENC='Customer Disc. Group';
            TableRelation = "Customer Discount Group";
        }
        field(41;"Language Code";Code[10])
        {
            CaptionML = ENU='Language Code',
                        ESM='Cód. idioma',
                        FRC='Code langue',
                        ENC='Language Code';
            TableRelation = Language;
        }
        field(43;"Salesperson Code";Code[20])
        {
            CaptionML = ENU='Salesperson Code',
                        ESM='Cód. vendedor',
                        FRC='Code représentant',
                        ENC='Salesperson Code';
            TableRelation = "Salesperson/Purchaser";
        }
        field(44;"Order No.";Code[20])
        {
            CaptionML = ENU='Order No.',
                        ESM='Nº pedido',
                        FRC='N° commande',
                        ENC='Order No.';
        }
        field(46;Comment;Boolean)
        {
            CalcFormula = Exist("Sales Comment Line" WHERE ("Document Type"=CONST(Shipment),
                                                            "No."=FIELD("No."),
                                                            "Document Line No."=CONST(0)));
            CaptionML = ENU='Comment',
                        ESM='Comentario',
                        FRC='Commentaire',
                        ENC='Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(47;"No. Printed";Integer)
        {
            CaptionML = ENU='No. Printed',
                        ESM='Nº copias impresas',
                        FRC='Nombre impressions',
                        ENC='No. Printed';
            Editable = false;
        }
        field(51;"On Hold";Code[3])
        {
            CaptionML = ENU='On Hold',
                        ESM='Esperar',
                        FRC='En attente',
                        ENC='On Hold';
        }
        field(52;"Applies-to Doc. Type";Option)
        {
            CaptionML = ENU='Applies-to Doc. Type',
                        ESM='Liq. por tipo documento',
                        FRC='Type document affecté à',
                        ENC='Applies-to Doc. Type';
            OptionCaptionML = ENU=' ,Payment,Invoice,Credit Memo,Finance Charge Memo,Reminder,Refund',
                              ESM=' ,Pago,Factura,Nota crédito,Docs. interés,Recordatorio,Reembolso',
                              FRC=' ,Paiement,Facture,Note de crédit,Note de frais financiers,Rappel,Remboursement',
                              ENC=' ,Payment,Invoice,Credit Memo,Finance Charge Memo,Reminder,Refund';
            OptionMembers = " ",Payment,Invoice,"Credit Memo","Finance Charge Memo",Reminder,Refund;
        }
        field(53;"Applies-to Doc. No.";Code[20])
        {
            CaptionML = ENU='Applies-to Doc. No.',
                        ESM='Liq. por nº documento',
                        FRC='N° doc. affecté à',
                        ENC='Applies-to Doc. No.';

            trigger OnLookup();
            begin
                CustLedgEntry.SETCURRENTKEY("Document No.");
                CustLedgEntry.SETRANGE("Document Type","Applies-to Doc. Type");
                CustLedgEntry.SETRANGE("Document No.","Applies-to Doc. No.");
                PAGE.RUN(0,CustLedgEntry);
            end;
        }
        field(55;"Bal. Account No.";Code[20])
        {
            CaptionML = ENU='Bal. Account No.',
                        ESM='Cta. contrapartida',
                        FRC='N° compte contrôle',
                        ENC='Bal. Account No.';
            TableRelation = IF ("Bal. Account Type"=CONST("G/L Account")) "G/L Account"
                            ELSE IF ("Bal. Account Type"=CONST("Bank Account")) "Bank Account";
        }
        field(70;"VAT Registration No.";Text[20])
        {
            CaptionML = ENU='Tax Registration No.',
                        ESM='RFC/Curp',
                        FRC='N° identification de la TPS/TVH',
                        ENC='GST/HST Registration No.';
        }
        field(73;"Reason Code";Code[10])
        {
            CaptionML = ENU='Reason Code',
                        ESM='Cód. auditoría',
                        FRC='Code motif',
                        ENC='Reason Code';
            TableRelation = "Reason Code";
        }
        field(74;"Gen. Bus. Posting Group";Code[20])
        {
            CaptionML = ENU='Gen. Bus. Posting Group',
                        ESM='Grupo contable negocio',
                        FRC='Groupe de report de marché',
                        ENC='Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
        }
        field(75;"EU 3-Party Trade";Boolean)
        {
            CaptionML = ENU='EU 3-Party Trade',
                        ESM='Op. triangular',
                        FRC='Trans. tripartite UE',
                        ENC='EU 3-Party Trade';
        }
        field(76;"Transaction Type";Code[10])
        {
            CaptionML = ENU='Transaction Type',
                        ESM='Naturaleza transacción',
                        FRC='Type de transaction',
                        ENC='Transaction Type';
            TableRelation = "Transaction Type";
        }
        field(77;"Transport Method";Code[10])
        {
            CaptionML = ENU='Transport Method',
                        ESM='Modo transporte',
                        FRC='Mode de transport',
                        ENC='Transport Method';
            TableRelation = "Transport Method";
        }
        field(78;"VAT Country/Region Code";Code[10])
        {
            CaptionML = ENU='Tax Country/Region Code',
                        ESM='Cód. IVA país/región',
                        FRC='Code pays/région TVA',
                        ENC='VAT Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(79;"Sell-to Customer Name";Text[50])
        {
            CaptionML = ENU='Sell-to Customer Name',
                        ESM='Venta a-Nombre',
                        FRC='Nom du client (débiteur)',
                        ENC='Sell-to Customer Name';
        }
        field(80;"Sell-to Customer Name 2";Text[50])
        {
            CaptionML = ENU='Sell-to Customer Name 2',
                        ESM='Venta a-Nombre 2',
                        FRC='Nom 2 du client (débiteur)',
                        ENC='Sell-to Customer Name 2';
        }
        field(81;"Sell-to Address";Text[50])
        {
            CaptionML = ENU='Sell-to Address',
                        ESM='Venta a-Dirección',
                        FRC='Adresse (débiteur)',
                        ENC='Sell-to Address';
        }
        field(82;"Sell-to Address 2";Text[50])
        {
            CaptionML = ENU='Sell-to Address 2',
                        ESM='Venta a-Colonia',
                        FRC='Adresse 2 (débiteur)',
                        ENC='Sell-to Address 2';
        }
        field(83;"Sell-to City";Text[30])
        {
            CaptionML = ENU='Sell-to City',
                        ESM='Venta a-Municipio/Ciudad',
                        FRC='Ville (débiteur)',
                        ENC='Sell-to City';
            TableRelation = "Post Code".City;
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(84;"Sell-to Contact";Text[50])
        {
            CaptionML = ENU='Sell-to Contact',
                        ESM='Venta a-Atención',
                        FRC='Contact (débiteur)',
                        ENC='Sell-to Contact';
        }
        field(85;"Bill-to Post Code";Code[20])
        {
            CaptionML = ENU='ZIP Code',
                        ESM='Fact. a-C.P.',
                        FRC='Code postal de facturation',
                        ENC='Postal/ZIP Code';
            TableRelation = "Post Code";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(86;"Bill-to County";Text[30])
        {
            CaptionML = ENU='State',
                        ESM='Fact. a-Provincia',
                        FRC='Comté de facturation',
                        ENC='Province/State';
        }
        field(87;"Bill-to Country/Region Code";Code[10])
        {
            CaptionML = ENU='Country/Region Code',
                        ESM='Fact. a-Cód. país/región',
                        FRC='Code pays/région (facturation)',
                        ENC='Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(88;"Sell-to Post Code";Code[20])
        {
            CaptionML = ENU='Sell-to ZIP Code',
                        ESM='Venta a-C.P.',
                        FRC='Code postal (débiteur)',
                        ENC='Sell-to Postal/ZIP Code';
            TableRelation = "Post Code";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(89;"Sell-to County";Text[30])
        {
            CaptionML = ENU='Sell-to State',
                        ESM='Venta a-Provincia',
                        FRC='Comté (débiteur)',
                        ENC='Sell-to Province/State';
        }
        field(90;"Sell-to Country/Region Code";Code[10])
        {
            CaptionML = ENU='Sell-to Country/Region Code',
                        ESM='Venta a-Cód. país/región',
                        FRC='Code pays/région (débiteur)',
                        ENC='Sell-to Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(91;"Ship-to Post Code";Code[20])
        {
            CaptionML = ENU='Ship-to ZIP Code',
                        ESM='Envío a-C.P.',
                        FRC='Code postal destinataire',
                        ENC='Ship-to Postal/ZIP Code';
            TableRelation = "Post Code";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(92;"Ship-to County";Text[30])
        {
            CaptionML = ENU='Ship-to State',
                        ESM='Envío a-Provincia',
                        FRC='Comté destinataire',
                        ENC='Ship-to Province/State';
        }
        field(93;"Ship-to Country/Region Code";Code[10])
        {
            CaptionML = ENU='Ship-to Country/Region Code',
                        ESM='Cód. país/región dirección de envío',
                        FRC='Code pays/région (destinataire)',
                        ENC='Ship-to Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(94;"Bal. Account Type";Option)
        {
            CaptionML = ENU='Bal. Account Type',
                        ESM='Tipo contrapartida',
                        FRC='Type compte contrôle',
                        ENC='Bal. Account Type';
            OptionCaptionML = ENU='G/L Account,Bank Account',
                              ESM='Cuenta,Banco',
                              FRC='Compte GL,Compte bancaire',
                              ENC='G/L Account,Bank Account';
            OptionMembers = "G/L Account","Bank Account";
        }
        field(97;"Exit Point";Code[10])
        {
            CaptionML = ENU='Exit Point',
                        ESM='Puerto/Aerop. carga',
                        FRC='Pays destination',
                        ENC='Exit Point';
            TableRelation = "Entry/Exit Point";
        }
        field(98;Correction;Boolean)
        {
            CaptionML = ENU='Correction',
                        ESM='Corrección',
                        FRC='Correction',
                        ENC='Correction';
        }
        field(99;"Document Date";Date)
        {
            CaptionML = ENU='Document Date',
                        ESM='Fecha emisión documento',
                        FRC='Date document',
                        ENC='Document Date';
        }
        field(100;"External Document No.";Code[35])
        {
            CaptionML = ENU='External Document No.',
                        ESM='Nº documento externo',
                        FRC='N° document externe',
                        ENC='External Document No.';
        }
        field(101;"Area";Code[10])
        {
            CaptionML = ENU='Area',
                        ESM='Cód. provincia',
                        FRC='Zone',
                        ENC='Area';
            TableRelation = Area;
        }
        field(102;"Transaction Specification";Code[10])
        {
            CaptionML = ENU='Transaction Specification',
                        ESM='Especificación transacción',
                        FRC='Spécification transaction',
                        ENC='Transaction Specification';
            TableRelation = "Transaction Specification";
        }
        field(104;"Payment Method Code";Code[10])
        {
            CaptionML = ENU='Payment Method Code',
                        ESM='Cód. forma pago',
                        FRC='Code mode de paiement',
                        ENC='Payment Method Code';
            TableRelation = "Payment Method";
        }
        field(105;"Shipping Agent Code";Code[10])
        {
            AccessByPermission = TableData "Shipping Agent Services"=R;
            CaptionML = ENU='Shipping Agent Code',
                        ESM='Cód. transportista',
                        FRC='Code agent de livraison',
                        ENC='Shipping Agent Code';
            TableRelation = "Shipping Agent";

            trigger OnValidate();
            begin
                if "Shipping Agent Code" <> xRec."Shipping Agent Code" then
                  VALIDATE("Shipping Agent Service Code",'');
            end;
        }
        field(106;"Package Tracking No.";Text[30])
        {
            CaptionML = ENU='Package Tracking No.',
                        ESM='Nº seguimiento bulto',
                        FRC='N° de traçabilité',
                        ENC='Package Tracking No.';
        }
        field(109;"No. Series";Code[20])
        {
            CaptionML = ENU='No. Series',
                        ESM='Nos. serie',
                        FRC='Séries de n°',
                        ENC='No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(110;"Order No. Series";Code[20])
        {
            CaptionML = ENU='Order No. Series',
                        ESM='Nº serie pedido',
                        FRC='Séries de n° commande',
                        ENC='Order No. Series';
            TableRelation = "No. Series";
        }
        field(112;"User ID";Code[50])
        {
            CaptionML = ENU='User ID',
                        ESM='Id. usuario',
                        FRC='Code utilisateur',
                        ENC='User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;

            trigger OnLookup();
            var
                UserMgt : Codeunit "User Management";
            begin
                UserMgt.LookupUserID("User ID");
            end;
        }
        field(113;"Source Code";Code[10])
        {
            CaptionML = ENU='Source Code',
                        ESM='Cód. origen',
                        FRC='Code d''origine',
                        ENC='Source Code';
            TableRelation = "Source Code";
        }
        field(114;"Tax Area Code";Code[20])
        {
            CaptionML = ENU='Tax Area Code',
                        ESM='Cód. área impuesto',
                        FRC='Code de région fiscale',
                        ENC='Tax Area Code';
            TableRelation = "Tax Area";
        }
        field(115;"Tax Liable";Boolean)
        {
            CaptionML = ENU='Tax Liable',
                        ESM='Sujeto a impuesto',
                        FRC='Imposable',
                        ENC='Tax Liable';
        }
        field(116;"VAT Bus. Posting Group";Code[20])
        {
            CaptionML = ENU='Tax Bus. Posting Group',
                        ESM='Grupo registro IVA neg.',
                        FRC='Groupe de reports de taxe sur la valeur ajoutée de l''entreprise',
                        ENC='Tax Bus. Posting Group';
            TableRelation = "VAT Business Posting Group";
        }
        field(119;"VAT Base Discount %";Decimal)
        {
            CaptionML = ENU='VAT Base Discount %',
                        ESM='% Dto. base IVA',
                        FRC='% escompte base TVA',
                        ENC='VAT Base Discount %';
            DecimalPlaces = 0:5;
            MaxValue = 100;
            MinValue = 0;
        }
        field(151;"Quote No.";Code[20])
        {
            CaptionML = ENU='Quote No.',
                        ESM='Nº cotización',
                        FRC='N° devis',
                        ENC='Quote No.';
            Editable = false;
        }
        field(480;"Dimension Set ID";Integer)
        {
            CaptionML = ENU='Dimension Set ID',
                        ESM='Id. grupo dimensiones',
                        FRC='Code ensemble de dimensions',
                        ENC='Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup();
            begin
                ShowDimensions;
            end;
        }
        field(5050;"Campaign No.";Code[20])
        {
            CaptionML = ENU='Campaign No.',
                        ESM='Nº campaña',
                        FRC='N° promotion',
                        ENC='Campaign No.';
            TableRelation = Campaign;
        }
        field(5052;"Sell-to Contact No.";Code[20])
        {
            CaptionML = ENU='Sell-to Contact No.',
                        ESM='Venta a-Nº contacto',
                        FRC='N° contact débiteur',
                        ENC='Sell-to Contact No.';
            TableRelation = Contact;
        }
        field(5053;"Bill-to Contact No.";Code[20])
        {
            CaptionML = ENU='Bill-to Contact No.',
                        ESM='Fact. a-Nº contacto',
                        FRC='N° contact facturation',
                        ENC='Bill-to Contact No.';
            TableRelation = Contact;
        }
        field(5055;"Opportunity No.";Code[20])
        {
            CaptionML = ENU='Opportunity No.',
                        ESM='Nº oportunidad',
                        FRC='N° opportunité',
                        ENC='Opportunity No.';
            TableRelation = Opportunity;
        }
        field(5700;"Responsibility Center";Code[10])
        {
            CaptionML = ENU='Responsibility Center',
                        ESM='Centro responsabilidad',
                        FRC='Centre de gestion',
                        ENC='Responsibility Centre';
            TableRelation = "Responsibility Center";
        }
        field(5790;"Requested Delivery Date";Date)
        {
            AccessByPermission = TableData "Order Promising Line"=R;
            CaptionML = ENU='Requested Delivery Date',
                        ESM='Fecha entrega requerida',
                        FRC='Date livraison demandée',
                        ENC='Requested Delivery Date';
        }
        field(5791;"Promised Delivery Date";Date)
        {
            CaptionML = ENU='Promised Delivery Date',
                        ESM='Fecha entrega prometida',
                        FRC='Date livraison confirmée',
                        ENC='Promised Delivery Date';
        }
        field(5792;"Shipping Time";DateFormula)
        {
            AccessByPermission = TableData "Shipping Agent Services"=R;
            CaptionML = ENU='Shipping Time',
                        ESM='Tiempo envío',
                        FRC='Délai de livraison',
                        ENC='Shipping Time';
        }
        field(5793;"Outbound Whse. Handling Time";DateFormula)
        {
            AccessByPermission = TableData Location=R;
            CaptionML = ENU='Outbound Whse. Handling Time',
                        ESM='Tiempo manip. alm. salida',
                        FRC='Délai désenlogement',
                        ENC='Outbound Whse. Handling Time';
        }
        field(5794;"Shipping Agent Service Code";Code[10])
        {
            CaptionML = ENU='Shipping Agent Service Code',
                        ESM='Cód. servicio transportista',
                        FRC='Code prestation agent de livraison',
                        ENC='Shipping Agent Service Code';
            TableRelation = "Shipping Agent Services".Code WHERE ("Shipping Agent Code"=FIELD("Shipping Agent Code"));
        }
        field(7001;"Allow Line Disc.";Boolean)
        {
            CaptionML = ENU='Allow Line Disc.',
                        ESM='Permite dto. línea',
                        FRC='Autoriser remise ligne',
                        ENC='Allow Line Disc.';
        }
        field(10005;"Ship-to UPS Zone";Code[2])
        {
            CaptionML = ENU='Ship-to UPS Zone',
                        ESM='Envío a-Zona UPS',
                        FRC='Zone de livraison UPS',
                        ENC='Ship-to UPS Zone';
        }
        field(80000;"Commission Calculated";Boolean)
        {
            Description = 'TIGCOMM1.0';
        }
    }

    keys
    {
        key(Key1;"No.")
        {
        }
        key(Key2;"Order No.")
        {
        }
        key(Key3;"Bill-to Customer No.")
        {
        }
        key(Key4;"Sell-to Customer No.")
        {
        }
        key(Key5;"Posting Date")
        {
        }
        key(Key6;"Commission Calculated","Posting Date")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown;"No.","Sell-to Customer No.","Sell-to Customer Name","Posting Date","Posting Description")
        {
        }
    }

    trigger OnDelete();
    var
        CertificateOfSupply : Record "Certificate of Supply";
        PostSalesDelete : Codeunit "PostSales-Delete";
    begin
        TESTFIELD("No. Printed");
        LOCKTABLE;
        PostSalesDelete.DeleteSalesShptLines(Rec);

        SalesCommentLine.SETRANGE("Document Type",SalesCommentLine."Document Type"::Shipment);
        SalesCommentLine.SETRANGE("No.","No.");
        SalesCommentLine.DELETEALL;

        ApprovalsMgmt.DeletePostedApprovalEntries(RECORDID);

        if CertificateOfSupply.GET(CertificateOfSupply."Document Type"::"Sales Shipment","No.") then
          CertificateOfSupply.DELETE(true);
    end;

    var
        SalesShptHeader : Record "Sales Shipment Header";
        SalesCommentLine : Record "Sales Comment Line";
        CustLedgEntry : Record "Cust. Ledger Entry";
        ShippingAgent : Record "Shipping Agent";
        DimMgt : Codeunit DimensionManagement;
        ApprovalsMgmt : Codeunit "Approvals Mgmt.";
        UserSetupMgt : Codeunit "User Setup Management";
        TrackingInternetAddr : Text;
        DocTxt : TextConst ENU='Shipment',ESM='Envío',FRC='Livraison',ENC='Shipment';

    [Scope('Personalization')]
    procedure SendProfile(var DocumentSendingProfile : Record "Document Sending Profile");
    var
        DummyReportSelections : Record "Report Selections";
    begin
        DocumentSendingProfile.Send(
          DummyReportSelections.Usage::"S.Shipment",Rec,"No.","Sell-to Customer No.",
          DocTxt,FIELDNO("Sell-to Customer No."),FIELDNO("No."));
    end;

    [Scope('Personalization')]
    procedure PrintRecords(ShowRequestForm : Boolean);
    var
        ReportSelection : Record "Report Selections";
    begin
        with SalesShptHeader do begin
          COPY(Rec);
          ReportSelection.PrintWithGUIYesNo(
            ReportSelection.Usage::"S.Shipment",SalesShptHeader,ShowRequestForm,FIELDNO("Bill-to Customer No."));
        end;
    end;

    [Scope('Internal')]
    procedure EmailRecords(ShowDialog : Boolean);
    var
        DocumentSendingProfile : Record "Document Sending Profile";
        DummyReportSelections : Record "Report Selections";
    begin
        DocumentSendingProfile.TrySendToEMail(
          DummyReportSelections.Usage::"S.Shipment",Rec,FIELDNO("No."),DocTxt,FIELDNO("Bill-to Customer No."),ShowDialog);
    end;

    [Scope('Personalization')]
    procedure Navigate();
    var
        NavigateForm : Page Navigate;
    begin
        NavigateForm.SetDoc("Posting Date","No.");
        NavigateForm.RUN;
    end;

    [Scope('Personalization')]
    procedure StartTrackingSite(PackageTrackingNo : Text[30]);
    begin
        if PackageTrackingNo = '' then
          PackageTrackingNo := "Package Tracking No.";

        HYPERLINK(GetTrackingInternetAddr);
    end;

    [Scope('Personalization')]
    procedure ShowDimensions();
    begin
        DimMgt.ShowDimensionSet("Dimension Set ID",STRSUBSTNO('%1 %2',TABLECAPTION,"No."));
    end;

    [Scope('Personalization')]
    procedure IsCompletlyInvoiced() : Boolean;
    var
        SalesShipmentLine : Record "Sales Shipment Line";
    begin
        SalesShipmentLine.SETRANGE("Document No.","No.");
        SalesShipmentLine.SETFILTER("Qty. Shipped Not Invoiced",'<>0');
        if SalesShipmentLine.ISEMPTY then
          exit(true);
        exit(false);
    end;

    [Scope('Personalization')]
    procedure SetSecurityFilterOnRespCenter();
    begin
        if UserSetupMgt.GetSalesFilter <> '' then begin
          FILTERGROUP(2);
          SETRANGE("Responsibility Center",UserSetupMgt.GetSalesFilter);
          FILTERGROUP(0);
        end;
    end;

    [Scope('Personalization')]
    procedure GetTrackingInternetAddr() : Text;
    var
        HttpStr : Text;
    begin
        HttpStr := 'http://';
        TESTFIELD("Shipping Agent Code");
        ShippingAgent.GET("Shipping Agent Code");
        TrackingInternetAddr := STRSUBSTNO(ShippingAgent."Internet Address","Package Tracking No.");

        if STRPOS(TrackingInternetAddr,HttpStr) = 0 then
          TrackingInternetAddr := HttpStr + TrackingInternetAddr;
        exit(TrackingInternetAddr);
    end;
}

