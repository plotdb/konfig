# Change Logs

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

