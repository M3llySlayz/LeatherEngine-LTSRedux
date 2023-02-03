function onEvent(name, position, argument1, argument2)
    if string.lower(name) == "set camera zoom" then
        local camZoom = tonumber(argument1)
        local hudZoom = tonumber(argument2)

        if camZoom == nil then
            camZoom = get("defaultCamZoom")
        end

        if hudZoom == nil then
            hudZoom = get("defaultHudCamZoom")
        end

        set("defaultCamZoom", camZoom)
        set("defaultHudCamZoom", hudZoom)
    end
end