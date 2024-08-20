-- Name: Morpheus|墨菲斯
-- PID: dOBu-dVlJtqMHN9_2beZ9J2lfSV0gmvqWkbx1sZwRlg

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
      return print("冷静的思考30秒再来问")
    end

    Send({
      Target = ChatTarget,
      Tags = {
        Action = 'ChatMessage',
        ['Author-Name'] = 'Morpheus',
      },
      Data = "Here are two pills, red and blue. Which one do you want to take? | 我这里有红色和蓝色两颗药丸，请问你要吃哪一颗？",
    })
    TimeStampLastMessageMs = msg.Timestamp
  end
)

