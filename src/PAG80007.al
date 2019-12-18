page 80007 "Commission Unit Group Members"
{
    // version TIGCOMM1.0

    // TIGCOMM1.0 Commissions

    DelayedInsert = true;
    PageType = List;
    SourceTable = "Commission Unit Group Member";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Group Code";"Group Code")
                {
                    Editable = false;
                    Visible = false;
                }
                field(Type;Type)
                {

                    trigger OnValidate();
                    begin
                        Desc := GetDescription;
                    end;
                }
                field("No.";"No.")
                {

                    trigger OnValidate();
                    begin
                        GetDescription;
                        CurrPage.UPDATE;
                    end;
                }
                field(Desc;Desc)
                {
                    Caption = 'Description';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord();
    begin
        Desc := GetDescription;
    end;

    var
        Desc : Text[50];

    local procedure GetDescription() : Text[50];
    var
        Item : Record Item;
        Resource : Record Resource;
    begin
        if "No." = '' then
          exit('');
        if Type = Type::Item then begin
          if not Item.GET("No.") then
            CLEAR(Item);
          exit(Item.Description);
        end;

        if Type = Type::Resource then begin
          if not Resource.GET("No.") then
            CLEAR(Resource);
          exit(Resource.Name);
        end;
    end;
}

