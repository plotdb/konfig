# Overview

`@plotdb/konfig` is for configuring with user interface. For this purpose, we have:

 - `meta`: a set of widgets defining how information is organized
 - `ctrl`: a widget for user to input certain information
   - `ctrl definition object`: config ( type, name, size, value range, ui order, etc ) for this ctrl
   - `block`: logic + interface definition in `@plotdb/block` format.
 - `tab`: a different view of ctrl, mainly for how ctrls are arranged in user interface.


# Ctrl definition

A control is a visually controllable widget for user to input anything, such as a number, string, a font or an animation.

A control can be defined by:

 - a ctrl definition object
 - a block handling the specified type

## Ctrl definition object

This is an object with following fields:

 - `name`: verbose name for this control. use `id` if omitted
 - `desc`: detail description of this field. optional
 - `hint`: hint of this field. optional. kinda secondary description, compared to `desc`.
 - `weight`: relative size of this ctrl. hint for rendering. default 1. optional
 - `id`: string, id for this control. optional, may determined externally.
 - `type`: string, type of this control. mapped to a specific block internally.
 - `block`: explicit definition of block. overwrite `type` if provided. this is an object with following members:
   - `ns`: namespace.
   - `name`: block name.
   - `version`: block version.
   - `path`: block path.
   - `type`: block type (should be `block`, and will be if omitted.)
 - `tab`: id for - if any - a group containing this control.
 - `order`: number for order of this control in specific tab. optional. random order if omitted.
   - lower order means higher priority.
 - `hidden`: default false. true to hide this widget.
 - `default`: default value for this config.
   - should be a serializable value such as plain object, string, number, etc.
   - this ensures a default object reconstruction via object tree traverse, even without using `@plotdb/konfig`.
   - it's still possible to have computed value from ctrls. users should be always aware of this.

It's for and by the view provided by user (or from default views) how `name`, `desc` and `hint` are used and rendered.

Controls can extend this interface but to prevent future conflict, it should *avoid using* words with `_` prefix.


## Ctrl type block 

A `@plotdb/block` object can be found for each ctrl definition object from its `block` or `type` value.

This block should provide an interface with following methods:

 - `get()`: get current value
 - `set(value)`: set value of this control
 - `meta(meta)`: update meta of this control
 - `limited()`: return true if current value is limited (such as, should not be used to generate result)
 - `default()`: return default value from this control
 - `on(event, cb(args...))`: register event handler for events fired by this control
 - `fire(event, args...)`: fire an event to this control
 - `render()`: update ui of this control
 - `object(v)`: convert a serializable `v` into corresponding object
   - return a Promise resolved with the corresponding object
 - `action`: this should be an object with fields of custom action to trigger by its host. for example:

    action: {open: function(name) { ... }}


To implement a block, check `@plotdb/konfig.widget.default`'s base block for example. ( available in `web/src/pug/block/default/base` )


### Base block

To make it easier to implement a block, `@plotdb/konfig` provides a block set `@plotdb/konfig.widget.default` with a base block in path `base` which has already implemented above methods. You can extend it directly to make your own widget.  However, you should still implement following mechanism:

 - for logic: init base block via `init` event through pubsub, with an object containing following:
   - `get`: same with the above `get`.
   - `set`: same with the above `set`.
   - `render`: same with the above `set`.
 - for interface: fill corresponding DOM for following plugs if necessary:
   - `config`: widget body
   - `ctrl`: additional control in head bar.

Here is a sample implementation of a block for simple data reflection which extends `base` block ( in `pug` ):

  div
    div(plug="config"): div Some Tags
    script(type="@plotdb/block").
      (function() { return {
        /* extent the base block */
        pkg: {extent: {name: "@plotdb/konfig.widget.default", version: "master", path: "base"}},
        init: function(opt) {
          var local = {};
          /* use pubsub to fire `init` event for passing interface object to base block */
          opt.pubsub.fire(
            "init", {
              get: function() { return local.data; },
              set: function(data) { local.data = data; },
            }
          );
        }
      }});


### UI Overwrite

`@plotdb/konfig` provides blocks for basic types such as `number`, `choice` in `@plotdb/konfig.widget.default` package. These blocks are implemented with UI / Logic separated, so if you want to customize its looks and feel, you can extend them and overwrite their DOM without rewriting their logic.

For example, this extends `number` block and overwrite its `config` plug with a simply `input` element:

    div
      div(plug="config"): input(ld="ldrs")
      script(type="@plotdb/block").
        (function() { return {
          pkg: {extent: {name: "@plotdb/konfig.widget.default", version: "master", path: "number"}}
        }});

All widgets use `ldview` directive to separate interface from logic so you should still follow the spec of individual blocks to make things work.


## Meta: Tree of Ctrls

Values of controls can be turned into a nested object by defining a meta object `meta` with keys as paths to each value of controls. For example, following `meta`:

    meta = {
      text: { type: "color", default: "#fff", ... }
      background: { type: "color", default: "#000", ... }
    };

provides an object like following:

    {text: "#fff", background: "#000"}


It can be nested:

    meta = {
      text: {
        color: {type: "color", default: "#fff", ...}
        size: {type: "unit-number", default: {value: 12, unit: "px"}, ...}
      },
      background: {
        color: {type: "color", default: "#000", ...}
        image: {type: "text", default: "sample text", ...}
      }
    }

above nested example provides following result:

    {
      text: {
        color: "#fff",
        size: {value: 12, unit: "px"}
      },
      background: {
        color: "#000",
        image: "sample text"
      }
    }

You can also specify `tab`, `order` and `hidden` fields in the parent node:

    meta = {
      text: {
        tab: '...', order: '...', hidden: false
        color: {type: "color", ...}
        size: {type: "unit-value", ...}
        }
      }, ...
    }

However in this example it's hard to distinguish a control defintion from a config for an intermediate node. To distinguish, use `child` field to keep sub controls:

    meta = {
      text: {
        tab: '...', order: '...', hidden: false
        child: {
          color: {type: "color", ...}
          size: {type: "unit-value", ...}
        }
      }, ...
    }

`@plotdb/konfig` use `type` to recognize a control, and use `child` to recognize such an intermediate node, so you should avoid using `type` and `child` as control id. However, you can still define a control with id `child` by putting it in `child`:

    meta = {
      text: {
        child: {
          child: {type: "color", ...}
        }
      }, ...
    }

Generally speaking, intermediate node without `child` is just a shorthand. Always put controls in `child` if you want to prevent ambiguity.


## Tab: Group of Ctrls 

While meta are constructed based on the hierarchy of the expected result object, we may want controls to be shown in different order or groups. This is done by setting `tab` and `order` members in ctrl definition object.

Tabs can also be nested, and defined similarly in a separated object:

    [
      {id: "some-tab", name: "Some Tab", order: ...}, 
      {id: "another-tab", child: [ ... ]}
    ]

or, in an object:

    {
      "some-tab": { ... }, 
      "another-tab": { ..., child: { ... } }, 
    }

where a tab object contains following members:

 - `id`: id of this tab, used to be referred by controls with `tab` field.
 - `name`: verbose name of a tab.
 - `desc`: detail description of this field. optional
 - `hint`: hint of this field. optional. kinda secondary description, compared to `desc`.
 - `child`: tab list as subtab of this tab.
 - `order`: order of this tab in its parent. default the order of this tab in its parent's child list.

`name`, `desc` and `hint` are up to view about rendering.

Providing a `tabs` object and a `meta` object, one can manually construct an edit panel, or use `@plotdb/konfig` to construct one.

