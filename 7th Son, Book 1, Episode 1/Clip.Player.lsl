string dataFile = "Clip.Data.txt";
string configFile = "Clip.Configuration.txt";

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
    // compensates for script method 
    // delay penalties + sim lag

    // if never been synchronized before
    if(synch == 0)
    {
        // wait 10 seconds
        llSetTimerEvent(10);
    }
    else
    {
        // determine length of time between last synch
        float delta = llGetTime() - synch;
        
        // determine how much lag we have
        float lag = delta - 10.;

        // adjust so that next sound clip is played exactly 10 seconds later
        float delay = 10. - lag;
        if(delay > 10) delay = 10;
 
        
        llSetTimerEvent(delay);
    }
    
    // get current time
    synch = llGetTime();
}
stop()
{
    // bug since 1.16 - current sound clip will continue to play until complete
    llStopSound();
    mode = AUDIO_STOP;
    clip = 0;
}
play(integer count)
{
    // reset query
    soundId = NULL_KEY;
    synch = 0;
    mode = AUDIO_PLAY;
    
    // set number of total clips
    clipCount = count;
    clip = 0;
    
    // start the timer to load/play sounds
    llSetTimerEvent(.01);
}
resume()
{
    synch = 0;
    mode = AUDIO_PLAY;
    
    // start the timer to load/play sounds
    llSetTimerEvent(10);
}
pause()
{
    // bug since 1.16 - current sound clip will continue to play until complete
    llStopSound();
    mode = AUDIO_PAUSE;
}
default
{
    link_message(integer sender, integer num, string message, key id)
    {
        // stop playing sound, reset clip to 0
        if(num == AUDIO_STOP) stop();
        
        // play from beginning
        if(num == AUDIO_PLAY) play((integer)message);
        
        // resume from current location
        if(num == AUDIO_RESUME) resume();
        
        // stop playing sound
        if(num == AUDIO_PAUSE) pause();
    }
    timer()
    {
        if(mode == AUDIO_PAUSE || mode == AUDIO_STOP)
        {
            llSetTimerEvent(0);
            
            // send message of current progress
            llMessageLinked(LINK_THIS, AUDIO_PROGRESS, (string)(clip - 1), NULL_KEY);
            
            return;
        }
        synchronize();
        
        // if we have an asset UUID loaded from data notecard
        if(soundId != NULL_KEY)
        {
            // play the sound
            llPlaySound(soundId, 1.0);
            
            // send message of current progress
            llMessageLinked(LINK_THIS, AUDIO_PROGRESS, (string)(clip - 1), NULL_KEY);
        }
        
        // read next assett UUID
        queryId = llGetNotecardLine(dataFile, clip++);
        
    }
    dataserver(key queryid, string data)
    {
        // don't do anything if not reading assett UUID in data notecard
        if(queryid != queryId) return;
        
        // don't do anything if not currently playing audio
        if(mode != AUDIO_PLAY) return;
        
        // if ran out of asset UUID's, stop playing
        if(data == EOF)
        {
            stop();
            return;
        }
        
        // assign the data
        soundId = (key)data;
        
        // notify prim scripts to preload an audio clip while next line is read
        llMessageLinked(LINK_THIS, AUDIO_PRELOAD, (string)clip, soundId);
        
        // next time timer event occurs, the preloaded audio will be played.
    }
}
