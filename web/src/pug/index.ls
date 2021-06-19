<- (->it.apply {}) _

@config =
  palette: name: \palette, type: \palette, hint: "pick your favorite palette."
  number: name: \number, type: \number, range: false, min: 10, max: 64, step: 1
  boolean: name: \boolean, type: \boolean
  color: name: \color, type: \color
  choice: name: \choice, type: \choice, values: <[left right center]>, default: \left
  text: name: \text, type: \text, default: 'default text'
  paragraph: name: \paragraph, type: \paragraph, default: 'some points\n1. multiple lines. \n2. fit into ui.'
  upload: name: \upload, type: \upload, multiple: true
  font: name: \font, type: \font

cfg = new config do
  root: document.body
  config: @config

cfg.on \change, ~> @update it
cfg.init! 
  .then -> console.log \done.

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
