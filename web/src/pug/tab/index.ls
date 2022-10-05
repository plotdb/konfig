obj =
  nodemap: new WeakMap!


_ = (n) -> (if n.parent => _(n.parent.tab) else []) ++ [n]
view = new ldview do
  root: document.body
  handler:
    lv:
      list: ->
        ret = if obj.active => _(obj.active.tab) else []
        ret.filter -> it.name
      key: -> it.id
      view:
        init: dropdown: ({node}) -> new BSN.Dropdown node
        text: "name": ({ctx}) -> "#{ctx.name or ''} "
        handler:
          icon: ({node, ctx}) -> node.classList.toggle \d-none, ctx == obj.active.tab
          picker:
            list: ({ctx}) ->
              if ctx.depth == 0 => obj.alltabs.map(->it).filter -> it.tab.depth == 0
              else ((ctx.parent or {}).tabs or []).map -> it
            key: -> it.tab.id
            view:
              text: "@": ({node, ctx}) -> ctx.tab.name
              action: click: "@": ({node, ctx}) ->
                if !(tag = obj.nodemap.get ctx) => return
                tag.scrollIntoView behavior: \smooth, block: \start



manager = new block.manager registry: ({name, version, path, type}) ->
  if type == \block =>
    ret = /^@plotdb\/konfig.widget.(.+)$/.exec(name)
    return if !ret => "/block/#name/#version/index.html"
    else "/block/#{ret.1}/#path/index.html"
  else return "/assets/lib/#name/#version/#{path or 'index.min.js'}"

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
    view.render \lv

  opt:
    threshold: [0 to 10].map -> it/10
io.obj = new IntersectionObserver io.cb, io.opt

myview = ({root, ctrls, tabs}) ->
  console.log "myview render: " , tabs
  obj.alltabs = tabs
  tabs = tabs.filter -> !it.tab.depth
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
                text: text: ({ctx}) -> ctx.name
        tab:
          list: ({ctx}) -> ctx.tabs
          key: -> it.key
          view: opt
        ctrl:
          list: ({ctx}) -> ctx.ctrls
          key: -> it.key
          view:
            init: "@": ({node, ctx}) -> node.appendChild ctx.root
            handler: "@": ({node, ctx}) -> ctx.itf.render!
    })
  )
  return render: -> obj.view.render!

kfg = new konfig do
  root: view.get('konfig')
  debounce: false, use-bundle: false, manager: manager
  typemap: (name) -> {name: "@plotdb/konfig.widget.bootstrap", version: "master", path: name}
  view: myview
  autotab: true


kfg.init!then ->

  meta = 
    simple:
      axis:
        enabled: type: \boolean
        tick:
          color: type: \color, default: \#f00
          font: type: \font
          size: type: \number
        caption:
          text: type: \text, default: \caption
          color: type: \color, default: \#f00
          font: type: \font
          size: type: \number

    chart: {} <<< chart.utils.config.preset.default <<< do
      xaxis: chart.utils.config.preset.axis
      yaxis: chart.utils.config.preset.axis
      legend: chart.utils.config.preset.legend

  console.log meta.chart
  kfg.meta meta.chart

  kfg.on \change, -> console.log it
