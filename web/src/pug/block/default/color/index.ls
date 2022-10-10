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
    @_meta = data
    @render = ->
      pubsub.fire \render
      if view? => view.render!
    @set = (c) ->
      @c = c
      if !(c in <[currentColor transparent]>) => @ldcp.set-color(c)
      @render!

    @prepare-default = (o={}) ->
      @default = if o.data.default in <[currentColor transparent]> => o.data.default
      else ldcolor.web(o.data.default or @ldcp.get-color!)
      if o.overwrite => @set @default

    pubsub.fire \init, do
      get: ~> @c
      set: ~> @set it
      default: ~> @default
      meta: ~>
        @_meta = it
        @ldcp.set-palette it.palette
        if it.idx? => @ldcp.set-idx it.idx
        @prepare-default {overwrite: true, data: it}
    @ldcp = new ldcolorpicker(
      root.querySelector('[ld~=input]'),
      className: "round shadow-sm round flat compact-palette no-button no-empty-color vertical"
      palette: (
        (if data.default => [data.default] else []).filter(->!(it in <[transparent currentColor]>)) ++
        (data.palette or <[#cc0505 #f5b70f #9bcc31 #089ccc]>)
      )
      context: data.context or 'random'
      exclusive: if data.exclusive? => data.exclusive else true
    )
    @prepare-default {overwrite: true, data}

    view = new ldview do
      root: root
      action:
        keyup: input: ({node, ctx, evt}) ~>
          if evt.keyCode == 13 =>
            @ldcp.set-color node.value
            @c = node.value
        click: default: ({node, ctx}) ~>
          @c = \currentColor
          pubsub.fire \event, \change, @c
          @render!
      handler:
        color: ({node, ctx}) ~>
          c = ldcolor.web(@c)
          if node.nodeName.toLowerCase! == \input => node.value = c
          else node.style.backgroundColor = c
    @ldcp.on \change, ~>
      @c = ldcolor.web it
      pubsub.fire \event, \change, @c
      @render!
