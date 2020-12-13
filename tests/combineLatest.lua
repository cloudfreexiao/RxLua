describe('combineLatest', function()
  it('returns the observable it is called on if only the identity function is passed as an argument', function()
    local observable = Rx.Observable.fromRange(1, 5):combineLatest(function(x) return x end)
    expect(observable).to.produce(1, 2, 3, 4, 5)
  end)

  it('unsubscribes from the combined source observables', function()
    local observableA = Rx.Observable.create(function(observer)
      return nil
    end)

    local unsubscribeB = spy()
    local subscriptionB = Rx.Subscription.create(unsubscribeB)
    local observableB = Rx.Observable.create(function(observer)
      return subscriptionB
    end)

    local subscription = Rx.Observable.combineLatest(observableA, observableB):subscribe()
    subscription:unsubscribe()
    expect(#unsubscribeB).to.equal(1)
  end)

  it('calls the combinator function with all values produced from all input observables once they have all produced a value', function()
    local observableA = Rx.Observable.of('a')
    local observableB = Rx.Observable.of('b')
    local observableC = Rx.Observable.of('c')
    local combinator = spy()
    Rx.Observable.combineLatest(observableA, observableB, observableC, function(...) combinator(...) end):subscribe()
    expect(combinator).to.equal({{'a', 'b', 'c'}})
  end)

  it('emits the return value of the combinator as values', function()
    local observableA = Rx.Subject.create()
    local observableB = Rx.Subject.create()
    local onNext = spy()
    Rx.Observable.combineLatest(observableA, observableB, function(a, b) return a + b end):subscribe(Rx.Observer.create(onNext))
    expect(#onNext).to.equal(0)
    observableA:onNext(1)
    observableB:onNext(2)
    observableB:onNext(3)
    observableA:onNext(4)
    expect(onNext).to.equal({{3}, {4}, {7}})
  end)

  it('should produce the most recent values as soon as all observable produces a value', function()
    local subjectA = Rx.Subject.create()
    local subjectB = Rx.Subject.create()
    local onNext = spy()
    local observable = subjectA:combineLatest(subjectB):subscribe(Rx.Observer.create(onNext))
    subjectA:onNext('a')
    subjectA:onNext('b')
    subjectB:onNext('c')
    expect(onNext).to.equal({{'b', 'c'}})
    subjectB:onNext('d')
    expect(onNext).to.equal({{'b', 'c'}, {'b', 'd'}})
    subjectA:onNext('e')
    expect(onNext).to.equal({{'b', 'c'}, {'b', 'd'}, {'e', 'd'}})
    subjectA:onNext('f')
    expect(onNext).to.equal({{'b', 'c'}, {'b', 'd'}, {'e', 'd'}, {'f', 'd'}})
  end)

  it('calls onCompleted once all sources complete', function()
    local observableA = Rx.Subject.create()
    local observableB = Rx.Subject.create()
    local complete = spy()
    Rx.Observable.combineLatest(observableA, observableB, function() end):subscribe(nil, nil, complete)

    expect(#complete).to.equal(0)
    observableA:onNext(1)
    expect(#complete).to.equal(0)
    observableB:onNext(2)
    expect(#complete).to.equal(0)
    observableB:onCompleted()
    expect(#complete).to.equal(0)
    observableA:onCompleted()
    expect(#complete).to.equal(1)
  end)

  it('calls onError if one source errors', function()
    local observableA = Rx.Subject.create()
    local observableB = Rx.Subject.create()
    local errored = spy()
    Rx.Observable.combineLatest(observableA, observableB, function() end):subscribe(nil, errored)
    expect(#errored).to.equal(0)
    observableB:onError()
    expect(#errored).to.equal(1)
  end)

  it('calls onError if the combinator errors', function()
    expect(Rx.Observable.combineLatest(Rx.Observable.fromRange(3), error)).to.produce.error()
  end)
end)
