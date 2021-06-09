<- (->it.apply {}) _

@config =
  palette: name: \palette, type: \palette
  number: name: \number, type: \number, range: false, min: 10, max: 64, step: 1
  boolean: name: \boolean, type: \boolean
  color: name: \color, type: \color
  choice: name: \choice, type: \choice, values: <[left right center]>, default: \left
  text: name: \text, type: \text, default: 'default text'
  paragraph: name: \paragraph, type: \paragraph, default: 'some points\n1. multiple lines. \n2. fit into ui.'
  upload: name: \upload, type: \upload, multiple: true
  font: name: \font, type: \font

sample = ld$.find('#sample',0)

@val = {}
@update = ~>
  sample.innerText = (@val.text or '') + '\n' + (@val.paragraph or '')
  sample.style <<<
    color: ldcolor.web(@val.color or '#000')
    fontFamily: @val.font or 'sans serif'
    fontSize: "#{@val.number}px"
    whiteSpace: 'pre-line'
    textAlign: (@val.choice or 'left')

  

block-prepare = ({name,root,data}) ~>
  manager.get({name, version: "0.0.1"})
    .then -> it.create {data}
    .then (bi) ->
      bi.attach {root} .then -> bi.interface!
    .then (item) ~>
      console.log item.get!
      item.on \change, ~>
        @val[data.name] = it
        @update!
        console.log data, it

manager = new block.manager registry: ({name, version}) -> "/block/#name/#version/index.html"
manager.init!then ~>
  view = new ldView do
    root: document.body
    handler:
      config:
        list: ~> [v for k,v of @config]
        key: -> it.name
        init: ({node,data}) ->
          block-prepare {name: data.type, root: node, data: data}
