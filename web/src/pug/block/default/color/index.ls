module.exports =
  pkg:
    extend: name: '@plotdb/konfig.widget.default', version: 'master', path: 'base'
    dependencies: [
      {name: "ldcolor", version: "main", path: "index.min.js", async: false}
      {name: "@loadingio/ldcolorpicker", version: "main", path: "index.min.js"}
      # ldcp inject DOM into global space so we need it to be global.
      {name: "@loadingio/ldcolorpicker", version: "main", path: "index.min.css", global: true}
    ]
  init: ({root, context, pubsub, data}) ->
    {ldview,ldcolor,ldcolorpicker} = context
    pubsub.fire \init, do
      get: ~> if @ldcp => ldcolor.web @ldcp.get-color!
      set: ~> @ldcp.set-color it
      default: ~> @default
      meta: ~>
        @ldcp.set-palette it.palette
        if it.idx? => @ldcp.set-idx it.idx
        @default = ldcolor.web(it.default or @ldcp.get-color!)
    @ldcp = new ldcolorpicker(
      root,
      className: "round shadow-sm round flat compact-palette no-button no-empty-color vertical"
      palette: (if data.default => [data.default] else []) ++ (data.palette or <[#cc0505 #f5b70f #9bcc31 #089ccc]>)
      context: data.context or 'random'
      exclusive: if data.exclusive? => data.exclusive else true
    )
    @default = ldcolor.web(data.default or @ldcp.get-color!)
    view = new ldview do
      ctx: {color: ldcolor.web @ldcp.get-color!}
      root: root
      handler:
        color: ({node, ctx}) ->
          if node.nodeName.toLowerCase! == \input => node.value = ctx.color
          else node.style.backgroundColor = ctx.color
    @ldcp.on \change, ~>
      color = ldcolor.web it
      pubsub.fire \event, \change, color
      view.setCtx {color}
      view.render!
