local json = require("json")
local bint = require('.bint')(1024)

TargetWorldPid = "Vv3Ir98X_BnU48JJCnpyKRmKmjOBrqiVUkUqaoqMX_c"
WAR = "xU9zFkq3X2ZQ6olwNVvr1vUWIjc3kXTWr7xKQD6dh10"
POOL = 'aGF7BWB_9B924sBXoirHy4KOceoCX72B77yh1nllMPA'
Px = Px or nil
Py = Py or nil
Discount = 200

local function getAmountOut(amountIn, reserveIn, reserveOut, discount)
  local discounted = bint.__mul(amountIn, bint.__sub(10000, discount))
  local numerator = bint.__mul(discounted, reserveOut)
  local denominator = bint.__add(bint.__mul(10000, reserveIn), discounted)
  return bint.udiv(numerator, denominator)
end

function Register()
  Send({
    Target = TargetWorldPid,
    Tags = {
      Action = "Reality.EntityCreate",
    },
    Data = json.encode({
      Type = "Avatar",
      Metadata = {
        DisplayName = "EgcSwap",
        SkinNumber = 1,
        Interaction = {
            Type = 'SchemaExternalForm',
            Id = 'Swap'
        },
      },
    }),
  })
end

function Move()
  Send({
    Target = TargetWorldPid,
    Tags = {
      Action = "Reality.EntityUpdatePosition",
    },
    Data = json.encode({
      Position = {
        math.random(-3, 3),
        math.random(-3, 3),
      },
    }),
  })
end

Handlers.add(
  'SchemaExternal',
  Handlers.utils.hasMatchingTag('Action', 'SchemaExternal'),
  function(msg)
    local amountIn = bint('50000000000')
    local reserveIn = bint(Py)
    local reserveOut = bint(Px)
    local amountOut = getAmountOut(amountIn, reserveIn, reserveOut, Discount)
    local formatted = string.format("%.2f", math.floor(amountOut/10000000000) / 100)

    Send({
        Target = msg.From,
        Tags = { Type = 'SchemaExternal' },
        Data = json.encode({
          Swap = {
            Target = WAR,
            Title = "Swap for Some $LLAMA coins ?",
            Description = [[
              Swap 0.05 $AR for at least ]] ..  formatted ..  [[ $LLAMA. 
              And check out swap result at https://www.permaswap.network/#/ao
              ]],
            Schema = {
              Tags = json.decode(SwapSchemaTags(amountOut)),
            },
          },
        })
      })
  end
)

function SwapSchemaTags(minAmountOut)
  local minOut = tostring(minAmountOut)
  return [[
  {
  "type": "object",
  "required": [
    "Action",
    "Recipient",
    "Quantity",
    "X-PS-For",
    "X-PS-MinAmountOut"
  ],
  "properties": {
    "Action": {
      "type": "string",
      "const": "Transfer"
    },
    "Recipient": {
      "type": "string",
      "const": "]] .. POOL .. [["
    },
    "Quantity": {
      "type": "number",
      "const": ]] .. 0.05 .. [[,
      "$comment": "]] .. 1000000000000 .. [["
    },
    "X-PS-For": {
      "type": "string",
      "const": "Swap",
    },
    "X-PS-MinAmountOut": {
      "type": "string",
      "const": "]] .. minOut .. [[",
    },
  }
  }
  ]]
end

Handlers.add(
  "CronTick",                                      
  Handlers.utils.hasMatchingTag("Action", "Cron"), 
  function()                                      
    Send({Target = POOL, Action = "Info"})
    Move()
  end
)

Handlers.add('infoResponse', Handlers.utils.hasMatchingTag('Action', 'InfoResponse'), 
    function(msg)
      assert(msg.From == POOL, 'Only accept info from pool process')
      Px = msg.PX
      Py = msg.PY
    end
)