view = new ldview do
  root: document.body
  init:
    kfg: ({node}) ->
      kfg = new konfig do
        root: node
        view: 'recurse'
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
