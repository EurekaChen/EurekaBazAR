-- ProcessName: Egc200Giver
-- ProcessId: Ru9kMtDMQ9bJrlZQ9TItoWUm9ejGOonXiJV3D6fm4ko

local json = require('json')
local sqlite3 = require('lsqlite3')

EgcTokenPid = 'JsroQVXlDCD9Ansr-n45SrTTB2LwqX_X6jDeaGiIHMo'
EGC_TOKEN_DENOMINATION = 2
EGC_TOKEN_MULTIPLIER = 10 ^ EGC_TOKEN_DENOMINATION
EGC_DONATION_SIZE_WHOLE = 200
EGC_DONATION_SIZE_QUANTITY = math.floor(EGC_DONATION_SIZE_WHOLE * EGC_TOKEN_MULTIPLIER)

-- ebazar
ChatTarget = "Vv3Ir98X_BnU48JJCnpyKRmKmjOBrqiVUkUqaoqMX_c"

GiverDb = GiverDb or sqlite3.open_memory()
GiverDbAdmin = GiverDbAdmin or require('DbAdmin').new(GiverDb)

SQLITE_TABLE_DONATION = [[
  CREATE TABLE IF NOT EXISTS Donation (
    WalletId TEXT PRIMARY KEY,
    Timestamp INTEGER NOT NULL
  );
]]

function InitDb()
  GiverDbAdmin:exec(SQLITE_TABLE_DONATION)
end

GiverInitialized = GiverInitialized or false
if (not GiverInitialized) then
  InitDb()
  GiverInitialized = true
end

function FormatEgcTokenAmount(amount)
  return string.format("%.1f", amount / EGC_TOKEN_MULTIPLIER)
end

function HasAlreadyDonated(walletId)
  local stmt = GiverDb:prepare [[
    SELECT COUNT(*) AS `N`
    FROM Donation
    WHERE WalletId = ?
  ]]
  stmt:bind_values(walletId)
  for row in stmt:nrows() do
    return row.N > 0
  end
  return false
end

OUT_OF_EGC = OUT_OF_EGC or false

Handlers.add(
  "OutOfEgc",
  Handlers.utils.hasMatchingTag("Error", "Insufficient EGC|EGC余额不足!"),
  function(msg)
    if (msg.From ~= EgcTokenPid) then
      return
    end

    local sender = msg.From

    -- Remove the sender from the donation list
    GiverDbAdmin:exec(string.format([[
      DELETE FROM Donation
      WHERE WalletId = '%s'
    ]], sender))

    -- 信息发送到聊天中
    Send({
      Target = ChatTarget,
      Tags = {
        Action = 'ChatMessage',
        ['Author-Name'] = 'EGC Giver|赠送',
      },
      Data = "I seem to be out of EGC. Come back again later.|对不起，我的EGC花光了，请下次再来。",
    })

    OUT_OF_EGC = true
  end
)

Handlers.add(
  "MoreEGC",
  Handlers.utils.hasMatchingTag("Action", "Credit-Notice"),
  function(msg)
    if (msg.From ~= EgcTokenPid) then
      return
    end

    print("收到" .. msg.Tags.Quantity .. " EGC")

    if (not OUT_OF_EGC) then
      return
    end

    -- Write in chat
    Send({
      Target = ChatTarget,
      Tags = {
        Action = 'ChatMessage',
        ['Author-Name'] = 'EGC Giver|赠送',
      },
      Data = "I have more EGC to give! | 我有EGC了！",
    })

    OUT_OF_EGC = false
  end
)

Handlers.add(
  "GetDonation",
  Handlers.utils.hasMatchingTag("Action", "GetDonation"),
  function(msg)
    local sender = msg.From

    -- Check if the sender has already donated
    local already = HasAlreadyDonated(sender)

    if (already) then
      -- Write in chat
      Send({
        Target = ChatTarget,
        Tags = {
          Action = 'ChatMessage',
          ['Author-Name'] = 'EGC Giver|赠送',
          Recipient = sender,
        },
        Data = "I rememember you! You can get more from someone else. | 我记得您已经在我这里领过EGC了，您可以到其他人那里再试试！",
      })
      return
    end

    -- Record the donation
    GiverDbAdmin:exec(string.format([[
      INSERT INTO Donation (WalletId, Timestamp)
      VALUES ('%s', %d)
    ]], sender, msg.Timestamp))

    -- 写到聊天中
    Send({
      Target = ChatTarget,
      Tags = {
        Action = 'ChatMessage',
        ['Author-Name'] = 'EGC Giver',
        Recipient = sender,
      },
      Data = "I shall bestow upon you the generous sum of " ..
          FormatEgcTokenAmount(EGC_DONATION_SIZE_QUANTITY) ..
          " EGC." ..
          "!|我会慷慨的送给你" .. FormatEgcTokenAmount(EGC_DONATION_SIZE_QUANTITY) ..
          " EGC ,请查看你的钱包"
    })

    -- Grant EGC Coin
    Send({
      Target = EgcTokenPid,
      Tags = {
        Action = 'Transfer',
        Recipient = sender,
        Quantity = tostring(EGC_DONATION_SIZE_QUANTITY),
      },
    })
  end
)

-- Schema

function GetDonationSchemaTags()
  return [[
{
"type": "object",
"required": [
  "Action",
],
"properties": {
  "Action": {
    "type": "string",
    "const": "GetDonation"
  },
}
}
]]
end

Handlers.add(
  'Schema',
  Handlers.utils.hasMatchingTag('Action', 'Schema'),
  function(msg)
    print('Schema')
    -- 查看数据库，看是否账号已经送出过EGC
    local walletId = msg.From

    if (OUT_OF_EGC) then
      Send({
        Target = walletId,
        Tags = { Type = 'Schema' },
        Data = json.encode({
          GetDonation = {
            Title = "This is embarassing|不好意思",
            Description = "I was so generous today that I ran out of EGC! | 今天我把EGC都送光了",
            Schema = nil,
          },
        })
      })
      return
    end

    local already = HasAlreadyDonated(walletId)

    if (already) then
      Send({
        Target = walletId,
        Tags = { Type = 'Schema' },
        Data = json.encode({
          GetDonation = {
            Title = "You have already received your EGC from here!|您已经在我这里拿过EGC了！",
            Description = "You can try getting more EGC from others | 您已经从我这里拿过EGC了哦，你可以试试从其他人那里拿更多的EGC",
            Schema = nil,
          },
        })
      })
      return
    end

    Send({
      Target = walletId,
      Tags = { Type = 'Schema' },
      Data = json.encode({
        GetDonation = {
          Title = "Lucky for finding me! | 遇到我真幸运！",
          Description = "You have found me. Click below to recieve 200 EGC.|这是上辈子修来的福份，点击一下就能收到我送给你的200EGC。",
          Schema = {
            Tags = json.decode(GetDonationSchemaTags()),
            -- Data
            -- Result?
          },
        },
      })
    })
  end
)
