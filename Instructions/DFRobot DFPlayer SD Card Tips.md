# The Most Stupid File & Folder Structure Ever!

While the DFRobot DFPlayer makes it easy to add MP3 file playing to about any project with minimal code, somebody at this company must smoke too much weed and listen Grateful Dead songs in random order all day long. This person has no choice than to listen to these songs in random order because that player relies on FAT32 formatted drives and once it becomes fragmented, it won't play MP3 files in any logical order. That is, unless, you use an absolutely stupid file/folder structure.

### Here are the rules you need to follow for LCC

- File and folder names can only be numbers, not verbal file names.

- You need to use two digit folder names and anything less than 10 needs to start with a zero.

- Each folder can only contain the file 001.mp3 (yes, now it needs two leading zeros.

- You must do a full long format (erase) before copying any files to the SD card.

- You should build your SD card structure on your computer and then copy all the files to the SD card as a group.

While these rules may sound outrageous and unnecessarily complicated, just try not following these rules and try using the SD card in the DFPlayer. You'll be asking yourself why file 10 always plays when you tell the LCC Slave play the 9th one. Or, you will try to play the 6th one and it doesn't play, even though the file is really there. This is how bad disk fragmentation will affect the DFPlayer and why you always need to do a long format before modifying or updating the files on it.
