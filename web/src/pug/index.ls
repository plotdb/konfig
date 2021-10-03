<- (->it.apply {}) _

popup = do
  ldcv: new ldcover root: ld$.find('.ldcv', 0)
  data: 'yes'

@manager = new block.manager do
  registry: ({name,version,path,type}) ->
    if type == \block => "/block/#name/#version/#{path or 'index.html'}"
    else "/assets/lib/#name/#version/#{path or ''}"

@meta =
  palette:
    name: \palette, type: \palette, hint: "pick your favorite palette.", tab: 'color'
    palettes: ldpp.get('default')
  number: name: \number, type: \number, range: false, min: 10, max: 64, step: 1, from: 24
  boolean: name: \boolean, type: \boolean, default: true
  color: name: \color, type: \color, tab: 'color', default: \#000000
  choice: name: \choice, type: \choice, values: <[left right center]>, default: \left
  text: name: \text, type: \text, default: 'default text'
  paragraph: name: \paragraph, type: \paragraph, default: 'some points\n1. multiple lines. \n2. fit into ui.'
  upload: name: \upload, type: \upload, multiple: true
  #font: name: \font, type: \font
  popup: name: \popup, type: \popup, popup:
    get: -> popup.ldcv.get!
    default: -> popup.data
    data: (d) -> Promise.resolve!then ~> if d? => popup.data = d else popup.data

cfg = new konfig do
  root: ld$.find('[ld=kfg]', 0)
  debounce: false
  meta: @meta
  view: \default
  manager: @manager

  /*
  use-bundle: false
  manager: new block.manager registry: ({name, version, path}) ->
    ret = /^@plotdb\/konfig.widget.(.+)$/.exec(name)
    return if !ret => "/block/#name/#version/index.html"
    else "/block/#{ret.1}/#path/index.html"
  */
  typemap: (name) -> {name: "@plotdb/konfig.widget.bootstrap", version: "master", path: name}

cfg.on \change, ~> @update it
cfg.init!then -> console.log '@plotdb/konfig cfg inited.'

cfg-alt = new konfig do
  root: ld$.find('[ld=kfg-alt]', 0)
  debounce: false
  meta: size: type: \number, min: 10, max: 32, step: 1, from: 10
  view: \default
  manager: @manager
  typemap: (name) -> {name: "@plotdb/konfig.widget.bootstrap", version: "master", path: name}

cfg-alt.on \change, -> ld$.find('[ld=kfg]',0).style.fontSize = "#{it.size}px"
cfg-alt.init!then -> console.log "@plotdb/konfig cfg-alt inited."

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
