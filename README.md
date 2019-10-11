Welcome to NoviOS!

# Filesystem
usage: require 'NoviOS/filsystem'
returns as fs

# Variables

fs.DriveTable: Once a drive is loaded this will contain the locations of all the files

fs.DriveInfo: Once a drive is loaded this will contain all the drive info
contains: raidnum (if raid, amount of raid numbers), identifier (identifier of the drive), raidamount (if main drive of raid amount of raids attatched)

fs.MainDrive: raw main databank, can be used for calling functions straight from Dual Universe databank such as fs.MainDrive.setStringValue(key, value)

fs.RaidDrives: Drives attatched to the main drive

fs.Drives: A list of all the drives and their names
example return: 
slots: Databank, Databank2, Databankthree

lua:
for i, v in pairs(fs.Drives) do
  print(i..": "..v)
end
output: 
Databank: function 102347127647192
Databank2: function 2190387129
Databank3: function 918230192
# fs.init(system, unit)
Initializes the system
usage: literally fs.init(system, unit). Make sure to do this at the start of your script!

# fs.checkdrive()
returns true if drives are available

# fs.setUpDrive(name)
WARNING THIS WILL RESET THE DRIVE AND ALL THE INFORMATION ON IT
sets up the drive given specified name
If my databank unit is for example called "Databank".
I will use fs.setUpDrive("Databank") to set up the drive or reset it

# fs.loadDrive(name)
Loads a set up drive.
Usage:
fs.loadDrive("Databank")
identifier = fs.DriveInfo["identifier"] --prints the identification

Info: Once a drive is loaded it will store its table in fs.DriveTable and its info in fs.DriveInfo

# fs.scanBanks()
scans for banks and stores them in fs.Drives

# fs.list(path)
lists a path and its containing files

# fs.remove(path)
self explanatory

# fs.mkdir(path)
Makes a directory.
Does not make directories on the way to end point, you will have to make each directory manually

# fs.isDir(path)
Checks if path is a directory

# fs.isFile(path)
Checks if path is a file

# fs.open(path)
Returns a file functions folder. See below

# File: 

# file.readAll()
Returns the file completely

# file.write(text)
Overwrites the file to text. Does not save, needs flush() to save

# file.append(text)
Adds text to file.
DOES NOT SKIP A LINE, DO IT YOURSELF LAZY

# file.flush()
Saves file!
