module.exports =
  pkg:
    extend: name: '@plotdb/konfig', version: 'main', path: 'base'
    dependencies: []
    i18n:
      "zh-TW":
        "config": "設定"
  init: ({root, context, data, pubsub, t}) ->
    local = {}
    get-data = -> if !it => null else if it.data => that else it
    set-text = ->
      local.text = if it and it.text => that else if typeof(it) == \string => "#{it}" else t('config')
      view.render \button
    {ldview,ldcolor} = context
    pubsub.fire \init, do
      get: ~> data.popup.data!
      set: (v,o={}) ~>
        data.popup.data v
        if !o.passive => pubsub.fire \event, \change, v
        set-text data.popup.data!
    view = new ldview do
      root: root
      action: click: button: ->
        data.popup.get!then ->
          pubsub.fire \event, \change, get-data(it)
          set-text it
      text: button: -> if local.text => that else t("config") 
