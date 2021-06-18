<-(->it!) _

block-factory =
  pkg:
    name: 'number', version: '0.0.1'
    extend: name: 'base', version: '0.0.1'
    dependencies: [
      {url: "/assets/lib/ldslider/main/ldrs.css", type: \css}
      {url: "/assets/lib/ldslider/main/ldrs.js", async: false}
    ]
  init: ({root, context, data, pubsub}) ->
    {ldview,ldrs} = context
    obj = {}
    pubsub.fire \init, do
      get: -> obj.ldrs.get!
      set: -> obj.ldrs.set it
      data: data
    view = new ldview do
      root: root
      action: click:
        switch: -> obj.ldrs.edit!
      init: ldrs: ({node}) ->
        obj.ldrs = new ldslider({root: node} <<< data{min,max,step,from,to,exp,limit-max,range,label,limit-max})
        obj.ldrs.on \change, -> pubsub.fire \event, \change, it

return block-factory
