-- ProcessName: LunarMan
-- ProcessId: ViH_QuAD0y8W8wHmY9YmWuRYfsHtkucQV2pQqrh2HKs

local json = require('json')

EgcTokenPid = 'JsroQVXlDCD9Ansr-n45SrTTB2LwqX_X6jDeaGiIHMo'

FirstGift=168
RegularGift=50

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
  -- 设置每1个农历月可以再次领取
  return timeDifference > 3600000*24*29
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
            ['Author-Name'] = 'LunarMan',
            Recipient = sender,
          },
          Data = "Please come back after one Lunar-Month. | 请过一个月再来吧，是一个农历月哦，不到30天。",
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
          ['Author-Name'] = 'LunarMan',
          Recipient = sender,
        },
        Data = "I'll give you 50 EGC, You can come back after one Lunar-Month.|送你 50 EGC，再过一个农历月，你还可以来找我。"
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
      local faucet = { total = 168, lastTimestamp = msg.Timestamp }
      --table.insert(Faucets, faucet)
      Faucets[sender] = faucet;
      Send({
        Target = ChatTarget,
        Tags = {
          Action = 'ChatMessage',
          ['Author-Name'] = 'LunarMan',
          Recipient = sender,
        },
        Data = "Nice to meet you. I'm giving you a welcome red envelope | 很高兴认识你，送你一个见面大红包。"
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
              Title = "Meeting is fate | 相识是缘份",
              Description =
              "We meet again. Please accept my 50 EGC red envelope. | 我们又见面了，请收下我 50 EGC的红包。",
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
                Title = "LunarMan with lunar gift!|月佬月佬月月佬！",
                Description = "Remember, as long as you treat her well, I will give you another gift every lunar month! | 记得，只要对她好，每过一个农历月我会再给您礼物的！",
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
              Title = "I'm Lunar Man | 我是月月佬",
              Description =
              "My relative has a daughter who is not married yet. Please be friends with her and I will give you 168 EGC as a welcome gift. | 我的亲戚有个女儿还没有结婚，请跟她做个朋友吧，我会给你 168 EGC作为见面礼。",            
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
