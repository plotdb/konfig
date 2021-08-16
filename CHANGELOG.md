# Change Logs

## v0.0.8 (upcoming)

 - add `render` interface and tweak `itf` and `block` naming in konfig design.
 - remove `data` interface since it's already passed directly into `base` block
 - remove `undefined` in `number` block ldslider initialization
 - prevent translating `undefined` in `base` block
 - support array of names in `base` block event handler
 - update documentation


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

