# upload widget

Value of this widget is an array of files where each file is an object with following fields:

 - `name`: name field from JS File object.
 - `size`: size field from JS File object.
 - `type`: type field from JS File object.
 - `lastModified`: lastModified field from JS File object.

Additional fields are also available via `object()` api:

 - `blob`: Blob object of this file
 - `dataurl`: Corresponding data url for this file.

For example, following is a sample value returned from `widget.get()`:

    [{name: 'sample.html', size: 0, type: 'text/html', lastModified: 1682755735156}]

and following is a sample value returne frmo `widget.object()`:

    [{
      name: 'sample.html', size: 0, type: 'text/html', lastModified: 1682755735156,
      blob: [...blob object ...], dataurl: "data:text/html;base64,...."
    }]

Host application can pass additional data to this widget through `data` parameter as an object with following fields:

 - `dataSource`: interface for accessing file stored remotely. It's an object with following fields:
   - `getKey(f)`: return a Promise resolving with the key corresponding to given file object `f`.
   - `getBlob(f)`: return a Promise resolving with the blob corresponding to given file object `f`.
