RegisterUiCallback('getAdverts', function(data, cb)
    local advertsData = CRP.RPC:execute('crp-phone:getAdverts')

    cb(advertsData)
end)

RegisterUiCallback('postAdvert', function(data, cb)
    local success, advertData = CRP.RPC:execute('crp-phone:postAdvert', data)

    cb({ state = success, advertData = advertData })
end)

RegisterUiCallback('removeAdvert', function(data, cb)
    local success = CRP.RPC:execute('crp-phone:removeAdvert', data)

    cb({ state = success })
end)