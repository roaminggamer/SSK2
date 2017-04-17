--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:b21e7c26aad7a2b4a03f77ba4215ef70:370894f5c31570e4a881bf5b7e819788:5ae33c46753ecc9c3125844ea9f1fcb7$
--
-- local sheetInfo = require("mysheet")
-- local myImageSheet = graphics.newImageSheet( "mysheet.png", sheetInfo:getSheet() )
-- local sprite = display.newSprite( myImageSheet , {frames={sheetInfo:getFrameIndex("sprite")}} )
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- 01
            x=119,
            y=129,
            width=96,
            height=108,

            sourceX = 9,
            sourceY = 3,
            sourceWidth = 128,
            sourceHeight = 128
        },
        {
            -- 02
            x=1,
            y=593,
            width=104,
            height=116,

            sourceX = 7,
            sourceY = 2,
            sourceWidth = 128,
            sourceHeight = 128
        },
        {
            -- 03
            x=1,
            y=1,
            width=118,
            height=124,

            sourceX = 4,
            sourceY = 0,
            sourceWidth = 128,
            sourceHeight = 128
        },
        {
            -- 04
            x=1,
            y=127,
            width=116,
            height=114,

            sourceX = 4,
            sourceY = 5,
            sourceWidth = 128,
            sourceHeight = 128
        },
        {
            -- 05
            x=1,
            y=829,
            width=108,
            height=80,

            sourceX = 4,
            sourceY = 14,
            sourceWidth = 128,
            sourceHeight = 128
        },
        {
            -- 06
            x=107,
            y=475,
            width=114,
            height=86,

            sourceX = 4,
            sourceY = 19,
            sourceWidth = 128,
            sourceHeight = 128
        },
        {
            -- 07
            x=123,
            y=239,
            width=92,
            height=116,

            sourceX = 15,
            sourceY = 1,
            sourceWidth = 128,
            sourceHeight = 128
        },
        {
            -- 08
            x=1,
            y=711,
            width=106,
            height=116,

            sourceX = 10,
            sourceY = 0,
            sourceWidth = 128,
            sourceHeight = 128
        },
        {
            -- 09
            x=109,
            y=691,
            width=88,
            height=108,

            sourceX = 15,
            sourceY = 4,
            sourceWidth = 128,
            sourceHeight = 128
        },
        {
            -- 10
            x=123,
            y=357,
            width=98,
            height=116,

            sourceX = 19,
            sourceY = 1,
            sourceWidth = 128,
            sourceHeight = 128
        },
        {
            -- 11
            x=107,
            y=563,
            width=74,
            height=126,

            sourceX = 26,
            sourceY = 1,
            sourceWidth = 128,
            sourceHeight = 128
        },
        {
            -- 12
            x=111,
            y=801,
            width=96,
            height=98,

            sourceX = 17,
            sourceY = 10,
            sourceWidth = 128,
            sourceHeight = 128
        },
        {
            -- 13
            x=1,
            y=243,
            width=120,
            height=112,

            sourceX = 0,
            sourceY = 4,
            sourceWidth = 128,
            sourceHeight = 128
        },
        {
            -- 14
            x=121,
            y=1,
            width=114,
            height=126,

            sourceX = 9,
            sourceY = 1,
            sourceWidth = 128,
            sourceHeight = 128
        },
        {
            -- 15
            x=1,
            y=471,
            width=104,
            height=120,

            sourceX = 10,
            sourceY = 5,
            sourceWidth = 128,
            sourceHeight = 128
        },
        {
            -- 16
            x=1,
            y=357,
            width=120,
            height=112,

            sourceX = 1,
            sourceY = 4,
            sourceWidth = 128,
            sourceHeight = 128
        },
    },
    
    sheetContentWidth = 236,
    sheetContentHeight = 910
}

SheetInfo.frameIndex =
{

    ["01"] = 1,
    ["02"] = 2,
    ["03"] = 3,
    ["04"] = 4,
    ["05"] = 5,
    ["06"] = 6,
    ["07"] = 7,
    ["08"] = 8,
    ["09"] = 9,
    ["10"] = 10,
    ["11"] = 11,
    ["12"] = 12,
    ["13"] = 13,
    ["14"] = 14,
    ["15"] = 15,
    ["16"] = 16,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
