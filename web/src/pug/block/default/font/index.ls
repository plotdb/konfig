module.exports =
  pkg:
    extend: name: '@plotdb/konfig', version: 'main', path: 'base'
    dependencies: [
      {name: "@xlfont/load", version: "main", path: "index.min.js"}
      {name: "@xlfont/choose", version: "main", path: "index.min.js"}
      {name: "@xlfont/choose", version: "main", path: "index.min.css", global: true}
    ]
    i18n:
      en: "default": "Default"
      "zh-TW": "system default": "預設字型"
  init: ({root, context, data, pubsub, t}) ->
    {ldview,ldcover,xfc} = context
    obj = {font: null}
    # TODO data for get/set should be serializable and backward compatible.
    pubsub.fire \init, do
      get: ->
        if obj.font => obj.font{name, style, weight}
        else @default!
      set: (f) ->
        obj.font = if !f => f
        else if typeof(f) == \string => {name: f}
        else f{name, style, weight}
        view.render \font-name
      default: -> if typeof(obj._m.default) == \string => {name: obj._m.default} else obj._m.default
      meta: (m) -> obj._meta = m
      object: (f) ~> chooser.load f
    obj._m = data
    chooser = new xfc do
      root: (if !root => null else root.querySelector('.ldcv')), init-render: true
      meta: 'https://xlfont.maketext.io/meta'
      links: 'https://xlfont.maketext.io/links'
    chooser.init!
    if !root => return
    chooser.on \choose, (f) ~> obj.ldcv.set f
    view = new ldview do
      root: root
      init:
        ldcv: ({node}) ->
          obj.ldcv = new ldcover root: node, in-place: false
          obj.ldcv.on \toggle.on, -> debounce 50 .then -> chooser.render!
      action: click:
        system: ({node}) ->
          obj.font = f = null
          view.render \font-name
          pubsub.fire \event, \change, f
        button: ({node}) ->
          obj.ldcv.get!
            .then (f) ->
              obj.font = if f => f{name, style, weight} else null
              view.render \font-name
              pubsub.fire \event, \change, obj.font
      handler:
        "font-name": ({node}) ->
          ret = if !obj.font => t("default") else obj.font.name or t("default")
          if ret.length > 10 => ret = ret.substring(0, 10) + '...'
          node.innerText = ret
          Promise.resolve(if obj.font => chooser.load obj.font else obj.font)
            .then (f) -> node.setAttribute \class, (if f and f.className => that else '')
