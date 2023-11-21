konfig.bundle = (konfig.bundle || []).concat([{"name":"@plotdb/konfig","version":"main","path":"bootstrap/base","code":"<div><div class=\"d-flex\"><div class=\"flex-grow-1 d-flex align-items-center\"><div ld=\"name\"></div><div ld=\"hint\">?</div></div><plug name=\"ctrl\"></plug></div><plug name=\"config\"></plug><style type=\"text/css\">[ld=hint]{margin-left:.5em;width:1.2em;height:1.2em;border-radius:50%;background:rgba(0,0,0,0.1);font-size:10px;line-height:1.1em;text-align:center;cursor:pointer}</style><script type=\"@plotdb/block\">module.exports={pkg:{extend:{name:\"@plotdb/konfig\",version:\"main\",path:\"base\",dom:\"overwrite\"}}};</script></div>"},{"name":"@plotdb/konfig","version":"main","path":"bootstrap/boolean","code":"<div><div plug=\"config\"><div class=\"btn-group w-100\" ld=\"switch\"><div class=\"btn btn-outline-secondary text-success\" ld=\"true\"><i class=\"i-check\"></i></div><div class=\"btn btn-outline-secondary text-danger\" ld=\"false\"><i class=\"i-close\"></i></div></div></div><style type=\"text/css\">.btn-group .btn:hover{background:#fff}.btn-group:not(.on) .btn[ld=true]{color:transparent !important;flex:0 0 auto;background:rgba(0,0,0,0.3)}.btn-group.on .btn[ld=false]{color:transparent !important;flex:0 0 auto;background:rgba(0,0,0,0.3)}.btn{font-size:1em}</style><script type=\"@plotdb/block\">module.exports={pkg:{extend:{name:\"@plotdb/konfig\",version:\"main\",path:\"boolean\",dom:\"overwrite\"}}};</script></div>"},{"name":"@plotdb/konfig","version":"main","path":"bootstrap/button","code":"<div><div plug=\"config\"><div class=\"btn btn-outline-secondary d-block position-relative\" ld=\"button\">...</div></div><style type=\"text/css\">.btn { font-size: 1em }</style><script type=\"@plotdb/block\">module.exports={pkg:{extend:{name:\"@plotdb/konfig\",version:\"main\",path:\"button\",dom:\"overwrite\"}}};</script></div>"},{"name":"@plotdb/konfig","version":"main","path":"bootstrap/choice","code":"<div><div plug=\"config\"><select class=\"form-control\" ld=\"select\"><option ld-each=\"option\"></option></select></div><style type=\"text/css\">.form-control { font-size: 1em }</style><script type=\"@plotdb/block\">module.exports={pkg:{extend:{name:\"@plotdb/konfig\",version:\"main\",path:\"choice\",dom:\"overwrite\"}}};</script></div>"},{"name":"@plotdb/konfig","version":"main","path":"bootstrap/color","code":"<div><div plug=\"config\"><div class=\"color\"><div class=\"input-group\" ld=\"input-group\"><input class=\"form-control\" ld=\"input color\" aria-label=\"color\" style=\"z-index:0\"><div class=\"input-group-append\" ld=\"menu\"><div ld=\"indicator color\"></div><div class=\"btn btn-outline-secondary border dropdown-toggle px-2\" ld=\"dropdown\" data-toggle=\"dropdown\" style=\"z-index:1\"></div><div class=\"dropdown-menu dropdown-menu-right shadow-sm z-float\"><div class=\"dropdown-item\" t ld=\"default\">current color</div><div class=\"dropdown-item\" ld-each=\"preset\"></div></div></div></div></div></div><style type=\"text/css\">.color{position:relative}div[ld~=indicator]{pointer-events:none;top:0;bottom:0;width:.66em;margin:auto;margin-left:-1em;position:absolute;height:calc(100% - 0.5em);border-radius:.25em}.form-control{font-size:1em}.btn{font-size:1em}.input-group.no-addon .form-control{border-top-right-radius:.25em;border-bottom-right-radius:.25em}.input-group.no-addon .input-group-append .btn{width:0;padding:0;border:none !important;overflow:hidden;pointer-events:none}</style><script type=\"@plotdb/block\">module.exports={pkg:{extend:{name:\"@plotdb/konfig\",version:\"main\",path:\"color\",dom:\"overwrite\"},i18n:{en:{\"current color\":\"Foreground Color\"},\"zh-TW\":{\"current color\":\"預設前景色\"}}},init:function(n){var r,o,e,t,u;r=n.root,o=n.data,e=n.pubsub,t=n.parent;u=new ldview({root:r,init:{dropdown:function(n){var r;r=n.node;return new BSN.Dropdown(r)}},handler:{\"input-group\":function(n){var r,o;r=n.node;o=t._meta.currentColor;return r.classList.toggle(\"no-addon\",o!=null&&!o)}}});return e.on(\"render\",function(){return u.render()})}};</script></div>"},{"name":"@plotdb/konfig","version":"main","path":"bootstrap/font","code":"<div><div plug=\"config\"><div class=\"ldcv default-size\" ld=\"ldcv\"><div class=\"base\"><div class=\"inner\"><div class=\"xfc toolbar d-flex flex-column h-100\"><div class=\"xfc-head d-flex px-3 py-2 border-bottom\"><div class=\"mr-2 text-left\"><div class=\"text-muted\" style=\"font-size:12px\" t>Category</div><div class=\"dropdown\"><div class=\"btn btn-sm btn-outline-secondary dropdown-toggle text-capitalize\" ld=\"cur-cat\" style=\"min-width:5em\" data-toggle=\"dropdown\"></div><div class=\"dropdown-menu shadow-sm\" style=\"max-height:50vh;overscroll-behavior:contain;overflow-y:scroll\"><div class=\"dropdown-item text-capitalize\" ld-each=\"category\"></div></div></div></div><div class=\"mr-2 text-left\"><div class=\"text-muted\" style=\"font-size:12px\" t>Subset</div><div class=\"dropdown mr-2\"><div class=\"btn btn-sm btn-outline-secondary dropdown-toggle text-capitalize\" ld=\"cur-subset\" style=\"min-width:5em\" data-toggle=\"dropdown\"></div><div class=\"dropdown-menu shadow-sm\" style=\"max-height:50vh;overscroll-behavior:contain;overflow-y:scroll\"><div class=\"dropdown-item text-capitalize\" ld-each=\"subset\"></div></div></div></div><div class=\"flex-grow-1 text-left\"><div class=\"text-muted\" style=\"font-size:12px\" t>Name</div><input class=\"form-control form-control-sm\" ld=\"search\" placeholder=\"Search...\"></div><div class=\"text-nowrap\"><div class=\"text-muted\" style=\"font-size:12px\">&nbsp;</div><div class=\"btn btn-sm btn-text mx-2\" t>or</div><div class=\"btn btn-sm btn-outline-secondary btn-upload\" ld=\"upload-button\"><span t>Use Your Own Font</span><input type=\"file\" ld=\"upload\"><i class=\"i-lock ml-2\"></i></div></div><div class=\"ml-2\"><div class=\"text-muted\" style=\"font-size:12px\">&nbsp;</div><div class=\"btn btn-sm btn-outline-secondary\" t ld=\"cancel\">Cancel</div></div></div><div class=\"xfc-content flex-grow-1\" style=\"overflow-y:hidden\"><div class=\"h-100\" ld=\"font-list\"><div class=\"xfc-font\" ld-each=\"font\"><div class=\"preview\" ld=\"preview\"></div><div class=\"name\" ld=\"name\"></div></div></div></div></div></div></div></div><div class=\"btn-group d-flex\"><div class=\"btn btn-outline-secondary d-block\" ld=\"button\"><span ld=\"font-name\">...</span></div><div class=\"btn-group\"><div class=\"btn btn btn-outline-secondary dropdown-toggle\" ld=\"dropdown\" data-toggle=\"dropdown\"><div class=\"dropdown-menu dropdown-menu-right shadow-sm\"><div class=\"dropdown-item\" t ld=\"system\" data-name=\"inherit\">default</div></div></div></div></div></div><style type=\"text/css\">[ld=button]{position:relative}.btn{font-size:1em}.choosefont .item .img{background-image:url(\"/assets/lib/choosefont.js/main/fontinfo/sprite.min.png\")}</style><script type=\"@plotdb/block\">module.exports={pkg:{extend:{name:\"@plotdb/konfig\",version:\"main\",path:\"font\",dom:\"overwrite\"}},init:function(n){var r,e,o,t,i;r=n.root,e=n.data,o=n.pubsub,t=n.parent;if(!r){return}i=new ldview({root:r,init:{dropdown:function(n){var r;r=n.node;return new BSN.Dropdown(r)}}});return o.on(\"render\",function(){return i.render()})}};</script></div>"},{"name":"@plotdb/konfig","version":"main","path":"bootstrap/format","code":"<div><div plug=\"config\"><div class=\"input-group\"><input class=\"form-control\" ld=\"input\" aria-label=\"text\"><div class=\"input-group-append\" ld=\"menu\"><div class=\"btn btn-outline-secondary border dropdown-toggle px-2\" ld=\"dropdown\" data-toggle=\"dropdown\" style=\"z-index:1\"></div><div class=\"dropdown-menu dropdown-menu-right shadow-sm z-float\"><div class=\"dropdown-item\" ld-each=\"preset\"></div></div></div></div></div><style type=\"text/css\">.form-control{font-size:1em}</style><script type=\"@plotdb/block\">module.exports={pkg:{extend:{name:\"@plotdb/konfig\",version:\"main\",path:\"text\",dom:\"overwrite\"}},init:function(e){var n,r,a,t,o;n=e.root,r=e.data,a=e.pubsub,t=e.parent;t._values=[{name:\"1235\",value:\"d\"},{name:\"1023.46\",value:\".2r\"},{name:\"1,023.46\",value:\",.2r\"},{name:\"1.25M\",value:\".2s\"},{name:\"12%\",value:\".0%\"},{name:\"12.35%\",value:\".2%\"}];o=new ldview({root:n,init:{dropdown:function(e){var n;n=e.node;return new BSN.Dropdown(n)}},handler:{menu:function(e){var n,r,a;n=e.node,r=e.local;if(!r.parent){r.parent=n.parentNode}a=!!(t._values&&t._values.length);if(a&&!n.parentNode){return n.parentNode.appendChild(n)}else if(!a&&n.parentNode){return n.parentNode.removeChild(n)}}}});return a.on(\"render\",function(){return o.render()})}};</script></div>"},{"name":"@plotdb/konfig","version":"main","path":"bootstrap/number","code":"<div><div plug=\"config\"><input class=\"ldrs auto\" data-class=\"form-control\" ld=\"ldrs\" aria-label=\"number\"></div><div plug=\"ctrl\"><div class=\"clickable\" ld=\"switch\"><i class=\"i-pen\"></i></div></div><script type=\"@plotdb/block\">module.exports={pkg:{extend:{name:\"@plotdb/konfig\",version:\"main\",path:\"number\",dom:\"overwrite\"}}};</script></div>"},{"name":"@plotdb/konfig","version":"main","path":"bootstrap/palette","code":"<div><style type=\"text/css\">.ctrl{opacity:0;transition:opacity .15s ease-in-out;cursor:pointer}.ctrl:hover{opacity:1}</style><div ld-scope plug=\"config\"><div class=\"ldp\"><div class=\"colors\"><div class=\"color\" ld-each=\"color\"></div></div><div class=\"ctrl\" style=\"display:flex;gap:1em\"><div ld=\"ldp\" data-action=\"view\"><i class=\"i-eye\"></i></div><div ld=\"ldp\" data-action=\"edit\"><i class=\"i-pen\"></i></div></div></div><div class=\"ldcv default-size\" ld=\"ldcv\"><div class=\"base\" style=\"height:35em\"><div class=\"inner\"><div class=\"ldpp\" ldpp><div class=\"header d-flex justify-content-center flex-wrap g-2\"><div style=\"white-space:nowrap;flex:3 0 auto;width:10em\"><div class=\"input-group\"><input class=\"form-control\" data-tag=\"search\"><div class=\"input-group-append\"><div class=\"btn btn-outline-dark dropdown-toggle\" data-toggle=\"dropdown\"><span t=\"filter\">&nbsp;</span></div><div class=\"dropdown-menu shadow-sm\" data-tag=\"categories\"><a class=\"dropdown-item\" href=\"#\" data-cat=\"\"><span t=\"all\"></span></a><div class=\"dropdown-divider\"></div><a class=\"dropdown-item\" href=\"#\" data-cat=\"artwork\"><span t=\"artwork\"></span></a><a class=\"dropdown-item\" href=\"#\" data-cat=\"brand\"><span t=\"brand\"></span></a><a class=\"dropdown-item\" href=\"#\" data-cat=\"concept\"><span t=\"concept\"></span></a><div class=\"dropdown-divider\"></div><a class=\"dropdown-item\" href=\"#\" data-cat=\"gradient\"><span t=\"gradient\"></span></a><a class=\"dropdown-item\" href=\"#\" data-cat=\"qualitative\"><span t=\"qualitative\"></span></a><a class=\"dropdown-item\" href=\"#\" data-cat=\"diverging\"><span t=\"diverging\"></span></a><a class=\"dropdown-item\" href=\"#\" data-cat=\"colorbrew\"><span t=\"colorbrew\"></span></a></div></div></div></div><div style=\"flex:5 0 1px\"></div><div class=\"d-flex justify-content-end text-nowrap\" style=\"flex:1 0 auto;width:fit-content\"><div class=\"btn btn-primary\" data-panel=\"view\"><span t=\"view\"></span></div><div class=\"btn btn-text\" data-panel=\"mypal\"><span t=\"my pals\"></span></div><div class=\"btn btn-text\" data-panel=\"edit\"><span t=\"edit\"></span></div></div></div><div class=\"panels\"><div class=\"panel active clusterize-scroll\" data-panel=\"view\" style=\"max-height:600px\"><div class=\"inner clusterize-content\"></div></div><div class=\"panel clusterize-scroll\" data-panel=\"mypal\" style=\"max-height:600px\"><div class=\"inner clusterize-content\"></div><div class=\"btn btn-primary btn-block ld-over-inverse btn-load\"><span t=\"load more\"></span><div class=\"ld ldld ldbtn sm\"></div></div></div><div class=\"panel\" data-panel=\"edit\"><div class=\"ldp\"><div class=\"name\"></div><div class=\"colors\"></div></div><div class=\"edit\"><div class=\"inner\"><div class=\"row\"><div class=\"col-sm-6 mb-2\"><div class=\"ldcolorpicker no-border no-palette\"></div></div><div class=\"col-sm-6 mb-2\"><div class=\"d-flex g-2 mb-2\"><div class=\"w-50\"><select class=\"form-control form-control-local-sm\" value=\"rgb\"><option value=\"rgb\">RGB</option><option value=\"hsl\">HSL</option><option value=\"hcl\">HCL</option></select></div><div class=\"w-100\"><input class=\"form-control form-control-local-sm value\" placeholder=\"Hex Value\" data-tag=\"hex\" style=\"margin:0\"></div></div><div class=\"config g-2 active\" data-tag=\"rgb\"><div class=\"w-100\"><div class=\"label-group\"><span>Red</span></div><input class=\"ldrs sm auto\" data-tag=\"rgb-r\"><div class=\"label-group\"><span>Green</span></div><input class=\"ldrs sm auto\" data-tag=\"rgb-g\"><div class=\"label-group\"><span>Blue</span></div><input class=\"ldrs sm auto\" data-tag=\"rgb-b\"></div><div class=\"w-50\"><input class=\"value form-control form-control-local-sm\" data-tag=\"rgb-r\"><input class=\"value form-control form-control-local-sm\" data-tag=\"rgb-g\"><input class=\"value form-control form-control-local-sm\" data-tag=\"rgb-b\"></div></div><div class=\"config g-2\" data-tag=\"hsl\"><div class=\"w-100\"><div class=\"label-group\"><span>Hue</span></div><input class=\"ldrs sm auto\" data-tag=\"hsl-h\"><div class=\"label-group\"><span>Saturation</span></div><input class=\"ldrs sm auto\" data-tag=\"hsl-s\"><div class=\"label-group\"><span>Luminance</span></div><input class=\"ldrs sm auto\" data-tag=\"hsl-l\"></div><div class=\"w-50\"><input class=\"value form-control form-control-local-sm\" data-tag=\"hsl-h\"><input class=\"value form-control form-control-local-sm\" data-tag=\"hsl-s\"><input class=\"value form-control form-control-local-sm\" data-tag=\"hsl-l\"></div></div><div class=\"config g-2\" data-tag=\"hcl\"><div class=\"w-100\"><div class=\"label-group\"><span>Hue</span></div><input class=\"ldrs sm auto\" data-tag=\"hcl-h\"><div class=\"label-group\"><span>Chroma</span></div><input class=\"ldrs sm auto\" data-tag=\"hcl-c\"><div class=\"label-group\"><span>Luminance</span></div><input class=\"ldrs sm auto\" data-tag=\"hcl-l\"></div><div class=\"w-50\"><input class=\"value form-control form-control-local-sm\" data-tag=\"hcl-h\"><input class=\"value form-control form-control-local-sm\" data-tag=\"hcl-c\"><input class=\"value form-control form-control-local-sm\" data-tag=\"hcl-l\"></div></div></div></div><div class=\"my-2\"><input class=\"form-control form-control-local-sm\" data-tag=\"tag\" placeholder=\"Comma separated tags for this color\"></div></div></div><div class=\"foot\"><hr class=\"mt-0 mb-3\"><div class=\"float-right\"><div class=\"btn btn-primary mr-2\" data-action=\"use\"><span t=\"use this palette\"></span></div><div class=\"btn btn-outline-secondary ld-ext-right\" data-action=\"save\"><span t=\"save as asset\"></span><div class=\"ld ldld ldbtn sm\"></div></div></div><div class=\"btn btn-outline-secondary\" data-action=\"undo\"><span t=\"undo\"></span> <i class=\"i-undo\"></i></div></div></div></div></div></div></div></div></div><script type=\"@plotdb/block\">module.exports={pkg:{extend:{name:\"@plotdb/konfig\",version:\"main\",path:\"palette\",dom:\"overwrite\"}}};</script></div>"},{"name":"@plotdb/konfig","version":"main","path":"bootstrap/paragraph","code":"<div><div plug=\"config\"><textarea class=\"form-control\" rows=\"1\" ld=\"input\" aria-label=\"paragraph\"></textarea><div class=\"ldcv\" ld=\"ldcv\"><div class=\"base\" ld=\"panel\"><div class=\"inner\"><div class=\"p-2\"><textarea class=\"form-control\" ld=\"textarea\" rows=\"3\" aria-label=\"paragraph\"></textarea></div><div class=\"px-2 pb-2 text-right\"><div class=\"btn btn-sm btn-outline-secondary\" data-ldcv-set=\"\">Cancel</div><div class=\"btn btn-sm btn-primary ml-2\" data-ldcv-set=\"ok\">OK</div></div></div></div></div></div><style type=\"text/css\">textarea[ld=input]{resize:none}.ldcv{position:absolute}.ldcv:before{background:rgba(0,0,0,0.1)}.ldcv:after{display:none}.ldcv .base{position:absolute}.form-control{font-size:1em}</style><script type=\"@plotdb/block\">module.exports={pkg:{extend:{name:\"@plotdb/konfig\",version:\"main\",path:\"paragraph\",dom:\"overwrite\"}}};</script></div>"},{"name":"@plotdb/konfig","version":"main","path":"bootstrap/popup","code":"<div><div plug=\"config\"><div class=\"btn btn-outline-secondary d-block position-relative\" ld=\"button\">...</div></div><style type=\"text/css\">.btn { font-size: 1em }</style><script type=\"@plotdb/block\">module.exports={pkg:{extend:{name:\"@plotdb/konfig\",version:\"main\",path:\"popup\",dom:\"overwrite\"}}};</script></div>"},{"name":"@plotdb/konfig","version":"main","path":"bootstrap/quantity","code":"<div><div plug=\"config\"><input class=\"ldrs auto\" data-class=\"form-control\" ld=\"ldrs\" aria-label=\"number\"></div><div plug=\"ctrl\"><div class=\"d-flex align-items-center\"><div class=\"dropdown\"><div class=\"dropdown-toggle clickable mr-2 text-sm\" ld=\"picker\" data-toggle=\"dropdown\"><span t>unit</span>: <span ld=\"picked\"></span></div><div class=\"dropdown-menu dropdown-menu-right shadow-sm\"><div class=\"dropdown-item\" ld-each=\"unit\"></div></div></div><div class=\"clickable\" ld=\"switch\"><i class=\"i-pen\"></i></div></div></div><script type=\"@plotdb/block\">module.exports={pkg:{extend:{name:\"@plotdb/konfig\",version:\"main\",path:\"quantity\",dom:\"overwrite\"}},init:function(n){var o,e;o=n.root;return e=new ldview({root:o,init:{picker:function(n){var o;o=n.node;return new BSN.Dropdown(o)}}})}};</script></div>"},{"name":"@plotdb/konfig","version":"main","path":"bootstrap/text","code":"<div><div plug=\"config\"><div class=\"input-group\"><input class=\"form-control\" ld=\"input\" aria-label=\"text\"><div class=\"input-group-append\" ld=\"menu\"><div class=\"btn btn-outline-secondary border dropdown-toggle px-2\" ld=\"dropdown\" data-toggle=\"dropdown\" style=\"z-index:1\"></div><div class=\"dropdown-menu dropdown-menu-right shadow-sm z-float\"><div class=\"dropdown-item\" ld-each=\"preset\"></div></div></div></div></div><style type=\"text/css\">.form-control{font-size:1em}</style><script type=\"@plotdb/block\">module.exports={pkg:{extend:{name:\"@plotdb/konfig\",version:\"main\",path:\"text\",dom:\"overwrite\"}},init:function(e){var n,r,t,o,d;n=e.root,r=e.data,t=e.pubsub,o=e.parent;d=new ldview({root:n,init:{dropdown:function(e){var n;n=e.node;return new BSN.Dropdown(n)}},handler:{menu:function(e){var n,r,t;n=e.node,r=e.local;if(!r.parent){r.parent=n.parentNode}t=!!(o._values&&o._values.length);if(t&&!n.parentNode){return n.parentNode.appendChild(n)}else if(!t&&n.parentNode){return n.parentNode.removeChild(n)}}}});return t.on(\"render\",function(){return d.render()})}};</script></div>"},{"name":"@plotdb/konfig","version":"main","path":"bootstrap/upload","code":"<div><div plug=\"config\"><div class=\"btn btn-outline-secondary d-block\" ld=\"button\"><span>Upload</span><input type=\"file\" ld=\"input\" aria-label=\"file\"></div></div><style type=\"text/css\">[ld=button]{position:relative}[ld=button] input{cursor:pointer;width:100%;height:100%;position:absolute;opacity:.001;z-index:1;top:0;left:0}::-webkit-file-upload-button{cursor:pointer;height:100%;border:0}.btn{font-size:1em}</style><script type=\"@plotdb/block\">module.exports={pkg:{extend:{name:\"@plotdb/konfig\",version:\"main\",path:\"upload\",dom:\"overwrite\"}}};</script></div>"}]);
