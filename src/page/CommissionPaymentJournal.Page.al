page 80015 "CommissionPaymentJournalTigCM"
{
    Caption = 'Commission Payment Journal';
    PageType = Worksheet;
    ApplicationArea = All;
    UsageCategory = Tasks;
    SourceTable = "Gen. Journal Line";
    DataCaptionExpression = DataCaption();
    DelayedInsert = true;
    PromotedActionCategories = 'New,Process,Report,Bank,Prepare,Approve';
    SaveValues = true;
    AutoSplitKey = true;

    layout
    {
        area(content)
        {
            field(CurrentJnlBatchNameLbl; CurrentJnlBatchName)
            {
                Caption = 'Current Journal Batch Name';
                ApplicationArea = All;
                Tooltip = 'Specifies the Current Journal Batch Name';
                Lookup = true;

                trigger OnLookup(var Text: Text): Boolean;
                begin
                    CurrPage.SaveRecord();
                    GenJnlManagement.LookupName(CurrentJnlBatchName, Rec);
                    CurrPage.Update(false);
                end;

                trigger OnValidate();
                begin
                    GenJnlManagement.CheckName(CurrentJnlBatchName, Rec);
                    CurrentJnlBatchNameOnAfterVali();
                end;
            }
            repeater(Control1)
            {
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Posting Date for the entry';
                    Style = Attention;
                    StyleExpr = HasPmtFileErr;
                }
                field("Document Date"; "Document Date")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the date on the document that provides the basis for the entry on the journal line.';
                    Style = Attention;
                    StyleExpr = HasPmtFileErr;
                }
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Document Type';
                    Style = Attention;
                    StyleExpr = HasPmtFileErr;
                    Visible = false;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Document No. for the journal line.';
                    Style = Attention;
                    StyleExpr = HasPmtFileErr;
                }
                field("Incoming Document Entry No."; "Incoming Document Entry No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the number of the incoming document that this general journal line is created for.';
                    Visible = false;

                    trigger OnAssistEdit();
                    begin
                        if "Incoming Document Entry No." > 0 then
                            Hyperlink(GetIncomingDocumentURL());
                    end;
                }
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies a document number that refers to the customer''s or vendor''s numbering system.';
                }
                field("Applies-to Ext. Doc. No."; "Applies-to Ext. Doc. No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the external document number that will be exported in the payment file.';
                    Visible = false;
                }
                field("Account Type"; "Account Type")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the type of account that the entry on the journal line will be posted to.';

                    trigger OnValidate();
                    begin
                        GenJnlManagement.GetAccounts(Rec, AccName, BalAccName);
                    end;
                }
                field("Account No."; "Account No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the account number that the entry on the journal line will be posted to.';
                    ShowMandatory = true;
                    Style = Attention;
                    StyleExpr = HasPmtFileErr;

                    trigger OnValidate();
                    begin
                        GenJnlManagement.GetAccounts(Rec, AccName, BalAccName);
                        ShowShortcutDimCode(ShortcutDimCode);
                    end;
                }
                field("Recipient Bank Account"; "Recipient Bank Account")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the bank account that the amount will be transferred to after it has been exported from the payment journal.';
                    ShowMandatory = true;
                }
                field("Message to Recipient"; "Message to Recipient")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the message exported to the payment file when you use the Export Payments to File function in the Payment Journal window.';
                    Visible = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies a description of the entry. The field is automatically filled when the Account No. field is filled.';
                    Style = Attention;
                    StyleExpr = HasPmtFileErr;
                }
                field("Salespers./Purch. Code"; "Salespers./Purch. Code")
                {
                    ApplicationArea = Suite;
                    Tooltip = 'Specifies the salesperson or purchaser who is linked to the journal line.';
                    Visible = false;
                }
                field("Campaign No."; "Campaign No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the number of the campaign the journal line is linked to.';
                    Visible = false;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the code of the currency for the amounts on the journal line.';
                    AssistEdit = true;

                    trigger OnAssistEdit();
                    begin
                        ChangeExchangeRate.SetParameter("Currency Code", "Currency Factor", "Posting Date");
                        if ChangeExchangeRate.RunModal() = Action::OK then
                            Validate("Currency Factor", ChangeExchangeRate.GetParameter());

                        Clear(ChangeExchangeRate);
                    end;
                }
                field("Gen. Posting Type"; "Gen. Posting Type")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the general posting type that will be used when you post the entry on this journal line.';
                    Visible = false;
                }
                field("Gen. Bus. Posting Group"; "Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the code of the general business posting group that will be used when you post the entry on the journal line.';
                    Visible = false;
                }
                field("Gen. Prod. Posting Group"; "Gen. Prod. Posting Group")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the code of the general product posting group that will be used when you post the entry on the journal line.';
                    Visible = false;
                }
                field("VAT Bus. Posting Group"; "VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Tax business posting group code that will be used when you post the entry on the journal line.';
                    Visible = false;
                }
                field("VAT Prod. Posting Group"; "VAT Prod. Posting Group")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the code of the Tax product posting group that will be used when you post the entry on the journal line.';
                    Visible = false;
                }
                field("Debit Amount"; "Debit Amount")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the total amount (including tax) that the journal line consists of, if it is a debit amount. The amount must be entered in the currency represented by the currency code on the line.';
                    Visible = false;
                }
                field("Credit Amount"; "Credit Amount")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the total amount (including tax) that the journal line consists of, if it is a credit amount. The amount must be entered in the currency represented by the currency code on the line.';
                    Visible = false;
                }
                field("Payment Method Code"; "Payment Method Code")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the payment method that was used to make the payment that resulted in the entry.';
                    ShowMandatory = true;
                }
                field("Payment Reference"; "Payment Reference")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the payment of the purchase invoice.';
                }
                field("Creditor No."; "Creditor No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the vendor who sent the purchase invoice.';
                    Visible = false;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the total amount (including tax) that the journal line consists of.';
                    ShowMandatory = true;
                    Style = Attention;
                    StyleExpr = HasPmtFileErr;
                }
                field("VAT Amount"; "VAT Amount")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the amount of Tax included in the total amount.';
                    Visible = false;
                }
                field("VAT Difference"; "VAT Difference")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the difference between the calculate tax amount and the tax amount that you have entered manually.';
                    Visible = false;
                }
                field("Bal. VAT Amount"; "Bal. VAT Amount")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the amount of Bal. Tax included in the total amount.';
                    Visible = false;
                }
                field("Bal. VAT Difference"; "Bal. VAT Difference")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the difference between the calculate tax amount and the tax amount that you have entered manually.';
                    Visible = false;
                }
                field("Bal. Account Type"; "Bal. Account Type")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the code for the balancing account type that should be used in this journal line.';
                }
                field("Bal. Account No."; "Bal. Account No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the number of the general ledger, customer, vendor, or bank account to which a balancing entry for the journal line will posted (for example, a cash account for cash purchases).';

                    trigger OnValidate();
                    begin
                        GenJnlManagement.GetAccounts(Rec, AccName, BalAccName);
                        ShowShortcutDimCode(ShortcutDimCode);
                    end;
                }
                field("Bal. Gen. Posting Type"; "Bal. Gen. Posting Type")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the general posting type that will be used when you post the entry on the journal line.';
                    Visible = false;
                }
                field("Bal. Gen. Bus. Posting Group"; "Bal. Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the code of the general business posting group that will be used when you post the entry on the journal line.';
                    Visible = false;
                }
                field("Bal. Gen. Prod. Posting Group"; "Bal. Gen. Prod. Posting Group")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the code of the general product posting group that will be used when you post the entry on the journal line.';
                    Visible = false;
                }
                field("Bal. VAT Bus. Posting Group"; "Bal. VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the code of the Tax business posting group that will be used when you post the entry on the journal line.';
                    Visible = false;
                }
                field("Bal. VAT Prod. Posting Group"; "Bal. VAT Prod. Posting Group")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the code of the Tax product posting group that will be used when you post the entry on the journal line.';
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the code for Shortcut Dimension 1.';
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the code for Shortcut Dimension 2.';
                    Visible = false;
                }
                field("ShortcutDimCode[3]"; ShortcutDimCode[3])
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ShortcutDimCode[3]';
                    CaptionClass = '1,2,3';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(3),
                                                                  "Dimension Value Type" = const(Standard),
                                                                  Blocked = const(false));
                    Visible = false;

                    trigger OnValidate();
                    begin
                        ValidateShortcutDimCode(3, ShortcutDimCode[3]);
                    end;
                }
                field("ShortcutDimCode[4]"; ShortcutDimCode[4])
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ShortcutDimCode[4]';
                    CaptionClass = '1,2,4';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(4),
                                                                  "Dimension Value Type" = const(Standard),
                                                                  Blocked = const(false));
                    Visible = false;

                    trigger OnValidate();
                    begin
                        ValidateShortcutDimCode(4, ShortcutDimCode[4]);
                    end;
                }
                field("ShortcutDimCode[5]"; ShortcutDimCode[5])
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ShortcutDimCode[5]';
                    CaptionClass = '1,2,5';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(5),
                                                                  "Dimension Value Type" = const(Standard),
                                                                  Blocked = const(false));
                    Visible = false;

                    trigger OnValidate();
                    begin
                        ValidateShortcutDimCode(5, ShortcutDimCode[5]);
                    end;
                }
                field("ShortcutDimCode[6]"; ShortcutDimCode[6])
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ShortcutDimCode[6]';
                    CaptionClass = '1,2,6';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(6),
                                                                  "Dimension Value Type" = const(Standard),
                                                                  Blocked = const(false));
                    Visible = false;

                    trigger OnValidate();
                    begin
                        ValidateShortcutDimCode(6, ShortcutDimCode[6]);
                    end;
                }
                field("ShortcutDimCode[7]"; ShortcutDimCode[7])
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ShortcutDimCode[7]';
                    CaptionClass = '1,2,7';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(7),
                                                                  "Dimension Value Type" = const(Standard),
                                                                  Blocked = const(false));
                    Visible = false;

                    trigger OnValidate();
                    begin
                        ValidateShortcutDimCode(7, ShortcutDimCode[7]);
                    end;
                }
                field("ShortcutDimCode[8]"; ShortcutDimCode[8])
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ShortcutDimCode[8]';
                    CaptionClass = '1,2,8';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(8),
                                                                  "Dimension Value Type" = const(Standard),
                                                                  Blocked = const(false));
                    Visible = false;

                    trigger OnValidate();
                    begin
                        ValidateShortcutDimCode(8, ShortcutDimCode[8]);
                    end;
                }
                field("Applied (Yes/No)"; IsApplied())
                {
                    Caption = 'Applied (Yes/No)';
                    ApplicationArea = All;
                    Tooltip = 'Specifies if the payment has been applied.';
                }
                field("Applies-to Doc. Type"; "Applies-to Doc. Type")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the type of the posted document that this document or journal line will be applied to when you post, for example to register payment.';
                }
                field("Applies-to Doc. No."; "Applies-to Doc. No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the number of the posted document that this document or journal line will be applied to when you post, for example to register payment.';
                    StyleExpr = StyleTxt;
                }
                field("Applies-to ID"; "Applies-to ID")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the entries that will be applied to by the journal line if you use the Apply Entries facility.';
                    StyleExpr = StyleTxt;
                    Visible = false;
                }
                field(GetAppliesToDocDueDate; GetAppliesToDocDueDate())
                {
                    Caption = 'Applies-to Doc. Due Date';
                    ApplicationArea = All;
                    Tooltip = 'Specifies the due date from the Applies-to Doc. on the journal line.';
                    StyleExpr = StyleTxt;
                }
                field("Bank Payment Type"; "Bank Payment Type")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the code for the payment type to be used for the entry on the payment journal line.';
                }
                field("Foreign Exchange Indicator"; "Foreign Exchange Indicator")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies an exchange indicator for the journal line. This is a required field. You can edit this field in the Purchase Journal window.';
                    Visible = false;
                }
                field("Foreign Exchange Ref.Indicator"; "Foreign Exchange Ref.Indicator")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies an exchange reference indicator for the journal line. This is a required field. You can edit this field in the Purchase Journal and the Payment Journal window.';
                    Visible = false;
                }
                field("Foreign Exchange Reference"; "Foreign Exchange Reference")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies a foreign exchange reference code. This is a required field. You can edit this field in the Purchase Journal window.';
                    Visible = false;
                }
                field("Origin. DFI ID Qualifier"; "Origin. DFI ID Qualifier")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the financial institution that will initiate the payment transactions sent by the originator. Select an ID for the originator''s Designated Financial Institution (DFI). This is a required field. You can edit this field in the Payment Journal window and the Purchase Journal window.';
                    Visible = false;
                }
                field("Receiv. DFI ID Qualifier"; "Receiv. DFI ID Qualifier")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the financial institution that will receive the payment transactions. Select an ID for the receiver''s Designated Financial Institution (DFI). This is a required field. You can edit this field in the Payment Journal window and the Purchase Journal window.';
                    Visible = false;
                }
                field("Transaction Type Code"; "Transaction Type Code")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies a transaction type code for the general journal line. This code identifies the transaction type for the Electronic Funds Transfer (EFT).';
                }
                field("Gateway Operator OFAC Scr.Inc"; "Gateway Operator OFAC Scr.Inc")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies an Office of Foreign Assets Control (OFAC) gateway operator screening indicator. This is a required field. You can edit this field in the Payment Journal window and the Purchase Journal window.';
                    Visible = false;
                }
                field("Secondary OFAC Scr.Indicator"; "Secondary OFAC Scr.Indicator")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies a secondary Office of Foreign Assets Control (OFAC) gateway operator screening indicator. This is a required field. You can edit this field in the Payment Journal window and the Purchase Journal window.';
                    Visible = false;
                }
                field("Transaction Code"; "Transaction Code")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies a transaction code for the general journal line. This code identifies the transaction type for the Electronic Funds Transfer (EFT).';
                    Visible = false;
                }
                field("Company Entry Description"; "Company Entry Description")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies a company description for the journal line.';
                    Visible = false;
                }
                field("Payment Related Information 1"; "Payment Related Information 1")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies payment related information for the general journal line.';
                    Visible = false;
                }
                field("Payment Related Information 2"; "Payment Related Information 2")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies additional payment related information for the general journal line.';
                    Visible = false;
                }
                field("Check Printed"; "Check Printed")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies whether a check has been printed for the amount on the payment journal line.';
                }
                field("Reason Code"; "Reason Code")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the reason code that has been entered on the journal lines.';
                    Visible = false;
                }
                field("Source Type"; "Source Type")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the number of the customer or vendor that the payment relates to.';
                    Visible = false;
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the number of the customer or vendor that the payment relates to.';
                    Visible = false;
                }
                field(TheComment; Comment)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies a comment related to registering a payment.';
                    Visible = false;
                }
                field("Exported to Payment File"; "Exported to Payment File")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies that the payment journal line was exported to a payment file.';
                    Visible = false;
                }
                field(TotalExportedAmount; TotalExportedAmount())
                {
                    Caption = 'Total Exported Amount';
                    ApplicationArea = All;
                    Tooltip = 'Specifies the amount for the payment journal line that has been exported to payment files that are not canceled.';
                    DrillDown = true;
                    Visible = false;

                    trigger OnDrillDown();
                    begin
                        DrillDownExportedAmount();
                    end;
                }
                field("Has Payment Export Error"; "Has Payment Export Error")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies that an error occurred when you used the Export Payments to File function in the Payment Journal window.';
                    Visible = false;
                }
            }
            group(Control24)
            {
                fixed(Control80)
                {
                    group(Control82)
                    {
                        field(OverdueWarningTextLbl; OverdueWarningText)
                        {
                            Caption = 'Overdue Warning Text';
                            ApplicationArea = All;
                            Tooltip = 'Specifies the text that is displayed for overdue payments.';
                            Style = Unfavorable;
                            StyleExpr = TRUE;
                        }
                    }
                }
                fixed(Control1903561801)
                {
                    group("Account Name")
                    {
                        Caption = 'Account Name';
                        field(AccNameLbl; AccName)
                        {
                            Caption = 'Account Name';
                            ApplicationArea = All;
                            Tooltip = 'Specifies the name of the account.';
                            Editable = false;
                            ShowCaption = false;
                        }
                    }
                    group("Bal. Account Name")
                    {
                        Caption = 'Bal. Account Name';
                        field(BalAccNameLbl; BalAccName)
                        {
                            Caption = 'Bal. Account Name';
                            ApplicationArea = All;
                            Tooltip = 'Specifies the name of the balancing account that has been entered on the journal line.';
                            Editable = false;
                        }
                    }
                    group(BalanceGroup)
                    {
                        Caption = 'Balance';
                        field(BalanceLbl; Balance + "Balance (LCY)" - xRec."Balance (LCY)")
                        {
                            Caption = 'Balance';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the balance that has accumulated in the payment journal on the line where the cursor is.';
                            Editable = false;
                            Visible = BalanceVisible;
                            AutoFormatType = 1;
                        }
                    }
                    group("Total Balance")
                    {
                        Caption = 'Total Balance';
                        field(TotalBalanceLbl; TotalBalance + "Balance (LCY)" - xRec."Balance (LCY)")
                        {
                            Caption = 'Total Balance';
                            ApplicationArea = All;
                            ToolTip = 'Specifies the total balance in the payment journal.';
                            Editable = false;
                            Visible = TotalBalanceVisible;
                            AutoFormatType = 1;
                        }
                    }
                }
            }
        }
        area(factboxes)
        {
            part(IncomingDocAttachFactBox; "Incoming Doc. Attach. FactBox")
            {
                ApplicationArea = All;
                ShowFilter = false;
            }
            part("Payment File Errors"; "Payment Journal Errors Part")
            {
                Caption = 'Payment File Errors';
                ApplicationArea = All;
                SubPageLink = "Journal Template Name" = field("Journal Template Name"),
                              "Journal Batch Name" = field("Journal Batch Name"),
                              "Journal Line No." = field("Line No.");
            }
            part(DimensionSetEntriesFactBox; "Dimension Set Entries FactBox")
            {
                Caption = 'Dimension Set Entries';
                ApplicationArea = All;
                SubPageLink = "Dimension Set ID" = field("Dimension Set ID");
                Visible = false;
            }
            part(WorkflowStatusBatch; "Workflow Status FactBox")
            {
                Caption = 'Batch Workflows';
                ApplicationArea = All;
                Editable = false;
                Enabled = false;
                ShowFilter = false;
                Visible = ShowWorkflowStatusOnBatch;
            }
            part(WorkflowStatusLine; "Workflow Status FactBox")
            {
                Caption = 'Line Workflows';
                ApplicationArea = All;
                Editable = false;
                Enabled = false;
                ShowFilter = false;
                Visible = ShowWorkflowStatusOnLine;
            }
            systempart(LinksPart; Links)
            {
                ApplicationArea = All;
                Visible = false;
            }
            systempart(NotesPart; Notes)
            {
                ApplicationArea = All;
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
                Caption = '&Line';
                Image = Line;
                action(Dimensions)
                {
                    Caption = 'Dimensions';
                    ApplicationArea = All;
                    ToolTip = 'View or edits dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';
                    Image = Dimensions;
                    AccessByPermission = TableData Dimension = R;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    ShortCutKey = 'Shift+Ctrl+D';

                    trigger OnAction();
                    begin
                        ShowDimensions();
                        CurrPage.SaveRecord();
                    end;
                }
                action(IncomingDoc)
                {
                    Caption = 'Incoming Document';
                    ApplicationArea = All;
                    ToolTip = 'View or create an incoming document record that is linked to the entry or document.';
                    Image = Document;
                    Promoted = true;
                    PromotedCategory = Process;
                    Scope = Repeater;
                    AccessByPermission = TableData "Incoming Document" = R;

                    trigger OnAction();
                    var
                        IncomingDocument: Record "Incoming Document";
                    begin
                        Validate("Incoming Document Entry No.", IncomingDocument.SelectIncomingDocument("Incoming Document Entry No.", RecordId()));
                    end;
                }
            }
            group("A&ccount")
            {
                Caption = 'A&ccount';
                Image = ChartOfAccounts;
                action(Card)
                {
                    Caption = 'Card';
                    ApplicationArea = All;
                    ToolTip = 'View or change detailed information about the record that is being processed on the journal line.';
                    Image = EditLines;
                    RunObject = Codeunit "Gen. Jnl.-Show Card";
                    ShortCutKey = 'Shift+F7';
                }
                action("Ledger E&ntries")
                {
                    Caption = 'Ledger E&ntries';
                    ApplicationArea = All;
                    ToolTip = 'View the history of transactions that have been posted for the selected record.';
                    Image = GLRegisters;
                    Promoted = false;
                    RunObject = Codeunit "Gen. Jnl.-Show Entries";
                    ShortCutKey = 'Ctrl+F7';
                }
            }
            group("&Payments")
            {
                Caption = '&Payments';
                Image = Payment;
                action(SuggestVendorPayments)
                {
                    Caption = 'Suggest Vendor Payments';
                    ApplicationArea = All;
                    ToolTip = 'Create payment suggestion as lines in the payment journal.';
                    Image = SuggestVendorPayments;
                    Ellipsis = true;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction();
                    var
                        SuggestVendorPayments: Report "Suggest Vendor Payments";
                    begin
                        Clear(SuggestVendorPayments);
                        SuggestVendorPayments.SetGenJnlLine(Rec);
                        SuggestVendorPayments.RunModal();
                    end;
                }
                action(PreviewCheck)
                {
                    Caption = 'P&review Check';
                    ApplicationArea = All;
                    ToolTip = 'Preview the check before printing it.';
                    Image = ViewCheck;
                    RunObject = Page "Check Preview";
                    RunPageLink = "Journal Template Name" = field("Journal Template Name"),
                                  "Journal Batch Name" = field("Journal Batch Name"),
                                  "Line No." = field("Line No.");
                }
                action(PrintCheck)
                {
                    Caption = 'Print Check';
                    ApplicationArea = All;
                    ToolTip = 'Prepare to print the check.';
                    Ellipsis = true;
                    Image = PrintCheck;
                    Promoted = true;
                    PromotedCategory = Process;
                    AccessByPermission = TableData "Check Ledger Entry" = R;

                    trigger OnAction();
                    begin
                        GenJnlLine.Reset();
                        GenJnlLine.Copy(Rec);
                        GenJnlLine.SetRange("Journal Template Name", "Journal Template Name");
                        GenJnlLine.SetRange("Journal Batch Name", "Journal Batch Name");
                        DocPrint.PrintCheck(GenJnlLine);
                        Codeunit.Run(Codeunit::"Adjust Gen. Journal Balance", Rec);
                    end;
                }
                group("Electronic Payments")
                {
                    Caption = 'Electronic Payments';
                    Image = ElectronicPayment;
                    action("E&xport")
                    {
                        Caption = 'E&xport';
                        ApplicationArea = All;
                        ToolTip = 'Export payments on journal lines that are set to electronic payment to a file prior to transmitting the file to your bank.';
                        Ellipsis = true;
                        Image = Export;
                        Promoted = true;
                        PromotedCategory = Process;
                        PromotedOnly = true;

                        trigger OnAction();
                        var
                            BankAccount: Record "Bank Account";
                            BulkVendorRemitReporting: Codeunit "Bulk Vendor Remit Reporting";
                            GenJnlLineRecordRef: RecordRef;
                            ExportAgainQst: Label 'One or more of the selected lines have already been exported. Do you want to export again?';
                        begin
                            GenJnlLine.Reset();
                            GenJnlLine := Rec;
                            GenJnlLine.SetRange("Journal Template Name", "Journal Template Name");
                            GenJnlLine.SetRange("Journal Batch Name", "Journal Batch Name");

                            if (("Bal. Account Type" = "Bal. Account Type"::"Bank Account") and
                                BankAccount.Get("Bal. Account No.") and (BankAccount."Payment Export Format" <> ''))
                            then begin
                                Codeunit.Run(Codeunit::"Export Payment File (Yes/No)", GenJnlLine);
                                exit;
                            end;

                            if GenJnlLine.IsExportedToPaymentFile() then
                                if not Confirm(ExportAgainQst) then
                                    exit;

                            GenJnlLineRecordRef.GetTable(GenJnlLine);
                            GenJnlLineRecordRef.SetView(GenJnlLine.GetView());
                            BulkVendorRemitReporting.RunWithRecord(GenJnlLine);
                        end;
                    }
                    action(Void)
                    {
                        Caption = 'Void';
                        ApplicationArea = All;
                        ToolTip = 'Void the exported electronic payment file.';
                        Image = VoidElectronicDocument;
                        Ellipsis = true;
                        Promoted = true;
                        PromotedCategory = Process;

                        trigger OnAction();
                        begin
                            GenJnlLine.Reset();
                            GenJnlLine := Rec;
                            GenJnlLine.SetRange("Journal Template Name", "Journal Template Name");
                            GenJnlLine.SetRange("Journal Batch Name", "Journal Batch Name");
                            Clear(VoidTransmitElecPayments);
                            VoidTransmitElecPayments.SetUsageType(1);   // Void
                            VoidTransmitElecPayments.SetTableView(GenJnlLine);
                            VoidTransmitElecPayments.RunModal();
                        end;
                    }
                    action(Transmit)
                    {
                        Caption = 'Transmit';
                        ApplicationArea = All;
                        ToolTip = 'Transmit the exported electronic payment file to the bank.';
                        Ellipsis = true;
                        Image = TransmitElectronicDoc;
                        Promoted = true;
                        PromotedCategory = Process;

                        trigger OnAction();
                        begin
                            GenJnlLine.Reset();
                            GenJnlLine := Rec;
                            GenJnlLine.SetRange("Journal Template Name", "Journal Template Name");
                            GenJnlLine.SetRange("Journal Batch Name", "Journal Batch Name");
                            Clear(VoidTransmitElecPayments);
                            VoidTransmitElecPayments.SetUsageType(2);   // Transmit
                            VoidTransmitElecPayments.SetTableView(GenJnlLine);
                            VoidTransmitElecPayments.RunModal();
                        end;
                    }
                }
                action("Void Check")
                {
                    Caption = 'Void Check';
                    ApplicationArea = All;
                    ToolTip = 'Void the check if, for example, the check is not cashed by the bank.';
                    Image = VoidCheck;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction();
                    var
                        VoidCheckQst: Label 'Void Check %1?';
                    begin
                        TestField("Bank Payment Type", "Bank Payment Type"::"Computer Check");
                        TestField("Check Printed", true);
                        if Confirm(VoidCheckQst, false, "Document No.") then
                            CheckManagement.VoidCheck(Rec);
                    end;
                }
                action("Void &All Checks")
                {
                    Caption = 'Void &All Checks';
                    ApplicationArea = All;
                    ToolTip = 'Void all checks if, for example, the checks are not cashed by the bank.';
                    Image = VoidAllChecks;

                    trigger OnAction();
                    var
                        VoidPrintedChecksQst: Label 'Void all printed checks?';
                    begin
                        if Confirm(VoidPrintedChecksQst, false) then begin
                            GenJnlLine.Reset();
                            GenJnlLine.Copy(Rec);
                            GenJnlLine.SetRange("Bank Payment Type", "Bank Payment Type"::"Computer Check");
                            GenJnlLine.SetRange("Check Printed", true);
                            if GenJnlLine.FindSet() then begin
                                repeat
                                    GenJnlLine2 := GenJnlLine;
                                    CheckManagement.VoidCheck(GenJnlLine2);
                                until GenJnlLine.Next() = 0;
                            end;
                        end;
                    end;
                }
                action(CreditTransferRegEntries)
                {
                    Caption = 'Credit Transfer Reg. Entries';
                    ApplicationArea = All;
                    ToolTip = 'View or edit the credit transfer entries that are related to file export for credit transfers.';
                    Image = ExportReceipt;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    RunObject = Codeunit "Gen. Jnl.-Show CT Entries";
                }
                action(CreditTransferRegisters)
                {
                    Caption = 'Credit Transfer Registers';
                    ApplicationArea = All;
                    ToolTip = 'View or edit the payment files that have been exported in connection with credit transfers.';
                    Image = ExportElectronicDocument;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    RunObject = Page "Credit Transfer Registers";
                }
            }
            action(Approvals)
            {
                Caption = 'Approvals';
                ApplicationArea = All;
                ToolTip = 'View a list of the records that are waiting to be approved. For example, you can see who requested the record to be approved, when it was sent, and when it is due to be approved.';
                Image = Approvals;
                AccessByPermission = TableData "Approval Entry" = R;

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
                Caption = 'F&unctions';
                Image = "Action";
                action("Renumber Document Numbers")
                {
                    Caption = 'Renumber Document Numbers';
                    ApplicationArea = All;
                    ToolTip = 'Resort the numbers in the Document No. column to avoid posting errors because the document numbers are not in sequence. Entry applications and line groupings are preserved.';
                    Image = EditLines;

                    trigger OnAction();
                    begin
                        RenumberDocumentNo();
                    end;
                }
                action(ApplyEntries)
                {
                    Caption = 'Apply Entries';
                    ApplicationArea = All;
                    ToolTip = 'Select one or more ledger entries that you want to apply this record to so that the related posted documents are closed as paid or refunded.';
                    Image = ApplyEntries;
                    Ellipsis = true;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Codeunit "Gen. Jnl.-Apply";
                    ShortCutKey = 'Shift+F11';
                }
                action(ExportPaymentsToFile)
                {
                    Caption = 'Export Payments to File';
                    ApplicationArea = All;
                    ToolTip = 'Export a file with the payment information on the journal lines.';
                    Image = ExportFile;
                    Ellipsis = true;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;

                    trigger OnAction();
                    var
                        GenJnlLine: Record "Gen. Journal Line";
                    begin
                        GenJnlLine.CopyFilters(Rec);
                        GenJnlLine.FindFirst();
                        GenJnlLine.ExportPaymentFile();
                    end;
                }
                action(CalculatePostingDate)
                {
                    Caption = 'Calculate Posting Date';
                    ApplicationArea = All;
                    ToolTip = 'Calculate the date that will appear as the posting date on the journal lines.';
                    Image = CalcWorkCenterCalendar;
                    Promoted = true;
                    PromotedCategory = Category5;

                    trigger OnAction();
                    begin
                        CalculatePostingDate();
                    end;
                }
                action("Insert Conv. $ Rndg. Lines")
                {
                    Caption = 'Insert Conv. $ Rndg. Lines';
                    ApplicationArea = All;
                    ToolTip = 'Insert a rounding correction line in the journal. This rounding correction line will balance in $ when amounts in the foreign currency also balance. You can then post the journal.';
                    Image = InsertCurrency;
                    RunObject = Codeunit "Adjust Gen. Journal Balance";
                }
                action(PositivePayExport)
                {
                    Caption = 'Positive Pay Export';
                    ApplicationArea = All;
                    ToolTip = 'Runs the Positive Pay Export';
                    Image = Export;

                    trigger OnAction();
                    var
                        GenJnlBatch: Record "Gen. Journal Batch";
                        BankAcc: Record "Bank Account";
                    begin
                        GenJnlBatch.Get("Journal Template Name", CurrentJnlBatchName);
                        if GenJnlBatch."Bal. Account Type" = GenJnlBatch."Bal. Account Type"::"Bank Account" then begin
                            BankAcc."No." := GenJnlBatch."Bal. Account No.";
                            Page.Run(Page::"Positive Pay Export", BankAcc);
                        end;
                    end;
                }
            }
            group("P&osting")
            {
                Caption = 'P&osting';
                Image = Post;
                action(Reconcile)
                {
                    Caption = 'Reconcile';
                    ApplicationArea = All;
                    ToolTip = 'View the balances on bank accounts that are marked for reconciliation, usually liquid accounts.';
                    Image = Reconcile;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ShortCutKey = 'Ctrl+F11';

                    trigger OnAction();
                    begin
                        GLReconcile.SetGenJnlLine(Rec);
                        GLReconcile.Run();
                    end;
                }
                action(PreCheck)
                {
                    Caption = 'Vendor Pre-Payment Journal';
                    ApplicationArea = All;
                    ToolTip = 'View journal line entries, payment discounts, discount tolerance amounts, payment tolerance, and any errors associated with the entries. You can use the results of the report to review payment journal lines and to review the results of posting before you actually post.';
                    Image = PreviewChecks;

                    trigger OnAction();
                    var
                        GenJournalBatch: Record "Gen. Journal Batch";
                    begin
                        GenJournalBatch.Init();
                        GenJournalBatch.SetRange("Journal Template Name", "Journal Template Name");
                        GenJournalBatch.SetRange(Name, "Journal Batch Name");
                        Report.Run(Report::"Vendor Pre-Payment Journal", true, false, GenJournalBatch);
                    end;
                }
                action("Test Report")
                {
                    Caption = 'Test Report';
                    ApplicationArea = All;
                    ToolTip = 'View a test report so that you can find and correct any errors before you perform the actual posting of the journal or document.';
                    Image = TestReport;
                    Ellipsis = true;

                    trigger OnAction();
                    begin
                        ReportPrint.PrintGenJnlLine(Rec);
                    end;
                }
                action(Post)
                {
                    Caption = 'P&ost';
                    ApplicationArea = All;
                    ToolTip = 'Finalize the document or journal by posting the amounts and quantities to the related accounts in your company books.';
                    Image = PostOrder;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';

                    trigger OnAction();
                    begin
                        Codeunit.Run(Codeunit::"Gen. Jnl.-Post", Rec);
                        CurrentJnlBatchName := GetRangeMax("Journal Batch Name");
                        CurrPage.Update(false);
                    end;
                }
                action("Preview")
                {
                    Caption = 'Preview Posting';
                    ApplicationArea = All;
                    ToolTip = 'Review the different types of entries that will be created when you post the document or journal.';
                    Image = ViewPostedOrder;

                    trigger OnAction();
                    var
                        GenJnlPost: Codeunit "Gen. Jnl.-Post";
                    begin
                        GenJnlPost.Preview(Rec);
                    end;
                }
                action("Post and &Print")
                {
                    Caption = 'Post and &Print';
                    ApplicationArea = All;
                    ToolTip = 'Finalize and prepare to print the document or journal. The values and quantities are posted to the related accounts. A report request window where you can specify what to include on the print-out.';
                    Image = PostPrint;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+F9';

                    trigger OnAction();
                    begin
                        Codeunit.Run(Codeunit::"Gen. Jnl.-Post+Print", Rec);
                        CurrentJnlBatchName := GetRangeMax("Journal Batch Name");
                        CurrPage.Update(false);
                    end;
                }
            }
            group("Request Approval")
            {
                Caption = 'Request Approval';
                group(SendApprovalRequest)
                {
                    Caption = 'Send Approval Request';
                    Image = SendApprovalRequest;
                    action(SendApprovalRequestJournalBatch)
                    {
                        Caption = 'Journal Batch';
                        ApplicationArea = All;
                        ToolTip = 'Send all journal lines for approval, also those that you may not see because of filters.';
                        Image = SendApprovalRequest;
                        Enabled = not OpenApprovalEntriesOnBatchOrAnyJnlLineExist;

                        trigger OnAction();
                        var
                            ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                        begin
                            ApprovalsMgmt.TrySendJournalBatchApprovalRequest(Rec);
                            SetControlAppearance();
                        end;
                    }
                    action(SendApprovalRequestJournalLine)
                    {
                        Caption = 'Selected Journal Lines';
                        ApplicationArea = Suite;
                        ToolTip = 'Send selected journal lines for approval.';
                        Image = SendApprovalRequest;
                        Enabled = NOT OpenApprovalEntriesOnBatchOrCurrJnlLineExist;

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
                    Caption = 'Cancel Approval Request';
                    Image = Cancel;
                    action(CancelApprovalRequestJournalBatch)
                    {
                        Caption = 'Journal Batch';
                        ApplicationArea = All;
                        ToolTip = 'Cancel sending all journal lines for approval, also those that you may not see because of filters.';
                        Image = CancelApprovalRequest;
                        Enabled = CanCancelApprovalForJnlBatch;

                        trigger OnAction();
                        var
                            ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                        begin
                            ApprovalsMgmt.TryCancelJournalBatchApprovalRequest(Rec);
                            SetControlAppearance();
                        end;
                    }
                    action(CancelApprovalRequestJournalLine)
                    {
                        Caption = 'Selected Journal Lines';
                        ApplicationArea = Suite;
                        ToolTip = 'Cancel sending selected journal lines for approval.';
                        Image = CancelApprovalRequest;
                        Enabled = CanCancelApprovalForJnlLine;

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
                Caption = 'Workflow';
                action(CreateApprovalWorkflow)
                {
                    Caption = 'Create Approval Workflow';
                    ApplicationArea = All;
                    ToolTip = 'Set up an approval workflow for payment journal lines, by going through a few pages that will guide you.';
                    Image = CreateWorkflow;
                    Enabled = NOT EnabledApprovalWorkflowsExist;

                    trigger OnAction();
                    var
                        TempApprovalWorkflowWizard: Record "Approval Workflow Wizard" temporary;
                    begin
                        TempApprovalWorkflowWizard."Journal Batch Name" := "Journal Batch Name";
                        TempApprovalWorkflowWizard."Journal Template Name" := "Journal Template Name";
                        TempApprovalWorkflowWizard."For All Batches" := false;
                        TempApprovalWorkflowWizard.Insert();

                        Page.RunModal(Page::"Pmt. App. Workflow Setup Wzrd.", TempApprovalWorkflowWizard);
                    end;
                }
                action(ManageApprovalWorkflows)
                {
                    Caption = 'Manage Approval Workflows';
                    ApplicationArea = All;
                    ToolTip = 'View or edit existing approval workflows for payment journal lines.';
                    Image = WorkflowSetup;
                    Enabled = EnabledApprovalWorkflowsExist;

                    trigger OnAction();
                    var
                        WorkflowManagement: Codeunit "Workflow Management";
                    begin
                        WorkflowManagement.NavigateToWorkflows(Database::"Gen. Journal Line", EventFilter);
                    end;
                }
            }
            group(Approval)
            {
                Caption = 'Approval';
                action(Approve)
                {
                    Caption = 'Approve';
                    ApplicationArea = All;
                    ToolTip = 'Approve the requested changes.';
                    Image = Approve;
                    Promoted = true;
                    PromotedCategory = Category6;
                    PromotedIsBig = true;
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
                    Caption = 'Reject';
                    ApplicationArea = All;
                    ToolTip = 'Reject the approval request.';
                    Image = Reject;
                    Promoted = true;
                    PromotedCategory = Category6;
                    PromotedIsBig = true;
                    PromotedOnly = true;
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
                    Caption = 'Delegate';
                    ApplicationArea = All;
                    ToolTip = 'Delegate the approval to a substitute approver.';
                    Image = Delegate;
                    Promoted = true;
                    PromotedCategory = Category6;
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
                    Caption = 'Comments';
                    ApplicationArea = All;
                    ToolTip = 'View or add comments.';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category6;
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction();
                    var
                        GenJournalBatch: Record "Gen. Journal Batch";
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        if OpenApprovalEntriesOnJnlLineExist then begin
                            ApprovalsMgmt.GetApprovalComment(Rec);
                        end else begin
                            if OpenApprovalEntriesOnJnlBatchExist then begin
                                if GenJournalBatch.Get("Journal Template Name", "Journal Batch Name") then begin
                                    ApprovalsMgmt.GetApprovalComment(GenJournalBatch);
                                end;
                            end;
                        end;
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
        SetControlAppearance();
        StyleTxt := GetOverdueDateInteractions(OverdueWarningText);
        GenJnlManagement.GetAccounts(Rec, AccName, BalAccName);
        UpdateBalance();
        CurrPage.IncomingDocAttachFactBox.Page.LoadDataFromRecord(Rec);

        if GenJournalBatch.Get("Journal Template Name", "Journal Batch Name") then
            ShowWorkflowStatusOnBatch := CurrPage.WorkflowStatusBatch.Page.SetFilterOnWorkflowRecord(GenJournalBatch.RecordId());
        ShowWorkflowStatusOnLine := CurrPage.WorkflowStatusLine.Page.SetFilterOnWorkflowRecord(RecordId());

        EventFilter := WorkflowEventHandling.RunWorkflowOnSendGeneralJournalLineForApprovalCode();
        EnabledApprovalWorkflowsExist := WorkflowManagement.EnabledWorkflowExist(Database::"Gen. Journal Line", EventFilter);
    end;

    trigger OnAfterGetRecord();
    begin
        StyleTxt := GetOverdueDateInteractions(OverdueWarningText);
        ShowShortcutDimCode(ShortcutDimCode);
        HasPmtFileErr := HasPaymentFileErrors();
    end;

    trigger OnInit();
    begin
        TotalBalanceVisible := true;
        BalanceVisible := true;
    end;

    trigger OnModifyRecord(): Boolean;
    begin
        CheckForPmtJnlErrors();
    end;

    trigger OnNewRecord(BelowxRec: Boolean);
    var
        CheckCannotVoidMsg: Label 'Warning:  Checks cannot be financially voided when Force Doc. Balance is set to No in the Journal Template.';
    begin
        HasPmtFileErr := false;
        UpdateBalance();
        SetUpNewLine(xRec, Balance, BelowxRec);
        Clear(ShortcutDimCode);
        if not VoidWarningDisplayed then begin
            GenJnlTemplate.Get("Journal Template Name");
            if not GenJnlTemplate."Force Doc. Balance" then
                Message(CheckCannotVoidMsg);
            VoidWarningDisplayed := true;
        end;
    end;

    trigger OnOpenPage();
    var
        JnlSelected: Boolean;
        CommissionsDisabledErr: Label 'The Commission Add-on is disabled';
    begin
        CommSetup.Get();
        if CommSetup.Disabled then
            Error(CommissionsDisabledErr);

        BalAccName := '';

        if IsOpenedFromBatch() then begin
            CurrentJnlBatchName := "Journal Batch Name";
            GenJnlManagement.OpenJnl(CurrentJnlBatchName, Rec);
            SetControlAppearance();
            exit;
        end;
        GenJnlManagement.TemplateSelection(Page::"Payment Journal", 4, false, Rec, JnlSelected);
        if not JnlSelected then
            Error('');
        GenJnlManagement.OpenJnl(CurrentJnlBatchName, Rec);
        SetControlAppearance();
        VoidWarningDisplayed := false;
    end;

    var
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
        ShortcutDimCode: array[8] of Code[20];
        CurrentJnlBatchName: Code[10];
        AccName: Text[100];
        BalAccName: Text[100];
        StyleTxt: Text;
        OverdueWarningText: Text;
        EventFilter: Text;
        TotalBalance: Decimal;
        Balance: Decimal;
        ShowBalance: Boolean;
        ShowTotalBalance: Boolean;
        VoidWarningDisplayed: Boolean;
        HasPmtFileErr: Boolean;
        [InDataSet]
        BalanceVisible: Boolean;
        [InDataSet]
        TotalBalanceVisible: Boolean;
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

    local procedure CheckForPmtJnlErrors();
    var
        BankAccount: Record "Bank Account";
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        if HasPmtFileErr then
            if ("Bal. Account Type" = "Bal. Account Type"::"Bank Account") and BankAccount.Get("Bal. Account No.") then
                if BankExportImportSetup.Get(BankAccount."Payment Export Format") then
                    if BankExportImportSetup."Check Export Codeunit" > 0 then
                        Codeunit.Run(BankExportImportSetup."Check Export Codeunit", Rec);
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
        CurrPage.SaveRecord();
        GenJnlManagement.SetName(CurrentJnlBatchName, Rec);
        CurrPage.Update(false);
    end;

    local procedure GetCurrentlySelectedLines(var GenJournalLine: Record "Gen. Journal Line"): Boolean;
    begin
        CurrPage.SetSelectionFilter(GenJournalLine);
        exit(GenJournalLine.FindSet());
    end;

    local procedure SetControlAppearance();
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    begin
        if GenJournalBatch.Get("Journal Template Name", "Journal Batch Name") then;
        OpenApprovalEntriesExistForCurrUser :=
          ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(GenJournalBatch.RecordId()) or
          ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(RecordId());

        OpenApprovalEntriesOnJnlBatchExist := ApprovalsMgmt.HasOpenApprovalEntries(GenJournalBatch.RecordId());
        OpenApprovalEntriesOnJnlLineExist := ApprovalsMgmt.HasOpenApprovalEntries(RecordId());
        OpenApprovalEntriesOnBatchOrCurrJnlLineExist := OpenApprovalEntriesOnJnlBatchExist or OpenApprovalEntriesOnJnlLineExist;

        OpenApprovalEntriesOnBatchOrAnyJnlLineExist :=
          OpenApprovalEntriesOnJnlBatchExist or
          ApprovalsMgmt.HasAnyOpenJournalLineApprovalEntries("Journal Template Name", "Journal Batch Name");

        CanCancelApprovalForJnlBatch := ApprovalsMgmt.CanCancelApprovalForRecord(GenJournalBatch.RecordId());
        CanCancelApprovalForJnlLine := ApprovalsMgmt.CanCancelApprovalForRecord(RecordId());
    end;
}