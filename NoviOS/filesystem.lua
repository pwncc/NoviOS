
--filesystem API
--make sure to init first!
require 'NoviOS/json'

fs = {}
function fs.init(system, unit)
	fslist = {}
	fs.DriveTable = {}
	_G.system = system
	_G.unit = unit
	local function dig(path)
		t = fs.DriveTable
		for part in path:gmatch("[^/]+") do
			if t[part] == nil then
				return false
			end
			t = t[part]
		end
		return t
	end
end


function fs.getKey(path)
    if fs.isFile(path) then
        return tonumber(dig(path))
    else
        return false
    end
end

function list1(tab)
	for i, v in pairs(tab) do
		print(v)
		if type(v) == "table" then
			list1(v)
		end
	end
end


function fs.checkdrive()
    if fs.DriveTable ~= nil then
        return false
    else
        return true
    end
end

function fs.setUpDrive(name)
    --warning this will reset the drive!
    fs.Drives[name].clear()
	driveinf = {}
	driveinf["1"] = {identifier=tostring(math.random(1, 9999999999999))}
end

function fs.loadDrive(name)
    if fs.Drives[name].getStringValue("1") ~= "" and fs.Drives[name].getStringValue("1") ~= nil then
        fs.DriveTable = json.decode(fs.Drives[name].getStringValue("1"))
        fs.DriveInfo = fs.DriveTable["1"]
		if fs.DriveInfo["raidnum"] ~= nil then
			if fs.DriveInfo["raidnum"] == "0" then
				drnum = 1
				fs.RaidDrives = {}
				fs.MainDrive = fs.Drives[name]
				for i,v in pairs(fs.Drives) do
				    if fs.Drives[name].getStringValue("1") ~= "" and fs.Drives[name].getStringValue("1") ~= nil then
						testtab = json.decode(v.getStringValue("1"))["1"]
						if testtab["identifier"] == fs.DriveInfo["identifier"] and testtab["raidnum"] ~= "0" then
							fs.RaidDrives[tonumber(testtab["raidnum"])] = v
						end
					end
				end
			else
				error("Cannot load a raid part! Must load main drive.")
			end
		end
    else
        system.print("We got an empty drive!")
    end
end

function fs.makeRaid(main, other) --other must be a table of the names. i.e {"Databank1", "Databank2"}
	--warning this will clear your data!
	raidentifier = tostring(tostring(math.random(1, 9999999999999)))
	for i,v in pairs(other) do
        f = fs.Drives[v]
		raidtab = {}
		f.clear()
		raidtab["1"] = {raidnum=tostring(i), identifier=raidentifier}
		f.setStringValue("1", json.encode(raidtab))
	end
	fs.Drives[main].clear()
	newtab = {}
	newtab["1"] = {raidnum="0", identifier=raidentifier, raidamount = tostring(#other)}
	fs.Drives[main].setStringValue("1", json.encode(newtab))
end

function fs.saveDrive()
    fs.MainDrive.setStringValue("1", json.encode(fs.DriveTable))
end

function fs.isDir(path)
    if dig(path) == false then
        return nil
    end
	if type(dig(path)) == "table" then
        return true
    else
        return false
    end
end

function fs.isFile(path)
    if dig(path) == false then
        return nil
    end
    if type(dig(path)) == "table" then
        return false
    else
        return true
    end
end

function fs.scanBanks()
    fs.Drives = {}
    for key, value in pairs(unit) do
        if type(value) == "table" then
            if value.setStringValue ~= nil then
                fs.Drives[key] = value
            end
        end
    end
end

function fs.setDriveValue(path, value)
    t = fs.DriveTable
    tab = {}
    for val in string.gmatch(path, "[^/]+") do
    	tab[#tab+1] = val
    end
    amount = #tab
    for i, part in pairs(tab) do
        if i == amount then
            t[part] = value
            for i, part in pairs(tab) do
                ft = fs.DriveTable
                s = (#tab+1 -i)
                for z =1, s-1 do
                    if z==s-1 then
                        ft[tab[z]]= t
                    else
                        ft = tab[z]
                    end
                end
            end
            fs.DriveTable = ft
            return true
        elseif i < amount and t[part] == nil then
            return false
        end
        t = t[part]
    end
    return false
end

function fs.list(path)
    if type(dig(path)) == "table" then
        temptab = {}
        q = 0
        for i,v in pairs(dig(path)) do
            q = q + 1
            if type(v) == "table" then
                temptab[q] = i.."/"
            else
                temptab[q] = v
            end
        end
        return temptab
    else
        error("not a directory!")
        return false
    end
end

function fs.remove(path)
    if type(dig(path)) == "table" or type(path) == "table" then
        if type(path) == "table" then
            for i,v in pairs(path) do
            	fs.remove(v)
        	end
        else
            for i,v in pairs(dig(path)) do
            	fs.remove(v)
        	end
        end
    elseif type(dig(path)) == "string" or type(path) == "string" then
        if type(path) == "string" then
            fs.MainDrive.setStringValue(tonumber(path), "")
			if fs.RaidDrives ~= nil and #fs.RaidDrives ~= 0 then
				for i, v in pairs(fs.RaidDrives) do
					v.setStringValue(tonumber(path), "")
				end
			end
        else
            fs.MainDrive.setStringValue(tonumber(dig(path)), "")
			if fs.RaidDrives ~= nil and #fs.RaidDrives ~= 0 then
				for i, v in pairs(fs.RaidDrives) do
					v.setStringValue(tonumber(path), "")
				end
			end
        end
    end
end



function fs.mkdir(path)
    fs.setDriveValue(path, {})
    fs.saveDrive()
end

function fs.runfile(path)
    string = fs.open(path).readAll()
    loaded = load(string)
    loaded()
end


local function splitByChunk(text, chunkSize)
    local s = {}
    for i=1, #text, chunkSize do
        s[#s+1] = text:sub(i,i+chunkSize - 1)
    end
    return s
end	

function fs.setRaidValue(key, file)
	filesize = #file
	s = splitByChunk(file, math.floor(5 +(#file / tonumber(fs.DriveInfo["raidamount"]) + 1)))
	for i, v in pairs(s) do
		if i==1 then fs.MainDrive.setStringValue(key, v) else fs.RaidDrives[i-1].setStringValue(key, v) end
	end
end

function fs.getRaidValue(key)
	chunk = fs.MainDrive.getStringValue(key)
	for i, v in pairs(fs.RaidDrives) do
		chunk = chunk..(fs.RaidDrives[i].getStringValue(key))
	end
	return chunk
end

function fs.open(path)
    if fs.isFile(path) == true or fs.isFile(path) == nil then
    	newfile = {}
        newfile.path = path
        newfile.key = fs.getKey(newfile.path)
        function newfile.readAll()
			if fs.DriveInfo["raidnum"] ~= nil then
				return fs.getRaidValue(newfile.key)
			else
				return fs.MainDrive.getStringValue(newfile.key)
			end
        end
        
        function newfile.write(text)
            tmpfile = text
        end
        
        function newfile.append(text)
            tmpfile = newfile.readAll()
            tmpfile = tmpfile..text
        end
        
        function newfile.flush()
            if newfile.key == false then
                newkey = tonumber(fs.MainDrive.getNbKeys()) + 1
				if fs.DriveInfo["raidnum"] ~= nil then
					fs.setRaidValue(newkey, tmpfile)
				else
					fs.setDriveValue(newkey, tmpfile)
				end
                fs.setDriveValue(newfile.path, tostring(newkey))
                fs.saveDrive()
                newfile.key = newkey
            else
                fs.MainDrive.setStringValue(fs.getKey(newfile.path), tmpfile)
            end
        end
        return newfile
    elseif fs.isDir(path) == true then
        error("This is a directory!")
    end
end
return fs
