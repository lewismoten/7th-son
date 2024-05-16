integer AUDIO_STOP = 10001;
integer AUDIO_PLAY = 10002;
integer AUDIO_PAUSE = 10003;
integer AUDIO_RESUME = 10004;
integer AUDIO_PRELOAD = 10005;
integer AUDIO_PROGRESS = 10006;
key queryId;
default
{
    link_message(integer sender, integer num, string message, key id)
    {
        if(num == AUDIO_PRELOAD)
        {
            llPreloadSound(id);
            // load up next sound too.
            queryId = llGetNotecardLine("Data", (integer)message);
        }
    }
    dataserver(key queryid, string data)
    {
        if(queryid != queryId) return;
        if(data == EOF) return;
        llPreloadSound((key)data);
    }
}
