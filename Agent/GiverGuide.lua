-- Name: GiverGuide|赠币向导
-- PID: nRHXKlVg1-il7PH6u9Z0X4chPKLvLNCKw00GlkYF8cc

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
      return print("冷静一下再发消息")
    end

    Send({
      Target = ChatTarget,
      Tags = {
        Action = 'ChatMessage',
        ['Author-Name'] = 'GiverGuide',
      },
      Data = "I heard that someone is giving away EGC outside the BazAR. | 听说商场外面有人在赠币。",
    })
    TimeStampLastMessageMs = msg.Timestamp
  end
)

