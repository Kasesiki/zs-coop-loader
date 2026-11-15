if (!npc_spawned_event_sent && npc_id != "dummy")
{
    npc_spawned_event_sent = true;
    mods_perform_event("npc_spawned", [id, npc_id], id);
    if (!instance_exists(id))
    {
        exit;
    }
}
mods_object_perform_event("step_begin_event");
