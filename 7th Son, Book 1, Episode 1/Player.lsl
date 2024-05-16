integer AUDIO_STOP = 10001;
integer AUDIO_PLAY = 10002;
integer AUDIO_PAUSE = 10003;
integer AUDIO_RESUME = 10004;
integer AUDIO_PRELOAD = 10005;
integer AUDIO_PROGRESS = 10006;
integer clipCount;
integer clip;
integer mode;
key queryId;
key soundId;
float synch;
integer gettingNext;
synchronize()
{
    if(synch == 0)
    {
        llSetTimerEvent(10);
    }
    else
    {
        float delta = llGetTime() - synch;
        llSetTimerEvent(10 + (delta - 10));
    }
    synch = llGetTime();
}
stop()
{
    llStopSound();
    mode = AUDIO_STOP;
    llSetTimerEvent(0);
    clip = 0;
}
play(integer count)
{
    soundId = NULL_KEY;
    mode = AUDIO_PLAY;
    clipCount = 0;
    llSetTimerEvent(.01);
}
pause()
{
    llStopSound();
    mode = AUDIO_PAUSE;
    llSetTimerEvent(0);
}
default
{
    link_message(integer sender, integer num, string message, key id)
    {
        if(num == AUDIO_STOP) stop();
        if(num == AUDIO_PLAY || num == AUDIO_RESUME) play((integer)message);
        if(num == AUDIO_PAUSE) pause();
    }
    timer()
    {
        synchronize();
        
        if(soundId != NULL_KEY)
        {
            llPlaySound(soundId, 1.0);
            llMessageLinked(LINK_THIS, AUDIO_PROGRESS, (string)(clip - 1), NULL_KEY);
        }
            
        queryId = llGetNotecardLine("Data", clip++);
        
    }
    dataserver(key queryid, string data)
    {
        if(queryid != queryId) return;
        if(mode != AUDIO_PLAY) return;
        if(data == EOF)
        {
            stop();
            return;
        }
        soundId = (key)data;
        llMessageLinked(LINK_THIS, AUDIO_PRELOAD, (string)clip, soundId);
    }
}
