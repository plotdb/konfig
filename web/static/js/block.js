bmgr.init().then(function(){
  return Promise.all(['choice', 'boolean', 'palette', 'color'].map(function(n){
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
  return ['choice', 'boolean', 'palette', 'color'].map(function(n){
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