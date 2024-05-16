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

init()
{
    llSetText("Initializing...", <1,1,1>, 1);
    llSetTimerEvent(0);
    clipCount = 0;
    clip = 0;
    configAbout = "";
    configUrl = "";
    configName = "";
    configDesc = "";
    configLine = 0;
    clipCountQueryId = llGetNumberOfNotecardLines("Data");
}
showProgress()
{
    string message = "";
    message += "\n" + configName + "\n" + configDesc + "\n[";
    integer percent = (integer)((clip / (float)clipCount) * 100);
    integer i = 0;
    for(; i < percent; i+=5) message += "|";
    for(; i < 100; i+= 5) message += ".";
    message += "]";
    
    integer minutes = (clipCount - clipCount % 6) / 6;
    integer seconds = clipCount % 6;
    
    integer minutesPlayed = (clip - clip % 6) / 6;
    integer secondsPlayed = clip % 6;
    
    message += "\n" + (string)minutesPlayed + ":" + (string)secondsPlayed + "0";
    message += " / " + (string)minutes + ":" + (string)seconds + "0";
    
    message += "\nTouch For Info";
    message += "\nTake a copy to Play at home";
    
    llSetText(message, <.5,.5,1.0>, 1);
}
startListener(key id)
{
    if(listener != 0)
        llListenRemove(listener);
    channel = (integer)llFrand(-2147483647);
    listenerKey = id;
    listenerName = llKey2Name(id);
    listener = llListen(channel, listenerName, listenerKey, "");
    llSetTimerEvent(60);
}
stopListener()
{
    llSetTimerEvent(0);
    if(listener != 0)
    {
        llListenRemove(listener);
        listenerName = "";
        listenerKey = NULL_KEY;
    }
}
ownerOptions()
{
    if(listenerKey != NULL_KEY && listenerKey != llGetOwner())
        llInstantMessage(listenerKey, "Menu in use by owner.");
    startListener(llGetOwner());
    list buttons = ["Stop", "Play", "Pause", "Resume", "Website", "Notecard"];
    llDialog(llGetOwner(), "Choose an option", buttons, channel);
}
guestOptions(key id)
{
    if(listener != 0 && listenerKey != NULL_KEY && listenerKey != id)
    {
        llInstantMessage(id, "Please wait.  " + listenerName + " is using the menu.");
        return;
    }
    startListener(llGetOwner());
    list buttons = ["Website", "Notecard"];
    llDialog(id, "Choose an option", buttons, channel);
}
default
{
    link_message(integer sender, integer num, string message, key id)
    {
        if(num == AUDIO_PROGRESS)
        {
            clip = (integer)message;
            showProgress();
        }
    }
    listen(integer channel, string name, key id, string message)
    {
        stopListener();
        if(message == "Stop") llMessageLinked(LINK_THIS, AUDIO_STOP, (string)clipCount, NULL_KEY);
        else if(message == "Play") llMessageLinked(LINK_THIS, AUDIO_PLAY, (string)clipCount, NULL_KEY);
        else if(message == "Pause") llMessageLinked(LINK_THIS, AUDIO_PAUSE, (string)clipCount, NULL_KEY);
        else if(message == "Resume") llMessageLinked(LINK_THIS, AUDIO_RESUME, (string)clipCount, NULL_KEY);
        else if(message == "Website") llInstantMessage(id, "Website: " + configUrl);
        else if(message == "Notecard") llGiveInventory(id, configAbout);
    }
    dataserver(key queryid, string data)
    {
        if(queryid == clipCountQueryId)
        {
            clipCountQueryId = NULL_KEY;
            clipCount = (integer)data;
            configQueryId = llGetNotecardLine("Config", configLine++);
            return;
        }
        if(queryid == configQueryId)
        {
            if(data == EOF)
            {
                llSetObjectName(configName);
                llSetObjectDesc(configDesc);
                showProgress();
                llOwnerSay("Ready.  Touch me for options.");
                return;
            }
            if(data != "" && llSubStringIndex(data, "#") == -1)
            {
                integer i = llSubStringIndex(data, "=");
                string name = llGetSubString(data, 0, i - 1);
                string value = llGetSubString(data, i + 1, -1);
                name = llToLower(name);
                if(name == "about") configAbout = value;
                else if(name == "url") configUrl = value;
                else if(name == "name") configName = value;
                else if(name == "description") configDesc = value;
                else llOwnerSay("Unknown configuration setting: " + name);
            }
            configQueryId = llGetNotecardLine("Config", configLine++);
            return;
        }
    }
    timer()
    {
        if(listenerKey != NULL_KEY)
            llInstantMessage(listenerKey, "Your response has timed out.");
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
        integer i;
        for(i = 0; i < total_number; i++)
            if(llDetectedKey(i) == llGetOwner())
                ownerOptions();
            else
                guestOptions(llDetectedKey(i));
    }
}
