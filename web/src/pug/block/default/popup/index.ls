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
      local.text = if it.text => that else if typeof(it) == \string => "#{it}" else '...'
      view.render \button
    {ldview,ldcolor} = context
    pubsub.fire \init, do
      get: ~> data.popup.data!
      set: ~>
        data.popup.data it
        set-text data.popup.data!
    view = new ldview do
      root: root
      action: click: button: ->
        data.popup.get!then ->
          pubsub.fire \event, \change, get-data(it)
          set-text it
      text: button: -> if local.text => that else t("config") 

return block-factory
