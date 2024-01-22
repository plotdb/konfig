singleton = {digest: {}}
module.exports =
  pkg:
    sync-init: true
    extend: name: '@plotdb/konfig', version: 'main', path: 'base'
    dependencies: [
      {name: "@xlfont/load", version: "main", path: "index.min.js"}
      {name: "@xlfont/choose", version: "main", path: "index.min.js"}
      {name: "@xlfont/choose", version: "main", path: "index.min.css", global: true}
    ]
    i18n:
      en: "default": "Default"
      "zh-TW": "system default": "預設字型"
  init: ({root, context, data, pubsub, t}) ->
    {ldview,ldcover,xfc} = context
    ds = data.data-source or {}
    obj = {font: null, fobj: null, digest: singleton.digest}
    get-default = ->
      return if typeof(obj._m.default) == \string => {name: obj._m.default}
      else obj._m.default or {}

    fobj = (opt = {}) ->
      font = opt.font
      cancelable = opt.cancelable
      if !font => font = obj.font or (obj.font = get-default!)
      file = font.{}mod.file or {}
      Promise.resolve!
        .then ->
          return if (file.blob instanceof Blob) => file.blob
          else if obj.digest[file.digest] => obj.digest[file.digest].blob
          else null
        .then (blob) ->
          if blob or !file.digest => blob
          else if ds.get-blob => ds.get-blob(file)
          else blob
        .then (blob) ->
          file.blob = blob
          if !(blob and ds.digest) => return
          (digest) <- ds.digest(file).then _
          if file.digest != digest => obj.changed = true
          file.digest = digest
          font.{}mod.{}file <<< file
        .then ->
          chooser.load font
            .catch -> chooser.load get-default!
            .catch -> return null
        .then ->
          if obj.font != font and cancelable => return lderror.reject 999
          if obj.font == font =>
            obj.fobj = it
            check-limited!
          return it or {} # default font object

    check-limited = ~> root.classList.toggle \limited, is-limited!
    is-limited = ~> return !!(obj.fobj and obj.fobj.{}mod.limited)
    serialize = (f = {}) ->
      m = f.mod or {}
      ret = f{name, style, weight}
      if m.limited => ret.{}mod.limited = m.limited
      if m.file and (m.file.blob or m.file.key or m.file.digest) =>
        ret.{}mod.file = m.file{key, digest, name, lastModified, size, type}
      ret
    # TODO data for get/set should be serializable and backward compatible.
    pubsub.fire \init, do
      get: ->
        # dont return a direct null/undefined to prevent json0 serialization issue.
        return if !obj.font => (@default! or '') else serialize obj.font
      set: (f,o={}) ->
        font = if !f => f
        else if typeof(f) == \string => {name: f}
        else serialize(f)
        notify = JSON.stringify(obj.font or {}) != JSON.stringify(font or {}) and !o.passive
        obj.font = font
        obj.fobj = null
        if notify => pubsub.fire \event, \change, obj.font
        obj.view.render \font-name
      default: -> get-default!
      meta: (m) -> obj._meta = m
      object: (font = {}) ~> fobj {font}
      limited: -> is-limited!
    obj._m = data or {}
    obj.font = get-default!
    urls = if xfc.url => xfc.url! else {}
    # TODO we may want to cache this chooser for other font widgets to speed up.
    chooser = new xfc do
      root: (if !root => null else root.querySelector('.ldcv')), init-render: true
      meta: urls.meta or 'https://xlfont.maketext.io/meta'
      links: urls.links or 'https://xlfont.maketext.io/links'
    pubsub.on \config, (o = {}) ->
      chooser.config o
      obj.fobj = null
      fobj!
    <~ chooser.init!then _
    if !root => return
    chooser.on \choose, (f) ~> obj.ldcv.set f
    obj.view = view = new ldview do
      root: root
      init:
        ldcv: ({node}) ~>
          obj.ldcv = new ldcover root: node, in-place: false
          obj.ldcv.on \toggle.on, -> debounce 50 .then -> chooser.render!
      action: click:
        system: ({node}) ->
          obj.font = f = null
          obj.fobj = null
          view.render \font-name
          pubsub.fire \event, \change, f
        button: ({node}) ->
          obj.ldcv.get!
            .then (font) ->
              if !font => return {font}
              file = (font.mod or {}).file
              if !(file and file.blob and ds.digest) => return {font}
              (digest) <- ds.digest file .then _
              file.digest = digest
              obj.digest[digest] = file
              if !ds.get-key? => return {font, file}
              (key) <- ds.get-key file .then _
              file.key = key
              return {font, file}
            .then ({font, file}) ->
              if !font => return
              obj.font = font{name, style, weight}
              obj.font.{}mod.file = file
              obj.fobj = null
              view.render \font-name
              pubsub.fire \event, \change, obj.font
      handler:
        "font-name": ({node}) ->
          ret = if !obj.font => t("default") else obj.font.name or t("default")
          if ret.length > 10 => ret = ret.substring(0, 10) + '...'
          node.innerText = ret
          fobj {cancelable: true}
            .then (f) ~>
              node.setAttribute \class, (if f and f.className => that else '')
              node.setAttribute \title, (if f => f.name or 'unnamed' else 'unnamed')
            .catch (e) ->
              if lderror.id(e) == 999 => # cancel
              # something wrong in chooser.load. skip.
    <~ view.init!then _
    @ <<<
      chooser: -> chooser
      cover: -> obj.ldcv
