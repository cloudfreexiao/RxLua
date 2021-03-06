local Observable = require "rx.observable"
local util = require "rx.util"

--- Determine whether all items emitted by an Observable meet some criteria.
-- @arg {function=identity} predicate - The predicate used to evaluate objects.
function Observable:all(predicate)
    predicate = predicate or util.identity

    return Observable.create(function(observer)
        local subscription
        local function onNext(...)
            util.tryWithObserver(observer, function(...)
                if not predicate(...) then
                    observer:onNext(false)
                    if subscription then
                        subscription:unsubscribe()
                    end
                    observer:onCompleted()
                end
            end, ...)
        end

        local function onError(e)
            return observer:onError(e)
        end

        local function onCompleted()
            observer:onNext(true)
            return observer:onCompleted()
        end

        subscription = self:subscribe(onNext, onError, onCompleted)
        return subscription
    end)
end
