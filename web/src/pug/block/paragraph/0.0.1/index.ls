<-(->it!) _

block-factory =
  pkg:
    name: 'paragraph', version: '0.0.1'
    extend: name: 'base', version: '0.0.1'
    dependencies: [
      {url: "/assets/lib/ldcover/main/ldcv.min.js"}
      {url: "/assets/lib/ldcover/main/ldcv.min.css"}
    ]
  init: ({root, context, data, pubsub}) ->
    obj = {data: data.default or ''}
    {ldview, ldCover} = context
    pubsub.fire \init, do
      get: -> obj.data or ''
      set: ->
        obj.data = (it or '')
        view.render!
    view = new ldview do
      root: root
      init: ldcv: ({node}) -> obj.ldcv = new ldCover root: node
      handler:
        panel: ({node}) ->
        input: ({node}) -> node.value = obj.data or ''
        textarea: ({node}) -> node.value = obj.data or ''

      action:
        click: input: ({node}) ->
          ibox = view.get('input').getBoundingClientRect!
          pbox = view.get('panel').getBoundingClientRect!
          view.get('panel').style <<< do
            width: "#{ibox.width}px"
            left: "#{ibox.left}px"
            top: "#{ibox.top}px"
          obj.ldcv.get!then ~>
            if it != \ok => return
            value = view.get('textarea').value
            if obj.data != value => pubsub.fire \event, \change, value
            obj.data = value
            view.render!

return block-factory
