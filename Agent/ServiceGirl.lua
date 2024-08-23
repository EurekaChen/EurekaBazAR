-- Name: ServiceGirl 参考：LlamaRunner
-- ProcessId: PdomQ-FtVrsFxOdniZKUKBb4DdHeL_uLZS-qLh1IKg0

local json = require("json")
TargetWorldPid = "Vv3Ir98X_BnU48JJCnpyKRmKmjOBrqiVUkUqaoqMX_c"

Initialized = Initialized or nil
TickCount = TickCount or 0
MinRunTime = MinRunTime or 5000

IsRunning = IsRunning or false
RunStage = RunStage or 1
LastRunStageTimestamp = LastRunStageTimestamp or 0

HomePosition = HomePosition or { 32, 27 }

function Register()
  print("Registering")
  Send({
    Target = TargetWorldPid,
    Tags = {
      Action = "Reality.EntityCreate",
    },
    Data = json.encode({
      Type = "Avatar",
      Position = HomePosition,
      Metadata = {
        DisplayName = "Service|服务员",
        SpriteTxId = 'r1idcioSm_lYEMj8GDdfGZQaWXWaLP6-cAOWYkabY0M',
        Interaction = {
          Type = "SchemaForm",
          Id = "Loop",
        },
        SkinNumber = 1,
      },
    }),
  })
end

if (not Initialized) then
  Register()
end

Handlers.add(
  "Loop",
  Handlers.utils.hasMatchingTag("Action", "Loop"),
  function(msg)
    print("Loop")
    if not IsRunning then
      IsRunning = true
      Send({
        Target = TargetWorldPid,
        Tags = {
          Action = "ChatMessage",
          ['Author-Name'] = 'Service|服务员',
        },
        Data = 'Alright! I\'ll be right there | 好的，马上过来!'
      })
    end
  end
)

Handlers.add(
  "CronTick",
  Handlers.utils.hasMatchingTag("Action", "Cron"),
  function(msg)
    print("CronTick")
    TickCount = TickCount + 1

    local elapsed = msg.Timestamp - LastRunStageTimestamp
    if elapsed < MinRunTime then
      return print("Too soon: " .. elapsed)
    end
    if not IsRunning then
      return print("Not running")
    end

    local positionTable = {
      { 33, 38 },
      { 30, 38 },
      { 30, 27 },
      HomePosition,
      nil,
    }

    local targetPosition = positionTable[RunStage]

    if targetPosition ~= nil then
      -- Move to the next position
      Send({
        Target = TargetWorldPid,
        Tags = {
          Action = "Reality.EntityUpdatePosition",
        },
        Data = json.encode({
          Position = targetPosition,
        }),
      })
    end

    if RunStage == 5 then
      Send({
        Target = TargetWorldPid,
        Tags = {
          Action = "ChatMessage",
          ['Author-Name'] = 'Service|服务员',
        },
        Data = 'I\'m done | 服务完毕!'
      })
      -- Reset
      IsRunning = false
      RunStage = 1
      LastRunStageTimestamp = 0
    else
      RunStage = RunStage + 1
      LastRunStageTimestamp = msg.Timestamp
    end
  end
)

-- Schema

function LoopSchemaTags()
  return [[
{
"type": "object",
"required": [
  "Action"
],
"properties": {
  "Action": {
    "type": "string",
    "const": "Loop"
  },
}
}
]]
end

function SchemaCanRun()
  return {
    Loop = {
      Title = "I'm ready to service!|随时为您服务",
      Description = "Click Submit to get service | 需要服务请点击提交",
      Schema = {
        Tags = json.decode(LoopSchemaTags()),
        -- Data
        -- Result?
      },
    },
  }
end

Handlers.add(
  'Schema',
  Handlers.utils.hasMatchingTag('Action', 'Schema'),
  function(msg)
    print('Schema')
    if IsRunning then
      Send({
        Target = msg.From,
        Tags = { Type = 'Schema' },
        Data = json.encode({
          Loop = {
            Title = "I'm busy service! | 正在服务中",
            Description = "Come back when I've finished this service. | 等我忙完后为您服务",
            Schema = nil,
          },
        })
      })
    else
      Send({
        Target = msg.From,
        Tags = { Type = 'Schema' },
        Data = json.encode(SchemaCanRun())
      })
    end
  end
)
