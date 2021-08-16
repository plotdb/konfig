<-(->it!) _

block-factory =
  pkg:
    dependencies: [
      {url: "/assets/lib/ldview/main/index.js"}
      {url: "/assets/lib/@loadingio/debounce.js/main/debounce.min.js"}
    ]
  init: ({root, context, data, pubsub, t}) ->
    @data = {}
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

return block-factory
