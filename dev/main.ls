
  _prepare: (meta, val, ctrl) ->
    id = meta[id]
    if ctrl[id] => return Promise.resolve!
    {name,version} = if meta.block => meta.block{name,version} else {name: meta.name, version: "0.0.1"}
    @mgr.get({name,version})
      .then -> it.create {data: meta}
      .then (itf) ~>
        root = document.createElement(\div)
        @_ctrl-list.push(ctrl[id] = {itf, meta, root})
        itf.attach {root} .then -> itf.interface!
      .then (item) -> 
        val[id] = v = item.get!
        @update!
        item.on \change, ~> 
          val[id] = it
          @update!
      .then -> ctrl[id]


  _build-ctrl: (clear = false)->
    traverse = (meta, val = {}, ctrl = {}) ->
      if !meta => return
      if meta.type => return _prepare(meta, val, ctrl)
      ctrls = if meta.child => meta.child else meta
      if !ctrls => return
      for id,v of ctrls => traverse(v <<< {id}, val{}[id], ctrl{}[id])
    if clear and @_ctrl-list =>
      @_ctrl-list.map ({itf, root}) ->
        if itf.destroy => itf.destroy!
        if root.parentNode => root.parentNode.removeChild root
    if clear or !@_val => @_val = {}
    if clear or !@_ctrl => @_ctrl = {}
    if clear or !@_ctrl-list => @_ctrl-list = []
    traverse @meta, @_val, @_ctrl
  _build-tab: (clear = false) ->
    if @render-mode == \ctrl => return
    if clear and @_tab-list => @_tab-list.map ({root}) -> root.parentNode.removeChild root
    if clear or !@_tab-list => @_tab-list = []
    if clear or !@_tab => @_tab = {}
    proc = (tab, clear = false) ~>
      if @_tabdom[tab.id] =>
        @_tabdom[tab.id] <<< {tab}
        return
      root = document.createElement('div')
      @_tab-list.push d = {root, tab}
      @_tabdom[tab.id] = d
    traverse = (tab) ~>
      if !tab => return
      list = if Array.isArray(tab) => tab
      else [{id,v} for id,v of tab].map ({id,v},i) ->
        if !(v.order?) => v.order = i
        v <<< {id}
      for item in list =>
        proc item
        traverse item.child
    traverse @_tab

