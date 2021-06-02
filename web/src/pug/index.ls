<- (->it.apply {}) _

@config =
  palette: name: \palette, type: \palette

block-prepare = ({name,root,data}) ->
  manager.get({name, version: "0.0.1"})
    .then -> it.create {data}
    .then (bi) ->
      bi.attach {root} .then -> bi.interface!
    .then (item) ->

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
