types = <[choice boolean palette color number text paragraph upload font]>
bmgr.init!
  .then ->
    Promise.all(
      types.map (n) ->
        bmgr.set {
          name: "ctrl-#n", version: '0.0.1', block: new block.class { root: "\#ctrl-#{n}"}
        }
    )
  .then ->

    ce = new config-editor do
      def: {}
    ce.init!
      .then -> console.log \ok1
    ce.init!
      .then -> console.log \ok2
    types.map (n) ->
      bmgr.get {name: "ctrl-#n", version: "0.0.1"}
        .then -> it.create!
        .then -> it.attach {root: container}

#ldrs = new ldSlider root: '.ldrs'

