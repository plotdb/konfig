view = new ldview do
  root: document.body

manager = new block.manager registry: ({name, version, path, type}) ->
  if type == \block =>
    ret = /^@plotdb\/konfig.widget.(.+)$/.exec(name)
    return if !ret => "/block/#name/#version/index.html"
    else "/block/#{ret.1}/#path/index.html"
  else return "/assets/lib/#name/#version/#{path or 'index.min.js'}"

obj = {}
myview = ({root, ctrls, tabs}) ->
  console.log "myview render: " , tabs
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
      handler:
        name: ({node, ctx}) ->
          node.innerText = ctx.tab.name or ctx.tab.id or '?'
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
  kfg.meta {
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

  }

  kfg.on \change, -> console.log it
