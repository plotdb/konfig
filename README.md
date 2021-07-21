# @plotdb/konfig

Config editor.


## Usage


Constructor options: 

 - `root`: root node or CSS selector for root node.
   - root node is used to place root tab for this config.
 - `useBundle`: true if use bundle blocks, if availale. default true.
 - `meta`: meta object. see spec for more information.
 - `tab`: tab object. see spec for more information.
 - `mgr`: block manager for retrieving blocks
   - use default mgr if omitted, which always throw an Error except for blocks available in bundle.


API:

 - `init()`: initialization. return Promise, resolved on initialized.
 - `render()`: re-render controls
 - `get()`: get value object.
 - `set(v)`: set value object to `v`.
 - `meta()`: update `meta` object.
 - `tab()`: update `tab` object.
 - `on(event, cb(args...))`
 - `fire(event, args...)`


Events

 - `change`: fired when value is changed. Params:
   - `value`: value object return by `get`.


## License

MIT
