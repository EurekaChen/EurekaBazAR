-- ProcessName: Egc200Giver
-- aos Egc200Giver --module=GYrbbe0VbHim_7Hi6zrOpHQXrSQz07XNtwCnfbFo2I0 --wallet="E:\Current\Life\Secret\wallet\arweave.general.TTe0.json"
-- ProcessId: Ru9kMtDMQ9bJrlZQ9TItoWUm9ejGOonXiJV3D6fm4ko

local json = require('json')
local sqlite3 = require('lsqlite3')

EGC_TOKEN_PROCESS = 'JsroQVXlDCD9Ansr-n45SrTTB2LwqX_X6jDeaGiIHMo'
EGC_TOKEN_DENOMINATION = 2
EGC_TOKEN_MULTIPLIER = 10 ^ EGC_TOKEN_DENOMINATION
EGC_DONATION_SIZE_WHOLE = 50
EGC_DONATION_SIZE_QUANTITY = math.floor(EGC_DONATION_SIZE_WHOLE * EGC_TOKEN_MULTIPLIER)

-- RPG Land
CHAT_TARGET = "eAO-MQi0PKeZkGPbvu7QAKSzk8Sy0Hqo18Mqj8H1RdU"

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
  Handlers.utils.hasMatchingTag("Error", "Insufficient Balance!"),
  function(msg)
    if (msg.From ~= EGC_TOKEN_PROCESS) then
      return
    end

    local sender = msg.From

    -- Remove the sender from the donation list
    GiverDbAdmin:exec(string.format([[
      DELETE FROM Donation
      WHERE WalletId = '%s'
    ]], sender))

    -- Write in chat
    Send({
      Target = CHAT_TARGET,
      Tags = {
        Action = 'ChatMessage',
        ['Author-Name'] = 'EGC Giver',
      },
      Data = "Well this is embarassing... I seem to be out of $EGC. Come back again later.",
    })

    OUT_OF_EGC = true
  end
)

Handlers.add(
  "MoreEGC",
  Handlers.utils.hasMatchingTag("Action", "Credit-Notice"),
  function(msg)
    if (msg.From ~= EGC_TOKEN_PROCESS) then
      return
    end

    print("Recieved " .. msg.Tags.Quantity .. " $EGC")

    if (not OUT_OF_EGC) then
      return
    end

    -- Write in chat
    Send({
      Target = CHAT_TARGET,
      Tags = {
        Action = 'ChatMessage',
        ['Author-Name'] = 'EGC Giver',
      },
      Data = "I have more $EGC to give! My generosity knows no bounds!",
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
        Target = CHAT_TARGET,
        Tags = {
          Action = 'ChatMessage',
          ['Author-Name'] = 'EGC Giver',
          Recipient = sender,
        },
        Data = "Hey, I think I rememember you! Now now, don't be greedy...",
      })
      return
    end

    -- Record the donation
    GiverDbAdmin:exec(string.format([[
      INSERT INTO Donation (WalletId, Timestamp)
      VALUES ('%s', %d)
    ]], sender, msg.Timestamp))

    -- Write in Chat
    Send({
      Target = CHAT_TARGET,
      Tags = {
        Action = 'ChatMessage',
        ['Author-Name'] = 'EGC Giver',
        Recipient = sender,
      },
      Data = "By my boundless grace, I shall bestow upon you the generous sum of " ..
          FormatEgcTokenAmount(EGC_DONATION_SIZE_QUANTITY) .. " $EGC."
    })

    -- Grant EGC Coin
    Send({
      Target = EGC_TOKEN_PROCESS,
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
    -- Query the database to see if the account has donated
    local walletId = msg.From

    if (OUT_OF_EGC) then
      Send({
        Target = walletId,
        Tags = { Type = 'Schema' },
        Data = json.encode({
          GetDonation = {
            Title = "Well, this is embarassing...",
            Description = "I was so generous today that I ran out of $EGC! Come back later.",
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
            Title = "You have already received your donation!",
            Description = "I'm not made of $EGC you know...",
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
          Title = "Well done for finding me!",
          Description = "You have found the EGC Giver. Click below to recieve a small donation.",
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
