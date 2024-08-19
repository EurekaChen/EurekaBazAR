--#region Model

RealityInfo = {
  Dimensions = 2,
  Name = 'EurekaBazAR',
  ['Render-With'] = '2D-Tile-0',
}

RealityParameters = {
  ['2D-Tile-0'] = {
    Version = 0,
    Spawn = { 19, 43 },
    -- This is a tileset themed to Llama Land main island
    Tileset = {
      Type = 'Fixed',
      Format = 'PNG',
      TxId = '-hNtDp4rgV22Vm8Vz0Qs17cmQILVN7xuOVirZqmIINg', -- TxId of the tileset in PNG format
    },
    -- This is a tilemap of sample small island
    Tilemap = {
      Type = 'Fixed',
      Format = 'TMJ',
      --TxId = 'F_umaBTvn4dQ2QazA4TPUHnZwCULCxip-ATXJtve-M0',
      TxId = 'Jj4Asvoh4LVQ_eA2q0uXxwqo380B8NIYPxmwI2yqCsw',
      --TxId = 'exzF9fmG0SvsUcAyWJ0AP4Eawn07Xlk5orAVAyZRKkg', -- TxId of the tilemap in TMJ format
      -- Since we are already setting the spawn in the middle, we don't need this
      -- Offset = { -10, -10 },
    },
    PlayerSpriteTxId = 'v47hvsNy8AFAKzKgqRT0UefRS1ibTu4tmhXrT_pSmMc'
  },
  ['Audio-0'] = {
    Bgm = {
      Type = 'Fixed',
      Format = 'MP3',
      TxId = 'bV32KZyCNVNXd3QHQCESQtL0JSwvILnnP2yXTzNmHHU',
    }
  },
  ['Audio-1'] = {
    Bgm = {
      Type = 'Fixed',
      Format = 'MP3',
      TxId = 'z4P1tqI0sTSMJybMlyU5Bvv0TEOZGJOZ-UEdNoqCa7A',
    }
  },
  ['Audio-2'] = {
    Bgm = {
      Type = 'Fixed',
      Format = 'MP3',
      TxId = 'tMiL7pGlhFG_KOxcDrgqw_wOUAZai6h4xNuch_5nn8Q',
    }
  },
  ['Audio-3'] = {
    Bgm = {
      Type = 'Fixed',
      Format = 'WEBM',
      TxId = 'k-p6enw-P81m-cwikH3HXFtYB762tnx2aiSSrW137d8',
    }
  },
}

RealityEntitiesStatic = {
  ['Npc1'] = {
    Type = 'Avatar',
    Position = { 42, 46 },
    Metadata = {
      DisplayName = 'Manager|经理',
      SpriteTxId = '0WFjH89wzK8XAA1aLPzBBEUQ1uKpQe9Oz_pj8x1Wxpc',
    },
  },
  ['Npc2'] = {
    Type = 'Avatar',
    Position = { 22, 44 },
    Metadata = {
      DisplayName = 'Info|信息',
      SpriteTxId = 'V0-MU_zRr1W5DMHe4VJGGP9xxBNhceolViTKLSQG7Ik',
    },
  },
  ['jcSGf0uhLDuQ3Ftl6iBmgSsx5Zl61mvYYq-7VkwzRVU'] = {
    Position = { 28, 33 },
    Type = 'Avatar',
    Metadata = {
      DisplayName = 'Seller|销售',
      SpriteTxId = 'MciyuI-s0xM1s_U7fMCfprHEGe1-W1mSaO7OuwNP-NY',
      SkinNumber = 5,
      Interaction = {
        Type = 'Default',
      },
    },
  },
  ['DaPNHtXMTRek4De_aG7DnX2Ef6UkEyN6UVgSJwYE7EU'] = {
    Position = { 16, 38 },
    Type = 'Avatar',
    Metadata = {
      DisplayName = 'Upload|上传者',
      SkinNumber = 2,
      Interaction = {
        Type = 'Default',
      },
    },
  },
  ['Q7dQ0Ai2UJTdy8dHd8R3QmnyZEHqCyjZ5enkDWwClao'] = {
    Position = { 16, 43 },
    Type = 'Avatar',
    Metadata = {
      DisplayName = 'Giver|赠币',
      SkinNumber = 2,
      Interaction = {
        Type = 'SchemaForm',
        Id = 'GetDonation',
      },
    },
  }
}

--#endregion
return print("Loaded Reality Template")