# Ctrl definition

A control is a visually controllable widget for user to input anything, such as a number, string, a font or an animation.

A control can be defined in an object and a corresponding block that implements it. Member for a single control:

 - `name`: string, verbose name for this control
 - `id`: string, id for this control. optional, may determined externally.
 - `type`: string, type of this control.
 - `block`: (TBD) more explicit definition which overwrite `type`. Object with following members:
   - `name`: block name.
   - `version`: block version.
 - `tab`: string for if of the tab containing this control.
 - `order`: number for order of this control in specific tab. optional. random order if omitted.
 - `hidden`: default false. true to disable this widget.

Specific control can extend this interface but to prevent future conflict, implementation should avoid using words starting with `_`.


The corresponding block of a control is implemented with the spec of `@plotdb/block`. A config block is responsible to
and should provide an interface with following methods:

 - `get`: get current value
 - `set(value)`: set value of this control
 - `on(event, cb(args...))`: register event handler for events fired by this control
 - `fire(event, args...)`: fire an event to this control


`@plotdb/config` provides a base block which has already implemented above methods. Yet after extending it, you should implement following mechanism:

 - init base block via `init` event through pubsub, with an object containing following:
   - `get`: same with the above `get`.
   - `set`: same with the above `set`.
   - `data` (TBD)

additionally, the base block provides two plugs for injecting DOM elements:

 - `config`: widget body
 - `ctrl`: additional control in head bar.


## Set of Controls / Edit

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


alternatively, you can specify additional information, including `tab`, `order` and `hidden` for an entire subtree. To distinguish config with other controls, use `child` field to hold sub controls:

    meta = {
      text: {
        child: {
          color: {type: "color", ...}
          size: {type: "unit-value", ...}
        }
        tab: '...', order: '...', hidden: false
      }, ...
    }

`@plotdb/config` use `type` to recognize a control, and use `child` to recognize such subtree so you should avoid using `type` and `child` as control id. However, you can still define a control with id `child` by putting it in `child`:

    meta = {
      text: {
        child: {
          child: {type: "color", ...}
        }
      }, ...
    }

Generally speaking, subtree without `child` is just a shorthand. Always put controls in `child` if you want to prevent ambiguity.


## Group of controls / Tabs

While meta are construct based on the hierarchy of the expected result object, we may want controls to be shown in different order or grouping. This is done by setting `tab` and `order` memebers in control's definition, yet tabs can also be nested, and defined similarly in a separated object:

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

Providing a `tabs` object and a `meta` object, one can manually construct an edit panel, or use `@plotdb/config` to construct one.


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

## Current Status

 - 建構 `config-editor` 以使用
 - 控制項放在 src/pug/ctrl, 以 @plotdb/block 格式設計.
   - 好處是
     - 模組化, 好版控, 統一規格方便理解. 相依性容易解決.
     - 不同介面如何客製? override or extend ?
 - 這個解析還需要再想: 定義 -> 控制項物件 -> 分組資訊
   - 分組如何分? 如何處理命名衝突? 多層式如何更新資料?

