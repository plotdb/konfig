# @plotdb/konfig

Config editor.


## Usage

    kfg = new konfig({...]);
    kfg.on("change", function(cfg) { ... });
    kfg.init().then(function() { ... });


### Constructor options

 - `root`: root node or CSS selector for root node.
   - root node is used to place root tab for this config.
 - `useBundle`: true if use bundle blocks, if availale. default true.
 - `meta`: meta object. see spec for more information.
 - `tab`: tab object. see spec for more information.
 - `mgr`: block manager for retrieving blocks
   - use default mgr if omitted, which always throw an Error except for blocks available in bundle.
 - `view`: name of the view renderer to use. optional, default null. possible value:
   - `simple`: simple list of control. sample DOM:
     div(ld-each="config")
   - `default`: controls with tabs. sample DOM:
     div(ld-each="tab")
       div(ld="name")
       div(ld-each="config")


### API

 - `init()`: initialization. return Promise, resolved on initialized.
 - `render()`: re-render controls
 - `get()`: get value object.
 - `set(v)`: set value object to `v`.
 - `meta()`: update `meta` object.
 - `tab()`: update `tab` object.
 - `on(event, cb(args...))`
 - `fire(event, args...)`


### Events

 - `change`: fired when value is changed. Params:
   - `value`: value object return by `get`.

### Sample Usage

    kfg = new konfig({
      root: document.body,
      meta: {
        showText: { type: 'boolean' },
        textSize: { type: 'number', range: false, min: 10, max: 64, step: 1 },
        textAlign: { type: 'choice', values: ["left", "right", "center"], default: 'left' },
        textColor: { type: 'color', tab: 'color' }
      }
    });


## Meta Specification

Check `doc/spec.md` for more information.


## License

MIT
