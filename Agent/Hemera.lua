-- ProcessName: Hemera
-- ProcessId:vql1x9DeVjTEqgobAQJIhvc2rBtXzCv1NU0pQezQZxw

local json = require('json')

EgcTokenPid = 'JsroQVXlDCD9Ansr-n45SrTTB2LwqX_X6jDeaGiIHMo'

FirstGift = 88
RegularGift = 10

EgcTokenDenomination = 2
EgcTokenMultiplier = 10 ^ EgcTokenDenomination

FirstGiftQuantity = math.floor(FirstGift * EgcTokenMultiplier)
RegularGiftQuantity = math.floor(RegularGift * EgcTokenMultiplier)

-- ebazar
ChatTarget = "Vv3Ir98X_BnU48JJCnpyKRmKmjOBrqiVUkUqaoqMX_c"

-- "WalletId" = {total=0,lastTimestamp=0}
-- Faucets={"WalletId"={total=0,lastTimestamp=0},"WalletId2"={total=0,lastTimestamp=0}}
Faucets = Faucets or {}

function IsTimeUp(walletId, timestamp)
  if not Faucets[walletId] then
    return true
  end
  local faucet = Faucets[walletId];
  local lastTimestamp = faucet.lastTimestamp
  local timeDifference = timestamp - lastTimestamp
  -- 设置每1天可以再次领取
  return timeDifference > 3600000 * 24
end

Handlers.add(
  "GetFaucet",
  Handlers.utils.hasMatchingTag("Action", "DailyFaucet"),
  function(msg)
    local sender = msg.From
    if Faucets[sender] then
      -- 已经见过面，看时间到了没
      local isTimeUp = IsTimeUp(sender, msg.Timestamp)
      if not isTimeUp then
        -- 时间未到
        Send({
          Target = ChatTarget,
          Tags = {
            Action = 'ChatMessage',
            ['Author-Name'] = 'Hemera',
            Recipient = sender,
          },
          Data = "Please come back tomorrow. | 请明天再来吧。",
        })
        return
      end
      -- 时间到了
      -- 更新赠送时间和金额
      Faucets[sender].lastTimestamp = msg.Timestamp
      Faucets[sender].total = Faucets[sender].total + RegularGift
      -- 写到聊天中
      Send({
        Target = ChatTarget,
        Tags = {
          Action = 'ChatMessage',
          ['Author-Name'] = 'Hemera',
          Recipient = sender,
        },
        Data = "I'll give you 10 EGC, You can come back tomorrow.|送你 10 EGC，明天还可以来问我要。"
      })
      -- 发送EGC
      Send({
        Target = EgcTokenPid,
        Tags = {
          Action = 'Transfer',
          Recipient = sender,
          Quantity = tostring(RegularGiftQuantity),
        },
      })
    else
      -- 第一次见面
      local faucet = { total = FirstGift, lastTimestamp = msg.Timestamp }
      --table.insert(Faucets, faucet)
      Faucets[sender] = faucet;
      Send({
        Target = ChatTarget,
        Tags = {
          Action = 'ChatMessage',
          ['Author-Name'] = 'Hemera',
          Recipient = sender,
        },
        Data = "Nice to meet you. I'm giving you a welcome red envelope | 很高兴认识你，送你一个见面红包。"
      })
      -- 发送EGC
      Send({
        Target = EgcTokenPid,
        Tags = {
          Action = 'Transfer',
          Recipient = sender,
          Quantity = tostring(FirstGiftQuantity),
        },
      })
    end
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
        "const": "DailyFaucet"
      },
    }
    }
    ]]
end

Handlers.add(
  'Schema',
  Handlers.utils.hasMatchingTag('Action', 'Schema'),
  function(msg)
    print('收到Schema的Action')
    local walletId = msg.From

    if Faucets[walletId] then
      -- 已经见过面
      local IsTimeUp = IsTimeUp(walletId, msg.Timestamp)
      if (IsTimeUp) then
        -- 时间到了
        Send({
          Target = walletId,
          Tags = { Type = 'Schema' },
          Data = json.encode({
            DailyFaucet = {
              Title = "Meeting is fate | 相识是缘份",
              Description =
              "We meet again. Please accept my 10 EGC gift. | 我们又见面了，请收下我 10 EGC的红包。",
              Schema = {
                Tags = json.decode(GetFaucetSchemaTags()),
                -- Data
                -- Result?
              },
            },
          })
        })
      else
        -- 时间未到
        Send({
          Target = walletId,
          Tags = { Type = 'Schema' },
          Data = json.encode({
            DailyFaucet = {
              Title = "Hemera|羲和",
              Description = "Remember, I will give you another gift every day! | 我是羲和，每天您都可以到我这里来领EGC哦！",
              Schema = {
                Tags = json.decode(GetFaucetSchemaTags()),
                -- Data
                -- Result?
              },
            },
          })
        })
      end
    else
      -- 第一次见面
      Send({
        Target = walletId,
        Tags = { Type = 'Schema' },
        Data = json.encode({
          DailyFaucet = {
            Title = "I'm Hemera | 我叫羲和",
            Description =
            "Great, nice to meet you. Please accept my EGC as a welcome gift. | 太好了，很高兴认识你，请收下我的 EGC 作为见面礼。",
            Schema = {
              Tags = json.decode(GetFaucetSchemaTags()),
              -- Data
              -- Result?
            },
          },
        })
      })
    end
  end
)
