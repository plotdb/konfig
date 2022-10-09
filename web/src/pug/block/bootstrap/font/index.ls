module.exports =
  pkg:
    extend: name: '@plotdb/konfig.widget.default', version: 'master', path: 'font', dom: \overwrite
  init: ({root, data, pubsub, parent}) ->
    if !root => return
    view = new ldview do
      root: root
      init: dropdown: ({node}) -> new BSN.Dropdown node
    pubsub.on \render, -> view.render!
