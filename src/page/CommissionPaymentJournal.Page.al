page 80015 "CommissionPaymentJournalTigCM"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions

    AutoSplitKey = true;
    CaptionML = ENU = 'Payment Journal',
                ESM = 'Diario pagos',
                FRC = 'Journal des paiements',
                ENC = 'Payment Journal';
    DataCaptionExpression = DataCaption;
    DelayedInsert = true;
    PageType = Worksheet;
    PromotedActionCategoriesML = ENU = 'New,Process,Report,Bank,Prepare,Approve',
                                 ESM = 'Nuevo,Procesar,Informar,Banco,Preparar,Aprobar',
                                 FRC = 'Nouveau,Traitement,Rapport,Banque,Préparer,Approuver',
                                 ENC = 'New,Process,Report,Bank,Prepare,Approve';
    SaveValues = true;
    SourceTable = "Gen. Journal Line";

    layout
    {
        area(content)
        {
            field(CurrentJnlBatchName; CurrentJnlBatchName)
            {
                ApplicationArea = Basic, Suite;
                CaptionML = ENU = 'Batch Name',
                            ESM = 'Nombre sección',
                            FRC = 'Nom de lot',
                            ENC = 'Batch Name';
                Lookup = true;
                ToolTipML = ENU = 'Specifies the batch name on the payment journal.',
                            ESM = 'Especifica el nombre de sección del diario de pagos.',
                            FRC = 'Spécifie le nom de lot sur le journal paiement.',
                            ENC = 'Specifies the batch name on the payment journal.';

                trigger OnLookup(Text: Text): Boolean;
                begin
                    CurrPage.SAVERECORD;
                    GenJnlManagement.LookupName(CurrentJnlBatchName, Rec);
                    CurrPage.UPDATE(false);
                end;

                trigger OnValidate();
                begin
                    GenJnlManagement.CheckName(CurrentJnlBatchName, Rec);
                    CurrentJnlBatchNameOnAfterVali;
                end;
            }
            repeater(Control1)
            {
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    Style = Attention;
                    StyleExpr = HasPmtFileErr;
                    ToolTipML = ENU = 'Specifies the posting date for the entry.',
                                ESM = 'Especifica la fecha de registro del movimiento.',
                                FRC = 'Spécifie la date de report de l''écriture.',
                                ENC = 'Specifies the posting date for the entry.';
                }
                field("Document Date"; "Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    Style = Attention;
                    StyleExpr = HasPmtFileErr;
                    ToolTipML = ENU = 'Specifies the date on the document that provides the basis for the entry on the journal line.',
                                ESM = 'Especifica la fecha del documento que proporciona la base para el movimiento en la línea del diario.',
                                FRC = 'Spécifie la date du document qui est utilisé comme base pour l''écriture de la ligne journal.',
                                ENC = 'Specifies the date on the document that provides the basis for the entry on the journal line.';
                }
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    Style = Attention;
                    StyleExpr = HasPmtFileErr;
                    ToolTipML = ENU = 'Specifies the type of document that the entry on the journal line is.',
                                ESM = 'Especifica el tipo de documento del movimiento de la línea del diario.',
                                FRC = 'Spécifie le type de document correspondant à l''écriture de la ligne journal.',
                                ENC = 'Specifies the type of document that the entry on the journal line is.';
                    Visible = false;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    Style = Attention;
                    StyleExpr = HasPmtFileErr;
                    ToolTipML = ENU = 'Specifies a document number for the journal line.',
                                ESM = 'Especifica un número de documento para la línea del diario.',
                                FRC = 'Spécifie le numéro de document de la ligne journal.',
                                ENC = 'Specifies a document number for the journal line.';
                }
                field("Incoming Document Entry No."; "Incoming Document Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTipML = ENU = 'Specifies the number of the incoming document that this general journal line is created for.',
                                ESM = 'Especifica el número del documento entrante para el que se crea esta línea del diario general.',
                                FRC = 'Spécifie le numéro du document entrant pour lequel cette ligne journal général est créée.',
                                ENC = 'Specifies the number of the incoming document that this general journal line is created for.';
                    Visible = false;

                    trigger OnAssistEdit();
                    begin
                        if "Incoming Document Entry No." > 0 then
                            HYPERLINK(GetIncomingDocumentURL);
                    end;
                }
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTipML = ENU = 'Specifies a document number that refers to the customer''s or vendor''s numbering system.',
                                ESM = 'Especifica un número de documento que hace referencia al sistema de numeración de clientes o proveedores.',
                                FRC = 'Spécifie un numéro de document qui fait référence au programme de numérotation du client ou du fournisseur.',
                                ENC = 'Specifies a document number that refers to the customer''s or vendor''s numbering system.';
                }
                field("Applies-to Ext. Doc. No."; "Applies-to Ext. Doc. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTipML = ENU = 'Specifies the external document number that will be exported in the payment file.',
                                ESM = 'Especifica el número de documento externo que se exportará en el archivo de pago.',
                                FRC = 'Spécifie le numéro document externe exporté dans le fichier paiement.',
                                ENC = 'Specifies the external document number that will be exported in the payment file.';
                    Visible = false;
                }
                field("Account Type"; "Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTipML = ENU = 'Specifies the type of account that the entry on the journal line will be posted to.',
                                ESM = 'Especifica el tipo de cuenta donde se registrará el movimiento de la línea del diario.',
                                FRC = 'Spécifie le type de compte sur lequel l''écriture de la ligne journal sera reportée.',
                                ENC = 'Specifies the type of account that the entry on the journal line will be posted to.';

                    trigger OnValidate();
                    begin
                        GenJnlManagement.GetAccounts(Rec, AccName, BalAccName);
                    end;
                }
                field("Account No."; "Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                    Style = Attention;
                    StyleExpr = HasPmtFileErr;
                    ToolTipML = ENU = 'Specifies the account number that the entry on the journal line will be posted to.',
                                ESM = 'Especifica el número de cuenta donde se registrará el movimiento de la línea del diario.',
                                FRC = 'Spécifie le numéro de compte sur lequel l''écriture de la ligne journal est reportée.',
                                ENC = 'Specifies the account number that the entry on the journal line will be posted to.';

                    trigger OnValidate();
                    begin
                        GenJnlManagement.GetAccounts(Rec, AccName, BalAccName);
                        ShowShortcutDimCode(ShortcutDimCode);
                    end;
                }
                field("Recipient Bank Account"; "Recipient Bank Account")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                    ToolTipML = ENU = 'Specifies the bank account that the amount will be transferred to after it has been exported from the payment journal.',
                                ESM = 'Especifica la cuenta bancaria a la que se transferirá el importe una vez se haya exportado del diario de pagos.',
                                FRC = 'Spécifie le compte bancaire sur lequel le montant sera transféré après son exportation à partir du journal paiement.',
                                ENC = 'Specifies the bank account that the amount will be transferred to after it has been exported from the payment journal.';
                }
                field("Message to Recipient"; "Message to Recipient")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTipML = ENU = 'Specifies the message exported to the payment file when you use the Export Payments to File function in the Payment Journal window.',
                                ESM = 'Especifica el mensaje exportado al archivo de pago cuando se usa la función Exportar pagos a archivo en la ventana Diario pagos.',
                                FRC = 'Spécifie le message exporté vers le fichier de paiement lorsque vous utilisez la fonction Exporter les paiements dans un fichier dans la fenêtre Journal des paiements.',
                                ENC = 'Specifies the message exported to the payment file when you use the Export Payments to File function in the Payment Journal window.';
                    Visible = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    Style = Attention;
                    StyleExpr = HasPmtFileErr;
                    ToolTipML = ENU = 'Specifies a description of the entry. The field is automatically filled when the Account No. field is filled.',
                                ESM = 'Especifica una descripción del movimiento. El campo se rellena automáticamente al rellenar el campo N.º de cuenta.',
                                FRC = 'Spécifie une description de l''écriture. Le champ est automatiquement rempli lorsque le champ N° compte est rempli.',
                                ENC = 'Specifies a description of the entry. The field is automatically filled when the Account No. field is filled.';
                }
                field("Salespers./Purch. Code"; "Salespers./Purch. Code")
                {
                    ApplicationArea = Suite;
                    ToolTipML = ENU = 'Specifies the salesperson or purchaser who is linked to the journal line.',
                                ESM = 'Especifica el vendedor o el comprador vinculados a la línea del diario.',
                                FRC = 'Spécifie le représentant ou l''acheteur lié à la ligne journal.',
                                ENC = 'Specifies the salesperson or purchaser who is linked to the journal line.';
                    Visible = false;
                }
                field("Campaign No."; "Campaign No.")
                {
                    ToolTipML = ENU = 'Specifies the number of the campaign the journal line is linked to.',
                                ESM = 'Especifica el número de la campaña a la que está vinculada la línea del diario.',
                                FRC = 'Spécifie le numéro de la promotion à laquelle la ligne journal est liée.',
                                ENC = 'Specifies the number of the campaign the journal line is linked to.';
                    Visible = false;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = Suite;
                    AssistEdit = true;
                    ToolTipML = ENU = 'Specifies the code of the currency for the amounts on the journal line.',
                                ESM = 'Especifica el código de la divisa de los importes que constan en la línea del diario.',
                                FRC = 'Spécifie le code de la devise des montants de la ligne journal.',
                                ENC = 'Specifies the code of the currency for the amounts on the journal line.';

                    trigger OnAssistEdit();
                    begin
                        ChangeExchangeRate.SetParameter("Currency Code", "Currency Factor", "Posting Date");
                        if ChangeExchangeRate.RUNMODAL = ACTION::OK then
                            VALIDATE("Currency Factor", ChangeExchangeRate.GetParameter);

                        CLEAR(ChangeExchangeRate);
                    end;
                }
                field("Gen. Posting Type"; "Gen. Posting Type")
                {
                    ToolTipML = ENU = 'Specifies the general posting type that will be used when you post the entry on this journal line.',
                                ESM = 'Especifica el tipo de registro general que se utilizará cuando se registre el movimiento en esta línea del diario.',
                                FRC = 'Spécifie le type report qui est utilisé lorsque vous reportez l''écriture sur cette ligne journal.',
                                ENC = 'Specifies the general posting type that will be used when you post the entry on this journal line.';
                    Visible = false;
                }
                field("Gen. Bus. Posting Group"; "Gen. Bus. Posting Group")
                {
                    ToolTipML = ENU = 'Specifies the code of the general business posting group that will be used when you post the entry on the journal line.',
                                ESM = 'Especifica el código del grupo contable de negocio general que se utilizará cuando se registre el movimiento en la línea del diario.',
                                FRC = 'Spécifie le code du groupe de report marché utilisé lorsque vous reportez l''écriture sur la ligne journal.',
                                ENC = 'Specifies the code of the general business posting group that will be used when you post the entry on the journal line.';
                    Visible = false;
                }
                field("Gen. Prod. Posting Group"; "Gen. Prod. Posting Group")
                {
                    ToolTipML = ENU = 'Specifies the code of the general product posting group that will be used when you post the entry on the journal line.',
                                ESM = 'Especifica el código del grupo contable de producto general que se utilizará cuando se registre el movimiento en la línea del diario.',
                                FRC = 'Spécifie le code du groupe de report produit utilisé lorsque vous reportez l''écriture sur la ligne journal.',
                                ENC = 'Specifies the code of the general product posting group that will be used when you post the entry on the journal line.';
                    Visible = false;
                }
                field("VAT Bus. Posting Group"; "VAT Bus. Posting Group")
                {
                    ToolTipML = ENU = 'Specifies the Tax business posting group code that will be used when you post the entry on the journal line.',
                                ESM = 'Especifica el código de grupo de registro de IVA de negocio que se utilizará cuando se registre el movimiento en la línea del diario.',
                                FRC = 'Spécifie le code groupe de report marché TVA qui est utilisé lorsque vous reportez l''écriture sur la ligne journal.',
                                ENC = 'Specifies the tax business posting group code that will be used when you post the entry on the journal line.';
                    Visible = false;
                }
                field("VAT Prod. Posting Group"; "VAT Prod. Posting Group")
                {
                    ToolTipML = ENU = 'Specifies the code of the Tax product posting group that will be used when you post the entry on the journal line.',
                                ESM = 'Especifica el código del grupo de registro de IVA de producto que se utilizará cuando se registre el movimiento en la línea del diario.',
                                FRC = 'Spécifie le code du groupe de report produit TVA utilisé lorsque vous reportez l''écriture sur la ligne journal.',
                                ENC = 'Specifies the code of the tax product posting group that will be used when you post the entry on the journal line.';
                    Visible = false;
                }
                field("Debit Amount"; "Debit Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTipML = ENU = 'Specifies the total amount (including tax) that the journal line consists of, if it is a debit amount. The amount must be entered in the currency represented by the currency code on the line.',
                                ESM = 'Especifica el importe total (incluido el IVA) del que consta la línea del diario, si es un importe de débito. El importe debe expresarse en la divisa indicada por el código de divisa en la línea.',
                                FRC = 'Indique le montant total (TVA incluse) composant la ligne journal, s''il s''agit d''un montant débit. Le montant doit être entré dans la devise représentée par le code devise de la ligne.',
                                ENC = 'Specifies the total amount (including tax) that the journal line consists of, if it is a debit amount. The amount must be entered in the currency represented by the currency code on the line.';
                    Visible = false;
                }
                field("Credit Amount"; "Credit Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTipML = ENU = 'Specifies the total amount (including tax) that the journal line consists of, if it is a credit amount. The amount must be entered in the currency represented by the currency code on the line.',
                                ESM = 'Especifica el importe total (incluido el IVA) del que consta la línea del diario, si es un importe de crédito. El importe debe expresarse en la divisa indicada por el código de divisa en la línea.',
                                FRC = 'Indique le montant total (TVA incluse) composant la ligne journal, s''il s''agit d''un montant crédit. Le montant doit être entré dans la devise représentée par le code devise de la ligne.',
                                ENC = 'Specifies the total amount (including tax) that the journal line consists of, if it is a credit amount. The amount must be entered in the currency represented by the currency code on the line.';
                    Visible = false;
                }
                field("Payment Method Code"; "Payment Method Code")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                    ToolTipML = ENU = 'Specifies the payment method that was used to make the payment that resulted in the entry.',
                                ESM = 'Especifica la forma de pago que se utilizó para hacer el pago que resultó en el movimiento.',
                                FRC = 'Spécifie le mode de paiement qui a été utilisé pour effectuer le paiement qui a abouti à l''écriture.',
                                ENC = 'Specifies the payment method that was used to make the payment that resulted in the entry.';
                }
                field("Payment Reference"; "Payment Reference")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTipML = ENU = 'Specifies the payment of the purchase invoice.',
                                ESM = 'Especifica el pago de la factura de compra.',
                                FRC = 'Spécifie le paiement de la facture achat.',
                                ENC = 'Specifies the payment of the purchase invoice.';
                }
                field("Creditor No."; "Creditor No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTipML = ENU = 'Specifies the vendor who sent the purchase invoice.',
                                ESM = 'Especifica el proveedor que envió la factura de compra.',
                                FRC = 'Spécifie le fournisseur qui a envoyé la facture achat.',
                                ENC = 'Specifies the vendor who sent the purchase invoice.';
                    Visible = false;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                    Style = Attention;
                    StyleExpr = HasPmtFileErr;
                    ToolTipML = ENU = 'Specifies the total amount (including tax) that the journal line consists of.',
                                ESM = 'Especifica el importe total (IVA incluido) de la línea del diario.',
                                FRC = 'Spécifie le montant total (avec TVA) qui constitue la ligne journal.',
                                ENC = 'Specifies the total amount (including tax) that the journal line consists of.';
                }
                field("VAT Amount"; "VAT Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTipML = ENU = 'Specifies the amount of Tax included in the total amount.',
                                ESM = 'Especifica el importe de IVA incluido en el importe total.',
                                FRC = 'Spécifie le montant de TVA incluse dans le montant total.',
                                ENC = 'Specifies the amount of tax included in the total amount.';
                    Visible = false;
                }
                field("VAT Difference"; "VAT Difference")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTipML = ENU = 'Specifies the difference between the calculate tax amount and the tax amount that you have entered manually.',
                                ESM = 'Especifica la diferencia entre el importe de IVA calculado y el importe de IVA que ha introducido manualmente.',
                                FRC = 'Spécifie la différence entre le montant TVA calculé et le montant TVA que vous avez entré manuellement.',
                                ENC = 'Specifies the difference between the calculate tax amount and the tax amount that you have entered manually.';
                    Visible = false;
                }
                field("Bal. VAT Amount"; "Bal. VAT Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTipML = ENU = 'Specifies the amount of Bal. Tax included in the total amount.',
                                ESM = 'Especifica el importe de IVA de contrapartida en el importe total.',
                                FRC = 'Spécifie le montant de TVA contrepartie incluse dans le montant total.',
                                ENC = 'Specifies the amount of Bal. Tax included in the total amount.';
                    Visible = false;
                }
                field("Bal. VAT Difference"; "Bal. VAT Difference")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTipML = ENU = 'Specifies the difference between the calculate tax amount and the tax amount that you have entered manually.',
                                ESM = 'Especifica la diferencia entre el importe de IVA calculado y el importe de IVA que ha introducido manualmente.',
                                FRC = 'Spécifie la différence entre le montant TVA calculé et le montant TVA que vous avez entré manuellement.',
                                ENC = 'Specifies the difference between the calculate tax amount and the tax amount that you have entered manually.';
                    Visible = false;
                }
                field("Bal. Account Type"; "Bal. Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTipML = ENU = 'Specifies the code for the balancing account type that should be used in this journal line.',
                                ESM = 'Especifica el código del tipo de cuenta de contrapartida que se debe utilizar en esta línea del diario.',
                                FRC = 'Spécifie le code pour le type de compte de contrepartie qui devrait être utilisé pour cette ligne journal.',
                                ENC = 'Specifies the code for the balancing account type that should be used in this journal line.';
                }
                field("Bal. Account No."; "Bal. Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTipML = ENU = 'Specifies the number of the general ledger, customer, vendor, or bank account to which a balancing entry for the journal line will posted (for example, a cash account for cash purchases).',
                                ESM = 'Especifica el número de la cuenta de contabilidad, cliente, proveedor o banco en la que se registrará un movimiento de contrapartida de la línea del diario (por ejemplo, una cuenta de caja para compras en efectivo).',
                                FRC = 'Spécifie le numéro du compte général, client, fournisseur ou bancaire sur lequel une écriture de contrepartie pour la ligne journal sera reportée (par exemple, un compte de trésorerie pour les achats au comptant).',
                                ENC = 'Specifies the number of the general ledger, customer, vendor, or bank account to which a balancing entry for the journal line will posted (for example, a cash account for cash purchases).';

                    trigger OnValidate();
                    begin
                        GenJnlManagement.GetAccounts(Rec, AccName, BalAccName);
                        ShowShortcutDimCode(ShortcutDimCode);
                    end;
                }
                field("Bal. Gen. Posting Type"; "Bal. Gen. Posting Type")
                {
                    ToolTipML = ENU = 'Specifies the general posting type that will be used when you post the entry on the journal line.',
                                ESM = 'Especifica el tipo de registro general que se usará para registrar el movimiento en la línea del diario.',
                                FRC = 'Spécifie le type de report qui est utilisé lorsque vous reportez l''écriture sur la ligne journal.',
                                ENC = 'Specifies the general posting type that will be used when you post the entry on the journal line.';
                    Visible = false;
                }
                field("Bal. Gen. Bus. Posting Group"; "Bal. Gen. Bus. Posting Group")
                {
                    ToolTipML = ENU = 'Specifies the code of the general business posting group that will be used when you post the entry on the journal line.',
                                ESM = 'Especifica el código del grupo contable de negocio general que se utilizará cuando se registre el movimiento en la línea del diario.',
                                FRC = 'Spécifie le code du groupe de report marché utilisé lorsque vous reportez l''écriture sur la ligne journal.',
                                ENC = 'Specifies the code of the general business posting group that will be used when you post the entry on the journal line.';
                    Visible = false;
                }
                field("Bal. Gen. Prod. Posting Group"; "Bal. Gen. Prod. Posting Group")
                {
                    ToolTipML = ENU = 'Specifies the code of the general product posting group that will be used when you post the entry on the journal line.',
                                ESM = 'Especifica el código del grupo contable de producto general que se utilizará cuando se registre el movimiento en la línea del diario.',
                                FRC = 'Spécifie le code du groupe de report produit utilisé lorsque vous reportez l''écriture sur la ligne journal.',
                                ENC = 'Specifies the code of the general product posting group that will be used when you post the entry on the journal line.';
                    Visible = false;
                }
                field("Bal. VAT Bus. Posting Group"; "Bal. VAT Bus. Posting Group")
                {
                    ToolTipML = ENU = 'Specifies the code of the Tax business posting group that will be used when you post the entry on the journal line.',
                                ESM = 'Especifica el código del grupo de registro de IVA de negocio que se utilizará cuando se registre el movimiento en la línea del diario.',
                                FRC = 'Spécifie le code du groupe de report marché TVA utilisé lorsque vous reportez l''écriture sur la ligne journal.',
                                ENC = 'Specifies the code of the tax business posting group that will be used when you post the entry on the journal line.';
                    Visible = false;
                }
                field("Bal. VAT Prod. Posting Group"; "Bal. VAT Prod. Posting Group")
                {
                    ToolTipML = ENU = 'Specifies the code of the Tax product posting group that will be used when you post the entry on the journal line.',
                                ESM = 'Especifica el código del grupo de registro de IVA de producto que se utilizará cuando se registre el movimiento en la línea del diario.',
                                FRC = 'Spécifie le code du groupe de report produit TVA utilisé lorsque vous reportez l''écriture sur la ligne journal.',
                                ENC = 'Specifies the code of the tax product posting group that will be used when you post the entry on the journal line.';
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Suite;
                    ToolTipML = ENU = 'Specifies the code for Shortcut Dimension 1.',
                                ESM = 'Especifica el código de la dimensión del acceso directo 1.',
                                FRC = 'Spécifie le code pour le Raccourci dimension 1.',
                                ENC = 'Specifies the code for Shortcut Dimension 1.';
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Suite;
                    ToolTipML = ENU = 'Specifies the code for Shortcut Dimension 2.',
                                ESM = 'Especifica el código de la dimensión del acceso directo 2.',
                                FRC = 'Spécifie le code pour le Raccourci dimension 2.',
                                ENC = 'Specifies the code for Shortcut Dimension 2.';
                    Visible = false;
                }
                field("ShortcutDimCode[3]"; ShortcutDimCode[3])
                {
                    CaptionClass = '1,2,3';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(3),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;

                    trigger OnValidate();
                    begin
                        ValidateShortcutDimCode(3, ShortcutDimCode[3]);
                    end;
                }
                field("ShortcutDimCode[4]"; ShortcutDimCode[4])
                {
                    CaptionClass = '1,2,4';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(4),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;

                    trigger OnValidate();
                    begin
                        ValidateShortcutDimCode(4, ShortcutDimCode[4]);
                    end;
                }
                field("ShortcutDimCode[5]"; ShortcutDimCode[5])
                {
                    CaptionClass = '1,2,5';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(5),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;

                    trigger OnValidate();
                    begin
                        ValidateShortcutDimCode(5, ShortcutDimCode[5]);
                    end;
                }
                field("ShortcutDimCode[6]"; ShortcutDimCode[6])
                {
                    CaptionClass = '1,2,6';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(6),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;

                    trigger OnValidate();
                    begin
                        ValidateShortcutDimCode(6, ShortcutDimCode[6]);
                    end;
                }
                field("ShortcutDimCode[7]"; ShortcutDimCode[7])
                {
                    CaptionClass = '1,2,7';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(7),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;

                    trigger OnValidate();
                    begin
                        ValidateShortcutDimCode(7, ShortcutDimCode[7]);
                    end;
                }
                field("ShortcutDimCode[8]"; ShortcutDimCode[8])
                {
                    CaptionClass = '1,2,8';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(8),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;

                    trigger OnValidate();
                    begin
                        ValidateShortcutDimCode(8, ShortcutDimCode[8]);
                    end;
                }
                field("Applied (Yes/No)"; IsApplied)
                {
                    ApplicationArea = Basic, Suite;
                    CaptionML = ENU = 'Applied (Yes/No)',
                                ESM = 'Aplicado (Sí/No)',
                                FRC = 'Affecté (Oui/Non)',
                                ENC = 'Applied (Yes/No)';
                    ToolTipML = ENU = 'Specifies if the payment has been applied.',
                                ESM = 'Especifica si se liquidó el pago.',
                                FRC = 'Indique si le paiement a été affecté.',
                                ENC = 'Specifies if the payment has been applied.';
                }
                field("Applies-to Doc. Type"; "Applies-to Doc. Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTipML = ENU = 'Specifies the type of the posted document that this document or journal line will be applied to when you post, for example to register payment.',
                                ESM = 'Especifica el tipo del documento registrado en el que se liquidará este documento o esta línea del diario al registrar, por ejemplo, un pago.',
                                FRC = 'Spécifie le type du document reporté auquel ce document ou cette ligne journal sera affecté(e) lors du report, par exemple pour enregistrer un paiement.',
                                ENC = 'Specifies the type of the posted document that this document or journal line will be applied to when you post, for example to register payment.';
                }
                field("Applies-to Doc. No."; "Applies-to Doc. No.")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleTxt;
                    ToolTipML = ENU = 'Specifies the number of the posted document that this document or journal line will be applied to when you post, for example to register payment.',
                                ESM = 'Especifica el número del documento registrado en el que se liquidará este documento o esta línea del diario al registrar, por ejemplo, un pago.',
                                FRC = 'Spécifie le numéro du document reporté auquel ce document ou cette ligne journal sera affecté(e) lors du report, par exemple pour enregistrer un paiement.',
                                ENC = 'Specifies the number of the posted document that this document or journal line will be applied to when you post, for example to register payment.';
                }
                field("Applies-to ID"; "Applies-to ID")
                {
                    ApplicationArea = Basic, Suite;
                    StyleExpr = StyleTxt;
                    ToolTipML = ENU = 'Specifies the entries that will be applied to by the journal line if you use the Apply Entries facility.',
                                ESM = 'Especifica los movimientos que se liquidarán en la línea del diario si se usa la función Liquidar movs.',
                                FRC = 'Spécifie les écritures qui vont être affectées par la ligne journal si vous utilisez l''option Affecter les écritures.',
                                ENC = 'Specifies the entries that will be applied to by the journal line if you use the Apply Entries facility.';
                    Visible = false;
                }
                field(GetAppliesToDocDueDate; GetAppliesToDocDueDate)
                {
                    ApplicationArea = Basic, Suite;
                    CaptionML = ENU = 'Applies-to Doc. Due Date',
                                ESM = 'Liq. por fecha vencimiento documento',
                                FRC = 'Date d''échéance du doc. affectée à',
                                ENC = 'Applies-to Doc. Due Date';
                    StyleExpr = StyleTxt;
                    ToolTipML = ENU = 'Specifies the due date from the Applies-to Doc. on the journal line.',
                                ESM = 'Especifica la fecha de vencimiento de la liquidación por n.º de documento en la línea del diario.',
                                FRC = 'Spécifie la date d''échéance du champ Doc. affectation sur la ligne journal.',
                                ENC = 'Specifies the due date from the Applies-to Doc. on the journal line.';
                }
                field("Bank Payment Type"; "Bank Payment Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTipML = ENU = 'Specifies the code for the payment type to be used for the entry on the payment journal line.',
                                ESM = 'Especifica el código para el tipo de pago que se usará para el movimiento en la línea del diario de pagos.',
                                FRC = 'Spécifie le code du mode de paiement à utiliser pour l''écriture de la ligne journal paiement.',
                                ENC = 'Specifies the code for the payment type to be used for the entry on the payment journal line.';
                }
                field("Foreign Exchange Indicator"; "Foreign Exchange Indicator")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTipML = ENU = 'Specifies an exchange indicator for the journal line. This is a required field. You can edit this field in the Purchase Journal window.',
                                ESM = 'Especifica un indicador de divisa para la línea del diario. Este campo es obligatorio y puede editarlo en la ventana Diario compras.',
                                FRC = 'Spécifie un indicateur de change pour la ligne journal. Ce champ est obligatoire. Vous pouvez le modifier dans la fenêtre Journal des achats.',
                                ENC = 'Specifies an exchange indicator for the journal line. This is a required field. You can edit this field in the Purchase Journal window.';
                    Visible = false;
                }
                field("Foreign Exchange Ref.Indicator"; "Foreign Exchange Ref.Indicator")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTipML = ENU = 'Specifies an exchange reference indicator for the journal line. This is a required field. You can edit this field in the Purchase Journal and the Payment Journal window.',
                                ESM = 'Especifica un indicador de referencia de divisa para la línea del diario. Este campo es obligatorio y puede editarlo en las ventanas Diario compras y Diario pagos.',
                                FRC = 'Spécifie un indicateur de référence de change pour la ligne journal. Ce champ est obligatoire. Vous pouvez le modifier dans la fenêtre Journal des achats ou Journal des paiements.',
                                ENC = 'Specifies an exchange reference indicator for the journal line. This is a required field. You can edit this field in the Purchase Journal and the Payment Journal window.';
                    Visible = false;
                }
                field("Foreign Exchange Reference"; "Foreign Exchange Reference")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTipML = ENU = 'Specifies a foreign exchange reference code. This is a required field. You can edit this field in the Purchase Journal window.',
                                ESM = 'Especifica un código de referencia de divisa extranjera. Este campo es obligatorio y puede editarlo en la ventana Diario compras.',
                                FRC = 'Spécifie un code de référence de devise étrangère. Ce champ est obligatoire. Vous pouvez le modifier dans la fenêtre Journal des achats.',
                                ENC = 'Specifies a foreign exchange reference code. This is a required field. You can edit this field in the Purchase Journal window.';
                    Visible = false;
                }
                field("Origin. DFI ID Qualifier"; "Origin. DFI ID Qualifier")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTipML = ENU = 'Specifies the financial institution that will initiate the payment transactions sent by the originator. Select an ID for the originator''s Designated Financial Institution (DFI). This is a required field. You can edit this field in the Payment Journal window and the Purchase Journal window.',
                                ESM = 'Especifica qué institución financiera iniciará las transacciones de pago que envió el remitente. Seleccione un id. para la Institución financiera designada (DFI) del remitente. Este campo es obligatorio y puede editarlo en las ventanas Diario pagos y Diario compras.',
                                FRC = 'Spécifie l''organisme financier qui va lancer les transactions de paiement envoyées par l''initiateur. Sélectionnez un code pour l''organisme financier désigné (DFI) de l''initiateur. Ce champ est obligatoire. Vous pouvez le modifier dans la fenêtre Journal des paiements ou Journal des achats.',
                                ENC = 'Specifies the financial institution that will initiate the payment transactions sent by the originator. Select an ID for the originator''s Designated Financial Institution (DFI). This is a required field. You can edit this field in the Payment Journal window and the Purchase Journal window.';
                    Visible = false;
                }
                field("Receiv. DFI ID Qualifier"; "Receiv. DFI ID Qualifier")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTipML = ENU = 'Specifies the financial institution that will receive the payment transactions. Select an ID for the receiver''s Designated Financial Institution (DFI). This is a required field. You can edit this field in the Payment Journal window and the Purchase Journal window.',
                                ESM = 'Especifica qué institución financiera recibirá las transacciones de pago. Seleccione un id. para la Institución financiera designada (DFI) del destinatario. Este campo es obligatorio y puede editarlo en las ventanas Diario pagos y Diario compras.',
                                FRC = 'Spécifie l''organisme financier qui va recevoir les transactions de paiement. Sélectionnez un code pour l''organisme financier désigné (DFI) du destinataire. Ce champ est obligatoire. Vous pouvez le modifier dans la fenêtre Journal des paiements ou Journal des achats.',
                                ENC = 'Specifies the financial institution that will receive the payment transactions. Select an ID for the receiver''s Designated Financial Institution (DFI). This is a required field. You can edit this field in the Payment Journal window and the Purchase Journal window.';
                    Visible = false;
                }
                field("Transaction Type Code"; "Transaction Type Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTipML = ENU = 'Specifies a transaction type code for the general journal line. This code identifies the transaction type for the Electronic Funds Transfer (EFT).',
                                ESM = 'Especifica un código de tipo de transacción de la línea del diario general. Este código identifica el tipo de transacción para la transferencia electrónica de fondos (EFT).',
                                FRC = 'Spécifie un code type de transaction pour la ligne journal général. Ce code identifie le type de transaction pour le transfert de fonds électronique (EFT).',
                                ENC = 'Specifies a transaction type code for the general journal line. This code identifies the transaction type for the Electronic Funds Transfer (EFT).';
                }
                field("Gateway Operator OFAC Scr.Inc"; "Gateway Operator OFAC Scr.Inc")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTipML = ENU = 'Specifies an Office of Foreign Assets Control (OFAC) gateway operator screening indicator. This is a required field. You can edit this field in the Payment Journal window and the Purchase Journal window.',
                                ESM = 'Especifica un indicador de filtrado del operador de puerta de enlace perteneciente a la Oficina de control de activos extranjeros (OFAC). Este campo es obligatorio y puede editarlo en las ventanas Diario pagos y Diario compras.',
                                FRC = 'Spécifie un indicateur de détection d''opérateur de passerelle du Bureau de contrôle des actifs étrangers (OFAC). Ce champ est obligatoire. Vous pouvez le modifier dans la fenêtre Journal des paiements ou Journal des achats.',
                                ENC = 'Specifies an Office of Foreign Assets Control (OFAC) gateway operator screening indicator. This is a required field. You can edit this field in the Payment Journal window and the Purchase Journal window.';
                    Visible = false;
                }
                field("Secondary OFAC Scr.Indicator"; "Secondary OFAC Scr.Indicator")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTipML = ENU = 'Specifies a secondary Office of Foreign Assets Control (OFAC) gateway operator screening indicator. This is a required field. You can edit this field in the Payment Journal window and the Purchase Journal window.',
                                ESM = 'Especifica un indicador de filtrado secundario del operador de puerta de enlace perteneciente a la Oficina de control de activos extranjeros (OFAC). Este campo es obligatorio y puede editarlo en las ventanas Diario pagos y Diario compras.',
                                FRC = 'Spécifie un indicateur de détection d''opérateur de passerelle du Bureau de contrôle des actifs étrangers (OFAC) secondaire. Ce champ est obligatoire. Vous pouvez le modifier dans la fenêtre Journal des paiements ou Journal des achats.',
                                ENC = 'Specifies a secondary Office of Foreign Assets Control (OFAC) gateway operator screening indicator. This is a required field. You can edit this field in the Payment Journal window and the Purchase Journal window.';
                    Visible = false;
                }
                field("Transaction Code"; "Transaction Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTipML = ENU = 'Specifies a transaction code for the general journal line. This code identifies the transaction type for the Electronic Funds Transfer (EFT).',
                                ESM = 'Especifica un código de transacción para la línea del diario general. Este código identifica el tipo de transacción para la transferencia electrónica de fondos (EFT).',
                                FRC = 'Spécifie un code de transaction pour la ligne journal général. Ce code identifie le type de transaction pour le transfert de fonds électronique (EFT).',
                                ENC = 'Specifies a transaction code for the general journal line. This code identifies the transaction type for the Electronic Funds Transfer (EFT).';
                    Visible = false;
                }
                field("Company Entry Description"; "Company Entry Description")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTipML = ENU = 'Specifies a company description for the journal line.',
                                ESM = 'Especifica una descripción de la empresa para la línea del diario.',
                                FRC = 'Spécifie une description de compagnie pour la ligne journal.',
                                ENC = 'Specifies a company description for the journal line.';
                    Visible = false;
                }
                field("Payment Related Information 1"; "Payment Related Information 1")
                {
                    ToolTipML = ENU = 'Specifies payment related information for the general journal line.',
                                ESM = 'Especifica información relacionada con el pago de la línea del diario general.',
                                FRC = 'Spécifie des renseignements de paiement pour la ligne journal général.',
                                ENC = 'Specifies payment related information for the general journal line.';
                    Visible = false;
                }
                field("Payment Related Information 2"; "Payment Related Information 2")
                {
                    ToolTipML = ENU = 'Specifies additional payment related information for the general journal line.',
                                ESM = 'Especifica información adicional relacionada con el pago de la línea del diario general.',
                                FRC = 'Spécifie des renseignements de paiement supplémentaires pour la ligne journal général.',
                                ENC = 'Specifies additional payment related information for the general journal line.';
                    Visible = false;
                }
                field("Check Printed"; "Check Printed")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTipML = ENU = 'Specifies whether a check has been printed for the amount on the payment journal line.',
                                ESM = 'Especifica si un cheque se ha impreso por el importe de la línea del diario de pagos.',
                                FRC = 'Spécifie si un chèque a été imprimé pour le montant sur la ligne journal paiement.',
                                ENC = 'Specifies whether a cheque has been printed for the amount on the payment journal line.';
                }
                field("Reason Code"; "Reason Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTipML = ENU = 'Specifies the reason code that has been entered on the journal lines.',
                                ESM = 'Especifica el código de auditoría que se ha introducido en las líneas del diario.',
                                FRC = 'Spécifie le code motif qui a été saisi sur les lignes journal.',
                                ENC = 'Specifies the reason code that has been entered on the journal lines.';
                    Visible = false;
                }
                field("Source Type"; "Source Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTipML = ENU = 'Specifies the number of the customer or vendor that the payment relates to.',
                                ESM = 'Especifica el número del cliente o el proveedor con el que está relacionado el pago.',
                                FRC = 'Spécifie le numéro du client ou du fournisseur auquel le paiement fait référence.',
                                ENC = 'Specifies the number of the customer or vendor that the payment relates to.';
                    Visible = false;
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTipML = ENU = 'Specifies the number of the customer or vendor that the payment relates to.',
                                ESM = 'Especifica el número del cliente o el proveedor con el que está relacionado el pago.',
                                FRC = 'Spécifie le numéro du client ou du fournisseur auquel le paiement fait référence.',
                                ENC = 'Specifies the number of the customer or vendor that the payment relates to.';
                    Visible = false;
                }
                field(Comment; Comment)
                {
                    ToolTipML = ENU = 'Specifies a comment related to registering a payment.',
                                ESM = 'Especifica un comentario relacionado con el registro de un pago.',
                                FRC = 'Spécifie un commentaire lié à l''enregistrement d''un paiement.',
                                ENC = 'Specifies a comment related to registering a payment.';
                    Visible = false;
                }
                field("Exported to Payment File"; "Exported to Payment File")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTipML = ENU = 'Specifies that the payment journal line was exported to a payment file.',
                                ESM = 'Especifica que la línea del diario de pagos se ha exportado a un archivo de pagos.',
                                FRC = 'Spécifie que la ligne journal paiement a été exportée vers un fichier de paiement.',
                                ENC = 'Specifies that the payment journal line was exported to a payment file.';
                    Visible = false;
                }
                field(TotalExportedAmount; TotalExportedAmount)
                {
                    ApplicationArea = Basic, Suite;
                    CaptionML = ENU = 'Total Exported Amount',
                                ESM = 'Importe exportado total',
                                FRC = 'Montant total exporté',
                                ENC = 'Total Exported Amount';
                    DrillDown = true;
                    ToolTipML = ENU = 'Specifies the amount for the payment journal line that has been exported to payment files that are not canceled.',
                                ESM = 'Especifica el importe para la línea del diario de pagos que se ha exportado a archivos de pagos que no están cancelados.',
                                FRC = 'Spécifie le montant de la ligne journal paiement qui a été exporté vers des fichiers de paiement qui ne sont pas annulés.',
                                ENC = 'Specifies the amount for the payment journal line that has been exported to payment files that are not cancelled.';
                    Visible = false;

                    trigger OnDrillDown();
                    begin
                        DrillDownExportedAmount
                    end;
                }
                field("Has Payment Export Error"; "Has Payment Export Error")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTipML = ENU = 'Specifies that an error occurred when you used the Export Payments to File function in the Payment Journal window.',
                                ESM = 'Especifica que se ha producido un error al utilizar la función Exportar pagos a archivo en la ventana Diario pagos.',
                                FRC = 'Spécifie qu''une erreur s''est produite lorsque vous avez utilisé la fonction Exporter les paiements dans un fichier dans la fenêtre Journal des paiements.',
                                ENC = 'Specifies that an error occurred when you used the Export Payments to File function in the Payment Journal window.';
                    Visible = false;
                }
            }
            group(Control24)
            {
                fixed(Control80)
                {
                    group(Control82)
                    {
                        field(OverdueWarningText; OverdueWarningText)
                        {
                            ApplicationArea = Basic, Suite;
                            Style = Unfavorable;
                            StyleExpr = TRUE;
                            ToolTipML = ENU = 'Specifies the text that is displayed for overdue payments.',
                                        ESM = 'Especifica el texto que se muestra para los pagos vencidos.',
                                        FRC = 'Indique le texte qui s''affiche pour des Paiements échus.',
                                        ENC = 'Specifies the text that is displayed for overdue payments.';
                        }
                    }
                }
                fixed(Control1903561801)
                {
                    group("Account Name")
                    {
                        CaptionML = ENU = 'Account Name',
                                    ESM = 'Nombre cuenta',
                                    FRC = 'Nom du compte',
                                    ENC = 'Account Name';
                        field(AccName; AccName)
                        {
                            ApplicationArea = Basic, Suite;
                            Editable = false;
                            ShowCaption = false;
                            ToolTipML = ENU = 'Specifies the name of the account.',
                                        ESM = 'Especifica el nombre de la cuenta.',
                                        FRC = 'Spécifie le nom du compte.',
                                        ENC = 'Specifies the name of the account.';
                        }
                    }
                    group("Bal. Account Name")
                    {
                        CaptionML = ENU = 'Bal. Account Name',
                                    ESM = 'Nombre contrapartida',
                                    FRC = 'Nom de compte de solde',
                                    ENC = 'Bal. Account Name';
                        field(BalAccName; BalAccName)
                        {
                            ApplicationArea = Basic, Suite;
                            CaptionML = ENU = 'Bal. Account Name',
                                        ESM = 'Nombre contrapartida',
                                        FRC = 'Nom de compte de solde',
                                        ENC = 'Bal. Account Name';
                            Editable = false;
                            ToolTipML = ENU = 'Specifies the name of the balancing account that has been entered on the journal line.',
                                        ESM = 'Especifica el nombre de la cuenta de contrapartida introducida en la línea del diario.',
                                        FRC = 'Spécifie le nom du compte de contrepartie qui a été entré sur la ligne journal.',
                                        ENC = 'Specifies the name of the balancing account that has been entered on the journal line.';
                        }
                    }
                    group(Balance)
                    {
                        CaptionML = ENU = 'Balance',
                                    ESM = 'Saldo',
                                    FRC = 'Solde',
                                    ENC = 'Balance';
                        field(Balance2; Balance + "Balance (LCY)" - xRec."Balance (LCY)")
                        {
                            ApplicationArea = All;
                            AutoFormatType = 1;
                            CaptionML = ENU = 'Balance',
                                        ESM = 'Saldo',
                                        FRC = 'Solde',
                                        ENC = 'Balance';
                            Editable = false;
                            ToolTipML = ENU = 'Specifies the balance that has accumulated in the payment journal on the line where the cursor is.',
                                        ESM = 'Especifica el saldo que se ha acumulado en el diario de pagos en la línea en la que está situado el cursor.',
                                        FRC = 'Spécifie le solde qui s''est accumulé dans le journal des paiements sur la ligne où se trouve le pointeur de la souris.',
                                        ENC = 'Specifies the balance that has accumulated in the payment journal on the line where the cursor is.';
                            Visible = BalanceVisible;
                        }
                    }
                    group("Total Balance")
                    {
                        CaptionML = ENU = 'Total Balance',
                                    ESM = 'Saldo total',
                                    FRC = 'Solde total',
                                    ENC = 'Total Balance';
                        field(TotalBalance; TotalBalance + "Balance (LCY)" - xRec."Balance (LCY)")
                        {
                            ApplicationArea = All;
                            AutoFormatType = 1;
                            CaptionML = ENU = 'Total Balance',
                                        ESM = 'Saldo total',
                                        FRC = 'Solde total',
                                        ENC = 'Total Balance';
                            Editable = false;
                            ToolTipML = ENU = 'Specifies the total balance in the payment journal.',
                                        ESM = 'Especifica el saldo total del diario de pagos.',
                                        FRC = 'Spécifie le solde total dans le journal des paiements.',
                                        ENC = 'Specifies the total balance in the payment journal.';
                            Visible = TotalBalanceVisible;
                        }
                    }
                }
            }
        }
        area(factboxes)
        {
            part(IncomingDocAttachFactBox; "Incoming Doc. Attach. FactBox")
            {
                ApplicationArea = Basic, Suite;
                ShowFilter = false;
            }
            part("Payment File Errors"; "Payment Journal Errors Part")
            {
                ApplicationArea = Basic, Suite;
                CaptionML = ENU = 'Payment File Errors',
                            ESM = 'Errores del archivo de pagos',
                            FRC = 'Erreurs fichier de paiement',
                            ENC = 'Payment File Errors';
                SubPageLink = "Journal Template Name" = FIELD("Journal Template Name"),
                              "Journal Batch Name" = FIELD("Journal Batch Name"),
                              "Journal Line No." = FIELD("Line No.");
            }
            part(Control1900919607; "Dimension Set Entries FactBox")
            {
                SubPageLink = "Dimension Set ID" = FIELD("Dimension Set ID");
                Visible = false;
            }
            part(WorkflowStatusBatch; "Workflow Status FactBox")
            {
                ApplicationArea = Suite;
                CaptionML = ENU = 'Batch Workflows',
                            ESM = 'Flujos de trabajo por lotes',
                            FRC = 'Flux de travail par lots',
                            ENC = 'Batch Workflows';
                Editable = false;
                Enabled = false;
                ShowFilter = false;
                Visible = ShowWorkflowStatusOnBatch;
            }
            part(WorkflowStatusLine; "Workflow Status FactBox")
            {
                ApplicationArea = Suite;
                CaptionML = ENU = 'Line Workflows',
                            ESM = 'Flujos de trabajo de línea',
                            FRC = 'Flux de travail ligne',
                            ENC = 'Line Workflows';
                Editable = false;
                Enabled = false;
                ShowFilter = false;
                Visible = ShowWorkflowStatusOnLine;
            }
            systempart(Control1900383207; Links)
            {
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Line")
            {
                CaptionML = ENU = '&Line',
                            ESM = '&Línea',
                            FRC = '&Ligne',
                            ENC = '&Line';
                Image = Line;
                action(Dimensions)
                {
                    AccessByPermission = TableData Dimension = R;
                    ApplicationArea = Suite;
                    CaptionML = ENU = 'Dimensions',
                                ESM = 'Dimensiones',
                                FRC = 'Dimensions',
                                ENC = 'Dimensions';
                    Image = Dimensions;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'Shift+Ctrl+D';
                    ToolTipML = ENU = 'View or edits dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.',
                                ESM = 'Permite ver o editar dimensiones, como el área, el proyecto o el departamento, que pueden asignarse a los documentos de venta y compra para distribuir costos y analizar el historial de transacciones.',
                                FRC = 'Affichez ou modifiez des dimensions, par exemple, région, projet ou département, que vous pouvez affecter à des documents vente et achat pour répartir les coûts et analyser l''historique des transactions.',
                                ENC = 'View or edits dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyse transaction history.';

                    trigger OnAction();
                    begin
                        ShowDimensions;
                        CurrPage.SAVERECORD;
                    end;
                }
                action(IncomingDoc)
                {
                    AccessByPermission = TableData "Incoming Document" = R;
                    ApplicationArea = Basic, Suite;
                    CaptionML = ENU = 'Incoming Document',
                                ESM = 'Documento entrante',
                                FRC = 'Document entrant',
                                ENC = 'Incoming Document';
                    Image = Document;
                    Promoted = true;
                    PromotedCategory = Process;
                    Scope = Repeater;
                    ToolTipML = ENU = 'View or create an incoming document record that is linked to the entry or document.',
                                ESM = 'Permite ver o crear un registro de documentos entrantes que esté vinculado al movimiento o al documento.',
                                FRC = 'Affichez ou créez un enregistrement de document entrant qui est lié à l''écriture ou au document.',
                                ENC = 'View or create an incoming document record that is linked to the entry or document.';

                    trigger OnAction();
                    var
                        IncomingDocument: Record "Incoming Document";
                    begin
                        VALIDATE("Incoming Document Entry No.", IncomingDocument.SelectIncomingDocument("Incoming Document Entry No.", RECORDID));
                    end;
                }
            }
            group("A&ccount")
            {
                CaptionML = ENU = 'A&ccount',
                            ESM = '&Cuenta',
                            FRC = '&Compte',
                            ENC = 'A&ccount';
                Image = ChartOfAccounts;
                action(Card)
                {
                    ApplicationArea = Basic, Suite;
                    CaptionML = ENU = 'Card',
                                ESM = 'Ficha',
                                FRC = 'Fiche',
                                ENC = 'Card';
                    Image = EditLines;
                    RunObject = Codeunit "Gen. Jnl.-Show Card";
                    ShortCutKey = 'Shift+F7';
                    ToolTipML = ENU = 'View or change detailed information about the record that is being processed on the journal line.',
                                ESM = 'Permite ver o cambiar la información detallada sobre el registro que se está procesando en la línea del diario.',
                                FRC = 'Affichez ou modifiez des informations détaillées sur l''enregistrement en cours de traitement sur la ligne journal.',
                                ENC = 'View or change detailed information about the record that is being processed on the journal line.';
                }
                action("Ledger E&ntries")
                {
                    ApplicationArea = Basic, Suite;
                    CaptionML = ENU = 'Ledger E&ntries',
                                ESM = '&Movimientos',
                                FRC = 'É&critures comptables',
                                ENC = 'Ledger E&ntries';
                    Image = GLRegisters;
                    Promoted = false;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    RunObject = Codeunit "Gen. Jnl.-Show Entries";
                    ShortCutKey = 'Ctrl+F7';
                    ToolTipML = ENU = 'View the history of transactions that have been posted for the selected record.',
                                ESM = 'Permite ver el historial de transacciones que se han registrado para el registro seleccionado.',
                                FRC = 'Affichez l''historique des transactions qui ont été reportées pour l''enregistrement sélectionné.',
                                ENC = 'View the history of transactions that have been posted for the selected record.';
                }
            }
            group("&Payments")
            {
                CaptionML = ENU = '&Payments',
                            ESM = '&Pagos',
                            FRC = '&Paiements',
                            ENC = '&Payments';
                Image = Payment;
                action(SuggestVendorPayments)
                {
                    ApplicationArea = Basic, Suite;
                    CaptionML = ENU = 'Suggest Vendor Payments',
                                ESM = 'Proponer pagos a proveedores',
                                FRC = 'Proposer paiements fournisseur',
                                ENC = 'Suggest Vendor Payments';
                    Ellipsis = true;
                    Image = SuggestVendorPayments;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTipML = ENU = 'Create payment suggestion as lines in the payment journal.',
                                ESM = 'Crea una sugerencia de pago como líneas en el diario de pagos.',
                                FRC = 'Créez une proposition de paiement en tant que lignes dans le journal paiement.',
                                ENC = 'Create payment suggestion as lines in the payment journal.';

                    trigger OnAction();
                    var
                        SuggestVendorPayments: Report "Suggest Vendor Payments";
                    begin
                        CLEAR(SuggestVendorPayments);
                        SuggestVendorPayments.SetGenJnlLine(Rec);
                        SuggestVendorPayments.RUNMODAL;
                    end;
                }
                action(PreviewCheck)
                {
                    ApplicationArea = Basic, Suite;
                    CaptionML = ENU = 'P&review Check',
                                ESM = 'Vista pr&eliminar cheque',
                                FRC = 'A&perçu du chèque',
                                ENC = 'P&review Cheque';
                    Image = ViewCheck;
                    RunObject = Page "Check Preview";
                    RunPageLink = "Journal Template Name" = FIELD("Journal Template Name"),
                                  "Journal Batch Name" = FIELD("Journal Batch Name"),
                                  "Line No." = FIELD("Line No.");
                    ToolTipML = ENU = 'Preview the check before printing it.',
                                ESM = 'Muestra una vista previa de un cheque antes de imprimirlo.',
                                FRC = 'Aperçu du chèque avant de l''imprimer.',
                                ENC = 'Preview the cheque before printing it.';
                }
                action(PrintCheck)
                {
                    AccessByPermission = TableData "Check Ledger Entry" = R;
                    ApplicationArea = Basic, Suite;
                    CaptionML = ENU = 'Print Check',
                                ESM = 'Imprimir cheque',
                                FRC = 'Imprimer chèque',
                                ENC = 'Print Cheque';
                    Ellipsis = true;
                    Image = PrintCheck;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTipML = ENU = 'Prepare to print the check.',
                                ESM = 'Prepara el cheque para imprimir.',
                                FRC = 'Préparez-vous à imprimer le chèque.',
                                ENC = 'Prepare to print the cheque.';

                    trigger OnAction();
                    begin
                        GenJnlLine.RESET;
                        GenJnlLine.COPY(Rec);
                        GenJnlLine.SETRANGE("Journal Template Name", "Journal Template Name");
                        GenJnlLine.SETRANGE("Journal Batch Name", "Journal Batch Name");
                        DocPrint.PrintCheck(GenJnlLine);
                        CODEUNIT.RUN(CODEUNIT::"Adjust Gen. Journal Balance", Rec);
                    end;
                }
                group("Electronic Payments")
                {
                    CaptionML = ENU = 'Electronic Payments',
                                ESM = 'Pagos electrónicos',
                                FRC = 'Paiements électroniques',
                                ENC = 'Electronic Payments';
                    Image = ElectronicPayment;
                    action("E&xport")
                    {
                        CaptionML = ENU = 'E&xport',
                                    ESM = 'E&xportar',
                                    FRC = 'E&xporter',
                                    ENC = 'E&xport';
                        Ellipsis = true;
                        Image = Export;
                        Promoted = true;
                        PromotedCategory = Process;
                        ToolTipML = ENU = 'Export payments on journal lines that are set to electronic payment to a file prior to transmitting the file to your bank.',
                                    ESM = 'Permite exportar a un archivo los pagos en las líneas de diario establecidas para el pago electrónico, antes de transmitir el archivo al banco.',
                                    FRC = 'Exportez les paiements des lignes journal à effectuer électroniquement dans un fichier avant de transmettre ce fichier à votre banque.',
                                    ENC = 'Export payments on journal lines that are set to electronic payment to a file prior to transmitting the file to your bank.';

                        trigger OnAction();
                        var
                            BankAccount: Record "Bank Account";
                            BulkVendorRemitReporting: Codeunit "Bulk Vendor Remit Reporting";
                            GenJnlLineRecordRef: RecordRef;
                        begin
                            GenJnlLine.RESET;
                            GenJnlLine := Rec;
                            GenJnlLine.SETRANGE("Journal Template Name", "Journal Template Name");
                            GenJnlLine.SETRANGE("Journal Batch Name", "Journal Batch Name");

                            if (("Bal. Account Type" = "Bal. Account Type"::"Bank Account") and
                                BankAccount.GET("Bal. Account No.") and (BankAccount."Payment Export Format" <> ''))
                            then begin
                                CODEUNIT.RUN(CODEUNIT::"Export Payment File (Yes/No)", GenJnlLine);
                                exit;
                            end;

                            if GenJnlLine.IsExportedToPaymentFile then
                                if not CONFIRM(ExportAgainQst) then
                                    exit;

                            GenJnlLineRecordRef.GETTABLE(GenJnlLine);
                            GenJnlLineRecordRef.SETVIEW(GenJnlLine.GETVIEW);
                            BulkVendorRemitReporting.RunWithRecord(GenJnlLine);
                        end;
                    }
                    action(Void)
                    {
                        CaptionML = ENU = 'Void',
                                    ESM = 'Anular',
                                    FRC = 'Nul',
                                    ENC = 'Void';
                        Ellipsis = true;
                        Image = VoidElectronicDocument;
                        Promoted = true;
                        PromotedCategory = Process;
                        ToolTipML = ENU = 'Void the exported electronic payment file.',
                                    ESM = 'Permite anular el archivo exportado de pagos electrónicos.',
                                    FRC = 'Annulez le fichier de paiement électronique exporté.',
                                    ENC = 'Void the exported electronic payment file.';

                        trigger OnAction();
                        begin
                            GenJnlLine.RESET;
                            GenJnlLine := Rec;
                            GenJnlLine.SETRANGE("Journal Template Name", "Journal Template Name");
                            GenJnlLine.SETRANGE("Journal Batch Name", "Journal Batch Name");
                            CLEAR(VoidTransmitElecPayments);
                            VoidTransmitElecPayments.SetUsageType(1);   // Void
                            VoidTransmitElecPayments.SETTABLEVIEW(GenJnlLine);
                            VoidTransmitElecPayments.RUNMODAL;
                        end;
                    }
                    action(Transmit)
                    {
                        CaptionML = ENU = 'Transmit',
                                    ESM = 'Transmitir',
                                    FRC = 'Transmettre',
                                    ENC = 'Transmit';
                        Ellipsis = true;
                        Image = TransmitElectronicDoc;
                        Promoted = true;
                        PromotedCategory = Process;
                        ToolTipML = ENU = 'Transmit the exported electronic payment file to the bank.',
                                    ESM = 'Permite transmitir al banco el archivo exportado de pagos electrónicos.',
                                    FRC = 'Transmettez le fichier de paiement électronique exporté à la banque.',
                                    ENC = 'Transmit the exported electronic payment file to the bank.';

                        trigger OnAction();
                        begin
                            GenJnlLine.RESET;
                            GenJnlLine := Rec;
                            GenJnlLine.SETRANGE("Journal Template Name", "Journal Template Name");
                            GenJnlLine.SETRANGE("Journal Batch Name", "Journal Batch Name");
                            CLEAR(VoidTransmitElecPayments);
                            VoidTransmitElecPayments.SetUsageType(2);   // Transmit
                            VoidTransmitElecPayments.SETTABLEVIEW(GenJnlLine);
                            VoidTransmitElecPayments.RUNMODAL;
                        end;
                    }
                }
                action("Void Check")
                {
                    ApplicationArea = Basic, Suite;
                    CaptionML = ENU = 'Void Check',
                                ESM = 'Anular cheque',
                                FRC = 'Annuler chèque',
                                ENC = 'Void Cheque';
                    Image = VoidCheck;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTipML = ENU = 'Void the check if, for example, the check is not cashed by the bank.',
                                ESM = 'Permite anular el cheque si, por ejemplo, el banco no lo cobra.',
                                FRC = 'Annulez le chèque si, par exemple, le chèque n''est pas encaissé par la banque.',
                                ENC = 'Void the cheque if, for example, the cheque is not cashed by the bank.';

                    trigger OnAction();
                    begin
                        TESTFIELD("Bank Payment Type", "Bank Payment Type"::"Computer Check");
                        TESTFIELD("Check Printed", true);
                        if CONFIRM(Text000, false, "Document No.") then
                            CheckManagement.VoidCheck(Rec);
                    end;
                }
                action("Void &All Checks")
                {
                    ApplicationArea = Basic, Suite;
                    CaptionML = ENU = 'Void &All Checks',
                                ESM = 'Anular t&odos los cheques',
                                FRC = 'Annuler &tous les chèques',
                                ENC = 'Void &All Cheques';
                    Image = VoidAllChecks;
                    ToolTipML = ENU = 'Void all checks if, for example, the checks are not cashed by the bank.',
                                ESM = 'Permite anular todos los cheques si, por ejemplo, el banco no los cobra.',
                                FRC = 'Annulez tous les chèques si, par exemple, les chèques ne sont pas encaissés par la banque.',
                                ENC = 'Void all cheques if, for example, the cheques are not cashed by the bank.';

                    trigger OnAction();
                    begin
                        if CONFIRM(Text001, false) then begin
                            GenJnlLine.RESET;
                            GenJnlLine.COPY(Rec);
                            GenJnlLine.SETRANGE("Bank Payment Type", "Bank Payment Type"::"Computer Check");
                            GenJnlLine.SETRANGE("Check Printed", true);
                            if GenJnlLine.FIND('-') then
                                repeat
                                    GenJnlLine2 := GenJnlLine;
                                    CheckManagement.VoidCheck(GenJnlLine2);
                                until GenJnlLine.NEXT = 0;
                        end;
                    end;
                }
                action(CreditTransferRegEntries)
                {
                    ApplicationArea = Basic, Suite;
                    CaptionML = ENU = 'Credit Transfer Reg. Entries',
                                ESM = 'Movimientos de reg. de transferencia de crédito',
                                FRC = 'Écritures reg. virement',
                                ENC = 'Credit Transfer Reg. Entries';
                    Image = ExportReceipt;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    RunObject = Codeunit "Gen. Jnl.-Show CT Entries";
                    ToolTipML = ENU = 'View or edit the credit transfer entries that are related to file export for credit transfers.',
                                ESM = 'Permite ver o editar los movimientos de transferencia de crédito que están relacionados con la exportación de archivos para transferencias de crédito.',
                                FRC = 'Affichez ou modifiez les écritures de virement qui sont liées à l''exportation de fichiers pour les virements.',
                                ENC = 'View or edit the credit transfer entries that are related to file export for credit transfers.';
                }
                action(CreditTransferRegisters)
                {
                    ApplicationArea = Basic, Suite;
                    CaptionML = ENU = 'Credit Transfer Registers',
                                ESM = 'Registros de transferencia de crédito',
                                FRC = 'Registres virement',
                                ENC = 'Credit Transfer Registers';
                    Image = ExportElectronicDocument;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    RunObject = Page "Credit Transfer Registers";
                    ToolTipML = ENU = 'View or edit the payment files that have been exported in connection with credit transfers.',
                                ESM = 'Permite ver o editar los archivos de pago que se han exportado en relación con las transferencias de crédito.',
                                FRC = 'Affichez ou modifiez les fichiers paiement qui ont été exportés dans le cadre de virements.',
                                ENC = 'View or edit the payment files that have been exported in connection with credit transfers.';
                }
            }
            action(Approvals)
            {
                AccessByPermission = TableData "Approval Entry" = R;
                ApplicationArea = Suite;
                CaptionML = ENU = 'Approvals',
                            ESM = 'Aprobaciones',
                            FRC = 'Approbations',
                            ENC = 'Approvals';
                Image = Approvals;
                ToolTipML = ENU = 'View a list of the records that are waiting to be approved. For example, you can see who requested the record to be approved, when it was sent, and when it is due to be approved.',
                            ESM = 'Permite ver una lista de los registros en espera de aprobación. Por ejemplo, puede ver quién ha solicitado la aprobación del registro, cuándo se envió y la fecha de vencimiento de la aprobación.',
                            FRC = 'Affichez une liste des enregistrements en attente d''approbation. Par exemple, vous pouvez voir qui a demandé l''approbation de l''enregistrement, quand il a été envoyé et quand son approbation est due.',
                            ENC = 'View a list of the records that are waiting to be approved. For example, you can see who requested the record to be approved, when it was sent, and when it is due to be approved.';

                trigger OnAction();
                var
                    GenJournalLine: Record "Gen. Journal Line";
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                begin
                    GetCurrentlySelectedLines(GenJournalLine);
                    ApprovalsMgmt.ShowJournalApprovalEntries(GenJournalLine);
                end;
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                CaptionML = ENU = 'F&unctions',
                            ESM = 'Acci&ones',
                            FRC = 'F&onctions',
                            ENC = 'F&unctions';
                Image = "Action";
                action("Renumber Document Numbers")
                {
                    ApplicationArea = Basic, Suite;
                    CaptionML = ENU = 'Renumber Document Numbers',
                                ESM = 'Volver a numerar los números de documento',
                                FRC = 'Renuméroter des documents',
                                ENC = 'Renumber Document Numbers';
                    Image = EditLines;
                    ToolTipML = ENU = 'Resort the numbers in the Document No. column to avoid posting errors because the document numbers are not in sequence. Entry applications and line groupings are preserved.',
                                ESM = 'Permite reordenar los números de la columna N.º documento para evitar errores de registro debido a que los números de documento no formen una secuencia. Las liquidaciones de movimientos y las agrupaciones de líneas se conservan.',
                                FRC = 'Réaffectez les priorités des numéros dans la colonne N° document pour éviter les erreurs de report dues au fait que les numéros de document ne sont pas dans l''ordre. L''affectation des écritures et les groupements de lignes sont préservés.',
                                ENC = 'Resort the numbers in the Document No. column to avoid posting errors because the document numbers are not in sequence. Entry applications and line groupings are preserved.';

                    trigger OnAction();
                    begin
                        RenumberDocumentNo
                    end;
                }
                action(ApplyEntries)
                {
                    ApplicationArea = Basic, Suite;
                    CaptionML = ENU = 'Apply Entries',
                                ESM = 'Liquidar movs.',
                                FRC = 'Affecter les écritures',
                                ENC = 'Apply Entries';
                    Ellipsis = true;
                    Image = ApplyEntries;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Codeunit "Gen. Jnl.-Apply";
                    ShortCutKey = 'Shift+F11';
                    ToolTipML = ENU = 'Select one or more ledger entries that you want to apply this record to so that the related posted documents are closed as paid or refunded.',
                                ESM = 'Permite seleccionar uno o varios movimientos que desea liquidar en este registro para que los documentos registrados relacionados se cierren como pagados o reembolsados.',
                                FRC = 'Sélectionnez une ou plusieurs écritures que vous voulez affecter avec cet enregistrement afin que les documents reportés concernés soient fermés comme étant payés ou remboursés.',
                                ENC = 'Select one or more ledger entries that you want to apply this record to so that the related posted documents are closed as paid or refunded.';
                }
                action(ExportPaymentsToFile)
                {
                    ApplicationArea = Basic, Suite;
                    CaptionML = ENU = 'Export Payments to File',
                                ESM = 'Exportar pagos a archivo',
                                FRC = 'Exporter les paiements dans un fichier',
                                ENC = 'Export Payments to File';
                    Ellipsis = true;
                    Image = ExportFile;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ToolTipML = ENU = 'Export a file with the payment information on the journal lines.',
                                ESM = 'Exporta un archivo con la información de pago de las líneas del diario.',
                                FRC = 'Exportez un fichier avec les informations de paiement sur les lignes journal.',
                                ENC = 'Export a file with the payment information on the journal lines.';

                    trigger OnAction();
                    var
                        GenJnlLine: Record "Gen. Journal Line";
                    begin
                        GenJnlLine.COPYFILTERS(Rec);
                        GenJnlLine.FINDFIRST;
                        GenJnlLine.ExportPaymentFile;
                    end;
                }
                action(CalculatePostingDate)
                {
                    ApplicationArea = Basic, Suite;
                    CaptionML = ENU = 'Calculate Posting Date',
                                ESM = 'Calcular fecha de registro',
                                FRC = 'Calculer la date de report',
                                ENC = 'Calculate Posting Date';
                    Image = CalcWorkCenterCalendar;
                    Promoted = true;
                    PromotedCategory = Category5;
                    ToolTipML = ENU = 'Calculate the date that will appear as the posting date on the journal lines.',
                                ESM = 'Calcula la fecha que aparecerá como fecha de registro en las líneas del diario.',
                                FRC = 'Calculez la date qui apparaîtra comme date de report sur les lignes journal.',
                                ENC = 'Calculate the date that will appear as the posting date on the journal lines.';

                    trigger OnAction();
                    begin
                        CalculatePostingDate;
                    end;
                }
                action("Insert Conv. $ Rndg. Lines")
                {
                    ApplicationArea = Basic, Suite;
                    CaptionML = ENU = 'Insert Conv. $ Rndg. Lines',
                                ESM = 'Insertar lín. conv. redon. $',
                                FRC = 'Insérer lignes arr. conv. ($)',
                                ENC = 'Insert Conv. $ Rndg. Lines';
                    Image = InsertCurrency;
                    RunObject = Codeunit "Adjust Gen. Journal Balance";
                    ToolTipML = ENU = 'Insert a rounding correction line in the journal. This rounding correction line will balance in $ when amounts in the foreign currency also balance. You can then post the journal.',
                                ESM = 'Inserta una línea de corrección de redondeo en el diario. Esta línea de corrección de redondeo se compensará en $ cuando los importes en divisa extranjera también se compensen. A continuación, se podrá registrar el diario.',
                                FRC = 'Insérez une ligne correction arrondissement dans le journal. Cette ligne correction d''arrondissement permet d''équilibrer en devise société lorsque les montants en devise étrangère sont également équilibrés. Vous pouvez alors reporter le journal.',
                                ENC = 'Insert a rounding correction line in the journal. This rounding correction line will balance in $ when amounts in the foreign currency also balance. You can then post the journal.';
                }
                action(PositivePayExport)
                {
                    CaptionML = ENU = 'Positive Pay Export',
                                ESM = 'Exportación de Positive Pay',
                                FRC = 'Exportation Positive Pay',
                                ENC = 'Positive Pay Export';
                    Image = Export;

                    trigger OnAction();
                    var
                        GenJnlBatch: Record "Gen. Journal Batch";
                        BankAcc: Record "Bank Account";
                    begin
                        GenJnlBatch.GET("Journal Template Name", CurrentJnlBatchName);
                        if GenJnlBatch."Bal. Account Type" = GenJnlBatch."Bal. Account Type"::"Bank Account" then begin
                            BankAcc."No." := GenJnlBatch."Bal. Account No.";
                            PAGE.RUN(PAGE::"Positive Pay Export", BankAcc);
                        end;
                    end;
                }
            }
            group("P&osting")
            {
                CaptionML = ENU = 'P&osting',
                            ESM = '&Registro',
                            FRC = 'Rep&ort',
                            ENC = 'P&osting';
                Image = Post;
                action(Reconcile)
                {
                    ApplicationArea = Basic, Suite;
                    CaptionML = ENU = 'Reconcile',
                                ESM = 'Control',
                                FRC = 'Rapprocher',
                                ENC = 'Reconcile';
                    Image = Reconcile;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ShortCutKey = 'Ctrl+F11';
                    ToolTipML = ENU = 'View the balances on bank accounts that are marked for reconciliation, usually liquid accounts.',
                                ESM = 'Permite ver los saldos de las cuentas bancarias marcadas para la conciliación, normalmente cuentas de liquidez.',
                                FRC = 'Affichez les soldes des comptes bancaires qui sont destinés au rapprochement, en général des comptes de liquidités.',
                                ENC = 'View the balances on bank accounts that are marked for reconciliation, usually liquid accounts.';

                    trigger OnAction();
                    begin
                        GLReconcile.SetGenJnlLine(Rec);
                        GLReconcile.RUN;
                    end;
                }
                action(PreCheck)
                {
                    ApplicationArea = Basic, Suite;
                    CaptionML = ENU = 'Vendor Pre-Payment Journal',
                                ESM = 'Diario de anticipos del proveedor',
                                FRC = 'Journal des paiements anticipés du fournisseur',
                                ENC = 'Vendor Pre-Payment Journal';
                    Image = PreviewChecks;
                    ToolTipML = ENU = 'View journal line entries, payment discounts, discount tolerance amounts, payment tolerance, and any errors associated with the entries. You can use the results of the report to review payment journal lines and to review the results of posting before you actually post.',
                                ESM = 'Permite ver los movimientos de líneas del diario, los descuentos por pronto pago, los importes de tolerancia de descuento, la tolerancia de pago y los errores asociados a los movimientos. Puede usar los resultados del informe para revisar la líneas del diario de pagos y los resultados del registro antes de proceder al registro real.',
                                FRC = 'Affichez les écritures ligne journal, les escomptes de paiement, les montants de tolérance d''escompte, la tolérance de règlement et toute erreur associée aux écritures. Vous pouvez utiliser les résultats du rapport pour examiner les lignes journal paiement ainsi que les résultats du report avant le report effectif.',
                                ENC = 'View journal line entries, payment discounts, discount tolerance amounts, payment tolerance, and any errors associated with the entries. You can use the results of the report to review payment journal lines and to review the results of posting before you actually post.';

                    trigger OnAction();
                    var
                        GenJournalBatch: Record "Gen. Journal Batch";
                    begin
                        GenJournalBatch.INIT;
                        GenJournalBatch.SETRANGE("Journal Template Name", "Journal Template Name");
                        GenJournalBatch.SETRANGE(Name, "Journal Batch Name");
                        REPORT.RUN(REPORT::"Vendor Pre-Payment Journal", true, false, GenJournalBatch);
                    end;
                }
                action("Test Report")
                {
                    ApplicationArea = Basic, Suite;
                    CaptionML = ENU = 'Test Report',
                                ESM = 'Informe prueba',
                                FRC = 'Tester le report',
                                ENC = 'Test Report';
                    Ellipsis = true;
                    Image = TestReport;
                    ToolTipML = ENU = 'View a test report so that you can find and correct any errors before you perform the actual posting of the journal or document.',
                                ESM = 'Permite ver un informe de prueba para poder encontrar y corregir cualquier error antes de realizar el registro en sí del diario o del documento.',
                                FRC = 'Affichez un rapport de test de manière à trouver et corriger toutes les erreurs avant de procéder au report effectif du journal ou du document.',
                                ENC = 'View a test report so that you can find and correct any errors before you perform the actual posting of the journal or document.';

                    trigger OnAction();
                    begin
                        ReportPrint.PrintGenJnlLine(Rec);
                    end;
                }
                action(Post)
                {
                    ApplicationArea = Basic, Suite;
                    CaptionML = ENU = 'P&ost',
                                ESM = '&Registrar',
                                FRC = 'Rep&orter',
                                ENC = 'P&ost';
                    Image = PostOrder;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';
                    ToolTipML = ENU = 'Finalize the document or journal by posting the amounts and quantities to the related accounts in your company books.',
                                ESM = 'Permite finalizar el documento o el diario registrando los importes y las cantidades en las cuentas relacionadas de los libros de la empresa.',
                                FRC = 'Finalisez le document ou le journal en reportant les montants et les quantités sur les comptes concernés dans la comptabilité de la compagnie.',
                                ENC = 'Finalize the document or journal by posting the amounts and quantities to the related accounts in your company books.';

                    trigger OnAction();
                    begin
                        CODEUNIT.RUN(CODEUNIT::"Gen. Jnl.-Post", Rec);
                        CurrentJnlBatchName := GETRANGEMAX("Journal Batch Name");
                        CurrPage.UPDATE(false);
                    end;
                }
                action("Preview")
                {
                    ApplicationArea = Basic, Suite;
                    CaptionML = ENU = 'Preview Posting',
                                ESM = 'Vista previa de registro',
                                FRC = 'Aperçu compta.',
                                ENC = 'Preview Posting';
                    Image = ViewPostedOrder;
                    ToolTipML = ENU = 'Review the different types of entries that will be created when you post the document or journal.',
                                ESM = 'Permite revisar los diferentes tipos de movimientos que se crearán al registrar el documento o el diario.',
                                FRC = 'Examinez les différents types d''écritures qui seront créés lorsque vous reportez le document ou le journal.',
                                ENC = 'Review the different types of entries that will be created when you post the document or journal.';

                    trigger OnAction();
                    var
                        GenJnlPost: Codeunit "Gen. Jnl.-Post";
                    begin
                        GenJnlPost.Preview(Rec);
                    end;
                }
                action("Post and &Print")
                {
                    ApplicationArea = Basic, Suite;
                    CaptionML = ENU = 'Post and &Print',
                                ESM = 'Registrar e &imprimir',
                                FRC = 'Reporter et im&primer',
                                ENC = 'Post and &Print';
                    Image = PostPrint;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+F9';
                    ToolTipML = ENU = 'Finalize and prepare to print the document or journal. The values and quantities are posted to the related accounts. A report request window where you can specify what to include on the print-out.',
                                ESM = 'Permite finalizar y preparar para imprimir el documento o el diario. Los valores y las cantidades se registran en las cuentas relacionadas. Se abre una ventana de solicitud de informe en la que puede especificar lo que desea incluir en la impresión.',
                                FRC = 'Finalisez et préparez-vous à imprimer le document ou le journal. Les valeurs et les quantités sont reportées en fonction des comptes associés. Une fenêtre de demande de rapport vous permet de spécifier ce qu''il faut inclure sur l''élément à imprimer.',
                                ENC = 'Finalize and prepare to print the document or journal. The values and quantities are posted to the related accounts. A report request window where you can specify what to include on the print-out.';

                    trigger OnAction();
                    begin
                        CODEUNIT.RUN(CODEUNIT::"Gen. Jnl.-Post+Print", Rec);
                        CurrentJnlBatchName := GETRANGEMAX("Journal Batch Name");
                        CurrPage.UPDATE(false);
                    end;
                }
            }
            group("Request Approval")
            {
                CaptionML = ENU = 'Request Approval',
                            ESM = 'Aprobación solic.',
                            FRC = 'Approbation de demande',
                            ENC = 'Request Approval';
                group(SendApprovalRequest)
                {
                    CaptionML = ENU = 'Send Approval Request',
                                ESM = 'Enviar solicitud aprobación',
                                FRC = 'Envoyer demande d''approbation',
                                ENC = 'Send Approval Request';
                    Image = SendApprovalRequest;
                    action(SendApprovalRequestJournalBatch)
                    {
                        ApplicationArea = Suite;
                        CaptionML = ENU = 'Journal Batch',
                                    ESM = 'Sección diario',
                                    FRC = 'Lot journal',
                                    ENC = 'Journal Batch';
                        Enabled = NOT OpenApprovalEntriesOnBatchOrAnyJnlLineExist;
                        Image = SendApprovalRequest;
                        ToolTipML = ENU = 'Send all journal lines for approval, also those that you may not see because of filters.',
                                    ESM = 'Envía todas las líneas del diario para su aprobación y también las que posiblemente no se vean debido a algún filtro.',
                                    FRC = 'Envoyez toutes les lignes journal pour approbation, y compris celles que vous ne voyez peut-être pas à cause de filtres.',
                                    ENC = 'Send all journal lines for approval, also those that you may not see because of filters.';

                        trigger OnAction();
                        var
                            ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                        begin
                            ApprovalsMgmt.TrySendJournalBatchApprovalRequest(Rec);
                            SetControlAppearance;
                        end;
                    }
                    action(SendApprovalRequestJournalLine)
                    {
                        ApplicationArea = Suite;
                        CaptionML = ENU = 'Selected Journal Lines',
                                    ESM = 'Seleccionar líneas de diario',
                                    FRC = 'Lignes de journal sélectionnées',
                                    ENC = 'Selected Journal Lines';
                        Enabled = NOT OpenApprovalEntriesOnBatchOrCurrJnlLineExist;
                        Image = SendApprovalRequest;
                        ToolTipML = ENU = 'Send selected journal lines for approval.',
                                    ESM = 'Envía las líneas del diario seleccionadas para su aprobación.',
                                    FRC = 'Envoyez certaines lignes journal pour approbation.',
                                    ENC = 'Send selected journal lines for approval.';

                        trigger OnAction();
                        var
                            GenJournalLine: Record "Gen. Journal Line";
                            ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                        begin
                            GetCurrentlySelectedLines(GenJournalLine);
                            ApprovalsMgmt.TrySendJournalLineApprovalRequests(GenJournalLine);
                        end;
                    }
                }
                group(CancelApprovalRequest)
                {
                    CaptionML = ENU = 'Cancel Approval Request',
                                ESM = 'Cancelar solicitud aprobación',
                                FRC = 'Annuler demande d''approbation',
                                ENC = 'Cancel Approval Request';
                    Image = Cancel;
                    action(CancelApprovalRequestJournalBatch)
                    {
                        ApplicationArea = Suite;
                        CaptionML = ENU = 'Journal Batch',
                                    ESM = 'Sección diario',
                                    FRC = 'Lot journal',
                                    ENC = 'Journal Batch';
                        Enabled = CanCancelApprovalForJnlBatch;
                        Image = CancelApprovalRequest;
                        ToolTipML = ENU = 'Cancel sending all journal lines for approval, also those that you may not see because of filters.',
                                    ESM = 'Cancela el envío de todas las líneas del diario para su aprobación y también las que posiblemente no se vean debido a algún filtro.',
                                    FRC = 'Annulez l''envoi de toutes les lignes journal pour approbation, y compris celles que vous ne voyez peut-être pas à cause de filtres.',
                                    ENC = 'Cancel sending all journal lines for approval, also those that you may not see because of filters.';

                        trigger OnAction();
                        var
                            ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                        begin
                            ApprovalsMgmt.TryCancelJournalBatchApprovalRequest(Rec);
                            SetControlAppearance;
                        end;
                    }
                    action(CancelApprovalRequestJournalLine)
                    {
                        ApplicationArea = Suite;
                        CaptionML = ENU = 'Selected Journal Lines',
                                    ESM = 'Seleccionar líneas de diario',
                                    FRC = 'Lignes de journal sélectionnées',
                                    ENC = 'Selected Journal Lines';
                        Enabled = CanCancelApprovalForJnlLine;
                        Image = CancelApprovalRequest;
                        ToolTipML = ENU = 'Cancel sending selected journal lines for approval.',
                                    ESM = 'Cancela el envío de las líneas del diario seleccionadas para su aprobación.',
                                    FRC = 'Annulez l''envoi de certaines lignes journal pour approbation.',
                                    ENC = 'Cancel sending selected journal lines for approval.';

                        trigger OnAction();
                        var
                            GenJournalLine: Record "Gen. Journal Line";
                            ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                        begin
                            GetCurrentlySelectedLines(GenJournalLine);
                            ApprovalsMgmt.TryCancelJournalLineApprovalRequests(GenJournalLine);
                        end;
                    }
                }
            }
            group(Workflow)
            {
                CaptionML = ENU = 'Workflow',
                            ESM = 'Flujo de trabajo',
                            FRC = 'Flux de travail',
                            ENC = 'Workflow';
                action(CreateApprovalWorkflow)
                {
                    ApplicationArea = Suite;
                    CaptionML = ENU = 'Create Approval Workflow',
                                ESM = 'Crear flujo de trabajo de aprobación',
                                FRC = 'Créer flux de travail approbation',
                                ENC = 'Create Approval Workflow';
                    Enabled = NOT EnabledApprovalWorkflowsExist;
                    Image = CreateWorkflow;
                    ToolTipML = ENU = 'Set up an approval workflow for payment journal lines, by going through a few pages that will guide you.',
                                ESM = 'Permite configurar un flujo de trabajo de aprobación para las líneas del diario de pagos a través de unas cuantas páginas que le orientarán.',
                                FRC = 'Configurez un flux de travail approbation pour les lignes journal paiement, en consultant quelques pages qui vous guideront.',
                                ENC = 'Set up an approval workflow for payment journal lines, by going through a few pages that will guide you.';

                    trigger OnAction();
                    var
                        TempApprovalWorkflowWizard: Record "Approval Workflow Wizard" temporary;
                    begin
                        TempApprovalWorkflowWizard."Journal Batch Name" := "Journal Batch Name";
                        TempApprovalWorkflowWizard."Journal Template Name" := "Journal Template Name";
                        TempApprovalWorkflowWizard."For All Batches" := false;
                        TempApprovalWorkflowWizard.INSERT;

                        PAGE.RUNMODAL(PAGE::"Pmt. App. Workflow Setup Wzrd.", TempApprovalWorkflowWizard);
                    end;
                }
                action(ManageApprovalWorkflows)
                {
                    ApplicationArea = Suite;
                    CaptionML = ENU = 'Manage Approval Workflows',
                                ESM = 'Administrar flujos de trabajo de aprobación',
                                FRC = 'Gérer les flux de travail approbation',
                                ENC = 'Manage Approval Workflows';
                    Enabled = EnabledApprovalWorkflowsExist;
                    Image = WorkflowSetup;
                    ToolTipML = ENU = 'View or edit existing approval workflows for payment journal lines.',
                                ESM = 'Permite ver o editar flujos de trabajo de aprobación existentes para las líneas del diario de pagos.',
                                FRC = 'Affichez ou modifiez des flux de travail approbation pour des lignes journal paiement.',
                                ENC = 'View or edit existing approval workflows for payment journal lines.';

                    trigger OnAction();
                    var
                        WorkflowManagement: Codeunit "Workflow Management";
                    begin
                        WorkflowManagement.NavigateToWorkflows(DATABASE::"Gen. Journal Line", EventFilter);
                    end;
                }
            }
            group(Approval)
            {
                CaptionML = ENU = 'Approval',
                            ESM = 'Aprobación',
                            FRC = 'Approbation',
                            ENC = 'Approval';
                action(Approve)
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Approve',
                                ESM = 'Aprobar',
                                FRC = 'Approuver',
                                ENC = 'Approve';
                    Image = Approve;
                    Promoted = true;
                    PromotedCategory = Category6;
                    PromotedIsBig = true;
                    ToolTipML = ENU = 'Approve the requested changes.',
                                ESM = 'Aprueba los cambios solicitados.',
                                FRC = 'Approuvez les modifications requises.',
                                ENC = 'Approve the requested changes.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction();
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.ApproveGenJournalLineRequest(Rec);
                    end;
                }
                action(Reject)
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Reject',
                                ESM = 'Rechazar',
                                FRC = 'Rejeter',
                                ENC = 'Reject';
                    Image = Reject;
                    Promoted = true;
                    PromotedCategory = Category6;
                    PromotedIsBig = true;
                    ToolTipML = ENU = 'Reject the approval request.',
                                ESM = 'Rechaza la solicitud de aprobación.',
                                FRC = 'Rejetez la demande d''approbation.',
                                ENC = 'Reject the approval request.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction();
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.RejectGenJournalLineRequest(Rec);
                    end;
                }
                action(Delegate)
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Delegate',
                                ESM = 'Delegar',
                                FRC = 'Déléguer',
                                ENC = 'Delegate';
                    Image = Delegate;
                    Promoted = true;
                    PromotedCategory = Category6;
                    ToolTipML = ENU = 'Delegate the approval to a substitute approver.',
                                ESM = 'Delega la aprobación a un aprobador sustituto.',
                                FRC = 'Déléguez l''approbation à un approbateur remplaçant.',
                                ENC = 'Delegate the approval to a substitute approver.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction();
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.DelegateGenJournalLineRequest(Rec);
                    end;
                }
                action(Comment)
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Comments',
                                ESM = 'Comentarios',
                                FRC = 'Commentaires',
                                ENC = 'Comments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category6;
                    ToolTipML = ENU = 'View or add comments.',
                                ESM = 'Permite ver o agregar comentarios.',
                                FRC = 'Affichez ou ajoutez des commentaires.',
                                ENC = 'View or add comments.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction();
                    var
                        GenJournalBatch: Record "Gen. Journal Batch";
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        if OpenApprovalEntriesOnJnlLineExist then
                            ApprovalsMgmt.GetApprovalComment(Rec)
                        else
                            if OpenApprovalEntriesOnJnlBatchExist then
                                if GenJournalBatch.GET("Journal Template Name", "Journal Batch Name") then
                                    ApprovalsMgmt.GetApprovalComment(GenJournalBatch);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord();
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        WorkflowManagement: Codeunit "Workflow Management";
    begin
        SetControlAppearance;
        StyleTxt := GetOverdueDateInteractions(OverdueWarningText);
        GenJnlManagement.GetAccounts(Rec, AccName, BalAccName);
        UpdateBalance;
        CurrPage.IncomingDocAttachFactBox.PAGE.LoadDataFromRecord(Rec);

        if GenJournalBatch.GET("Journal Template Name", "Journal Batch Name") then
            ShowWorkflowStatusOnBatch := CurrPage.WorkflowStatusBatch.PAGE.SetFilterOnWorkflowRecord(GenJournalBatch.RECORDID);
        ShowWorkflowStatusOnLine := CurrPage.WorkflowStatusLine.PAGE.SetFilterOnWorkflowRecord(RECORDID);

        EventFilter := WorkflowEventHandling.RunWorkflowOnSendGeneralJournalLineForApprovalCode;
        EnabledApprovalWorkflowsExist := WorkflowManagement.EnabledWorkflowExist(DATABASE::"Gen. Journal Line", EventFilter);
    end;

    trigger OnAfterGetRecord();
    begin
        StyleTxt := GetOverdueDateInteractions(OverdueWarningText);
        ShowShortcutDimCode(ShortcutDimCode);
        HasPmtFileErr := HasPaymentFileErrors;
    end;

    trigger OnInit();
    var
        PermissionManager: Codeunit "Permission Manager";
    begin
        TotalBalanceVisible := true;
        BalanceVisible := true;
    end;

    trigger OnModifyRecord(): Boolean;
    begin
        CheckForPmtJnlErrors;
    end;

    trigger OnNewRecord(BelowxRec: Boolean);
    begin
        HasPmtFileErr := false;
        UpdateBalance;
        SetUpNewLine(xRec, Balance, BelowxRec);
        CLEAR(ShortcutDimCode);
        if not VoidWarningDisplayed then begin
            GenJnlTemplate.GET("Journal Template Name");
            if not GenJnlTemplate."Force Doc. Balance" then
                MESSAGE(CheckCannotVoidMsg);
            VoidWarningDisplayed := true;
        end;
    end;

    trigger OnOpenPage();
    var
        JnlSelected: Boolean;
    begin
        CommSetup.GET;
        if CommSetup.Disabled then
            ERROR(Text002);

        BalAccName := '';

        if IsOpenedFromBatch then begin
            CurrentJnlBatchName := "Journal Batch Name";
            GenJnlManagement.OpenJnl(CurrentJnlBatchName, Rec);
            SetControlAppearance;
            exit;
        end;
        GenJnlManagement.TemplateSelection(PAGE::"Payment Journal", 4, false, Rec, JnlSelected);
        if not JnlSelected then
            ERROR('');
        GenJnlManagement.OpenJnl(CurrentJnlBatchName, Rec);
        SetControlAppearance;
        VoidWarningDisplayed := false;
    end;

    var
        Text000: TextConst ENU = 'Void Check %1?', ESM = '¿Confirma que desea anular el cheque %1?', FRC = 'Annuler le chèque %1 ?', ENC = 'Void Cheque %1?';
        Text001: TextConst ENU = 'Void all printed checks?', ESM = '¿Confirma que desea anular todos los cheques impresos?', FRC = 'Souhaitez-vous annuler tous les chèques imprimés ?', ENC = 'Void all printed cheques?';
        CommSetup: Record CommissionSetupTigCM;
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlLine2: Record "Gen. Journal Line";
        GenJnlTemplate: Record "Gen. Journal Template";
        VoidTransmitElecPayments: Report "Void/Transmit Elec. Payments";
        GenJnlManagement: Codeunit GenJnlManagement;
        ReportPrint: Codeunit "Test Report-Print";
        DocPrint: Codeunit "Document-Print";
        CheckManagement: Codeunit CheckManagement;
        ChangeExchangeRate: Page "Change Exchange Rate";
        GLReconcile: Page Reconciliation;
        CurrentJnlBatchName: Code[10];
        AccName: Text[50];
        BalAccName: Text[50];
        Balance: Decimal;
        TotalBalance: Decimal;
        ShowBalance: Boolean;
        ShowTotalBalance: Boolean;
        VoidWarningDisplayed: Boolean;
        HasPmtFileErr: Boolean;
        ShortcutDimCode: array[8] of Code[20];
        [InDataSet]
        BalanceVisible: Boolean;
        [InDataSet]
        TotalBalanceVisible: Boolean;
        ExportAgainQst: TextConst ENU = 'One or more of the selected lines have already been exported. Do you want to export again?', ESM = 'Una o más de las líneas seleccionadas ya se han exportado. ¿Desea repetir la exportación?', FRC = 'Une ou plusieurs des lignes sélectionnées ont déjà été exportées. Souhaitez-vous les exporter à nouveau ?', ENC = 'One or more of the selected lines have already been exported. Do you want to export again?';
        StyleTxt: Text;
        OverdueWarningText: Text;
        CheckCannotVoidMsg: TextConst ENU = 'Warning:  Checks cannot be financially voided when Force Doc. Balance is set to No in the Journal Template.', ESM = 'Aviso: los cheques podrán anularse si Forzar saldo por nº documento está establecido en No en el Libro diario.', FRC = 'Avertissement : impossible d''annuler financièrement un chèque lorsque le paramètre Forcer équilibre doc. est défini à Non dans le modèle de journal.', ENC = 'Warning:  Cheques cannot be financially voided when Force Doc. Balance is set to No in the Journal Template.';
        EventFilter: Text;
        OpenApprovalEntriesExistForCurrUser: Boolean;
        OpenApprovalEntriesOnJnlBatchExist: Boolean;
        OpenApprovalEntriesOnJnlLineExist: Boolean;
        OpenApprovalEntriesOnBatchOrCurrJnlLineExist: Boolean;
        OpenApprovalEntriesOnBatchOrAnyJnlLineExist: Boolean;
        ShowWorkflowStatusOnBatch: Boolean;
        ShowWorkflowStatusOnLine: Boolean;
        CanCancelApprovalForJnlBatch: Boolean;
        CanCancelApprovalForJnlLine: Boolean;
        EnabledApprovalWorkflowsExist: Boolean;
        Text002: Label 'The Commission Add-on is disabled';

    local procedure CheckForPmtJnlErrors();
    var
        BankAccount: Record "Bank Account";
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        if HasPmtFileErr then
            if ("Bal. Account Type" = "Bal. Account Type"::"Bank Account") and BankAccount.GET("Bal. Account No.") then
                if BankExportImportSetup.GET(BankAccount."Payment Export Format") then
                    if BankExportImportSetup."Check Export Codeunit" > 0 then
                        CODEUNIT.RUN(BankExportImportSetup."Check Export Codeunit", Rec);
    end;

    local procedure UpdateBalance();
    begin
        GenJnlManagement.CalcBalance(
          Rec, xRec, Balance, TotalBalance, ShowBalance, ShowTotalBalance);
        BalanceVisible := ShowBalance;
        TotalBalanceVisible := ShowTotalBalance;
    end;

    local procedure CurrentJnlBatchNameOnAfterVali();
    begin
        CurrPage.SAVERECORD;
        GenJnlManagement.SetName(CurrentJnlBatchName, Rec);
        CurrPage.UPDATE(false);
    end;

    local procedure GetCurrentlySelectedLines(var GenJournalLine: Record "Gen. Journal Line"): Boolean;
    begin
        CurrPage.SETSELECTIONFILTER(GenJournalLine);
        exit(GenJournalLine.FINDSET);
    end;

    local procedure SetControlAppearance();
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    begin
        if GenJournalBatch.GET("Journal Template Name", "Journal Batch Name") then;
        OpenApprovalEntriesExistForCurrUser :=
          ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(GenJournalBatch.RECORDID) or
          ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(RECORDID);

        OpenApprovalEntriesOnJnlBatchExist := ApprovalsMgmt.HasOpenApprovalEntries(GenJournalBatch.RECORDID);
        OpenApprovalEntriesOnJnlLineExist := ApprovalsMgmt.HasOpenApprovalEntries(RECORDID);
        OpenApprovalEntriesOnBatchOrCurrJnlLineExist := OpenApprovalEntriesOnJnlBatchExist or OpenApprovalEntriesOnJnlLineExist;

        OpenApprovalEntriesOnBatchOrAnyJnlLineExist :=
          OpenApprovalEntriesOnJnlBatchExist or
          ApprovalsMgmt.HasAnyOpenJournalLineApprovalEntries("Journal Template Name", "Journal Batch Name");

        CanCancelApprovalForJnlBatch := ApprovalsMgmt.CanCancelApprovalForRecord(GenJournalBatch.RECORDID);
        CanCancelApprovalForJnlLine := ApprovalsMgmt.CanCancelApprovalForRecord(RECORDID);
    end;
}

