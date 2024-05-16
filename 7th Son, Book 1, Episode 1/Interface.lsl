integer clip;
integer channel;
integer listener;
key listenerKey = NULL_KEY;
string listenerName;

string configAbout;
string configUrl;
string configName;
string configDesc;
integer configLine;

string webUrl;
integer clipCount;

key clipCountQueryId;
key configQueryId;

integer AUDIO_STOP = 10001;
integer AUDIO_PLAY = 10002;
integer AUDIO_PAUSE = 10003;
integer AUDIO_RESUME = 10004;
integer AUDIO_PRELOAD = 10005;
integer AUDIO_PROGRESS = 10006;

vector textColor =  <.75, .75, 1>;//<.5,.5,1.0>;

init()
{
    // notify state of initialization
    llSetText("Initializing...", <1,1,1>, 1);
    
    // cleanup resources
    stopListener();
    
    // reset default values
    clipCount = 0;
    clip = 0;
    configAbout = "";
    configUrl = "";
    configName = "";
    configDesc = "";
    configLine = 0;
    
    // find out how many lines are in the data notecard
    // (Each line is an asset UUID for a sound clip)
    clipCountQueryId = llGetNumberOfNotecardLines("Data");
}
showProgress()
{
    // display name & description
    string message = configName;
    message += "\n" + configDesc + "\n";
    
    // compile progress bar of 100 characters 
    // [||||||||....]
    message += "[";
    integer percent = (integer)((clip / (float)clipCount) * 100);
    integer i = 0;
    // append pipe for progress
    for(; i < percent; i+=5) message += "|";
    // append dot for remaining
    for(; i < 100; i+= 5) message += ".";
    message += "]";
    
    // determine total length of audio in minutes and seconds
    integer minutes = (clipCount - clipCount % 6) / 6;
    integer seconds = clipCount % 6;
    
    // determine position in audio in minutes and seconds
    integer minutesPlayed = (clip - clip % 6) / 6;
    integer secondsPlayed = clip % 6;
    
    // append minutes:seconds played
    message += "\n" + (string)minutesPlayed + ":" + (string)secondsPlayed + "0";
    // append total minutes:seconds of audio
    message += " / " + (string)minutes + ":" + (string)seconds + "0";
    
    // display additional message
    message += "\nTouch For Info";
    message += "\nTake a copy to Play at home";
    
    llSetText(message, textColor, 1);
}
startListener(key id)
{
    // clean up existing resources
    stopListener();
    
    // pick a random channel between -2000010000 and -10000 
    channel = (integer)llFrand(2000000000) + 10000;
    channel *= -1;
    
    // assign the new listener
    listenerKey = id;
    listenerName = llKey2Name(id);
    
    // start listening
    listener = llListen(channel, listenerName, listenerKey, "");
    
    // set timeout to stop listening after a small duration of time
    llSetTimerEvent(60);
}
stopListener()
{
    // stop timing out
    llSetTimerEvent(0);
    
    // clean up resources
    if(listener != 0)
    {
        llListenRemove(listener);
        listener = 0;
    }
    
    // reset defaults
    listenerName = "";
    listenerKey = NULL_KEY;
}
ownerOptions()
{
    // if someone else using the menu
    if(listenerKey != NULL_KEY && listenerKey != llGetOwner())
    
        // notify resident they will not be able to use the menu
        llInstantMessage(listenerKey, "Owner is now using the menu. It will not respond to you any longer.");
    
    // start listening to the owner    
    startListener(llGetOwner());
    
    // display menu
    list buttons = ["Stop", "Play", "Pause", "Resume", "Website", "Notecard"];
    llDialog(llGetOwner(), "Choose an option", buttons, channel);
}
guestOptions(key id)
{
    // if someone else using the menu
    if(listener != 0 && listenerKey != NULL_KEY && listenerKey != id)
    {
        // notify resident to wait.
        llInstantMessage(id, "Please wait.  " + listenerName + " is using the menu.");
        return;
    }
    
    // start listening to the guest
    startListener(id);
    
    // display menu
    list buttons = ["Website", "Notecard"];
    llDialog(id, "Choose an option", buttons, channel);
}
default
{
    link_message(integer sender, integer num, string message, key id)
    {
        // Player stating what clip is currently being played
        if(num == AUDIO_PROGRESS)
        {
            clip = (integer)message;
            showProgress();
        }
    }
    listen(integer channel, string name, key id, string message)
    {
        // Stop listening (cleanup resources)
        stopListener();
        
        // Media controls
        if(message == "Stop")
        {
            llSetText("Stopping...", textColor, 1);
            llMessageLinked(LINK_THIS, AUDIO_STOP, (string)clipCount, NULL_KEY);
        }
        else if(message == "Play")
        {
            llSetText("Playing...", textColor, 1);
            llMessageLinked(LINK_THIS, AUDIO_PLAY, (string)clipCount, NULL_KEY);
        }
        else if(message == "Pause")
        {
            llSetText("Pausing...", textColor, 1);
            llMessageLinked(LINK_THIS, AUDIO_PAUSE, (string)clipCount, NULL_KEY);
        }
        else if(message == "Resume") 
        {
            llSetText("Resuming...", textColor, 1);
            llMessageLinked(LINK_THIS, AUDIO_RESUME, (string)clipCount, NULL_KEY);
        }
    
        // Other options
        else if(message == "Website") llInstantMessage(id, "Website: " + configUrl);
        else if(message == "Notecard") llGiveInventory(id, configAbout);
    }
    dataserver(key queryid, string data)
    {
        // Received number of lines in Data Notecard
        if(queryid == clipCountQueryId)
        {
            clipCountQueryId = NULL_KEY;
            clipCount = (integer)data;
            
            // start reading configuration notecard
            configQueryId = llGetNotecardLine("Config", configLine++);
            
            // Stop doing anything else
            return;
        }
        
        // Received line from Configuration Notecard
        if(queryid == configQueryId)
        {
            // end of notecard reached
            if(data == EOF)
            {
                // set name/description of object
                llSetObjectName(configName);
                llSetObjectDesc(configDesc);
                
                // final touches
                showProgress();
                llOwnerSay("Ready.  Touch me for options.");
                
                // don't do anything else now
                return;
            }
            
            // if line is not to be ignored
            if(data != "" && llSubStringIndex(data, "#") == -1)
            {
                // parse name/value on line
                integer i = llSubStringIndex(data, "=");
                string name = llGetSubString(data, 0, i - 1);
                string value = llGetSubString(data, i + 1, -1);
                name = llToLower(name);
                
                // assign value to internal variables
                if(name == "about") configAbout = value;
                else if(name == "url") configUrl = value;
                else if(name == "name") configName = value;
                else if(name == "description") configDesc = value;
                else llOwnerSay("Unknown configuration setting: " + name);
            }
            
            // read next line
            configQueryId = llGetNotecardLine("Config", configLine++);
            
            return;
        }
    }
    timer()
    {
        // timeout dialog menu response
        
        // someone was using menu?
        if(listenerKey != NULL_KEY)
            llInstantMessage(listenerKey, "Your response has timed out.");
        
        // stop listening
        stopListener();
    }
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
        // determine access control level
        
        integer i;
        for(i = 0; i < total_number; i++)
        
            // Owner?
            if(llDetectedKey(i) == llGetOwner())
                ownerOptions();
                
            // Someone Else (not owner)
            else
                guestOptions(llDetectedKey(i));
    }
}
