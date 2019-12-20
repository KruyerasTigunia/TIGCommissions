page 80007 "CommissionUnitGrpMembersTigCM"
{
    //TODO - replace the description stuff with a flowfield in the table
    Caption = 'Commission Unit Group Members';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = CommissionUnitGroupMemberTigCM;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Group Code"; "Group Code")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Group Code';
                    Editable = false;
                    Visible = false;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Type';

                    trigger OnValidate();
                    begin
                        Desc := GetDescription();
                    end;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the No.';

                    trigger OnValidate();
                    begin
                        GetDescription();
                        CurrPage.Update();
                    end;
                }
                field(Desc; Desc)
                {
                    Caption = 'Description';
                    ApplicationArea = All;
                    Tooltip = 'Specifies the Desc';
                    Editable = false;
                }
            }
        }
    }

    trigger OnAfterGetRecord();
    begin
        Desc := GetDescription();
    end;

    var
        Desc: Text[50];

    local procedure GetDescription(): Text[50];
    var
        Item: Record Item;
        Resource: Record Resource;
    begin
        if "No." = '' then
            exit('');
        case Type of
            Type::Item:
                begin
                    if not Item.GET("No.") then
                        CLEAR(Item);
                    exit(CopyStr(Item.Description, 1, MaxStrLen(Desc)));
                end;
            Type::Resource:
                begin
                    if not Resource.GET("No.") then
                        CLEAR(Resource);
                    exit(CopyStr(Resource.Name, 1, MaxStrLen(Desc)));
                end;
            else begin
                    exit('');
                end;
        end;
    end;
}