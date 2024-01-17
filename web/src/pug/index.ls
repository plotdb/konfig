<- (->it.apply {}) _

ts =
  _: []
  log: -> @_.push [Date.now!, it or '']
  stat: ->
    for i from 1 til @_.length =>
      console.log(
        "#i".padStart(3,' ') + " / " + "#{(@_[i].0 - @_[i - 1].0)}".padStart(5, ' ') + "ms" +
        if @_[i].1 or @_[i - 1].1 => " / #{@_[i - 1].1 or '-'} to #{@_[i].1 or '-'}" else ''
      )

ts.log!

popup = do
  ldcv: new ldcover root: ld$.find('.ldcv', 0)
  data: 'yes'

@meta =
  palette:
    name: 'color brewer', type: \palette, hint: "pick your favorite palette.", tab: 'color'
    palettes: \colorbrewer
  allpal:
    name: 'Default Palettes', type: \palette, hint: "pick your favorite palette.", tab: 'color'
  number: name: \number, type: \number, range: false, min: 10, max: 64, step: 1, default: 24
  boolean: name: \boolean, type: \boolean, default: true
  button: name: \button, type: \button, text: \action, default: 0, cb: (-> console.log \clicked; return Math.random!)
  color: name: \color, type: \color, tab: 'color', palette: <[#e15b64 #f8b26a #abbd81 #64afd2]>, default: \#000
  color2:
    name: \color2, type: \color, tab: 'color', palette: <[#e15b64 #f8b26a #abbd81 #64afd2]>, context: \c
    default: \currentColor
    current-color: true
  color3: name: \color3, type: \color, tab: 'color', palette: <[#e15b64 #f8b26a #abbd81 #64afd2]>, context: \c
  choice: name: \choice, type: \choice, values: <[left right center]>, default: \left
  text:
    name: \text, type: \text, default: 'default text'
    values: [{name: "Sample 1", value: 's1'}, {name: "Sample 2", value: 's2'}]
  format:
    name: \format, type: \format, default: 'default format'
  paragraph: name: \paragraph, type: \paragraph, default: 'some points\n1. multiple lines. \n2. fit into ui.'
  upload: name: \upload, type: \upload, multiple: true
  font: name: \font, type: \font
  popup: name: \popup, type: \popup, popup:
    get: -> popup.ldcv.get!
    default: -> popup.data
    data: (d) -> Promise.resolve!then ~> if d? => popup.data = d else popup.data

@manager = new block.manager do
  registry: ({name,version,path,type}) ->
    if type == \block => "/block/#name/#version/#{path or 'index.html'}"
    else "/assets/lib/#name/#version/#{path or ''}"

kfg-cfg =
  root: ld$.find('[ld=kfg]', 0)
  debounce: false
  meta: @meta
  view: \default
  manager: @manager
  typemap: (name) -> {name: "@plotdb/konfig.widget.bootstrap", version: "master", path: name}

kfg-alt-cfg =
  root: ld$.find('[ld=kfg-alt]', 0)
  debounce: false
  meta:
    size: type: \number, min: 10, max: 32, step: 1, default: 14
    size2:
      type: \quantity
      name: "size with unit"
      default: "1em"
      units:
        * name: \em, min: 0, max: 10, step: 0.01, default: 1
        * name: \px, min: 0, max: 1024, step: 1, default: 16
        * name: \%, min: 0, max: 100, step: 0.1, default: 20
  view: \default
  manager: @manager
  typemap: (name) -> {name: "@plotdb/konfig.widget.bootstrap", version: "master", path: name}


if true =>
  @manager = new block.manager registry: ({name, version, path, type}) ->
    if type == \block =>
      ret = /^@plotdb\/konfig.widget.(.+)$/.exec(name)
      return if !ret => "/block/#name/#version/index.html"
      else "/block/#{ret.1}/#path/index.html"
    else return "/assets/lib/#name/#version/#{path or 'index.min.js'}"
  kfg-cfg <<< { use-bundle: false, manager: @manager }
  kfg-alt-cfg <<< { use-bundle: false, manager: @manager }

ts.log 'before debundling'
@manager.debundle url: "/assets/bundle/index.html"
  .then ~>
    ts.log 'after debundling'
    cfg = new konfig kfg-cfg
    cfg.on \change, ~> @update it
    p1 = cfg.init!then ->
      console.log '@plotdb/konfig cfg inited with init config:', it
      c = cfg._ctrllist
        .filter -> it.meta.type == \color
        .0
      c.itf.meta c.meta <<< {palette: {colors: <[#f00 #0f0 #00f]>}}
    cfg-alt = new konfig kfg-alt-cfg
    cfg-alt.on \change, -> ld$.find('[ld=kfg]',0).style.fontSize = "#{it.size2}"
    p2 = cfg-alt.init!then -> console.log "@plotdb/konfig cfg-alt inited."

    sample = ld$.find('#sample',0)

    @val = {}
    @update = ~>
      @val = it
      sample.innerText = (@val.text or '') + '\n' + (@val.paragraph or '')
      sample.style <<<
        color: ldcolor.web(@val.color or '#000')
        fontFamily: @val.font or 'sans serif'
        fontSize: "#{@val.number}px"
        whiteSpace: 'pre-line'
        textAlign: (@val.choice or 'left')
      if @val.font =>
        sample.style.fontFamily = @val.font.name
        console.log @val.font
        cfg.obj!then -> console.log ">",it
        cfg.interface kfg-cfg.meta.font
          .then (o = {}) ~> o.object @val.font
          .then (f) -> if f => f.sync sample.innerText

    ld$.find('.btn[ld=get-default]', 0).addEventListener \click, ->
      console.log "cfg default: ", cfg.default!
      console.log "cfg-alt default: ", cfg-alt.default!

    Promise.all [p1, p2]
      .then -> ts.log 'wait for initialization'
      .then -> debounce 1000
      .then ->
        ts.log 'after debounce'
        # test updating konfig programmatically
        val = cfg.get!
        console.log val
        val.choice = \right
        cfg.set val
        cfg.render!
      .then ->
        ts.log 'update config'
        console.log "performance profile"
        ts.stat!
