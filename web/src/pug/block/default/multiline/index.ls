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
    input-handler = ({node}) ->
      value = node.value
      if obj.data != value => pubsub.fire \event, \change, value
      obj.data = value
      view.render!

    view = new ldview do
      root: root
      init: ldcv: ({node}) ->
        obj.ldcv = new ldcover root: node, resident: false, in-place: false
        obj.ldcv.on \toggled.on, -> view.get \textarea .focus!
      handler:
        panel: ({node}) ->
        input: ({node}) ->
          node.value = obj.data or ''
          node.textContent = (obj.data or '').substring(0, 10) + ' ...'
          mode = node.getAttribute \data-mode
          node.classList.toggle \d-none, (mode == \multiline xor obj.multiline)
        textarea: ({node}) -> node.value = obj.data or ''
        multiline: ({node}) -> node.classList.toggle \active, !!obj.multiline
      action:
        input: input: input-handler
        change: input: input-handler
        click:
          multiline: ({node}) ->
            obj.multiline = !obj.multiline
            view.render \multiline, \input
          input: ({node}) ->
            if !obj.multiline => return
            ibox = view.getAll('input').map(->it.getBoundingClientRect!).filter(->it.width).0
            pbox = view.get('panel').getBoundingClientRect!
            extwr = window.innerWidth - (ibox.left + ibox.width) <? ibox.width / 2
            extwl = ibox.left <? ibox.width / 2
            x = ibox.left - extwl
            w = ibox.width + extwr + extwl
            y = ibox.top + (window.scrollTop or 0)
            view.get(\ldcv).style <<< do
              left: "#{x}px"
              top: "#{y}px"
            view.get('panel').style <<< do
              width: "#{w}px"
            obj.ldcv.get!then ~>
              if it != \ok => return
              value = view.get('textarea').value
              if obj.data != value => pubsub.fire \event, \change, value
              obj.data = value
              view.render!
