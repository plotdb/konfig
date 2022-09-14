module.exports =
  pkg:
    extend: name: '@plotdb/konfig.widget.default', version: 'master', path: 'base'
    dependencies: []
    i18n:
      "zh-TW":
        "config": "設定"
  init: ({root, context, data, pubsub, t}) ->
    {ldview,ldcolor} = context
    local = {data: data.default, default: data.default}
    pubsub.fire \init, {
      get: (-> local.data )
      set: (-> local.data = it)
      default: -> local.default
      meta: -> local.data = local.default = it.default
    }
    view = new ldview do
      root: root
      action: click: button: ->
        Promise.resolve(data.cb local.data)
          .then ->
            if local.data == it => return
            pubsub.fire \event, \change, ( local.data = it )
      text: button: -> data.text or '...'
