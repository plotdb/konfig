view = new ldview do
  root: document.body
  init:
    kfg: ({node}) ->
      template = ld$.find('[template]', 0)
      template.parentNode.removeChild template
      template.removeAttribute \ld-scope
      rview = new ldview (opt = {}) <<< do
        ctx: {tab: id: null}
        template: template
        root: node
        init-render: false
        text: name: ({ctx}) -> return if ctx.tab => "#{ctx.tab.depth or 0} / #{ctx.tab.id}" else ''
        handler:
          "@": ({node, ctx}) -> if !ctx.tab.id => node.classList.add \root
          tab:
            list: ({ctx}) ~>
              tabs = kfg._tablist.filter ->
                !(it.tab.parent.id or ctx.tab.id) or
                (it.tab.parent and ctx.tab and it.tab.parent.id == ctx.tab.id)
              tabs.sort (a,b) -> b.tab.order - a.tab.order
              tabs
            key: -> it.key
            view: opt
          ctrl:
            list: ({ctx}) ~>
              ret = kfg._ctrllist.filter ->
                if !ctx.tab => return false
                it.meta.tab == ctx.tab.id and !it.meta.hidden
              return ret
            key: -> it.key
            init: ({node, data}) ~> node.appendChild data.root
            handler: ({node, data}) ~>
              node.style.flex = "1 0 #{16 * (data.meta.weight or 1)}%"
              data.itf.render!


      kfg = new konfig do
        root: node
        view: rview
        manager: new block.manager do
          registry: ({name, version, path, type}) ->
            if type == \block => return "/assets/block/#name/#version/#{path or 'index.html'}"
            return "/assets/lib/#name/#version/#path"
        typemap: (name) -> {name: "@plotdb/konfig.widget.bootstrap", version: "master", path: name}
        meta:
          font:
            tab: \font
            child:
              size: type: \number
              family: type: \choice, values: ["sans serif", "serif", "monospace", "handwriting", "fantasy"]
          flex:
            tab: \flex
            child:
              wrap: type: \choice, values: ["wrap", "nowrap"]
              direction: type: \choice, values: ["column", "row", "column-reverse", "row-reverse"]
          axis:
            tab: \axis
            child:
              padding:
                tab: \padding
                child: 
                  inner: type: \number, weight: 2
                  outer: type: \number
                  top: type: \number
                  bottom: type: \number
                  letter: type: \number
                  caption: type: \number
              direction: type: \choice, values: <[horizontal vertical]>
        tab:
          default:
            name: \default
            child: 
              flex: {}
              font: {}
          axis: {child: padding: {}}


      kfg.init!
        .then ->
view.render!
