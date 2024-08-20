-- ProcessName: HourlyGiver
-- ProcessId: 

local json = require('json')

EgcTokenPid = 'JsroQVXlDCD9Ansr-n45SrTTB2LwqX_X6jDeaGiIHMo'
EgcTokenDenomination = 2
EgcTokenMultiplier = 10 ^ EgcTokenDenomination
EgcDonationSizeWhole = 1
EgcDonationSizeQuantity = math.floor(EgcDonationSizeWhole * EgcTokenMultiplier)

-- ebazar
ChatTarget = "Vv3Ir98X_BnU48JJCnpyKRmKmjOBrqiVUkUqaoqMX_c"

Faucets=Faucets or {}

GiverInitialized = GiverInitialized or false
if (not GiverInitialized) then
  Faucets={}
  GiverInitialized = true
end

function FormatEgcTokenAmount(quantity)
  return string.format("%.1f", quantity / EgcTokenMultiplier)
end

function HasAlreadyDonated(walletId)
  --timestamp  Faucets[walletId].Recently
  return false
end

OutOfEgc = OutOfEgc or false

Handlers.add(
  "GetFaucet",
  Handlers.utils.hasMatchingTag("Action", "GetFaucet"),
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
          ['Author-Name'] = 'HourlyFaucet',
          Recipient = sender,
        },
        Data = "I rememember you! You can get more from someone else. | 。",
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

function GetFaucetSchemaTags()
  return [[
{
"type": "object",
"required": [
  "Action",
],
"properties": {
  "Action": {
    "type": "string",
    "const": "GetFaucet"
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

    local already = HasAlreadyDonated(walletId)

    if (already) then
      Send({
        Target = walletId,
        Tags = { Type = 'Schema' },
        Data = json.encode({
          GetDonation = {
            Title = "You have already received your EGC from here!|您已经在我这里拿过EGC了！",
            Description = "You can try getting more EGC from others | 我已经从我这里拿过EGC了哦，你可以试试从其他人那里拿更多的EGC",
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
          Title = "Meeting is fate | 相识是缘份",
          Description = "I'm HourlyFaucet, You can take another EGC from me every double-hour. just click below.|我叫时时送，不要赚少，每隔一个时辰你就可以从我这里再拿一次币哦。",
          Schema = {
            Tags = json.decode(GetFaucetSchemaTags()),
            -- Data
            -- Result?
          },
        },
      })
    })
  end
)
