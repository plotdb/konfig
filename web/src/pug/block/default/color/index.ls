<-(->it!) _

block-factory =
  pkg:
    extend: name: '@plotdb/konfig.widget.default', version: 'master', path: 'base'
    dependencies: [
      {name: "ldcolor", version: "main", path: "ldcolor.min.js", async: false}
      {name: "@loadingio/ldcolorpicker", version: "main", path: "ldcp.min.js"}
      # ldcp inject DOM into global space so we need it to be global.
      {name: "@loadingio/ldcolorpicker", version: "main", path: "ldcp.min.css", global: true}
    ]
  init: ({root, context, pubsub}) ->
    {ldview,ldcolor,ldcolorpicker} = context
    pubsub.fire \init, do
      get: ~> if @ldcp => ldcolor.web @ldcp.get-color!
      set: ~> @ldcp.set it
    @ldcp = new ldcolorpicker root, className: "round shadow-sm round flat compact-palette no-button no-empty-color"
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

return block-factory
