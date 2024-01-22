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
    notify = ~> pubsub.fire \event, \change, @c
    @set = (c) ->
      @c = c
      if !(c in <[currentColor transparent]> or isNaN(ldcolor.hsl(c).h)) => @ldcp.set-color(c)
      @render!

    @prepare-default = (o={}) ->
      @default = if o.default in <[currentColor transparent]> => o.default
      else ldcolor.web(o.default or @ldcp.get-color!)
      if o.overwrite => @set @default

    prepare = (o = {}) ->
      p = o.palette or <[#cc0505 #f5b70f #9bcc31 #089ccc]>
      if Array.isArray(p) => p = colors: p
      p.colors = p.colors.map -> ldcolor.web(it)
      if o.default =>
        c = ldcolor.web(o.default)
        if !(c in (p.colors ++ <[transparent currentColor]>)) => p.colors = [c] ++ p.colors
      else c = p.colors[o.idx or 0] or o.colors.0
      if !~(idx = p.colors.indexOf c) => idx = 0
      return {palette: p, default: c, idx: idx}

    pubsub.fire \init, do
      get: ~> @c
      set: (v,o={}) ~>
        fire = !ldcolor.same(v,@c) and !o.passive
        @set(v)
        if fire => notify!
      default: ~> @default
      meta: ~>
        @_meta = it
        # palette is expected to be an object with `name` and `colors` fields.
        # for simplicity we detect array and transform it for user.
        ret = prepare it
        @ldcp.set-palette ret.palette
        if ret.idx? => @ldcp.set-idx ret.idx
        @prepare-default {overwrite: true, default: ret.default}

    ret = prepare data

    @ldcp = new ldcolorpicker(
      root.querySelector('[ld~=input]'),
      className: "round shadow-sm round flat compact-palette no-empty-color vertical"
      palette: ret.palette
      idx: ret.idx
      context: data.context or 'random'
      exclusive: if data.exclusive? => data.exclusive else true
    )
    @prepare-default {overwrite: true, default: ret.default}

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
      notify!
      @render!
