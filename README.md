# 7th Son Podcast in Second Life

This is an old project from 2006 where I made a podcast freely available in Second Life. The platform has limitations where sound files can be no longer than 10 seconds, and that sounds needed to be pre-loaded in order to play one clip after another without pause.

As instructed by the ficticious Ministry of Propaganda in Mission #2 (Operation Burn, Baby Burn), I freely distributed copies of the prologue episode throughout Second Life. The author, J. C. Hutchins, also had a release party in Second Life on podcast island.

The books podcast website is now located at https://jchutchins.net/7th-son-original-podcast-trilogy

The "CD" was a box that appeared as an old audio CD Jewel case. Clicking on it would present you with a dialog with a few options to Play the CD, visit the books web page, or receive a notecard about the podcast.

![Clip Interface](./docs/Clip%20Interface.png)

The CD itself would have floating text showing how far into the podcast you were with the play time, and total time for the entire podcast. In addition, it displayed a progress bar using pipe characters and dots.

![Clip Interface](./docs/Playing%20CD%20Progress.png)

The scripts were designed in a way to be generic. I wanted to be prepared for additional missions related to bringing long clips of audio into Second Life. After uploading all of your audio clips, you just pasted the asset UUID's into a [Clip.Data.txt](./7th%20Son,%20Book%201,%20Episode%201%20v1.2/Clip.Data.txt.md) note card. In [Clip.Configuration.txt](./7th%20Son,%20Book%201,%20Episode%201%20v1.2/Clip.Configuration.txt.md) notecard you could change the name, url, description, and `About` note card name. Anyone who had the Album could see the code and create their own podcasts.

## Splitting Sound Clips

I believe I used Audacity to split the file into 262 individual clips at 10 seconds each to be uploaded for 10 L$ each. In December 2006 the Linden dollar to US dollar rate would have been around 250 Linden dollars per 1 US dollar. With 262 clips, it was 2,620 L$ (~$10.48 US) for a 44 minute podcast.

# Vendor

Included in the source code is the vendor object that I used to sell the promotional album for 0 L$. One thing of note is the price tag at the top of the vendor. It is a prism that is able to change the listed price and permissions (Modify/Copy/Transfer) with a script. It does not change the actual price or permissions of the object - only what is displayed visually.

![7th Son Box Vendor](./docs/7th%20Son%20Box%20Vendor.png)

![Price Tag Dialog](./docs/Price%20Tag%20Dialog.png)

The dialog lets you adjust the price from 0 to 999,999 L$ by 1, 10, and 100. Once you are happy with the price, you can "freeze" it in place, causing the script to delete itself so that the server no longer running the price script unnecessarily. This lets you display the price and permissions clearly without having to upload additional images any time you want to change a price.

I've included the script, images, and asset ids so that you can use it in-world.

# Boxed

Last is the packaged version of the product. This was often made availabe on platforms like SL Exchange (SLX), JEVN, OnRez, and Apez. I package all of my products in a box that advertised the shop with a logo and picture of the product inside. The contents of my packages included a landmark to my in-world store, a notecard about the product, a notecard about the store, and the purchased product. The box looks just like a file box. It uses one texture that is scaled, rotated, and offset for each side.

![7th Son Boxed](./docs/7th%20Son%20Boxed.png)

# Scripts

Last in this repo are some scripts that I created to assist in aquiring files for the repo.

## Copy Prim

This script allows will generate LSL code that can be dropped into a new object to transform it into the original object. It also generates markdown for some of the read-only information such as the link number, date acquired, inventory content, etc. It's not perfect, but it saves a lot of time.

## Copy Cache

The Second Life Viewer doesn't offer a way to download the original PCM WAV sounds that I had uploaded. I found a workaround by looking at the cache folder on my local file system. The `copy-cache.js` file reads through a text file of asset id's, looked for those ID's in the cache folder, and copied them locally while renaming them as Ogg Vorbis (`.ogg`) files. You may need to modify it to grab your own sound files so long as you know the asset UUID of your sounds to look for.