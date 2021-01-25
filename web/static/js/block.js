var types;
types = ['choice', 'boolean', 'palette', 'color', 'number', 'text', 'paragraph', 'upload', 'font'];
bmgr.init().then(function(){
  return Promise.all(types.map(function(n){
    return bmgr.set({
      name: "ctrl-" + n,
      version: '0.0.1',
      block: new block['class']({
        root: "#ctrl-" + n
      })
    });
  }));
}).then(function(){
  var ce;
  ce = new configEditor({
    def: {}
  });
  return types.map(function(n){
    return bmgr.get({
      name: "ctrl-" + n,
      version: "0.0.1"
    }).then(function(it){
      return it.create();
    }).then(function(it){
      return it.attach({
        root: container
      });
    });
  });
});