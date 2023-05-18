module.exports =
  pkg:
    extend: name: '@plotdb/konfig', version: 'main', path: 'base'
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
      if !(c in <[currentColor transparent]> or isNaN(ldcolor.hsl(c).h)) => @ldcp.set-color(c)
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
        @ldcp.set-palette(it.palette or <[#cc0505 #f5b70f #9bcc31 #089ccc]>)
        if it.idx? => @ldcp.set-idx it.idx
        @prepare-default {overwrite: true, data: it}

    palette = data.palette or <[#cc0505 #f5b70f #9bcc31 #089ccc]>
    defc = ldcolor.web(data.default)
    if !(defc in (palette ++ <[transparent currentColor]>)) => palette = [defc] ++ palette
    @ldcp = new ldcolorpicker(
      root.querySelector('[ld~=input]'),
      className: "round shadow-sm round flat compact-palette no-empty-color vertical"
      palette: palette
      idx: if ~(idx = palette.indexOf(defc)) => idx else 0
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
        preset:
          list: ~> @_meta.presets or []
          key: -> it
          view:
            text: "@": ({ctx}) -> ctx
            action: click: "@": ({ctx}) ~>
              @c = ctx
              pubsub.fire \event, \change, @c
              @render!

        color: ({node, ctx}) ~>
          c = ldcolor.web(@c)
          if node.nodeName.toLowerCase! == \input =>
            node.value = if isNaN(ldcolor.hsl(@c).h) => @c else c
          else node.style.backgroundColor = c
    @ldcp.on \change, ~>
      @c = ldcolor.web it
      pubsub.fire \event, \change, @c
      @render!
