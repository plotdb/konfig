<-(->it!) _

block-factory =
  pkg:
    name: 'base', version: '0.0.1'
    dependencies: [
      {url: "/assets/lib/ldview/main/index.min.js"}
      {url: "/assets/lib/@loadingio/debounce.js/main/debounce.min.js"}
    ]
  init: ({root, context, data, pubsub, t}) ->
    @data = {}
    pubsub.on \init, (opt = {}) ~>
      @data = opt.data or {}
      @itf = itf =
        evt-handler: {}
        get: (opt.get or ->)
        set: (opt.set or ->)
        on: (n, cb) -> @evt-handler.[][n].push cb
        fire: (n, ...v) -> for cb in (@evt-handler[n] or []) => cb.apply @, v
      view.render \hint
    pubsub.on \event, (n, ...v) ~> @itf.fire.apply @itf, [n] ++ v
    view = new ldview do
      root: root
      text: name: -> t(data.name)
      handler: hint: ({node}) ~> node.classList.toggle \d-none, !@data.hint
      action: click: hint: ~>
        alert(t(@data.hint or 'no hint'))


  interface: -> @itf

return block-factory
