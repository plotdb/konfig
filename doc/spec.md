# Overview

`@plotdb/konfig` is for configuring with interface. For this purpose, we have:

 - `ctrl`: a widget for user to input certain information
   - `ctrl definition object`: config ( type, name, size, value range, ui order, etc ) for this ctrl
   - `block`: logic + interface definition in `@plotdb/block` format.
 - `meta`: a set of widgets in defined arrangement that defines how information are organized
 - `tab`: a different view of ctrl, mainly for how ctrls are arranged in user interface.


# Ctrl definition

A control is a visually controllable widget for user to input anything, such as a number, string, a font or an animation.

A control can be defined by:

 - a ctrl definition object
 - a block handling the specified type

## Ctrl definition object

This is an object with following fields:

 - `name`: string, verbose name for this control. use `id` if omitted
 - `id`: string, id for this control. optional, may determined externally.
 - `type`: string, type of this control. mapped to a specific block internally.
 - `block`: explicit definition of block. overwrite `type` if provided. this is an object with following members:
   - `name`: block name.
   - `version`: block version.
   - `path`: block path.
 - `tab`: id for - if any - a group containing this control.
 - `order`: number for order of this control in specific tab. optional. random order if omitted.
   - lower order mean higher priority.
 - `hidden`: default false. true to disable this widget.

Specific control can extend this interface but to prevent future conflict, implementation should *avoid using* words starting with `_`.


## Ctrl type block 

`@plotdb/konfig` identifies a specific `@plotdb/block` object via the `block` or `type` value in an ctrl definition object.

This block follows `@plotdb/block` spec, and should provide an interface with following methods:

 - `get`: get current value
 - `set(value)`: set value of this control
 - `on(event, cb(args...))`: register event handler for events fired by this control
 - `fire(event, args...)`: fire an event to this control
 - `render()`: update ui of this control

For detail about how to implement a block, check `@plotdb/konfig.widget.default`'s base block for example. ( available in `web/src/pug/block/default/base` )


### Base block

To make implementation easier, `@plotdb/konfig` provides a block set `@plotdb/konfig.widget.default` with a base block in path `base` which has already implemented above methods. Yet after extending it, you should still implement following mechanism:

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

`@plotdb/konfig` has provided blocks for using with basic types such as `number`, `choice` in the `@plotdb/konfig.widget.default` package, and these blocks are implemented with UI / Logic separated, so you can simply extend corresponding widgets to overwrite their default interface without rewriting their logic.

For example, this extends `number` block and overwrite its `config` plug with a simply `input` element:

    div
      div(plug="config"): input(ld="ldrs")
      script(type="@plotdb/block").
        (function() { return {
          pkg: {extent: {name: "@plotdb/konfig.widget.default", version: "master", path: "number"}}
        }});

All widgets use `ldview` directive to separate interface from logic so you should still follow the spec of individual blocks to make things work.


## Meta: Tree of Ctrls

User can compose return values of a set of controls into a nested object by defining a meta object `meta` using hash keys as paths of value from specpfic control. For example, following `meta`:

    meta = {
      text: { type: "color", ... }
      background: { type: "color", ... }
    };

may provide result object like following:

    {text: "#fff", background: "#000"}


It can be nested:

    meta = {
      text: {
        color: {type: "color", ...}
        size: {type: "unit-value", ...}
      },
      background: {
        color: {type: "color", ...}
        image: {type: "text", ...}
      }
    }

which may provide following result:

    {
      text: {
        color: "#fff",
        size: "12px"
      },
      background: {
        color: "#000",
        image: "https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png"
      }
    }


Alternatively, you can specify additional information, including `tab`, `order` and `hidden` for an entire subtree. To distinguish config with other controls, use `child` field to hold sub controls:

    meta = {
      text: {
        child: {
          color: {type: "color", ...}
          size: {type: "unit-value", ...}
        }
        tab: '...', order: '...', hidden: false
      }, ...
    }

`@plotdb/konfig` use `type` to recognize a control, and use `child` to recognize such subtree so you should avoid using `type` and `child` as control id. However, you can still define a control with id `child` by putting it in `child`:

    meta = {
      text: {
        child: {
          child: {type: "color", ...}
        }
      }, ...
    }

Generally speaking, subtree without `child` is just a shorthand. Always put controls in `child` if you want to prevent ambiguity.


## Tab: Group of Ctrls 

While meta are constructed based on the hierarchy of the expected result object, we may want controls to be shown in different order or grouping. This is done by setting `tab` and `order` members in ctrl definition object.

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
 - `child`: tab list as subtab of this tab.
 - `order`: order of this tab in its parent. default the order of this tab in its parent's child list.

Providing a `tabs` object and a `meta` object, one can manually construct an edit panel, or use `@plotdb/konfig` to construct one.


## Draft

original definition ( used in loading.io )

    {
      a: name: '...', type: '...', default: '...', priority: 0.5, tab: '...'
      ..
    }

proposed improving: ( TBD )

    {
      tab-a: # group ctrls in one named tab
        name: '...', type: 'group', priority: 0.5
        ctrl: {}
      tab-b:
        name: '...', type: 'group',
        collapsed: true # default show / not show
        priority: undefined # ctrls without priorities are sorted by name, placed after ctrls with priority
        ctrl:
          inp-a: { name: '...', type: '...', default: '...', priority: 0.5 }
      # stray ctrl can still have tab. overwrite when conflict ( make extension easier )
      inp-b: { name: '...', type: '...', default: '...', priority: 0.5, tab: 'tab-a' }
    }

## TODO

 - 這個解析還需要再想: 定義 -> 控制項物件 -> 分組資訊
   - 分組如何分? 如何處理命名衝突? 多層式如何更新資料?

