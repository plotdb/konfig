<-(->it!) _

block-factory =
  pkg:
    extend: name: '@plotdb/konfig.widget.default', version: 'master', path: 'base'
    dependencies: [
      {url: "/assets/lib/ldslider/main/ldrs.css"}
      {url: "/assets/lib/ldslider/main/ldrs.js"}
    ]
  init: ({root, context, data, pubsub}) ->
    {ldview,ldslider} = context
    obj = {}
    pubsub.fire \init, do
      get: -> obj.ldrs.get!
      set: -> obj.ldrs.set it
      render: -> obj.ldrs.update!
    view = new ldview do
      root: root
      action: click:
        switch: -> obj.ldrs.edit!
      init: ldrs: ({node}) ->
        obj.ldrs = new ldslider(
          {root: node} <<< Object.fromEntries(
            <[min max step from to exp limitMax range label]>.map(-> [it, data[it]]).filter(->it.1?)
          )
        )
        obj.ldrs.on \change, -> pubsub.fire \event, \change, it

return block-factory
