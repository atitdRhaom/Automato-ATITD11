dofile("common.inc");

xOffset = 10;
yOffset = 2;
pointingSpeed = 2000; --ms

function doit()
  lsRequireVersion(2,40);
  askForWindow("Test to find text in regions (windows) such building windows.\n\nEnter text value and optional offset. Mouse will point to location. Useful to finding where a macro is clicking.\n\nTo test image locations, use test_findImage_offset.lua\n\nPress Shift (while hovering ATITD) to continue.");

  while true do
    checkBreak();
    findStuff();

    checkBreak();
    lsDoFrame();
    lsSleep(10);
  end
end

function pointToLocation()
  window = 1;
  while 1 do
    if lsMouseIsDown(1) then
      lsSleep(50);
      -- Don't move mouse until we let go of mouse button
    else
      lsSleep(100); -- wait a moment in case we moved mouse while clicking
      if not tonumber(xOffset) then
        xOffset = 0;
      end
      if not tonumber(yOffset) then
        yOffset = 0;
      end

      for i=#findBlah, 1, -1 do
        srSetMousePos(findBlah[i][0]+xOffset,findBlah[i][1]+yOffset);
        sleepWithStatus(pointingSpeed, "Pointing to Location " .. window .. "/" .. #findBlah .. "\n\nX Offset: "
          .. xOffset .. "\nY Offset: " .. yOffset .. "\n\nMouse Location: " .. findBlah[i][0]+xOffset .. ", " ..
        findBlah[i][1]+yOffset, nil, 0.7, "Moving Mouse");
        window = window + 1;
      end

      break;
    end
  end
end

function showDebugInRange(name, screenx, screeny, imgw, imgh, x, y, z, w, h)
  srMakeImage(name, screenx, screeny, imgw, imgh, true);
  local scale = 1;
  local border = 1;
  for stest=2,10 do
    if imgw * stest <= w and imgh * stest <= h then
      scale = stest;
      border = scale;
    end
  end
  srShowImageDebug(name, x, y, z, scale);
  lsDrawRect(x - border, y - border, x + imgw * scale + border, y + imgh * scale + border, 1, 0xFF0000ff);
end

local searchText = '';
local findBlah = {};
local errorInfo = '';
local x = 5;
local w = 0;
local bg = {};
local z = 10;
function findStuff()
  local scale = 0.7;
  local y = 5;
  local foo;
  local text = "";
  local result = "";
  srReadScreen();
  local pos = getMousePos();
  x = 5;

  w = lsPrint(x, y, z, scale, scale, 0xFFFFFFff, "Search Text (case sensitive):");  
  if (errorInfo and errorInfo ~= '') then
   -- Draw the error message with a red background
    x = x+w+5;
    w = lsPrint(x, y, z, scale, scale, 0xFFFFB0ff, errorInfo);
    bg.x = x+1;
    bg.x1 = x+w+1;
    bg.y = y;
    bg.y1 = (y+14);
    lsDrawRect(bg.x, bg.y, bg.x1, bg.y1, z-1, 0xB00000ff);

   -- Put a red border around the editbox below
    lsDrawRect(8, y+16, 212, y+42, z-1, 0xFF0000ff);
  end
  y = y + 18;
  foo, text = lsEditBox("text", 10, y, z, 200, 25, scale, scale, 0x000000ff);  
  -- foo is set to 1 if the user presses enter while in the editbox
  if (foo==1 or lsButtonText(220, y, z, 100, 0xff0Bffff, "Search")) then    
    searchText = text;
  end


  y = y + 25;
  lsPrint(5, y, z, scale, scale, 0xFFFFFFff, "X offset:    +/-");
  is_done, xOffset = lsEditBox("xoffset", 94 , y, z, 50, 0, scale, scale, 0x000000ff, xOffset);
  y = y + 20;
  lsPrint(5, y, z, scale, scale, 0xFFFFFFff, "Y offset:    +/-");
  is_done, yOffset = lsEditBox("yoffset", 94, y, z, 50, 0, scale, scale, 0x000000ff, yOffset);
  y = y + 20;

  -- needs clock finding image/code
  -- local startPos = findCoords();
  -- if startPos then
  --   lsPrint(10, y, z, scale, scale, 0xFFFFFFff, "ATITD Clock Coordinates: " .. startPos[0] .. ", " .. startPos[1]);
  -- else
  --   lsPrint(10, y, z, scale, scale, 0xFFFFFFff, "ATITD Clock Coordinates: Not Found");
  -- end
  -- y = y + 20;
  lsPrint(10, y, z, scale, scale, 0xFFFFFFff, "Current Mouse Position: " .. pos[0] .. ", " .. pos[1]);
  y = y + 25;


  local status, result = pcall(function () return findAllText(searchText, nil, REGEX); end);
  if (status) then
    print('Status: '..tostring(status).. "; Results: "..#result);
    errorInfo = '';
    findBlah = result or {};
  else 
    print('Status: '..tostring(status).. "; Result: "..result);
    errorInfo = result:match(": ([A-Za-z ]+)");    
    findBlah = {};
  end

  findCount = #findBlah;

  lsPrint(10, y, z, scale, scale, 0xFFFFFFff, "Searching for \"" .. searchText .. "\"");
  y = y + 18;
  if findCount == 0 then
    result = " Not Found";
  else
    result = " FOUND (" .. findCount .. ") strings";
  end
  lsPrint(10, y, z, scale, scale, 0xFFFFFFff, "Results: " .. result);
  y = y + 18;

  for i=1, #findBlah do
    local parse = findBlah[i];
    lsPrint(10, y, 10, scale, scale, 0xFFFFFFff, parse[0] .. "," .. parse[1] .. ": " .. parse[2]);
    if lsMouseClick(10, y, 200, 16) then
      srSetMousePos(parse[0]+xOffset,parse[1]+yOffset);
    end
    if lsMouseOver(10, y, 200, 16) then
      showDebugInRange("capture",
        parse[0], parse[1], 50, 14,
        120, y, 2, lsScreenX - 120, lsScreenY - y - 30);
    end
    y = y + 16;
  end

  if findCount ~= 0 then
    lsPrint(10, lsScreenY - 30 - 18*2, 20, scale, scale, 0xFFFFFFff, "Click a string above to move mouse to that location.");
    lsPrint(10, lsScreenY - 30 - 18, 20, scale, scale, 0xFFFFFFff, "Click Point to move mouse to location(s).");
    if lsButtonText(10, lsScreenY - 30, 20, 100, 0x00ff00ff, "Point") then
      while lsMouseIsDown() do
        sleepWithStatus(16, "Release Mouse to continue ...", nil, 0.7, "Preparing to Click");
      end
      pointToLocation();
    end
  end
  if lsButtonText(lsScreenX - 110, lsScreenY - 30, 1000, 100, 0xFF0000ff, "End script") then
    error "Clicked End Script button";
  end

end
