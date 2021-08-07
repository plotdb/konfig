<-(->it!) _

block-factory =
  pkg:
    extend: name: '@plotdb/konfig.widget.default', version: 'master', path: 'base'
    dependencies: []
    i18n:
      "zh-TW":
        "config": "設定"
  init: ({root, context, data, pubsub, t}) ->
    local = {}
    get-data = -> if it.data => that else it
    set-text = ->
      local.text = if it.text => that else "#{it}"
      view.render \button
    {ldview,ldcolor} = context
    pubsub.fire \init, do
      get: ~> data.popup.data!then -> get-data it
      set: ~>
        data.popup.data it
        data.popup.data!then -> set-text it
    view = new ldview do
      root: root
      action: click: button: ->
        data.popup.get!then ->
          pubsub.fire \event, \change, get-data(it)
          set-text it
      text: button: -> if local.text => that else t("config") 

return block-factory
