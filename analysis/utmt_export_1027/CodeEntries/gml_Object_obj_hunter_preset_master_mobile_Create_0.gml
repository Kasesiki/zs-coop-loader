event_inherited();
npc_setup("hunter_master");
npc_setup_weapon();
if (ai_human_dev_enable_personality(id, "hunter", "mobile"))
{
    state = "human_general";
}
