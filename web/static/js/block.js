var context;
context = function(){
  var this$ = this;
  Promise.resolve().then(function(){
    var ce;
    this$.def = {};
    configEditor.types.map(function(n){
      return this$.def[n] = {
        name: n,
        type: n
      };
    });
    this$.ce = ce = new configEditor({
      def: this$.def,
      root: container
    });
    return ce.init();
  }).then(function(){
    return this$.ce.parse();
  }).then(function(){
    return this$.ce.render();
  }).then(function(){
    return console.log('done.');
  });
  return this;
};
new context();