module.exports =
  pkg:
    extend: name: '@plotdb/konfig', version: 'main', path: 'color', dom: \overwrite
    i18n:
      en: "current color": "Foreground Color"
      "zh-TW": "current color": "預設前景色"
  init: ({root, data, pubsub, parent}) ->
    view = new ldview do
      root: root
      init: dropdown: ({node}) -> new BSN.Dropdown node
      handler: "input-group": ({node}) ->
        c = parent._meta.current-color
        node.classList.toggle \no-addon, (c? and !c)
    pubsub.on \render, -> view.render!
