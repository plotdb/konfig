# popup

custom config:

 - `popup`
   - `data(d)`
     - when `d` is omitted, return `{text, data}` object with the same structure of object returned by `get()`.
     - when `d` is presented, update data to `d`.
   - `get()`: should return a promise which resolves either a text, or an object with following structure:
     - `text`: text for display
     - `data`: actual data

ui: use ldview.

 - ld=button: a button for triggering popup, with its content for displaying given text.
