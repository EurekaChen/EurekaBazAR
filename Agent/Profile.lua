-- Name: Pofile|档案
-- PID: xP2GsrL2RzNtH0BEQyczxI__8bI90u73f3m3aLz0NSU

EurekaBazarPid = "Vv3Ir98X_BnU48JJCnpyKRmKmjOBrqiVUkUqaoqMX_c"
ChatTarget = EurekaBazarPid
TimeStampLastMessageMs = TimeStampLastMessageMs or 0
-- 防止发送信息过于频繁
CooldownMs = 30000 -- 30秒

Handlers.add(
  'DefaultInteraction',
  Handlers.utils.hasMatchingTag('Action', 'DefaultInteraction'),
  function(msg)
    print('DefaultInteraction')
    if ((msg.Timestamp - TimeStampLastMessageMs) < CooldownMs) then
      return print("冷静的思考30秒再来")
    end

    Send({
      Target = ChatTarget,
      Tags = {
        Action = 'ChatMessage',
        ['Author-Name'] = 'Helix',
      },
      Data = "To use atomic assets, it is necessary to create a profile here https://helix.arweave.net/  | 使用原子资产，需要创建档案，请访问 https://helix.aos.cool/",
    })
    TimeStampLastMessageMs = msg.Timestamp
  end
)

