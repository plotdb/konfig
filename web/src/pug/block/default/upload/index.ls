singleton = {digest: {}}
module.exports =
  pkg:
    extend: name: '@plotdb/konfig', version: 'main', path: 'base'
    dependencies: [ {name: \ldfile} ]
  init: ({root, context, data, pubsub}) ->
    {ldview, ldfile} = context
    ds = data.data-source or {}
    @_meta = data
    # files: Array of file with following fields:
    #  - name, size, type, lastModified: from File Object
    #  - blob, dataurl: manually created by this widget
    #  - key: key to find this file from data source.
    #  - digest: file digest(hash) for identifying file change.
    obj = {files: [], digest: singleton.digest}
    serialize = (files) -> files.map (f) -> f{name, size, type, lastModified, key, idx, digest}
    pubsub.fire \init, do
      get: -> serialize obj.files
      set: (files) ->
        # import into new obj to prevent pollution
        # always rewrite idx - we actually need index directly
        # from their real order so idx is only for reference.
        obj.files = (if Array.isArray(files) => files else [files])
          .map (f, i) -> ({} <<< f <<< {idx: i} <<< (obj.digest[f.digest] or {}){blob, dataurl})
        view.get(\input).value = ''
      default: -> []
      meta: ~> @_meta = it
      object: ->
        lc = changed: false
        ps = obj.files.map (f, i) ->
          # in following cases, we don't have to fetch the file:
          #  - blob exists
          #  - blob can be found based on given digest (not yet saved, but set again with the same digest)
          #  - no data source key / no get-blob (thus file won't be able to be found)
          if f.blob => return Promise.resolve f
          if obj.digest[f.digest] => return Promise.resolve(f <<< obj.digest[f.digest]{blob, dataurl})
          # legacy - dataurl in f.result. remove it and convert it into blob
          if f.result =>
            f.dataurl = f.result
            fetch f.result .then -> it.blob!
              .then (blob) ->
                f.name = f.name or 'unnamed'
                f <<< {blob} <<< size: blob.size, type: blob.type, lastModified: Date.now!
                delete f.result
                if !ds.digest? => f else ds.digest(f, i).then (digest) -> f <<< {digest}
              .then (f) -> if !ds.get-key? => f else ds.get-key(f, i).then (key) -> f <<< {key}
              .then (f) -> if !f.digest => f else obj.digest[f.digest] = f
              .then -> lc.changed = true
          if !f.key? or !ds.get-blob? => return Promise.resolve f
          ds.get-blob f, i
            .then (blob) ->
              f.blob = blob
              (ret) <- ldfile.fromFile blob, \dataurl .then _
              f.dataurl = ret.result
              if !ds.digest? => return
              (digest) <- ds.digest(f, i).then _
              if f.digest != digest => lc.changed = true
              f.digest = digest
        <- Promise.all ps .then _
        if lc.changed => debounce 0 .then -> pubsub.fire \event, \change, serialize(obj.files)
        return obj.files
    view = new ldview do
      root: root
      init: input: ({node}) ~> if @_meta.multiple => node.setAttribute \multiple, true
      action: change:
        input: ({node}) ->
          ps = [node.files[v] for v from 0 til node.files.length].map (v,i) ->
            ldfile.fromFile v, \dataurl
              .then -> v{name, size, type, lastModified} <<< {dataurl: it.result, blob: v, idx: i}
              .then (f) ->
                if !ds.digest? => f else ds.digest(f, i).then (digest) -> f <<< {digest}
              .then (f) -> if !ds.get-key? => f else ds.get-key(f, i).then (key) -> f <<< {key}
              .then (f) -> if !f.digest => f else obj.digest[f.digest] = f
          Promise.all ps
            .then (files) ->
              obj.files = files
              node.value = ''
              pubsub.fire \event, \change, serialize(files)
