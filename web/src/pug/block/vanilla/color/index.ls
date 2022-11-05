module.exports =
  pkg:
    extend: name: '@plotdb/konfig.widget.default', version: 'main', path: 'base'
    dependencies: [
      {url: "/assets/lib/ldcolor/main/index.min.js", async: false}
      {url: "/assets/lib/@loadingio/ldcolorpicker/main/index.min.js"}
      # ldcp inject DOM into global space so we need it to be global.
      {url: "/assets/lib/@loadingio/ldcolorpicker/main/index.min.css", global: true}
    ]
  init: ({root, context, pubsub}) ->
    {ldview,ldcolor} = context
    pubsub.fire \init, do
      get: ~> if @ldcp => ldcolor.web @ldcp.get-color!
      set: ~> @ldcp.set it
    view = new ldview do
      root: root
      init: color: ({node}) ~>
        @ldcp = new ldcolorpicker node
        node.style.backgroundColor = ldcolor.web @ldcp.get-color!
        @ldcp.on \change, ~>
          pubsub.fire \event, \change, it
          node.style.backgroundColor = ldcolor.web it
