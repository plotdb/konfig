module.exports =
  pkg: extend: name: '@plotdb/konfig', version: 'main', path: 'text', dom: \overwrite
  init: ({root, data, pubsub, parent}) ->
    parent._values = [
      * name: "1235", value: "d"
      * name: "1023.46", value: ".2r"
      * name: "1,023.46", value: ",.2r"
      * name: "1.25M", value: ".2s"
      * name: "12%", value: ".0%"
      * name: "12.35%", value: ".2%"
    ]
    view = new ldview do
      root: root
      init: dropdown: ({node}) -> new BSN.Dropdown node
      handler:
        menu: ({node, local}) ->
          if !local.parent => local.parent = node.parentNode
          show = !!(parent._values and parent._values.length)
          if show and !node.parentNode => node.parentNode.appendChild node
          else if !show and node.parentNode => node.parentNode.removeChild node
    pubsub.on \render, -> view.render!
