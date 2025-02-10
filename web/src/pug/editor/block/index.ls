module.exports =
  pkg: {}
  init: ({root}) ->
    @root = root
  interface: ->
    mod @

# host: {manager, t, update}
mod = (obj) -> (host) ->
  root = obj.root
  t = host.t
  reset: -> @_kfg.reset!
  meta: (m) -> @_kfg.meta m
  data: (c) -> if c? => @_kfg.set(c, {append: true}) else @_kfg.get!
  init: ->
    obj = nodemap: new WeakMap!

    _ = (n) -> (if n.parent => _(n.parent.tab) else []) ++ [n]
    baseview = new ldview do
      root: ld$.find(root, '[ld-scope=config]',0)
      handler:
        lv:
          list: ->
            ret = if obj.active => _(obj.active.tab) else []
            ret.filter -> it.name
          key: -> it.id
          view:
            init: dropdown: ({node}) -> new BSN.Dropdown node
            text: "name": ({ctx}) -> "#{t(ctx.name or 'n/a')}"
            handler:
              icon: ({node, ctx}) -> node.classList.toggle \d-none, ctx == obj.active.tab
              picker:
                list: ({ctx}) ->
                  ret = if ctx.depth == 0 => obj.alltabs.map(->it).filter -> it.tab.depth == 0
                  else ((ctx.parent or {}).tabs or []).map -> it
                  ret.sort (a,b) ->
                    if a.tab.order < b.tab.order => -1 else if a.tab.order > b.tab.order => 1 else 0
                  ret
                key: -> it.tab.id
                view:
                  text: "@": ({node, ctx}) -> t(ctx.tab.name or 'n/a')
                  action: click: "@": ({node, ctx}) ->
                    if !(tag = obj.nodemap.get ctx) => return
                    tag.scrollIntoView behavior: \smooth, block: \start

    io =
      visible: []
      cb: (list) ->
        list
          .filter -> it.isIntersecting
          .map -> if !~(idx = io.visible.indexOf it.target) => io.visible.push it.target
        list
          .filter -> !it.isIntersecting
          .map -> if ~(idx = io.visible.indexOf it.target) => io.visible.splice idx, 1
        list = io.visible.map (node) ->
          box = node.getBoundingClientRect!
          anchor = window.innerHeight / 4
          delta = Math.min(
            Math.abs(anchor - box.y), Math.abs(anchor - (box.y + box.height))
          )
          {node, box, delta}
        list.sort (a,b) -> a.delta - b.delta
        if !(item = list.0) => return
        obj.active = item.node._ctx
        baseview.render \lv
      opt:
        threshold: [0 to 10].map -> it/10
    io.obj = new IntersectionObserver io.cb, io.opt

    myview = ({root, ctrls, tabs}) ->
      obj.alltabs = tabs
      tabs = tabs.filter -> !it.tab.depth
      tabs.map (t) ->
        if t.tab.depth == 0 and t.tab.id == \default => t.tab <<< {name: \generic, order: ""}
        else t.tab <<< order: t.tab.name
      tabs.sort (a,b) ->
        if a.tab.order < b.tab.order => -1 
        else if a.tab.order > b.tab.order => 1 
        else 0

      if obj.view =>
        return render: ->
          obj.view.ctx {ctrls: [], tabs, tab: {}}
          obj.view.render!

      if obj._template => template = obj._template
      else
        template = ld$.find(root, '[ld=template]', 0)
        template.parentNode.removeChild template
        template.removeAttribute \ld-scope
        obj._template = template

      opt = {}
      obj.view = new ldview(
        {root, ctx: {ctrls: [], tabs, tab: {}}, init-render: false} <<< (opt <<< {
          template: template
          init: "@": ({node, ctx}) ->
            obj.nodemap.set ctx, node
            node._ctx = ctx
            if ctx.tab.id => io.obj.observe node
          handler:
            name:
              handler:
                "@": ({node, ctxs}) -> node.classList.toggle \d-none, !(ctxs.0.tab.name or ctxs.0.tab.id)
                bread:
                  list: ({ctxs}) -> _(ctxs.0.tab)
                  key: -> it.id
                  view:
                    handler:
                      "@": ({node, ctx}) -> node.classList.toggle \d-none, !(ctx.name or ctx.id)
                      icon: ({node, ctx, ctxs}) ->
                        if ctxs.1 => node.classList.toggle \d-none, ctx == ctxs.1.tab
                    text: text: ({ctx}) -> t(ctx.name or 'n/a')
            tab:
              list: ({ctx}) -> ctx.tabs
              key: -> it.key
              view: opt
            ctrl:
              list: ({ctx}) ->
                ctx.ctrls.sort (a,b) ->
                  return if !(a.meta.order? or b.meta.order?) => 0
                  else if !a.meta.order? => 1
                  else if !b.meta.order? => -1
                  else a.meta.order - b.meta.order
                ctx.ctrls
              key: -> it.key
              view:
                init: "@": ({node, ctx}) -> node.appendChild ctx.root
                handler: "@": ({node, ctx}) ->
                  if ctx.meta.type == \note => node.style = "grid-column: span 2"
                  ctx.itf.render!
        })
      )
      return render: -> obj.view.render!

    @_kfg = new konfig do
      root: baseview.get('konfig')
      manager: host.manager
      use-bundle: false
      autotab: true
      view: myview
      typemap: (name) -> {name: "@plotdb/konfig", version: "main", path: "bootstrap/#name"}
    @_kfg.on \change, (cfg) ~>
      (o) <~ @_kfg.obj!then _
      # cfg may have changed due to delay, so we call @_kfg.get! again.
      host.update \config, JSON.parse(JSON.stringify(@_kfg.get!)), o
    @_kfg.init!

