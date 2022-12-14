DB = {}

function DB:Execute(query, ...)
    local executePromise = promise:new()

    exports.ghmattimysql:execute(query, { ... }, function(result) executePromise:resolve(result) end)

    return executePromise
end

function DB:Scalar(query, ...)
    local scalarPromise = promise:new()

    exports.ghmattimysql:scalar(query, { ... }, function(result) scalarPromise:resolve(result) end)

    return scalarPromise
end

function DB:Transaction(query, ...)
	local transaction = promise:new()

	exports.ghmattimysql:transaction(query, { ... }, function(result) transaction:resolve(result) end)

    return transaction
end