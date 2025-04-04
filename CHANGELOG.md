# Change Logs

## v4.9.30

 - fix bug: set may lead to inconsistency between widget internal value and konfig value due to widget limitation.


## v4.9.29

 - add `note` widget for informative purpose
 - construct tab in `_build-ctrl` if tab provided and if necessary recursively
 - make `meta()` return (clone of) `meta` when no parameter is provided
 - prevent infinite recursion by checking equality between object and value in iteration


## v4.9.28

 - fix bug: provided tab should be kept without be pruned.
 - fix bug: incorrect variable used when build-tab


## v4.9.27

 - fix bug: input box in multiline widget doesn't work


## v4.9.26

 - tweak base header vertical alignment
 - rewrite `paragraph` widget as a plain textarea.
 - port original paragraph to `multiline` widget.
 - add `multiline` in demo page.
 - tweak layout in demo page.


## v4.9.25

 - paragraph widget:
   - enlarge paragraph widget dialog
   - auto focus paragraph widget dialog
   - use mini style ldcover
   - use non-in-place, non-resident dialog to prevent being scoped in parent container


## v4.9.24

 - fix bug: `check-limited` doesn't work for initial value in `number` and `choice` widgets


## v4.9.23

 - detacth controls when clear rebuilding all controls
 - font widfget: destroy ldcover when widget is destroyed
 - upgrade dependencies


## v4.9.22

 - choice widget: check limitation only if `limit` is defined and is not false.


## v4.9.21

 - add aria-label in select element in choice widget
 - font widget:
   - don't wait for view.init to speed up initialization
   - set `init-render` of chooser constructor param to false to speed up initialization
   - skip `chooser.init` so metadata can be provided later in child block.
   - provide cover dom directly so child block doesn't have to wait until parent view inited.


## v4.9.20

 - fix bug: `widget.set` doesn't update values in konfig object.
 - upgrade devdependencies


## v4.9.19

 - fix bug: check config corresponding ctrl for existency before using it to prevent from exception.
 - warn when setting config without corresponding meta / ctrl.


## v4.9.18

 - font widget: use fallback font object when font can't be found.


## v4.9.17

 - font widget: fix bug: in `fobj`, ensure a dummy font object to prevent accessing null object
 - upload widget: support legacy file object with only `result` (dataurl) stored.


## v4.9.16

 - font widget:
   - adapt data source
   - support font object from saved asset file
   - use `serialize` in `get` and `set` api
   - use `fobj` for `object` api
   - prevent race condition when updating `font-name`
   - get `digest` and `key` for uploaded fonts after chooser dialog is resolved
   - add `title` for tooltip in font button


## v4.9.15

 - keep additional members in meta by a customized deep clone function.
 - copy meta in constructor
 - upload widget: in `set` / `object`, update file object with `blob` and `dataurl` if available


## v4.9.14

 - fix bug: number widget: `disableLimit` option doesn't work as expected


## v4.9.13

 - prevent set from running if build is running again.
 - fix bug: `config` field doesn't work when calling `meta`
 - support `disableLimit` option in `number` and `choice` widget


## v4.9.12

 - call `set` during `building`, but add `build` option to determine that it's inside `build` so don't wait for `ensure-built`.


## v4.9.11

 - fix bug: font widget: access a variable that is not in scope
 - upload widget:
   - rename `hkey` to `digest`
   - add `digest` dataSource api requiremnet for retrieving blob digest
   - add additional field `idx` in file object as a reference of the original order
   - digest file object
   - check `digest` change to fire `change` event if necessary when updating `digest` field


## v4.9.10

 - font widget: use `syncInit` to pass widget interface to child.


## v4.9.9

 - font widget: correctly support `limit` with cached font loading


## v4.9.8

 - update limited function of `number` and `choice` for initializing rendering


## v4.9.7

 - prevent re-entry of `build` when build is already running


## v4.9.6

 - upgrade `@xlfont/choose` and rebuild for font widget


## v4.9.5

 - upload widget: clone input object to prevent pollution


## v4.9.4

 - set config along with build / meta should be done after built to prevent a deadlock.


## v4.9.3

 - call `ensure-built` when `set` is called to ensure widgets are ready to be used.
 - ensure `build` return a Promise so `meta` resolves after built.


## v4.9.2

 - check if value is an object before traverse into it in set / merge
 - provide warning when an attempt to traverse a non-object value is made due to config issue


## v4.9.1

 - upgrade @xlfont/choose for url hinting feature
 - respect url hint when constructing xfc chooser in font widget.


## v4.9.0

 - support top-down `action` (simply by document it) for host to control widgets by exposed APIs.
 - support bottom-up `action` event for host to accept action requests from widgets.


## v4.8.25

 - add `limited` api and support `limited` feature in `number` and `choice` fields.


## v4.8.24

 - color widget: normalize default palette, color and picker index in both meta update and initialization steps.


## v4.8.23

 - fix bug: widgets disappear randomly after meta is updated multiple times with default views.


## v4.8.22

 - fix bug: `ensureBuilt()` behaves like `!ensuretBuilt()`


## v4.8.21

 - add `ensureBuilt()` api and update document
 - fix bug: update meta multiple times may lead to unexpected result when calling `obj()` between konfig rebuilding.


## v4.8.20

 - `choice` widget: support object as values


## v4.8.19

 - `color` widget: correctly initialize palette and color index.


## v4.8.18

 - `color` widget: add add/remove color button in picker


## v4.8.17

 - `font` widget: fix bug: font object should not be updated if user cancel from choosing font.


## v4.8.16

 - remove unnecessary log


## v4.8.15

 - `font` widget: should return `null` if get object fails.


## v4.8.14

 - `font` widget: properly handle exception from font loading failure


## v4.8.13

 - in widgets `boolean`, `choice`, `palette`, `text`:
   - update `meta` related update code and prepare `_meta` for base widget.
 - `base` widget: check `_meta` for existence befor using


## v4.8.12

 - `upload` widget:
   - support data source for saving / loading files.


## v4.8.11

 - wrap widget.object in Promise to prevent failure if non-Promise data is returned.


## v4.8.10

 - `palette` widget:
   - prevent ldpp from re-constructing due to multiple adjacent click events
   - toggle specific tab explicitly to prevent from unexpected tab toggling


## v4.8.9

 - `font` widget: check default object againt empty to prevent serialization issue


## v4.8.8

 - `font` widget: return default object if font is not available.


## v4.8.7

 - add `ldfile` dev module for upload widget 
 - `upload` widget: convert uploaded files into dataurl in widget to prevent config serialization issue.


## v4.8.6

 - `text` widget: support preset menu
 - `font` widget: remove `z-float` class to maintain correct z order among widgets
 - add `format` widget for d3-format style formatting with presets


## v4.8.5

 - `palette` widget: view palette should still set current palette for potential following editing


## v4.8.4

 - support customized color value in color widget


## v4.8.3

 - fix bug: `font` widget: access undefined object if no config given.


## v4.8.2

 - `palette` widget: support view / edit toggling


## v4.8.1

 - upgrade dependencies
 - update bunlder based on dependencies upgrade
 - `palette` widget: toggle editor on when clicking


## v4.8.0

 - support `reset` API
 - fix bug: `quantity` widget incorrectly parse input value for unit, leading empty unit.
   - tweak parser regex and fallback to default unit if no unit found
 - fix bug: `quantity` widget doesn't update unit ui after value set


## v4.7.7

 - upgrade ldpalettepicker for tag feature
 - tweak ldpalettepicker widget height


## v4.7.6

 - fix bug: `font` widget should initialize `font` object with default function.


## v4.7.5

 - fix bug: always clear objps array after `obj()` even if promise rejects.
 - npm audit fix to resolve vulnerabilities


## v4.7.4

 - fix bug: name of builtin widgets inside bundle are incorrect


## v4.7.3

 - fix bug: incorrect widgets (bootstrap) are used as default widgets, causing recursive extend


## v4.7.2

 - use correct naming for both default and bootstrap widget in both separated widget files and bundle js


## v4.7.1

 - replace `master` in tools with `main` to align with 4.7.0 version changes.


## v4.7.0

 - include widgets separately in dist folder
 - use `main` to replace `master`


## v4.6.0

 - fix bug: color widget: cant input value into input box by hand correctly
 - support `currentColor` in color widget
 - add quantity widget
 - support `default` in font widget
 - extend widget spec with `object(v)` API
 - add `interface()` API for retrieving widget interface
 - add `obj()` API for retrieving config corresponding objects.
 - color widget:
   - currentColor by default on now.
   - tweak dropdown button size
   - take care of `currentColor` and `transparent` value in default field
 - quantity widget: tweak unit dropdown toggler alignment
 - font widget: tweak text size


## v4.5.1

 - add `@xlfont/choose` and `@xlfont/load` for correctly building


## v4.5.0

 - support complete config tree via root tab (tab with depth = 0)


## v4.4.1

 - bug fix: get function in font widget should return font object if available
 - bug fix: color key in palette widget may duplicate, pointing to the same node to be removed.


## v4.4.0

 - add `default()` api for getting default value from konfig meta.
 - support addition option in `set()` api for setting config with different methods ( such as append new config to the old config )
 - add `konfig.append()` class method for merging config objects
 - extend widget api with `meta()` and `default()` api in spec.
 - update default widgets with `meta()` and `default()` api.


## v4.3.0

 - font widget:
   - popup should not be in-place
   - support default value
   - get return minimal data from xlfont
 - support passing `meta` object directly into `meta()` api
 - use `ctx()` to replace `setCtx()` with object type `view` definition
 - return `_view` even if `clear` is true for builtin views, since there is no need to re-generate ldview for builtin views.
 - support `config` in `meta()` and `build()` for instantly reconfig after meta updated.
 - `meta()` should check for type of `meta.type` for parameter analysis
 - return cloned config object in change event to prevent pollution from outside
 - update dev dependencies to prevent vulnerability warning


## v4.2.11

 - consider both src and des type in konfig.merge to make konfig merge simpler


## v4.2.10

 - bug fix: `ns` in block def is not used to get a block


## v4.2.9

 - bug fix: `ns` in block def is not resolved in `typemap`


## v4.2.8

 - bug fix: recursive `set` should read value from `nval` instead of the root `nv`.


## v4.2.7

 - upgrade dependencies
 - bug fix: `set` should also update widgets
 - bug fix: color widget: when updating color, should use `ldcp.set-color` instead of `ldcp.set`
 - bug fix: boolean widget: when updating boolean, should render widget
 - bug fix: when setting value, widgets should also be updated and rendered


## v4.2.6

 - pass parameter into functional view


## v4.2.5

 - in recursive view, keep template and use cloned version of template for any rebuilding


## v4.2.4

 - add `ldbutton` dependency for palette picker
 - make css of `ldslider` and `ldbutton` global for global ldpalettepicker


## v4.2.3

 - palette widget should use `default` instead of `palette` as its default value 
 - lazy-load `all.palettes.js` and load it only if necessary


## v4.2.2

 - add an option for regenerate view
 - always regenerate view when build with clear option on


## v4.2.1

 - rebuild and remove useless log


## v4.2.0

 - support function as view parameter, with `{root, ctrls, tabs}` as this object.
 - use `{root, ctrls, tabs}` as view context
 - bundler output to standard out.
 - pass changed id and value to `update` and `change` event.
 - support `meta` in widget for re-configuring


## v4.1.0

 - add missing `ldview` lib in boolean widget
 - batch attach widgets
 - add `konfig.merge` API


## v4.0.3

 - remove log in `boolean` widget
 - upgrade `@plotdb/rescope` and `@plotdb/csscope` for running in nodejs


## v4.0.2

 - fix bug: in recursive view, ctx should be defined outside view config to prevent infinite recursive call.


## v4.0.1

 - fix ldpp include path in palette blocks
 - rebuild dist for correct version of lib inclusion


## v4.0.0

 - add `main` field in `package.json`.
 - upgrade modules
 - patch test code to make it work with upgraded modules
 - add `@plotdb/semver` to make things work
 - release with compact directory structure


## v3.0.0

 - upgrade `@plotdb/block` and `@plotdb/rescope` for bug fixing
 - adopt `@xlfont` for font picker
 - upgrade modules
 - adopt `@plotdb/block` v4 syntax
 - add bunlder sample


## v2.0.2

 - upgrade rescope for bug fixing


## v2.0.1

 - replace `konfig.js`, `konfig.min.js` with `index.js` and `index.min.js`


## v2.0.0

 - upgrade block modules


## v1.2.10

 - add `aria-label` in controls with input for accessibility


## v1.2.9

 - rebuild blocks for fixing incorrectly removed code
 - upgrade `@zbryikt/template` for inline script minification bug fixing


## v1.2.8

 - minify inline script and style.
 - mangle and compress minified output.


## v1.2.7

 - lazy init ldpp, and init with vscroll to improve performance
 - update blocks to use minimized version of lib files


## v1.2.6

 - paragraph ctrl remove `inline` class to prevent from conflict of new ldcover feature


## v1.2.5

 - accept string palettes option in in palette ctrl and by default use `all` palettes from all.palettes.js


## v1.2.4

 - add button ctrl


## v1.2.3

 - enable auto direction detection in ldcolorpicker


## v1.2.2

 - support autotab ( use group id as name )


## v1.2.1

 - support default value in boolean ( default false )
 - support default value in color ( default black )
 - support context in colorpicker ( default random )
 - add default palette for colorpicker
 - show warning if use `from` in number ( which should be `default` )
 - in number ctrl, pass `default` as `from` ( and optionally `to` if default is an object ) to ldslider
 - when calling `build`, update only after built, not in between each `prepare-ctrl`.
 - resolve config object for init call. ( based on proxise 0.1.3 )
 - upgrade proxise dependency to 0.1.3


## v1.2.0

 - make all bootstrap config size relative to container font size
 - add config for panel font size to see the relative size effect


## v1.1.0

 - upgrade dependencies.
 - change ldCover to ldcover due to ldcover upgrade.
 - remove unnecessary dependencies and fix ldcover module path.


## v1.0.3

 - upgrade dependencies


## v1.0.2

 - enable debouncing switch


## v1.0.1

 - fix typo
 - add missing attributes in implicit tab object


## v1.0.0

 - rename `config` in view presets to `ctrl` to better align the spec naming 
 - update block dependency to `2.0.5`, which uses new registry syntax ( breaking change ).
 - support customized views
 - add nested (parent) information in tab
 - add recursive config panel example
 - add depth info in tab
 - reorg tab builder code for supporting both list and object type tab metadata.
 - add recurse view
 - update README for recursive view and fix some incorrect information


## v0.0.18

 - fix bug: check parentNode for existence before using it
 - clear also tabobj when force cleaning
 - force clean when rebuild


## v0.0.17

 - tweak `color` config


## v0.0.16

 - upgrade ldpalettepicker and rebuild palette widget ( to 3.1.1 )


## v0.0.15

 - upgrade ldpalettepicker and rebuild palette widget


## v0.0.14

 - popup by default show `config` instead of `...`
 - use ✎ for switch in bootstrap/number


## v0.0.13

 - update for rebuild missed by 0.0.12


## v0.0.12

 - update palette for `ldpalettepicker` 3.0.3


## v0.0.11

 - move util view to class level.
 - update render for actually rendering thing, and separate code from build
 - fix bug in default popup block


## v0.0.10

 - use semantic module naming in dependencies


## v0.0.9

 - by default enabling clusterizejs in palette picker. it will still be enabled only if clusterize.js is available.


## v0.0.8

 - add `render` interface and tweak `itf` and `block` naming in konfig design.
 - remove `data` interface since it's already passed directly into `base` block
 - remove `undefined` in `number` block ldslider initialization
 - prevent translating `undefined` in `base` block
 - support array of names in `base` block event handler
 - update documentation
 - fix bug: don't traverse into non-object in prepare-ctrl / prepare-tab
 - add `view` option for default view handler


## v0.0.7

 - support `palette` and `palettes` in palette directive.
 - upgrade modules for correct work in @plotdb/block


## v0.0.6

 - fix bug: popup.data should not be promise-based.


## v0.0.5

 - bug fix: block name should use `meta.type`, instead of `meta.id`
 - add `path` information in registry error
 - use `...` in `popup` directive for display text, if text is not defined.


## v0.0.4

 - add `popup` directive


## v0.0.3

 - correctly rename all config to konfig


## v0.0.2

 - remove dependencies temporarily ( choosefont.js, xl-fontload )

