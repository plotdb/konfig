module.exports =
  pkg:
    extend: name: '@plotdb/konfig', version: 'main', path: 'base'
    dependencies: [
      {name: "ldslider", version: "main", path: "index.min.css"}
      {name: "ldslider", version: "main", path: "index.min.js"}
    ]
  init: ({root, context, data, pubsub}) ->
    {ldview,ldslider} = context
    obj = {}
    @_meta = {}
    set-meta = (m) ~> @_meta = JSON.parse(JSON.stringify(m))
    pubsub.fire \init, do
      get: -> ''
      set: (v, o={}) -> ''
      default: ~> ''
      meta: ~> set-meta(it)
      limited: -> false
      render: ->
    set-meta data

    view = new ldview do
      root: root
      text: text: ~> @_meta.desc or 'no description'
