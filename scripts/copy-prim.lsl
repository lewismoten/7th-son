key creatorIdRequest = NULL_KEY;
string text = "\n";
integer paramLines = 0;
integer debug = TRUE;

addText(string suffix) {
    if(llStringLength(text + suffix) >= 1000) {
        llOwnerSay(text);
        text = suffix;
    } else {
        text += suffix;
    }
}
string fixNumber(float value) {
    if((integer)value == value) return (string)((integer)value);
    // Float
    string num = (string)value;
    string endChar = llGetSubString((string)num, -1, -1);
    // remove extra zeros at end
    while(endChar == "0") {
        num = llGetSubString(num, 0, -2);
        endChar = llGetSubString(num, -1, -1);
    }
    return num;
}
string fixString(string value) {
    string startChar = llGetSubString(value, 0, 0);
    string endChar = llGetSubString(value, -1, -1);
    string middle = llGetSubString(value, 1, -2);
    
    // Vector or Rotation
    if(startChar == "<" && endChar == ">") {
        list parts = llParseString2List(middle, [","], []);
        integer partCount = llGetListLength(parts);
        if(partCount == 3) {
            vector v = (vector)value;
            if(v == ZERO_VECTOR) return "ZERO_VECTOR";
            return "<" + fixNumber(v.x) + ", " + fixNumber(v.y) + ", " + fixNumber(v.z) + ">";
        } else if(partCount == 4) {
            rotation r = (rotation)value;
            if(r == ZERO_ROTATION) return "ZERO_ROTATION";
            return "<" + fixNumber(r.x) + ", " + fixNumber(r.y) + ", " + fixNumber(r.z) + ", " + fixNumber(r.s) + ">";
        } else {
            string fixed = startChar;
            integer i = 0;
            for(i = 0; i < partCount; i++) {
                if(i != 0) fixed += ", ";
                fixed += fixString(llList2String(parts, i));
            }
            fixed += endChar;
            return fixed;
        }
    }
    string numCheck = llStringTrim(value, STRING_TRIM);
    integer charCount = llStringLength(numCheck);
    // one or more digits
    // zero or one decimal
    // zero or one sign at beginning
    integer isNumber = TRUE;
    integer isFloat = FALSE;
    integer i;
    integer decimalCount = 0;
    if(charCount > 0) {
        for(i = 0; i < charCount; i++) {
            string char = llGetSubString(numCheck, i, i);
            if(char == "-") {
                if(i != 0) {
                    isNumber = FALSE;
                }
            } else if(char == ".") {
                if(isFloat == TRUE) isNumber = FALSE;
                else isFloat = TRUE;
            } else if(llListFindList(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"], [char]) == -1) {
                isNumber = FALSE;
            } else {
                decimalCount++;
            }
        }
        if(isNumber && decimalCount > 0) {
            return fixNumber((float)numCheck);
        }
    }    

    if(value == NULL_KEY) {
        return "NULL_KEY";
    }
    // Encode backslash and quote
    value = llReplaceSubString(value, "\\", "\\\\", 0);
    value = llReplaceSubString(value, "\"", "\\\"", 0);
    return "\"" + value + "\"";
}
setNString(string fn, integer n, string value) {
    addText(fn + "(" + (string)n + ", " + fixString(value) + ");\n");
}
setNVector(string fn, integer n, vector value) {
    setNString(fn, n, (string)value);
}
setNFloat(string fn, integer n, float value) {
    setNString(fn, n, (string)value);
}
setNParamString(string param, integer n, string value) {
    string text = "";
    if(paramLines != 0) text += ",\n";
    else text += "\n";
    text += "  " + param + ", " + (string)n + ", " + fixString(value);
    addText(text);
    paramLines++;
}
setParamString(string param, string value) {
    string text = "";
    if(paramLines != 0) text += ",\n";
    else text += "\n";
    text += "  " + param + ", " + fixString(value);
    addText(text);
    paramLines++;
}
setParamVector(string fn, vector value) {
    setParamString(fn, (string)value);
}
setParamRotation(string fn, rotation value) {
    setParamString(fn, (string)value);
}
setNParamInteger(string param, integer n, integer value) {
    setNParamString(param, n, (string)value);
}
setNParamFloat(string param, integer n, float value) {
    setNParamString(param, n, (string)value);
}
setNParamList(string param, integer n, list value) {
    string text = "";
    list fixed = [];
    integer count = llGetListLength(value);
    integer i;
    for(i = 0; i < count; i++) {
        string value = llList2String(value, i);
        fixed += fixString(value);
    }
    if(paramLines != 0) text += ",\n";
    else text += "\n";
    text += "  " + param + ", " + (string)n + ", " + llList2CSV(fixed);
    addText(text);
    paramLines++;
}
setParamList(string param, list value) {
    string text = "";
    list fixed = [];
    integer count = llGetListLength(value);
    integer i;
    for(i = 0; i < count; i++) {
        string value = llList2String(value, i);
        fixed += fixString(value);
    }
    if(paramLines != 0) text += ",\n";
    else text += "\n";
    text += "  " + param + ", " + llList2CSV(fixed);
    addText(text);
    paramLines++;
}
setParamNamedList(string param, list named, list value) {
    string text = "";
    list fixed = [];
    integer count = llGetListLength(value);
    integer i;
    for(i = 0; i < count; i++) {
        string value = llList2String(value, i);
        fixed += fixString(value);
    }
    if(paramLines != 0) text += ",\n";
    else text += "\n";
    text += "  " + param + ", " + llList2CSV(named);
    if(count > 0) text += ", " + llList2CSV(fixed);
    addText(text);
    paramLines++;
}
openParams() {
    addText("llSetPrimitiveParams([");
}
closeParams() {
    addText("\n]);\n");
    paramLines = 0;
}
string getPrimTypeConst(integer value) {
    if(value == PRIM_TYPE_BOX) return "PRIM_TYPE_BOX";
    if(value == PRIM_TYPE_CYLINDER) return "PRIM_TYPE_CYLINDER";
    if(value == PRIM_TYPE_PRISM) return "PRIM_TYPE_PRISM";
    if(value == PRIM_TYPE_SPHERE) return "PRIM_TYPE_SPHERE";
    if(value == PRIM_TYPE_TORUS) return "PRIM_TYPE_TORUS";
    if(value == PRIM_TYPE_TUBE) return "PRIM_TYPE_TUBE";
    if(value == PRIM_TYPE_RING) return "PRIM_TYPE_RING";
    if(value == PRIM_TYPE_SCULPT) return "PRIM_TYPE_SCULPT";
    return (string)value;
}
string getHoleShapeConst(integer shape) {
    if(shape == PRIM_HOLE_DEFAULT) return "PRIM_HOLE_DEFAULT";
    if(shape == PRIM_HOLE_CIRCLE) return "PRIM_HOLE_CIRCLE";
    if(shape == PRIM_HOLE_SQUARE) return "PRIM_HOLE_SQUARE";
    if(shape == PRIM_HOLE_TRIANGLE) return "PRIM_HOLE_TRIANGLE";
    return (string)shape;
}
string getSculptType(integer value) {
    string text = "";
    if(value & PRIM_SCULPT_TYPE_SPHERE) text += "PRIM_SCULPT_TYPE_SPHERE";
    if(value & PRIM_SCULPT_TYPE_TORUS) text += "PRIM_SCULPT_TYPE_TORUS";
    if(value & PRIM_SCULPT_TYPE_PLANE) text += "PRIM_SCULPT_TYPE_PLANE";
    if(value & PRIM_SCULPT_TYPE_CYLINDER) text += "PRIM_SCULPT_TYPE_CYLINDER";
    if(value & PRIM_SCULPT_TYPE_MESH) text += "PRIM_SCULPT_TYPE_MESH";
    if(value & PRIM_SCULPT_FLAG_INVERT) text += " | PRIM_SCULPT_FLAG_INVERT";
    if(value & PRIM_SCULPT_FLAG_INVERT) text += " | PRIM_SCULPT_FLAG_MIRROR";
    return text;
}
string primPhysicsShapeTypeConst(integer value) {
    if(value == PRIM_PHYSICS_SHAPE_PRIM) return "PRIM_PHYSICS_SHAPE_PRIM";
    if(value == PRIM_PHYSICS_SHAPE_CONVEX) return "PRIM_PHYSICS_SHAPE_PRIM";
    if(value == PRIM_PHYSICS_SHAPE_NONE) return "PRIM_PHYSICS_SHAPE_NONE";
    return (string)value;
    
}
string primMaterialConst(integer value) {
    if(value == PRIM_MATERIAL_STONE) return "PRIM_MATERIAL_STONE";
    if(value == PRIM_MATERIAL_METAL) return "PRIM_MATERIAL_METAL";
    if(value == PRIM_MATERIAL_GLASS) return "PRIM_MATERIAL_GLASS";
    if(value == PRIM_MATERIAL_WOOD) return "PRIM_MATERIAL_WOOD";
    if(value == PRIM_MATERIAL_FLESH) return "PRIM_MATERIAL_FLESH";
    if(value == PRIM_MATERIAL_PLASTIC) return "PRIM_MATERIAL_PLASTIC";
    if(value == PRIM_MATERIAL_RUBBER) return "PRIM_MATERIAL_RUBBER";
    if(value == PRIM_MATERIAL_LIGHT) return "PRIM_MATERIAL_LIGHT";
    return (string)value;
}
string clickActionConst(integer value) {
    if(value == CLICK_ACTION_NONE) return "CLICK_ACTION_NONE";
    if(value == CLICK_ACTION_TOUCH) return "CLICK_ACTION_TOUCH";
    if(value == CLICK_ACTION_SIT) return "CLICK_ACTION_SIT";
    if(value == CLICK_ACTION_BUY) return "CLICK_ACTION_BUY";
    if(value == CLICK_ACTION_PAY) return "CLICK_ACTION_PAY";
    if(value == CLICK_ACTION_OPEN) return "CLICK_ACTION_OPEN";
    if(value == CLICK_ACTION_PLAY) return "CLICK_ACTION_PLAY";
    if(value == CLICK_ACTION_OPEN_MEDIA) return "CLICK_ACTION_OPEN_MEDIA";
    if(value == CLICK_ACTION_ZOOM) return "CLICK_ACTION_ZOOM";
    if(value == CLICK_ACTION_DISABLED) return "CLICK_ACTION_DISABLED";
    if(value == CLICK_ACTION_IGNORE) return "CLICK_ACTION_IGNORE";
    return (string)value;
}
string inventoryTypeMarkdown(integer value) {
    if(value == INVENTORY_NONE) return "Does not exist";
    if(value == INVENTORY_TEXTURE) return "Texture";
    if(value == INVENTORY_SOUND) return "Sound";
    if(value == INVENTORY_LANDMARK) return "Landmark";
    if(value == INVENTORY_CLOTHING) return "Clothing";
    if(value == INVENTORY_OBJECT) return "Object";
    if(value == INVENTORY_NOTECARD) return "Notecard";
    if(value == INVENTORY_SCRIPT) return "Script";
    if(value == INVENTORY_BODYPART) return "Body Part";
    if(value == INVENTORY_ANIMATION) return "Animation";
    if(value == INVENTORY_GESTURE) return "Gesture";
    if(value == INVENTORY_SETTING) return "Setting";
    if(value == INVENTORY_MATERIAL) return "Material";
    return (string)value;
}
string primReflectionConst(integer value) {
    string text = "";
    if(value & PRIM_REFLECTION_PROBE) {
        value = value & ~PRIM_REFLECTION_PROBE;
        text = "PRIM_REFLECTION_PROBE_BOX";
    }
    if(value & PRIM_REFLECTION_PROBE_DYNAMIC) {
        value = value & ~PRIM_REFLECTION_PROBE_DYNAMIC;
        if(llStringLength(text) != 0) text += " | ";
        text += "PRIM_REFLECTION_PROBE_DYNAMIC";
    }
    if(value & PRIM_REFLECTION_PROBE_MIRROR) {
        value = value & ~PRIM_REFLECTION_PROBE_MIRROR;
        if(llStringLength(text) != 0) text += " | ";
        text += "PRIM_REFLECTION_PROBE_MIRROR";
    }
    if(value > 0) {
        if(llStringLength(text) != 0) text += " | ";
        text += (string)value;
    }
    if(text == "") {
        return "0";
    }
    return text;
}
showTextures() {
    integer sides = llGetNumberOfSides();
    integer i;
    for(i = 0; i < sides; i++) {
        list params = llGetPrimitiveParams([
            PRIM_FULLBRIGHT, i,
            PRIM_RENDER_MATERIAL, i,
            PRIM_TEXGEN, i,
            PRIM_GLOW, i,
            PRIM_NORMAL, i,
            PRIM_SPECULAR, i,
            PRIM_ALPHA_MODE, i,
            PRIM_GLTF_BASE_COLOR, i,
            PRIM_GLTF_NORMAL, i,
            PRIM_GLTF_METALLIC_ROUGHNESS, i,
            PRIM_GLTF_EMISSIVE, i,
            PRIM_BUMP_SHINY, i,
            PRIM_COLOR, i,
            PRIM_TEXTURE, i
        ]);
        addText("\n// Face " + (string)i + "\n");
        openParams();
        setNParamList("PRIM_COLOR", i, llList2List(params, 43, 44));
        setNParamList("PRIM_TEXTURE", i, llList2List(params, 45, 48));
        setNParamInteger("PRIM_FULLBRIGHT", i, llList2Integer(params, 0));
        setNParamString("PRIM_RENDER_MATERIAL", i, llList2String(params, 1));
        setNParamInteger("PRIM_TEXGEN", i, llList2Integer(params, 2));
        setNParamFloat("PRIM_GLOW", i, llList2Float(params, 3));
        setNParamList("PRIM_NORMAL", i, llList2List(params, 4, 7));
        setNParamList("PRIM_SPECULAR", i, llList2List(params, 8, 14));
        setNParamList("PRIM_ALPHA_MODE", i, llList2List(params, 15, 16));
        setNParamList("PRIM_GLTF_BASE_COLOR", i, llList2List(params, 17, 25));
        setNParamList("PRIM_GLTF_NORMAL", i, llList2List(params, 26, 29));
        setNParamList("PRIM_GLTF_METALLIC_ROUGHNESS", i, llList2List(params, 30, 35));
        setNParamList("PRIM_GLTF_EMISSIVE", i, llList2List(params, 36, 40));
        setNParamList("PRIM_BUMP_SHINY", i, llList2List(params, 41, 42));
        closeParams();
    }
}
string trueFalse(integer value) {
    if(value == TRUE) return "TRUE";
    if(value == FALSE) return "FALSE";
    return (string)value;
}

showGeneral() {
    integer offset;
    
    list params = llGetPrimitiveParams([
        PRIM_NAME,
        PRIM_DESC,
        PRIM_TYPE,
        PRIM_SLICE,
        PRIM_PHYSICS_SHAPE_TYPE,
        PRIM_MATERIAL,
        PRIM_PHYSICS,
        PRIM_TEMP_ON_REZ,
        PRIM_PHANTOM,
        PRIM_POSITION,
        PRIM_POS_LOCAL,
        PRIM_ROTATION,
        PRIM_ROT_LOCAL,
        PRIM_SIZE,
        PRIM_TEXT,
        PRIM_FLEXIBLE,
        PRIM_POINT_LIGHT,
        PRIM_REFLECTION_PROBE,
        PRIM_OMEGA,
        PRIM_ALLOW_UNSIT,
        PRIM_SCRIPTED_SIT_ONLY,
        PRIM_SIT_TARGET,
        PRIM_CLICK_ACTION
    ]);
    addText("\n// Link Number: " + (string)llGetLinkNumber() + "\n");
    openParams();
    setParamString("PRIM_NAME", llList2String(params, 0));
    setParamString("PRIM_DESC", llList2String(params, 1));
    
    offset = 2;
    integer primType = llList2Integer(params, 2);
    string primTypeConst = getPrimTypeConst(primType);
    if(primType == PRIM_TYPE_SCULPT) {
        string map = fixString(llList2String(params, 3));
        integer type = llList2Integer(params, 4);
        string typeS = getSculptType(type);
        
        setParamNamedList("PRIM_TYPE", [primTypeConst, map, typeS], []);
        offset = 5;
    } else {
        string holeShape = getHoleShapeConst(llList2Integer(params, 3));
        if(primType == PRIM_TYPE_BOX || primType == PRIM_TYPE_CYLINDER || primType == PRIM_TYPE_PRISM) {
            setParamNamedList("PRIM_TYPE", [primTypeConst, holeShape], llList2List(params, 4, 8));
            offset = 9;
        } else if(primType == PRIM_TYPE_SPHERE) {
            setParamNamedList("PRIM_TYPE", [primTypeConst, holeShape], llList2List(params, 4, 7));
            offset = 8;
        } else if(primType == PRIM_TYPE_TORUS || primType == PRIM_TYPE_TUBE) {
            setParamNamedList("PRIM_TYPE", [primTypeConst, holeShape], llList2List(params, 4, 13));
            offset = 14;
        } else if(primType == PRIM_TYPE_RING) {
            setParamNamedList("PRIM_TYPE", [primTypeConst, holeShape], llList2List(params, 4, 11));
            offset = 12;
        }
    }
    setParamVector("PRIM_SLICE", llList2Vector(params, offset++));
    setParamNamedList("PRIM_PHYSICS_SHAPE_TYPE", [primPhysicsShapeTypeConst(llList2Integer(params, offset++))], []);
    setParamNamedList("PRIM_MATERIAL", [primMaterialConst(llList2Integer(params, offset++))], []);
    setParamNamedList("PRIM_PHYSICS", [trueFalse(llList2Integer(params, offset++))], []);
    setParamNamedList("PRIM_TEMP_ON_REZ", [trueFalse(llList2Integer(params, offset++))], []);
    setParamNamedList("PRIM_PHANTOM", [trueFalse(llList2Integer(params, offset++))], []);
    setParamVector("PRIM_POSITION", llList2Vector(params, offset++));
    setParamVector("PRIM_POS_LOCAL", llList2Vector(params, offset++));
    setParamRotation("PRIM_ROTATION", llList2Rot(params, offset++));
    setParamRotation("PRIM_ROT_LOCAL", llList2Rot(params, offset++));
    setParamVector("PRIM_SIZE", llList2Vector(params, offset++));
    setParamList("PRIM_TEXT", llList2List(params, offset, offset + 2));
    offset += 3;
    setParamNamedList("PRIM_FLEXIBLE", [trueFalse(llList2Integer(params, offset++))], llList2List(params, offset, offset + 5));
    offset += 6;
    setParamNamedList("PRIM_POINT_LIGHT", [trueFalse(llList2Integer(params, offset++))], llList2List(params, offset, offset + 3));
    offset += 4;
    setParamNamedList("PRIM_REFLECTION_PROBE", [
        trueFalse(llList2Integer(params, offset++)),
        fixString(llList2String(params, offset++)),
        fixString(llList2String(params, offset++)),
        primReflectionConst(llList2Integer(params, offset++))
    ], []);
        // vector, float, flat
    setParamList("PRIM_OMEGA", llList2List(params, offset, offset + 2));
    offset += 3;
    setParamNamedList("PRIM_ALLOW_UNSIT", [trueFalse(llList2Integer(params, offset++))], []);
    setParamNamedList("PRIM_SCRIPTED_SIT_ONLY", [trueFalse(llList2Integer(params, offset++))], []);
    
    // shoudl be a last number should be a vector?
    setParamNamedList("PRIM_SIT_TARGET", [trueFalse(llList2Integer(params, offset++))], llList2List(params, offset, offset+1));
    offset += 2;
    setParamNamedList("PRIM_CLICK_ACTION", [clickActionConst(llList2Integer(params, offset++))], []);
    
    closeParams();    
}
showGeneralMarkdown() {
    addText("# General\n\n");
    addText("| Setting | Value | | | |\n");
    addText("| --- | --- | --- | --- | --- |\n");
    addText("| Link Number | " + (string)llGetLinkNumber() + " |\n");
    addText("| Name | " + llGetObjectName() + " |\n");
    addText("| Description | " + llGetObjectDesc() + " |\n");

    key creatorId = llGetCreator();
    creatorIdRequest = llRequestUsername(creatorId);
}
string yesOrNo(integer value) {
    if(value) return "Yes";
    return "No";
}
string permMarkdown(integer perms) {
    string text = "";
    text += yesOrNo(perms & PERM_MOVE);
    text += " | ";
    text += yesOrNo(perms & PERM_MODIFY);
    text += " | ";
    text += yesOrNo(perms & PERM_COPY);
    text += " | ";
    text += yesOrNo(perms & PERM_TRANSFER);
    return text;
}
showPermsFor(string name, integer mask) {    
    integer perms = llGetObjectPermMask(mask);
    addText("| " + name + " | " + permMarkdown(perms) + " |\n");
}
showPermissions() {
    addText("\n\n#Permssions\n\n");
    addText("| Who | Move | Modify | Copy | Transfer |\n");
    addText("| --- | --- | --- | --- | --- |\n");
    showPermsFor("Owner", MASK_OWNER);
    showPermsFor("Group", MASK_GROUP);
    showPermsFor("Anyone", MASK_EVERYONE);
    showPermsFor("Next owner", MASK_NEXT);
    addText("\n");
    showInventory();
}
integer inventoryCount;
integer inventoryNumber;
key inventoryNameRequestId;
key inventoryCreatorNameRequestId;
string inventoryLineItem;

showInventory() {
    integer inventoryCount = llGetInventoryNumber(INVENTORY_ALL);
    if(inventoryCount <= 1) {
        done();
        return;
    }
    addText("\n\n#Inventory\n\n");
    addText("| Name | Type | Key | Move | Modify | Copy | Transfer | Acquired |");
    addText("| --- | --- | --- | --- | --- | --- | --- | --- |");
    
    inventoryNumber = 0;
    inventoryLineItem = "| ";
    inventoryNameRequestId = llGetInventoryName(INVENTORY_ALL, inventoryNumber);
}
done() {
    llOwnerSay(text);
    text = "";
}
default
{
    state_entry()
    {
        integer showMarkdown = FALSE;
        if(showMarkdown) {
            showGeneralMarkdown();
        } else {
            showGeneral();
            showTextures();
            done();
        }
    }
    dataserver(key queryid, string data)
    {
        if(queryid == creatorIdRequest) {
           creatorIdRequest = NULL_KEY;
            string text = "";
            text += "| Creator | " + data + " |\n";
            addText(text);
            showPermissions();
        } else if(queryid == inventoryNameRequestId) {
            inventoryNameRequestId = NULL_KEY;
            inventoryLineItem += data + " | ";
            inventoryLineItem += inventoryTypeMarkdown(llGetInventoryType(data)) + " | ";
            key id = llGetInventoryKey(data);
            if(id == NULL_KEY) inventoryLineItem += "NULL_KEY | ";
            else inventoryLineItem += (string)id + " | ";
            inventoryLineItem += permMarkdown(llGetInventoryPermMask(data, MASK_NEXT)) + " | ";
            inventoryLineItem += llGetInventoryAcquireTime(data) + " | ";
            key creatorId = llGetInventoryCreator(data);
            inventoryCreatorNameRequestId = llRequestAgentData(creatorId, DATA_NAME);
        } else if(queryid == inventoryCreatorNameRequestId) {
            inventoryLineItem += data + " |\n";
            addText(inventoryLineItem);
            inventoryLineItem = "| ";
            inventoryNumber++;
            if(inventoryNumber < inventoryCount) {
              inventoryNameRequestId = llGetInventoryName(INVENTORY_ALL, inventoryNumber);
            } else {
                done();
            }
        }
    }
}
