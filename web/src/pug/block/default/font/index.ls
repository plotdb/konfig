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
    obj = {font: null, fobj: null}
    get-default = -> if typeof(obj._m.default) == \string => {name: obj._m.default} else obj._m.default
    fobj = ->
      Promise.resolve!
        .then ->
          return if obj.fobj => that
          else if obj.font => chooser.load obj.font else {}
        .then ->
          obj.fobj = it
          check-limited!
          return it
    check-limited = ~> root.classList.toggle \limited, is-limited!
    is-limited = ~> return !!(obj.fobj and obj.fobj.limited)
    # TODO data for get/set should be serializable and backward compatible.
    pubsub.fire \init, do
      get: ->
        # dont return a direct null/undefined to prevent json0 serialization issue.
        if !obj.font => return (@default! or '')
        obj.font{name, style, weight}
      set: (f) ->
        obj.font = if !f => f
        else if typeof(f) == \string => {name: f}
        else f{name, style, weight}
        obj.fobj = null
        view.render \font-name
      default: -> get-default!
      meta: (m) -> obj._meta = m
      object: (f) ~> chooser.load f .catch -> return null
      limited: -> is-limited!
    obj._m = data or {}
    obj.font = get-default!
    urls = if xfc.url => xfc.url! else {}
    # TODO we may want to cache this chooser for other font widgets to speed up.
    chooser = new xfc do
      root: (if !root => null else root.querySelector('.ldcv')), init-render: true
      meta: urls.meta or 'https://xlfont.maketext.io/meta'
      links: urls.links or 'https://xlfont.maketext.io/links'
    pubsub.on \config, (o = {}) ->
      chooser.config o
      obj.fobj = null
      fobj!
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
          obj.fobj = null
          view.render \font-name
          pubsub.fire \event, \change, f
        button: ({node}) ->
          obj.ldcv.get!
            .then (f) ->
              if !f => return
              obj.font = if f => f{name, style, weight} else null
              obj.fobj = null
              view.render \font-name
              pubsub.fire \event, \change, obj.font
      handler:
        "font-name": ({node}) ->
          ret = if !obj.font => t("default") else obj.font.name or t("default")
          if ret.length > 10 => ret = ret.substring(0, 10) + '...'
          node.innerText = ret
          fobj!
            .then (f) ~> node.setAttribute \class, (if f and f.className => that else '')
            .catch -> # something wrong in chooser.load. skip.
