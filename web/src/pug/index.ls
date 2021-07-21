<- (->it.apply {}) _

@meta =
  palette: name: \palette, type: \palette, hint: "pick your favorite palette.", tab: 'color'
  number: name: \number, type: \number, range: false, min: 10, max: 64, step: 1
  boolean: name: \boolean, type: \boolean
  color: name: \color, type: \color, tab: 'color'
  choice: name: \choice, type: \choice, values: <[left right center]>, default: \left
  text: name: \text, type: \text, default: 'default text'
  paragraph: name: \paragraph, type: \paragraph, default: 'some points\n1. multiple lines. \n2. fit into ui.'
  upload: name: \upload, type: \upload, multiple: true
  font: name: \font, type: \font

cfg = new konfig do
  root: document.body
  meta: @meta
  /*
  use-bundle: false
  manager: new block.manager registry: ({name, version, path}) ->
    ret = /^@plotdb\/konfig.widget.(.+)$/.exec(name)
    return if !ret => "/block/#name/#version/index.html"
    else "/block/#{ret.1}/#path/index.html"
  */
  typemap: (name) ->
    set = if name == \number => \bootstrap else \default
    set = \bootstrap
    {name: "@plotdb/konfig.widget.#set", version: "master", path: name}

cfg.on \change, ~> @update it
cfg.init!then -> console.log '@plotdb/konfig inited.'

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
