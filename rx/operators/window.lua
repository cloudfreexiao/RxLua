local Observable = require "rx.observable"
local util = require "rx.util"

--- Returns an Observable that produces a sliding window of the values produced by the original.
-- @arg {number} size - The size of the window. The returned observable will produce this number
--                      of the most recent values as multiple arguments to onNext.
-- @returns {Observable}
function Observable:window(size)
    if not size or type(size) ~= "number" then
        error("Expected a number")
    end

    return Observable.create(function(observer)
        local window = {}

        local function onNext(value)
            table.insert(window, value)

            if #window >= size then
                observer:onNext(util.unpack(window))
                table.remove(window, 1)
            end
        end

        local function onError(message)
            return observer:onError(message)
        end

        local function onCompleted()
            return observer:onCompleted()
        end

        return self:subscribe(onNext, onError, onCompleted)
    end)
end
