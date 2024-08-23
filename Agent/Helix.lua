-- Name: Helix|海利克斯
-- PID: 35gCxPNDn7h4S_-hDDOkJGq3RMcgtDP_Ht8YFwlUo14

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
      Data = "To upload your assets to Eureka BarzAR, please visit https://helix.arweave.net/  | 想要将你的资产上传到易易市场，请访问 https://helix.aos.cool/",
    })
    TimeStampLastMessageMs = msg.Timestamp
  end
)

