-- Local JSON storage. Files are data only; imported configs are never executed.
return function(options)
    local http=options.HttpService
    local fs=options.FS or {read=readfile,write=writefile,folder=isfolder,mkdir=makefolder,delete=delfile}
    local store={Root="PrimeVisuals/Configs/"..tostring(options.UserId),Imports="PrimeVisuals/Imports",Available=false,Error=nil}
    local LIMIT=512*1024
    local function finite(n) return type(n)=="number" and n==n and math.abs(n)<math.huge end
    local function dataOnly(value,depth,budget)
        budget.count=budget.count+1
        assert(budget.count<12000 and depth<12,"Config is too complex")
        local kind=type(value)
        if kind=="number" then assert(finite(value),"Invalid number")
        elseif kind=="string" then assert(#value<=8192,"Config text is too long")
        elseif kind=="table" then
            for key,item in pairs(value) do
                assert(type(key)=="string" or (finite(key) and key>=1 and key%1==0),"Invalid config key")
                dataOnly(item,depth+1,budget)
            end
        else assert(kind=="boolean" or kind=="nil","Invalid config value") end
    end
    local function decode(text)
        assert(type(text)=="string" and #text<=LIMIT,"Config file is too large")
        local doc=http:JSONDecode(text)
        assert(type(doc)=="table" and doc.format=="PrimeVisualsConfig" and doc.schema==1,"Unsupported config format")
        assert(finite(doc.revision) and doc.revision>=0 and doc.revision%1==0,"Invalid config revision")
        assert(type(doc.name)=="string" and #doc.name<=160,"Invalid config name")
        if not doc.deleted then
            assert(type(doc.payload)=="table" and type(doc.payload.values)=="table","Missing config settings")
            dataOnly(doc.payload,0,{count=0})
            if options.Validate then options.Validate(doc.payload) end
        end
        return doc
    end
    local function protect(fn)
        local ok,a,b=pcall(fn)
        if not ok then return nil,tostring(a) end
        return a,b
    end
    local function requireReady() assert(store.Available,store.Error or "Local files unavailable") end
    local function backupPath(path) return (path:gsub("%.json$",".backup.json")) end
    local function readPair(path)
        local newest,raw,errors
        for _,file in ipairs({path,backupPath(path)}) do
            local ok,text=pcall(fs.read,file)
            if ok then
                local valid,doc=pcall(decode,text)
                if valid and (not newest or doc.revision>newest.revision) then newest,raw=doc,text
                elseif not valid then errors=tostring(doc) end
            end
        end
        return newest,raw,errors
    end
    local writing={}
    local function writePair(path,payload,name,deleted)
        requireReady()
        assert(not writing[path],"A write to this config is already in progress; try again")
        writing[path]=true
        local ok,result=pcall(function()
            local previous=readPair(path)
            local revision=previous and previous.revision+1 or 1
            local doc={format="PrimeVisualsConfig",schema=1,scriptVersion=options.Version or "2.0.0",revision=revision,name=name or "",payload=payload,deleted=deleted or false}
            local text=http:JSONEncode(doc)
            assert(#text<=LIMIT,"Config file is too large") decode(text)
            -- Write the older journal side first; a failed write keeps the newest valid copy.
            local first=revision%2==1 and path or backupPath(path)
            local second=revision%2==1 and backupPath(path) or path
            fs.write(first,text)
            assert(fs.read(first)==text,"Config write verification failed")
            -- Mirror best-effort; one verified copy is enough, and reads choose newest revision.
            pcall(function() fs.write(second,text) assert(fs.read(second)==text) end)
            return true
        end)
        writing[path]=nil
        assert(ok,result)
        return result
    end
    local function slotPath(slot)
        assert(type(slot)=="number" and slot%1==0 and slot>=1 and slot<=5,"Choose a slot from 1 to 5")
        return store.Root.."/slots/slot"..slot..".json"
    end
    local initialized,message=pcall(function()
        assert(type(fs.read)=="function" and type(fs.write)=="function" and type(fs.folder)=="function" and type(fs.mkdir)=="function","Executor does not provide local file APIs")
        for _,path in ipairs({"PrimeVisuals","PrimeVisuals/Configs",store.Root,store.Root.."/slots",store.Root.."/exports",store.Imports}) do
            if not fs.folder(path) then fs.mkdir(path) end
        end
        store.Available=true
    end)
    if not initialized then store.Error=tostring(message) end
    function store:ReadAuto()
        if not self.Available then return nil end
        local doc,_,failure=readPair(self.Root.."/autosave.json")
        if doc and not doc.deleted then return doc.payload end
        return nil,failure
    end
    function store:WriteAuto(payload)
        return protect(function() return writePair(self.Root.."/autosave.json",payload,"Last session") end)
    end
    function store:ReadSlot(slot)
        return protect(function()
            requireReady()
            local doc=readPair(slotPath(slot))
            assert(doc and not doc.deleted,"This slot is empty or unreadable")
            return doc.payload,doc.name
        end)
    end
    function store:SlotNames()
        local names={}
        for slot=1,5 do
            local doc=self.Available and readPair(slotPath(slot)) or nil
            names[slot]=doc and not doc.deleted and doc.name or ""
        end
        return names
    end
    function store:SaveSlot(slot,name,payload)
        return protect(function()
            assert(type(name)=="string","Enter a config name")
            name=name:match("^%s*(.-)%s*$")
            assert(#name>0 and #name<=160,"Enter a name of 1–160 bytes")
            return writePair(slotPath(slot),payload,name)
        end)
    end
    function store:DeleteSlot(slot)
        return protect(function() return writePair(slotPath(slot),nil,"",true) end)
    end
    function store:Export(slot)
        return protect(function()
            requireReady()
            local doc=readPair(slotPath(slot))
            assert(doc and not doc.deleted,"This slot is empty or unreadable")
            local path=self.Root.."/exports/slot"..slot..".json"
            local text=http:JSONEncode(doc)
            fs.write(path,text) assert(fs.read(path)==text,"Export write verification failed")
            return path
        end)
    end
    function store:Import(slot,filename)
        return protect(function()
            requireReady()
            assert(type(filename)=="string" and #filename<=160 and filename:match("%.json$")
                and not filename:find("[\\/:%c]") and not filename:find("..",1,true),"Use a JSON filename inside PrimeVisuals/Imports")
            local doc=decode(fs.read(self.Imports.."/"..filename))
            assert(not doc.deleted,"This config was deleted")
            -- decode already validates against the current script before replacing a slot.
            return writePair(slotPath(slot),doc.payload,doc.name)
        end)
    end
    store.Decode=decode
    return store
end
