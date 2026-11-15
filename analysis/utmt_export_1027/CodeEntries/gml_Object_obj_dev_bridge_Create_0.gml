instance_destroy();
exit;
directory_create("dev/");
poll_timer = 0;
loadout_wait = 30;
dev_log("bridge ready in " + room_get_name(room));
