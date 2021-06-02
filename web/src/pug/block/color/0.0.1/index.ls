<-(->it!) _

block-factory =
  pkg:
    name: 'color', version: '0.0.1'
    extend: name: 'base', version: '0.0.1'
    dependencies: [
      {url: "/assets/lib/ldcolor/main/ldcolor.min.js", async: false}
      {url: "/assets/lib/@loadingio/ldcolorpicker/main/ldcp.min.js"}
      # this doesn't work since ldcp instance is outside scoped DOM!
      #{url: "/assets/lib/@loadingio/ldcolorpicker/main/ldcp.min.css"}
    ]
  init: ({root, context, pubsub}) ->
    {ldView,ldcolor} = context
    pubsub.fire \init, do
      get: ~> if @ldcp => ldcolor.web @ldcp.get-color!
      set: ~> @ldcp.set it
    view = new ldView do
      root: root
      init: color: ({node}) ~>
        @ldcp = new ldcolorpicker node
        node.style.backgroundColor = ldcolor.web @ldcp.get-color!
        @ldcp.on \change, ~>
          pubsub.fire \event, \change, it
          node.style.backgroundColor = ldcolor.web it

return block-factory
