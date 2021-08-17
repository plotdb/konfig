view = new ldview do
  root: document.body
  handler: template: ->
  init:
    ctrl: ({node}) ->
      kobj = new konfig do
        root: node
        meta: {
          font:
            size: name: "font size", type: \number, min: 10, max: 64, step: 1
            color: name: "font color", type: \color, default: \#222
            family:
              name: name: "font name", type: \text, default: \arial
              style: name: "font style", type: \choice, values: <[normal italic]>
              weight: name: "font weight", type: \choice, values: <[light normal bold]>
        }
        tab: {
          font: 
            name: 'font'
            child:
              basic: name: 'font basic'
              family: name: 'font family'
        }
        typemap: (name) ->
          set = \bootstrap
          {name: "@plotdb/konfig.widget.#set", version: "master", path: name}

      kobj.init!then ->
        kobj.on \change, -> console.log it
        tab = kobj._tabobj
        ctrl = kobj._ctrllist
        template = view.get('template').childNodes.0
        template.removeAttribute('ld-scope')
        (cfg = {}) <<<
          root: node
          template: template
          text:
            name: ({ctx}) -> ctx.name or ctx.id or 'unnamed'
          handler:
            config:
              list: ->
              view: {}
            child:
              list: ({ctx}) -> [v for k,v of ctx.tab.child or {}]
              view: cfg





