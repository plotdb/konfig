module.exports =
  pkg: extend: name: '@plotdb/konfig.widget.default', version: 'master', path: 'quantity', dom: \overwrite
  init: ({root}) ->
    view = new ldview do
      root: root
      init: picker: ({node}) -> new BSN.Dropdown node
