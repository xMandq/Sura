function getFilePath(fileName)
    return os.getenv("USERPROFILE") .. "\\Desktop\\WebControl\\" .. fileName
end

function clearFile(filePath)
    fileHandle = io.open(filePath, "w")
    if fileHandle then
        fileHandle:write("")
        fileHandle:close()
    else
        print("Failed to open file for clearing: " .. filePath)
    end
end

clearFile(getFilePath("break.txt"))
clearFile(getFilePath("place.txt"))
clearFile(getFilePath("movement.txt"))

function placeTile(x, y, id)
    pkt = {}
    pkt.type = 3
    pkt.int_data = id
    pkt.int_x = (GetLocal().pos_x // 32) + x
    pkt.int_y = (GetLocal().pos_y // 32) + y
    pkt.pos_x = GetLocal().pos_x
    pkt.pos_y = GetLocal().pos_y
    SendPacketRaw(pkt)
end

function hitTile(x, y)
    pkt = {}
    pkt.type = 3
    pkt.int_data = 18
    pkt.int_x = (GetLocal().pos_x // 32) + x
    pkt.int_y = (GetLocal().pos_y // 32) + y
    pkt.pos_x = GetLocal().pos_x
    pkt.pos_y = GetLocal().pos_y
    SendPacketRaw(pkt)
end

movementFilePath = getFilePath("movement.txt")
breakFilePath = getFilePath("break.txt")
placeFilePath = getFilePath("place.txt")

function readNewContent(fileHandle, startPos)
    fileHandle:seek("set", startPos)
    content = fileHandle:read("*all")
    return content or "", fileHandle:seek()
end

function processAction(action)
    parts = {}
    for part in action:gmatch("[^_]+") do
        table.insert(parts, part)
    end
    
    actionType = parts[1]
    x = tonumber(parts[2])
    y = tonumber(parts[3])
    id = parts[4]

    if actionType == "break" then
        hitTile(x, y)
    elseif actionType == "place" then
        placeTile(x, y, id)
    end
end

function handleMovementCommand(command)
    directions = {
        W = {0, -1},
        A = {-1, 0},
        S = {0, 1},
        D = {1, 0}
    }
    direction = directions[command]
    if direction then
        x, y = direction[1], direction[2]
        FindPath(GetLocal().pos_x // 32 + x,GetLocal().pos_y // 32 + y)
    end
end

movementFileHandle = io.open(movementFilePath, "r")
breakFileHandle = io.open(breakFilePath, "r")
placeFileHandle = io.open(placeFilePath, "r")

if not movementFileHandle or not breakFileHandle or not placeFileHandle then
    print("Failed to open one or more files.")
end

lastMovementPos = 0
lastBreakPos = 0
lastPlacePos = 0

while true do
    movementContent, newMovementPos = readNewContent(movementFileHandle, lastMovementPos)
    lastMovementPos = newMovementPos
    for line in movementContent:gmatch("[^\r\n]+") do
        handleMovementCommand(line)
    end

    breakContent, newBreakPos = readNewContent(breakFileHandle, lastBreakPos)
    lastBreakPos = newBreakPos
    for line in breakContent:gmatch("[^\r\n]+") do
        processAction(line)
    end

    placeContent, newPlacePos = readNewContent(placeFileHandle, lastPlacePos)
    lastPlacePos = newPlacePos
    for line in placeContent:gmatch("[^\r\n]+") do
        processAction(line)
    end

    Sleep(1)
end
