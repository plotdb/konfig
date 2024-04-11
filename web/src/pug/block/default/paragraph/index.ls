module.exports =
  pkg:
    extend: name: '@plotdb/konfig', version: 'main', path: 'base'
    dependencies: []
  init: ({root, context, data, pubsub}) ->
    obj = 
      default: data.default or ''
      data: data.default or ''
    {ldview, ldcover} = context
    pubsub.fire \init, do
      get: -> obj.data or ''
      set: (v,o={}) ->
        fire = obj.data != (v or '') and !o.passive
        obj.data = (v or '')
        if fire => pubsub.fire \event, \change, obj.data
        view.render!
      default: -> obj.default
      meta: -> obj.default = it.default
    view = new ldview do
      root: root
      init: ldcv: ({node}) ->
        obj.ldcv = new ldcover root: node, resident: false, in-place: false
        obj.ldcv.on \toggled.on, -> view.get \textarea .focus!
      handler:
        panel: ({node}) ->
        input: ({node}) -> node.value = obj.data or ''
        textarea: ({node}) -> node.value = obj.data or ''

      action:
        click: input: ({node}) ->
          ibox = view.get('input').getBoundingClientRect!
          pbox = view.get('panel').getBoundingClientRect!
          extwr = window.innerWidth - (ibox.left + ibox.width) <? ibox.width / 2
          extwl = ibox.left <? ibox.width / 2
          x = ibox.left - extwl
          w = ibox.width + extwr + extwl
          view.get(\ldcv).style <<< do
            left: "#{x}px"
            top: "#{ibox.top}px"
          view.get('panel').style <<< do
            width: "#{w}px"
          obj.ldcv.get!then ~>
            if it != \ok => return
            value = view.get('textarea').value
            if obj.data != value => pubsub.fire \event, \change, value
            obj.data = value
            view.render!
