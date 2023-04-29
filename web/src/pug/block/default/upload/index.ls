singleton = {hash: {}}
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
    #  - hkey: temporal key if data source of this file is in user's browser.
    obj = {files: [], hash: singleton.hash}
    serialize = (files) -> files.map -> it{name, size, type, lastModified, key, hkey}
    pubsub.fire \init, do
      get: -> serialize obj.files
      set: (files) ->
        obj.files = if Array.isArray(files) => files else [files]
        view.get(\input).value = ''
      default: -> []
      meta: ~> @_meta = it
      object: ->
        ps = obj.files.map (f) ->
          # in following cases, we don't have to fetch the file:
          #  - blob exists
          #  - blob can be found based on given hash key
          #  - no data source key (thus file won't be found in data source)
          if f.blob => return Promise.resolve f
          if obj.hash[f.hkey] => return Promise.resolve(f <<< that)
          if !f.key? or !ds.get-blob? => return Promise.resolve f
          ds.get-blob f .then (blob) ->
            ldfile.fromFile blob, \dataurl
              .then -> f <<< {dataurl: it.result, blob: blob}
        Promise.all ps .then -> obj.files
    view = new ldview do
      root: root
      init: input: ({node}) ~> if @_meta.multiple => node.setAttribute \multiple, true
      action: change:
        input: ({node}) ->
          ps = [node.files[v] for v from 0 til node.files.length]
            .map (v) ->
              ldfile.fromFile v, \dataurl
                .then -> v{name, size, type, lastModified} <<< {dataurl: it.result, blob: v}
                .then (file) ->
                  if !ds.get-key? => return Promise.resolve file
                  ds.get-key file .then (key) -> file <<< {key}
                .then (file) ->
                  if file.key => return file
                  file.hkey = [k for k of obj.hash].length
                  obj.hash[file.hkey] = file{blob, dataurl}
                  file
          Promise.all ps
            .then (files) ->
              obj.files = files
              node.value = ''
              pubsub.fire \event, \change, serialize(files)
