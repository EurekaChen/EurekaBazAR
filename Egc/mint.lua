-- 生成1亿EGC
Send({ Target = "JsroQVXlDCD9Ansr-n45SrTTB2LwqX_X6jDeaGiIHMo",Tags = { Action = "Mint", Quantity = "10000000000" } })

-- 转账给21点进程
Send({ Target = "JsroQVXlDCD9Ansr-n45SrTTB2LwqX_X6jDeaGiIHMo", Tags = { Action = "Transfer", Recipient = 'lKZ6SpyB_V8YwewgPmctsRDWaKQaLY3fP_3s-AnjzAs', Quantity = '10000000000'}})

-- Egc200Giver 先发100万，可供5000人收到款项
Send({ Target = "JsroQVXlDCD9Ansr-n45SrTTB2LwqX_X6jDeaGiIHMo", Tags = { Action = "Transfer", Recipient = 'Ru9kMtDMQ9bJrlZQ9TItoWUm9ejGOonXiJV3D6fm4ko', Quantity = '100000000'}})

--下面好象无效
-- Send({ Target = "lKZ6SpyB_V8YwewgPmctsRDWaKQaLY3fP_3s-AnjzAs",Tags = { Action = "Mint", Quantity = "1000000000" } })
-- Send({ Target = "Vv3Ir98X_BnU48JJCnpyKRmKmjOBrqiVUkUqaoqMX_c",Tags = { Action = "Mint", Quantity = "1000000000" } })



