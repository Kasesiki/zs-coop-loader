using System;
using UndertaleModLib.Compiler;

EnsureDataLoaded();

const string DialogueMapGo = "gml_GlobalScript_npc_dialogue_map_go";
const string DialogueText = "gml_GlobalScript_lista_text";
const string MapGeneratorCreate = "gml_Object_obj_map_generator_Create_0";
const string UiFunctions = "gml_GlobalScript_ui_initialize_functions";

UndertaleCode RequireCode(string name)
{
    UndertaleCode code = Data.Code.ByName(name);
    if (code is null)
        throw new Exception("Required conductor seed code entry is missing: " + name);
    return code;
}

CodeImportGroup importGroup = new(Data, null, Data.ToolInfo.DecompilerSettings)
{
    MainThreadAction = MainThreadAction
};

UndertaleCode dialogueMapGo = RequireCode(DialogueMapGo);
UndertaleCode dialogueText = RequireCode(DialogueText);
UndertaleCode mapGeneratorCreate = RequireCode(MapGeneratorCreate);
UndertaleCode uiFunctions = RequireCode(UiFunctions);

// Add the seed entry to the conductor's dialogue list, directly before the map
// chooser entry, so a seed can be prepared before a destination is picked.
// The page itself is opened by the existing "map_seed" frame table in
// ZS_vanilla/ui/npc_left_talk.ui.
importGroup.QueueFindReplace(dialogueText,
    @"    text[i][u] = ""npc.interaction.train_type"";
    dia_type[i][u] = ""train_skin"";
    u++;
    text[i][u] = ""npc.interaction.i_want_to_leave"";",
    
    @"    text[i][u] = ""npc.interaction.train_type"";
    dia_type[i][u] = ""train_skin"";
    u++;
    text[i][u] = ""npc.interaction.map_seed"";
    dia_type[i][u] = ""map_seed"";
    u++;
    text[i][u] = ""npc.interaction.i_want_to_leave"";",
    true);

// The seed editor is a UI page, so all text handling and validation lives in
// these small helpers. They are registered with the UI Catspeak environment
// below; the page itself only renders and routes input.
importGroup.QueueFindReplace(dialogueMapGo,
    "function npc_dialogue_map_is_unlocked(arg0 = uiGetData().map_selected)",
    @"function map_seed_pending_text()
{
    if (variable_global_exists(""map_seed_override"") && global.map_seed_override != undefined)
    {
        return string(global.map_seed_override);
    }
    return """";
}

function map_seed_draft_begin()
{
    global.map_seed_draft = map_seed_pending_text();
    return global.map_seed_draft;
}

function map_seed_draft_get()
{
    if (!variable_global_exists(""map_seed_draft""))
    {
        global.map_seed_draft = """";
    }
    return global.map_seed_draft;
}

function map_seed_draft_append(arg0)
{
    var _digit = string(arg0);
    if (string_length(_digit) != 1 || string_digits(_digit) != _digit)
    {
        return map_seed_draft_get();
    }
    var _text = map_seed_draft_get();
    if (string_length(_text) >= 10)
    {
        return _text;
    }
    if (_text == ""0"")
    {
        _text = """";
    }
    global.map_seed_draft = _text + _digit;
    return global.map_seed_draft;
}

function map_seed_draft_backspace()
{
    var _text = map_seed_draft_get();
    if (_text != """")
    {
        _text = string_delete(_text, string_length(_text), 1);
    }
    global.map_seed_draft = _text;
    return _text;
}

function map_seed_draft_clear()
{
    global.map_seed_draft = """";
    return """";
}

function map_seed_draft_random()
{
    global.map_seed_draft = string(irandom(4294967295));
    return global.map_seed_draft;
}

function map_seed_draft_valid()
{
    var _text = map_seed_draft_get();
    if (_text == """")
    {
        return true;
    }
    if (string_digits(_text) != _text || string_length(_text) > 10)
    {
        return false;
    }
    return real(_text) <= 4294967295;
}

function map_seed_format_text(arg0)
{
    var _text = string(arg0);
    var _length = string_length(_text);
    var _out = """";
    var _count = 0;
    for (var _i = _length; _i >= 1; _i--)
    {
        _out = string_char_at(_text, _i) + _out;
        _count++;
        if (_count == 3 && _i > 1)
        {
            _out = "" "" + _out;
            _count = 0;
        }
    }
    return _out;
}

function map_seed_draft_commit()
{
    var _text = map_seed_draft_get();
    if (_text == """")
    {
        global.map_seed_override = undefined;
        return ""random"";
    }
    if (!map_seed_draft_valid())
    {
        return ""invalid"";
    }
    global.map_seed_override = floor(real(_text));
    return ""set"";
}

function map_seed_key_backspace()
{
    return keyboard_check_pressed(vk_backspace);
}

function npc_dialogue_map_is_unlocked(arg0 = uiGetData().map_selected)",
    true);

// Expose the helpers to the .ui Catspeak environment. Without this the page
// could not read or write the pending seed. The registrations are split over
// several calls on purpose: a single call with 32 arguments is mis-decompiled
// by UTMT, so keep each addGlobalFunction call around the game's own size.
importGroup.QueueFindReplace(uiFunctions,
    @"    uiCatspeakGetEnvironment().addGlobalFunction(""NPCDialogueHealRad"", npc_dialogue_heal_rad, ""NPCDialogueFreeEquipment"",",
    @"    uiCatspeakGetEnvironment().addGlobalFunction(""MapSeedDraftBegin"", map_seed_draft_begin, ""MapSeedDraftGet"", map_seed_draft_get, ""MapSeedDraftAppend"", map_seed_draft_append);
    uiCatspeakGetEnvironment().addGlobalFunction(""MapSeedDraftBackspace"", map_seed_draft_backspace, ""MapSeedDraftClear"", map_seed_draft_clear, ""MapSeedDraftRandom"", map_seed_draft_random, ""MapSeedDraftValid"", map_seed_draft_valid);
    uiCatspeakGetEnvironment().addGlobalFunction(""MapSeedDraftCommit"", map_seed_draft_commit, ""MapSeedFormat"", map_seed_format_text, ""MapSeedKeyBackspace"", map_seed_key_backspace);
    uiCatspeakGetEnvironment().addGlobalFunction(""NPCDialogueHealRad"", npc_dialogue_heal_rad, ""NPCDialogueFreeEquipment"",",
    true);

// The map generator is the first place where the new map's random stream is
// initialized. Consume the prepared seed there and preserve the original
// random path when the player left the seed empty.
importGroup.QueueFindReplace(mapGeneratorCreate,
    @"randomize();
global.map_seed = undefined ?? irandom(4294967295);",
    @"randomize();
if (variable_global_exists(""map_seed_override"") && global.map_seed_override != undefined)
{
    global.map_seed = global.map_seed_override;
    global.map_seed_override = undefined;
}
else
{
    global.map_seed = irandom(4294967295);
}",
    true);

importGroup.Import();
ScriptMessage("Applied conductor map-seed dialogue page and one-shot seed consumption.");
