return {
  version = "1.1",
  luaversion = "5.1",
  tiledversion = "0.18.0",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 24,
  height = 16,
  tilewidth = 40,
  tileheight = 40,
  nextobjectid = 258,
  properties = {},
  tilesets = {
    {
      name = "Proto",
      firstgid = 1,
      tilewidth = 40,
      tileheight = 40,
      spacing = 0,
      margin = 0,
      tileoffset = {
        x = 0,
        y = 0
      },
      properties = {},
      terrains = {},
      tilecount = 14,
      tiles = {
        {
          id = 0,
          image = "proto/actionMapHelper.png",
          width = 40,
          height = 40
        },
        {
          id = 1,
          image = "proto/camera.png",
          width = 40,
          height = 40
        },
        {
          id = 2,
          image = "proto/damageBlockGreen.png",
          width = 40,
          height = 40
        },
        {
          id = 3,
          image = "proto/damageBlockRed.png",
          width = 40,
          height = 40
        },
        {
          id = 4,
          image = "proto/damageBlockYellow.png",
          width = 40,
          height = 40
        },
        {
          id = 5,
          image = "proto/gamelogic.png",
          width = 40,
          height = 40
        },
        {
          id = 6,
          image = "proto/blockA.png",
          width = 40,
          height = 40
        },
        {
          id = 7,
          image = "proto/blockB.png",
          width = 40,
          height = 40
        },
        {
          id = 8,
          image = "proto/blockC.png",
          width = 40,
          height = 40
        },
        {
          id = 9,
          image = "proto/blockD.png",
          width = 40,
          height = 40
        },
        {
          id = 10,
          image = "proto/blockE.png",
          width = 40,
          height = 40
        },
        {
          id = 11,
          image = "proto/blockF.png",
          width = 40,
          height = 40
        },
        {
          id = 12,
          image = "proto/blockG.png",
          width = 40,
          height = 40
        },
        {
          id = 13,
          image = "proto/blockH.png",
          width = 40,
          height = 40
        }
      }
    }
  },
  layers = {
    {
      type = "objectgroup",
      name = "background",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      draworder = "topdown",
      properties = {},
      objects = {
        {
          id = 254,
          name = "",
          type = "",
          shape = "rectangle",
          x = 901,
          y = 60,
          width = 40,
          height = 40,
          rotation = 0,
          gid = 6,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      name = "content",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      draworder = "topdown",
      properties = {},
      objects = {
        {
          id = 162,
          name = "",
          type = "",
          shape = "rectangle",
          x = 920,
          y = 40,
          width = 40,
          height = 40,
          rotation = 0,
          gid = 3,
          visible = true,
          properties = {}
        },
        {
          id = 163,
          name = "",
          type = "",
          shape = "rectangle",
          x = 0,
          y = 640,
          width = 40,
          height = 40,
          rotation = 0,
          gid = 3,
          visible = true,
          properties = {}
        },
        {
          id = 164,
          name = "",
          type = "",
          shape = "rectangle",
          x = 920,
          y = 640,
          width = 40,
          height = 40,
          rotation = 0,
          gid = 3,
          visible = true,
          properties = {}
        },
        {
          id = 165,
          name = "",
          type = "",
          shape = "rectangle",
          x = 0,
          y = 40,
          width = 40,
          height = 40,
          rotation = 0,
          gid = 3,
          visible = true,
          properties = {}
        },
        {
          id = 250,
          name = "",
          type = "",
          shape = "rectangle",
          x = 51,
          y = 49,
          width = 40,
          height = 40,
          rotation = 0,
          gid = 7,
          visible = true,
          properties = {}
        },
        {
          id = 251,
          name = "",
          type = "",
          shape = "rectangle",
          x = 26,
          y = 63,
          width = 40,
          height = 40,
          rotation = 0,
          gid = 8,
          visible = true,
          properties = {}
        },
        {
          id = 255,
          name = "spinner",
          type = "",
          shape = "rectangle",
          x = 360,
          y = 280,
          width = 40,
          height = 40,
          rotation = 0,
          gid = 14,
          visible = true,
          properties = {
            ["rotTime"] = 5000
          }
        },
        {
          id = 256,
          name = "spinner",
          type = "",
          shape = "rectangle",
          x = 403,
          y = 401,
          width = 40,
          height = 40,
          rotation = 0,
          gid = 14,
          visible = true,
          properties = {
            ["rotTime"] = 2000
          }
        },
        {
          id = 257,
          name = "spinner",
          type = "",
          shape = "rectangle",
          x = 425,
          y = 332,
          width = 40,
          height = 40,
          rotation = 0,
          gid = 14,
          visible = true,
          properties = {
            ["rotTime"] = 500
          }
        }
      }
    },
    {
      type = "objectgroup",
      name = "foreground",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      draworder = "topdown",
      properties = {},
      objects = {
        {
          id = 252,
          name = "",
          type = "",
          shape = "rectangle",
          x = 6,
          y = 74,
          width = 40,
          height = 40,
          rotation = 0,
          gid = 4,
          visible = true,
          properties = {}
        },
        {
          id = 253,
          name = "",
          type = "",
          shape = "rectangle",
          x = 26,
          y = 626,
          width = 40,
          height = 40,
          rotation = 0,
          gid = 4,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
