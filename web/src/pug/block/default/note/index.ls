module.exports =
  pkg:
    extend: name: '@plotdb/konfig', version: 'main', path: 'base'
    dependencies: [
      {name: "marked", version: "main", path: "marked.min.js"}
      {name: "dompurify", version: "main", path: "dist/purify.min.js"}
    ]
  init: ({root, context, data, pubsub}) ->
    {ldview,marked,DOMPurify} = context

    markedr = new marked.Renderer!
    markedr.link = (href, title, text) ->
      link = marked.Renderer.prototype.link.call @, href, title, text
      return link.replace \<a, '<a target="_blank" rel="noopener noreferrer" '
    marked.setOptions renderer: markedr

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
      handler: text: ({node}) ~>
        if @_meta.markdown? and !@_meta.markdown =>
          node.textContent = @_meta.desc or ''
        else node.innerHTML = DOMPurify.sanitize(marked.parse(@_meta.desc or ''))
