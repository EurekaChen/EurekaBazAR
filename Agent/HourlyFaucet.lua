-- ProcessName: HourlyFaucet
-- ProcessId:kRi973TXQnuxZWMjVgdmDMighkIwmHDCguggBin0ul8

local json = require('json')

EgcTokenPid = 'JsroQVXlDCD9Ansr-n45SrTTB2LwqX_X6jDeaGiIHMo'
EgcTokenDenomination = 2
EgcTokenMultiplier = 10 ^ EgcTokenDenomination
EgcFaucetSizeWhole = 1
EgcFaucetSizeQuantity = math.floor(EgcFaucetSizeWhole * EgcTokenMultiplier)

-- ebazar
ChatTarget = "Vv3Ir98X_BnU48JJCnpyKRmKmjOBrqiVUkUqaoqMX_c"

-- "WalletId" = {total=0,lastTimestamp=0}
-- Faucets={"WalletId"={total=0,lastTimestamp=0},"WalletId2"={total=0,lastTimestamp=0}}
Faucets = Faucets or {}

function FormatEgcTokenAmount(quantity)
  return string.format("%.1f", quantity / EgcTokenMultiplier)
end

function IsTimeUp(walletId, timestamp)
  if not Faucets[walletId] then
    return true
  end
  local faucet = Faucets[walletId];
  local lastTimestamp = faucet.lastTimestamp
  local timeDifference = timestamp - lastTimestamp
  -- 假设我们设置每2小时（7200000秒）可以再次领取
  return timeDifference > 7200000
end

Handlers.add(
  "GetFaucet",
  Handlers.utils.hasMatchingTag("Action", "GetFaucet"),
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
            ['Author-Name'] = 'HourlyFaucet',
            Recipient = sender,
          },
          Data = "Please come back after Double-Hour. | 请过一个时辰再来，请记住：一个时辰是两个小时。",
        })
        return
      end
      -- 时间到了
      -- 更新赠送时间和金额
      Faucets[sender].lastTimestamp = msg.Timestamp
      Faucets[sender].total = Faucets[sender].total + 1
      -- 写到聊天中
      Send({
        Target = ChatTarget,
        Tags = {
          Action = 'ChatMessage',
          ['Author-Name'] = 'HourlyFaucet',
          Recipient = sender,
        },
        Data = "I'll give you 1 EGC, You can come back after Double-Hour.|送你 1 EGC，不要嫌少，过一个时辰还可以来拿哦。"
      })
      -- 发送EGC
      Send({
        Target = EgcTokenPid,
        Tags = {
          Action = 'Transfer',
          Recipient = sender,
          Quantity = tostring(EgcFaucetSizeQuantity),
        },
      })
    else
      -- 第一次见面
      local faucet = { total = 66, lastTimestamp = msg.Timestamp }
      --table.insert(Faucets, faucet)
      Faucets[sender] = faucet;
      Send({
        Target = ChatTarget,
        Tags = {
          Action = 'ChatMessage',
          ['Author-Name'] = 'HourlyFaucet',
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
          Quantity = "6600",
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
            GetFaucet = {
              Title = "Meeting is fate | 我们又相见了",
              Description =
              "I'm HourlyFaucet, You can take another EGC from me every double-hour. |我叫时时送，不要赚少，每隔一个时辰你就可以从我这里再拿一次币哦。",
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
              GetFaucet = {
                Title = "Double-Hour is two hours!|一个时辰是两个小时！",
                Description = "See you again so soon, Double-Hour is two hours | 这么快以相见了，请记住，一个时辰是两个小时哦！",
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
            GetFaucet = {
              Title = "Meeting is fate | 相见是缘份",
              Description =
              "Nice to meet you. Here's a welcome gift for you, 66EGC. | 很高兴认识您，送您一个见面礼，有66EGC，祝您一切顺利。",
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
