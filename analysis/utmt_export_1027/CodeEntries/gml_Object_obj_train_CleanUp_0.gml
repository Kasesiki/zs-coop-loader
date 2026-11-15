if (train_snd_id != -1)
{
    audio_stop_sound(train_snd_id);
    train_snd_id = -1;
}
if (train_snd_emitter != -1)
{
    audio_emitter_free(train_snd_emitter);
    train_snd_emitter = -1;
}
