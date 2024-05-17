string texture = "329ef5de-8cfd-90c5-511b-99683b6a4382";
string alphahalf = "14625371-dfd3-da91-021d-24f0e5e11e5d";

vector tint = <1,1,1>;
integer listener = 0;
integer perms = 0;
integer price = 0;

list permParams()
{
    integer index = 0;
    
    if((perms & PERM_TRANSFER) == PERM_TRANSFER)  index++;
    if((perms & PERM_COPY) == PERM_COPY) index += 2;
    if((perms & PERM_MODIFY) == PERM_MODIFY) index += 4;
    
    vector repeats = <0.336756, 0.1, 0.0>;
    vector offsets = <0.33059, 0.45 - (index * 0.1), 0>;
    float radians = 0 * DEG_TO_RAD;

    return [
        PRIM_TEXTURE, 1, texture, repeats, offsets, radians,
        PRIM_COLOR, 1, tint, 1.0
        ];
    
}
list currencyParams()
{
    vector repeats = <0.11807, 0.095238, 0.0>;
    vector offsets = <0.43942, -0.34881, 0>;
    float radians = 0 * DEG_TO_RAD;
    return [
        PRIM_TEXTURE, 6, texture, repeats, offsets, radians,
        PRIM_COLOR, 6, tint, 1.0
        ];
}
list mapOverMoney()
{
    vector repeats = <.5, .5, 0.0>;
    vector offsets = <.83, 0, 0>;
    float radians = 0 * DEG_TO_RAD;
    return [
        PRIM_TEXTURE, 7, alphahalf, repeats, offsets, radians,
        PRIM_COLOR, 7, tint, 1.0
    ];
}
list moneyParams()
{
    string chars = " 0123456789";
    
    string text = (string)price;
    
    while(llStringLength(text) < 6)
        text = " " + text;
    if(llStringLength(text) > 6)
        text = llGetSubString(text, -6, -1);
    
    list params = [];
    
    integer i;
    for(i = 0; i < 3; i++)
    {
        string c1 = llGetSubString(text, i * 2, i * 2);
        string c2 = llGetSubString(text, (i * 2) + 1, (i * 2) + 1);
        
        integer column = llSubStringIndex(chars, c1);
        integer row = llSubStringIndex(chars, c2);
        
        if(i == 0) params += mapMoney(3, row, column);
        else if(i == 1 && price < 100)
            params += mapOverMoney();
        else if(i == 1)
            params += mapMoney(7, row, column);
        
        else if(i == 2) params += mapMoney(4, row, column);
    }
    return params;
}
vector getOffset(integer face, integer row, integer column)
{
    float width = 1.0 / 14.4225;
    float halfWidth = width * 0.5;
    float left = -0.5 + halfWidth;
    
    
    float height = 1.0 / 11.0;
    float halfHeight = height * 0.5;
    float top = 0.5 - halfHeight;
    
    vector offset = <left,top,0>;
    
    offset.x += column * width;
    offset.y -= row * height;
    
    if(face == 1) offset.x += width * .54;
    else if (face == 4) offset.x -= width * 7.55;
    else if (face == 3) offset.x += width * 0.75;
     
    if(offset.x > 1.0) offset.x -= 1.0; 
    else if(offset.x < -1.0) offset.x += 1.0;
    
    if(offset.y > 1.0) offset.y -= 1.0; 
    else if(offset.y < -1.0) offset.y += 1.0;
    
    return offset;    
}
vector getSize(integer face)
{
    float width = 1.0 / 14.4225;
    float height = 1.0 / 11.0;
    
    if(face == 1 || face == 3) return <width * 2.5, height, 0>;
    else if(face == 4) return <width * -18.7, height, 0>;
    else return <width, height, 0>;
}
list mapMoney(integer face, integer row, integer column)
{
    if(row == 0 && column == 0)
        return [PRIM_COLOR, face, tint, 0.0];
    
    vector offsets = getOffset(face, row, column);
    vector repeats = getSize(face);
    float radians = 0 * DEG_TO_RAD;
    
    return [
        PRIM_TEXTURE, face, texture, repeats, offsets, radians,
        PRIM_COLOR, face, tint, 1.0
        ];
}
stopListening()
{
    llSetTimerEvent(0.0);
    if(listener != 0)
    {
        llListenRemove(listener);
        listener = 0;
    }
}
integer startListening(key id)
{
    stopListening();
    integer channel = -1 * llRound(llFrand(0x7FFFFBFF) + 0x400);
    listener = llListen(channel, "", id, "");
    llSetTimerEvent(60.0);
    return channel;
}
showMenu(key id)
{
    integer channel = startListening(id);
    
    list buttons = [
        "Color", "Freeze", "Help",
        "+100", "+10", "+1",
        "-100", "-10", "-1",
        "Mod-Toggle", "Copy-Toggle", "Tran-Toggle"
    ];
    llDialog(id, "\nMain Menu", buttons, channel);
}
showColor(key id)
{
    integer channel = startListening(id);
    
    list buttons = [
        "Red", "Green", "Blue",
        "White", "Black", "Purple",
        "Cyan", "Yellow", "Grey"
    ];
    llDialog(id, "\nColor Menu", buttons, channel);
}
updateDisplay()
{
    llSetPrimitiveParams(
        [PRIM_COLOR, ALL_SIDES, tint, 0.0]
        + [PRIM_COLOR, 2, ZERO_VECTOR, 1.0]
        + permParams()
        + currencyParams()
        + moneyParams()
    );
}
init()
{
    stopListening();
    updateDisplay();
}
togglePerm(integer perm)
{
    if((perms & perm) == perm) perms -= perm;
    else perms += perm;
    updateDisplay();
}
addPrice(integer delta)
{
    price += delta;
    if(price > 999999)
        price = 999999;
    if(price < 0)
        price = 0;
    updateDisplay();
}
setColor(vector color)
{
    tint = color;
    updateDisplay();
}
integer foundColor(string command)
{
    if(command == "Red") setColor(<1,0,0>);
    else if(command == "Green") setColor(<0,1,0>);
    else if(command == "Blue") setColor(<0,0,1>);
    else if(command == "White") setColor(<1,1,1>);
    else if(command == "Black") setColor(<0,0,0>);
    else if(command == "Purple") setColor(<1,0,1>);
    else if(command == "Cyan") setColor(<0,1,1>);
    else if(command == "Yellow") setColor(<1,1,0>);
    else if(command == "Grey") setColor(<.5,.5,.5>);
    else return FALSE;
    return TRUE;
}
integer foundPrice(string command)
{
    if(llGetSubString(command, 0, 0) == "+")
        addPrice((integer)command);
    else if(llGetSubString(command, 0, 0) == "-")
        addPrice((integer)command);
    else
        return FALSE;
    return TRUE;
}
default
{
    state_entry()
    {
        init();
    }
    on_rez(integer start_param)
    {
        init();
    }
    touch_start(integer total_number)
    {
        integer i;
        for(i = 0; i < total_number; i++)
            if(llDetectedKey(i) == llGetOwner())
                showMenu(llDetectedKey(i));
    }
    listen(integer channel, string name, key id, string message)
    {
        if(message == "Color")
        {
            showColor(id);
            return;
        }
        if(message == "Freeze")
        {
            llOwnerSay("Script has been removed.");
            llRemoveInventory(llGetScriptName());
            return;
        }
        if(message == "Help")
        {
            if(llGetInventoryNumber(INVENTORY_NOTECARD) == 0)
                llOwnerSay("Notecard is missing.");
            else
                llGiveInventory(id, llGetInventoryName(INVENTORY_NOTECARD, 0));
        }
        else if(foundPrice(message))
        {
            // no more processing
        }
        else if(foundColor(message))
        {
            // no more processing
        }
        if(message == "Mod-Toggle")
            togglePerm(PERM_MODIFY);
        if(message == "Copy-Toggle")
            togglePerm(PERM_COPY);
        if(message == "Tran-Toggle")
            togglePerm(PERM_TRANSFER);
        
        showMenu(id);
    }
    timer()
    {
        stopListening();
        llOwnerSay("Timed out. Touch again to continue configuring.");
    }
}
