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
    @data = {}
    {ldcover,ldloader,zmgr} = context
    z = new zmgr!
    ldcover.zmgr z
    ldloader.zmgr z
    pubsub.on \init, (opt = {}) ~>
      @itf = itf =
        evt-handler: {}
        get: (opt.get or ->)
        set: (opt.set or ->)
        render: ->
          view.render!
          if opt.render => opt.render!
        on: (n, cb) -> (if Array.isArray(n) => n else [n]).map (n) ~> @evt-handler.[][n].push cb
        fire: (n, ...v) -> for cb in (@evt-handler[n] or []) => cb.apply @, v
      view.render \hint
    pubsub.on \event, (n, ...v) ~> @itf.fire.apply @itf, [n] ++ v
    view = new ldview do
      root: root
      text: name: -> t(data.name or data.id or '')
      handler: hint: ({node}) ~> node.classList.toggle \d-none, !data.hint
      action: click: hint: ~>
        alert(t(data.hint or 'no hint'))
  interface: -> @itf
