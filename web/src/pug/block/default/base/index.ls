module.exports =
  pkg:
    dependencies: [
      {name: "@loadingio/vscroll", version: "main", path: "index.min.js"}
      {name: "@loadingio/debounce.js", version: "main", path: "index.min.js"}
      {name: "ldview", version: "main", path: "index.min.js"}
      {name: "ldcover", version: "main", path: "index.min.js"}
      {name: "ldcover", version: "main", path: "index.min.css"}
      {name: "ldloader", version: "main", path: "index.min.js"}
      {name: "ldloader", version: "main", path: "index.min.css", global: true}
      {name: "zmgr", version: "main", path: "index.min.js"}
    ]
  init: ({root, context, data, pubsub, t}) ->
    @_meta = data
    {ldcover,ldloader,zmgr} = context
    z = new zmgr!
    ldcover.zmgr z
    ldloader.zmgr z
    pubsub.on \init, (opt = {}) ~>
      @itf = itf =
        evt-handler: {}
        get: opt.get or ->
        set: opt.set or ->
        meta: opt.meta or ~> @_meta = it
        default: opt.default or ~> @_meta.default
        object: opt.object or (->it)
        render: ->
          view.render!
          if opt.render => opt.render!
        on: (n, cb) -> (if Array.isArray(n) => n else [n]).map (n) ~> @evt-handler.[][n].push cb
        fire: (n, ...v) -> for cb in (@evt-handler[n] or []) => cb.apply @, v
      if view => view.render \hint
    pubsub.on \event, (n, ...v) ~> @itf.fire.apply @itf, [n] ++ v
    if !root => return
    view = new ldview do
      root: root
      text: name: ~> t(@_meta.name or @_meta.id or '')
      handler: hint: ({node}) ~> node.classList.toggle \d-none, !@_meta.hint
      action: click: hint: ~>
        alert(t(@_meta.hint or 'no hint'))
  interface: -> @itf
