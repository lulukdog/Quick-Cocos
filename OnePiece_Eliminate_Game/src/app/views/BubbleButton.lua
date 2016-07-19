
local BubbleButton = {}

-- create bubble button
function BubbleButton.new(params)
    local listener = params.listener
    local button -- pre-reference

    params.listener = function(tag)
        if params.prepare then
            params.prepare()
        end

        local oriScaleX = button:getScaleX()
        local oriScaleY = button:getScaleY()
        local function zoom1(time, onComplete)
            transition.scaleTo(button, {
                scaleX     = oriScaleX*1.2,
                scaleY     = oriScaleY*1.2,
                time       = time,
                onComplete = onComplete,
            })
        end

        local function zoom2(time, onComplete)
            transition.scaleTo(button, {
                scaleX     = oriScaleX,
                scaleY     = oriScaleY,
                time       = time,
                onComplete = onComplete,
            })
        end

        button:setButtonEnabled(false)

        zoom1(0.08, function()
            zoom2(0.09, function()
                button:setButtonEnabled(true)
                listener(tag)
            end)
        end)
    end

    button =  cc.ui.UIPushButton.new({normal = params.image})
    button:onButtonClicked(function(tag)
        params.listener(tag)
    end)
    return button
end

return BubbleButton
