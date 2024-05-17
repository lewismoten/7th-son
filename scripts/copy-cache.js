/*
The Second Life Viewer does not provide
a way to export sound files that you have
previously uploaded. This script looks in
the cache folder for specific files with
known asset UUID's and copies them to
the sub folder "Assets" and renames them
with their actual name and appropriate
file extension. You'll need to have the
sounds play in-world before they appear
in the cache.

NOTE: The original files were uploaded as
PCM WAV files. The viewer receives them
as Ogg Vorbis files.

The script will also open the _assets.md
file and update the list with any new
UUID's found in the Clip.Data.txt file
based on it's ordinal position within the
list.
*/

const fs = require('fs');
const path = require('path');

const cachePath = '/users/lewismoten/library/caches/secondlife';
const clipDataPath = '../7th Son, Book 1, Episode 1 v1.2/Clip.Data.txt';
const assetPath = '../Assets';
const assetListPath = path.join(assetPath, '_assets.md');

const clipUUIDs = fs.readFileSync(clipDataPath, 'utf8').split('\n');
clipUUIDs.forEach((uuid, i) => {
  if(uuid.length !== 36) {
    throw `Invalid line ${i + 1} is not 36 characters!`;
  }
});

const assetMarkdown = fs.readFileSync(assetListPath, 'utf8').trim().split('\n');

const getClipNumber = index => (index + 1).toString().padStart(3, '0');
const getClipName = index => `7th Son, Book 1, Episode 1, Clip ${getClipNumber(index)}`;
const getClipFileName = index => getClipName(index) + '.ogg';
const getCacheFileName = uuid => `${uuid}.dsf`;
const isDecompressedStandaloneFile = file => file.endsWith('.dsf');

// Loop through all asset UUID files in the data file
clipUUIDs.forEach((clipUUID, clipIndex) => {
  // If the UUID is already listed in the asset list, do nothing
  if(assetMarkdown.some(line => line.includes(clipUUID))) return;

  // Create markdown listing the UUID, File Name, and a display of audio controls to play the clip
  const clipName = getClipName(clipIndex);
  const clipFile = encodeURIComponent(getClipFileName(clipIndex));
  const markdown = `| [${clipName}](./${clipFile}) | ${clipUUID} | <audio controls><source src="./${clipFile}" type="audio/ogg"></audio> |`;

  // Add it to the list
  assetMarkdown.push(markdown);
});

// Save asset server list
fs.writeFileSync(assetListPath, assetMarkdown.join('\r\n')+'\r\n', {encoding: 'utf8'});

// Find audio files in Second Life cache
let missing = 0;
let found = 0;
fs.readdir(cachePath, (err, files) => {
  if(err) {
    console.log('Error:', err);
    return;
  }
  const cache = files.filter(isDecompressedStandaloneFile);

  // Loop thorugh all UUID's from the data file
  clipUUIDs.forEach((clipUUID, clipIndex) => {

    const cacheName = getCacheFileName(clipUUID);
    const clipFileName = getClipFileName(clipIndex);
    const clipNumber = getClipNumber(clipIndex);

    // Did we find the file?
    if(cache.includes(cacheName)) {
      found++;
      if(found <= 5) {
        console.log(`Found Clip ${clipNumber} in cache`);
      } else if(found === 6) {
        console.log('More found...');
      }
      // Copy the file with the real name and correct extension
      fs.copyFileSync(
        path.join(cachePath, cacheName),
        path.join(assetPath, clipFileName)
      );
    } else {
      missing++;
      if(missing <= 5) {
        console.log(`Unable to find clip number ${clipNumber} in cache as ${cacheName}`)
      } else if(missing === 6) {
        // Stop the spam
        console.log('More missing...');
      }
    }
  });
  if(missing > 5) {
    console.log('...total assets missing:', missing);
  }
  if(found > 5) {
    console.log('...total assets found:', found);
  }
  console.log('Done.');
});
