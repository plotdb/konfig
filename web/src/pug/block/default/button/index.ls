module.exports =
  pkg:
    extend: name: '@plotdb/konfig', version: 'main', path: 'base'
    dependencies: []
    i18n:
      "zh-TW":
        "config": "設定"
  init: ({root, context, data, pubsub, t}) ->
    {ldview,ldcolor} = context
    lc = {data: data.default, default: data.default}
    notify = -> pubsub.fire \event, \change, lc.data
    pubsub.fire \init, {
      get: (-> lc.data )
      set: (v, o = {}) ->
        fire = lc.data != v and !o.passive
        lc.data = v
        if fire => notify!
      default: -> lc.default
      meta: -> lc.data = lc.default = it.default
    }
    view = new ldview do
      root: root
      action: click: button: ->
        Promise.resolve(data.cb lc.data)
          .then ->
            if lc.data == it => return
            lc.data = it
            notify!
      text: button: -> data.text or '...'
