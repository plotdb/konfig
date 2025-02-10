({konfig}) <- ldc.register <[konfig]>, _

view = new ldview do
  root: document.body
  action: click:
    "set-meta": ({node}) ~>
      name = node.dataset.name
      @mod.konfig1.meta sample[name]
      @mod.konfig2.meta sample[name]

@mod = {}
@update = ->
@manager = new block.manager registry: ({name, version, path, type}) ->
  if type == \block =>
    return if name != \@plotdb/konfig => "/block/#name/#version/index.html"
    else if /bootstrap/.exec(path) => "/block/#path/index.html"
    else "/block/default/#path/index.html"
  else return "/assets/lib/#name/#version/#{path or 'index.min.js'}"

i18next.init supportedLng: <[en zh-TW]>, fallbackLng: \en, fallbackNS: '', defaultNS: ''
  .then -> i18next.use i18nextBrowserLanguageDetector
  .then ~>
    block.i18n.use i18next
    @t = (t,o) -> i18next.t(t, o)

    for k,v of i18n-data.en => if !i18n-data["zh-TW"][k] => i18n-data{}["zh-TW"][k] = k
    for k,v of i18n-data => i18next.add-resource-bundle k, '', v, true, true
    lng = (
      httputil.qs(\lng) or
      httputil.cookie(\lng) or
      navigator.language or navigator.userLanguage
    )
    console.log "[i18n] use language: ", lng
    i18next.changeLanguage lng
  .then ~> @mod.konfig1 = konfig @
  .then ~> @mod.konfig1.init!
  .then ~> @mod.konfig1.meta sample.meta1
  .then ~>
    tpl = view.get \block-template .content.childNodes.0.cloneNode(true)
    cls = new block.class(root: tpl, manager: @manager)
    cls.create!
      .then (bi) -> bi.attach {root: view.get(\block-root)} .then -> bi.interface!
      .then ~> @mod.konfig2 = it @
      .then ~> @mod.konfig2.init!
      .then ~> @mod.konfig2.meta sample.meta1
      .then -> console.log \done.
