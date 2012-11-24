(function(){var require = function (file, cwd) {
    var resolved = require.resolve(file, cwd || '/');
    var mod = require.modules[resolved];
    if (!mod) throw new Error(
        'Failed to resolve module ' + file + ', tried ' + resolved
    );
    var cached = require.cache[resolved];
    var res = cached? cached.exports : mod();
    return res;
};

require.paths = [];
require.modules = {};
require.cache = {};
require.extensions = [".js",".coffee",".json"];

require._core = {
    'assert': true,
    'events': true,
    'fs': true,
    'path': true,
    'vm': true
};

require.resolve = (function () {
    return function (x, cwd) {
        if (!cwd) cwd = '/';
        
        if (require._core[x]) return x;
        var path = require.modules.path();
        cwd = path.resolve('/', cwd);
        var y = cwd || '/';
        
        if (x.match(/^(?:\.\.?\/|\/)/)) {
            var m = loadAsFileSync(path.resolve(y, x))
                || loadAsDirectorySync(path.resolve(y, x));
            if (m) return m;
        }
        
        var n = loadNodeModulesSync(x, y);
        if (n) return n;
        
        throw new Error("Cannot find module '" + x + "'");
        
        function loadAsFileSync (x) {
            x = path.normalize(x);
            if (require.modules[x]) {
                return x;
            }
            
            for (var i = 0; i < require.extensions.length; i++) {
                var ext = require.extensions[i];
                if (require.modules[x + ext]) return x + ext;
            }
        }
        
        function loadAsDirectorySync (x) {
            x = x.replace(/\/+$/, '');
            var pkgfile = path.normalize(x + '/package.json');
            if (require.modules[pkgfile]) {
                var pkg = require.modules[pkgfile]();
                var b = pkg.browserify;
                if (typeof b === 'object' && b.main) {
                    var m = loadAsFileSync(path.resolve(x, b.main));
                    if (m) return m;
                }
                else if (typeof b === 'string') {
                    var m = loadAsFileSync(path.resolve(x, b));
                    if (m) return m;
                }
                else if (pkg.main) {
                    var m = loadAsFileSync(path.resolve(x, pkg.main));
                    if (m) return m;
                }
            }
            
            return loadAsFileSync(x + '/index');
        }
        
        function loadNodeModulesSync (x, start) {
            var dirs = nodeModulesPathsSync(start);
            for (var i = 0; i < dirs.length; i++) {
                var dir = dirs[i];
                var m = loadAsFileSync(dir + '/' + x);
                if (m) return m;
                var n = loadAsDirectorySync(dir + '/' + x);
                if (n) return n;
            }
            
            var m = loadAsFileSync(x);
            if (m) return m;
        }
        
        function nodeModulesPathsSync (start) {
            var parts;
            if (start === '/') parts = [ '' ];
            else parts = path.normalize(start).split('/');
            
            var dirs = [];
            for (var i = parts.length - 1; i >= 0; i--) {
                if (parts[i] === 'node_modules') continue;
                var dir = parts.slice(0, i + 1).join('/') + '/node_modules';
                dirs.push(dir);
            }
            
            return dirs;
        }
    };
})();

require.alias = function (from, to) {
    var path = require.modules.path();
    var res = null;
    try {
        res = require.resolve(from + '/package.json', '/');
    }
    catch (err) {
        res = require.resolve(from, '/');
    }
    var basedir = path.dirname(res);
    
    var keys = (Object.keys || function (obj) {
        var res = [];
        for (var key in obj) res.push(key);
        return res;
    })(require.modules);
    
    for (var i = 0; i < keys.length; i++) {
        var key = keys[i];
        if (key.slice(0, basedir.length + 1) === basedir + '/') {
            var f = key.slice(basedir.length);
            require.modules[to + f] = require.modules[basedir + f];
        }
        else if (key === basedir) {
            require.modules[to] = require.modules[basedir];
        }
    }
};

(function () {
    var process = {};
    var global = typeof window !== 'undefined' ? window : {};
    var definedProcess = false;
    
    require.define = function (filename, fn) {
        if (!definedProcess && require.modules.__browserify_process) {
            process = require.modules.__browserify_process();
            definedProcess = true;
        }
        
        var dirname = require._core[filename]
            ? ''
            : require.modules.path().dirname(filename)
        ;
        
        var require_ = function (file) {
            var requiredModule = require(file, dirname);
            var cached = require.cache[require.resolve(file, dirname)];

            if (cached && cached.parent === null) {
                cached.parent = module_;
            }

            return requiredModule;
        };
        require_.resolve = function (name) {
            return require.resolve(name, dirname);
        };
        require_.modules = require.modules;
        require_.define = require.define;
        require_.cache = require.cache;
        var module_ = {
            id : filename,
            filename: filename,
            exports : {},
            loaded : false,
            parent: null
        };
        
        require.modules[filename] = function () {
            require.cache[filename] = module_;
            fn.call(
                module_.exports,
                require_,
                module_,
                module_.exports,
                dirname,
                filename,
                process,
                global
            );
            module_.loaded = true;
            return module_.exports;
        };
    };
})();


require.define("path",function(require,module,exports,__dirname,__filename,process,global){function filter (xs, fn) {
    var res = [];
    for (var i = 0; i < xs.length; i++) {
        if (fn(xs[i], i, xs)) res.push(xs[i]);
    }
    return res;
}

// resolves . and .. elements in a path array with directory names there
// must be no slashes, empty elements, or device names (c:\) in the array
// (so also no leading and trailing slashes - it does not distinguish
// relative and absolute paths)
function normalizeArray(parts, allowAboveRoot) {
  // if the path tries to go above the root, `up` ends up > 0
  var up = 0;
  for (var i = parts.length; i >= 0; i--) {
    var last = parts[i];
    if (last == '.') {
      parts.splice(i, 1);
    } else if (last === '..') {
      parts.splice(i, 1);
      up++;
    } else if (up) {
      parts.splice(i, 1);
      up--;
    }
  }

  // if the path is allowed to go above the root, restore leading ..s
  if (allowAboveRoot) {
    for (; up--; up) {
      parts.unshift('..');
    }
  }

  return parts;
}

// Regex to split a filename into [*, dir, basename, ext]
// posix version
var splitPathRe = /^(.+\/(?!$)|\/)?((?:.+?)?(\.[^.]*)?)$/;

// path.resolve([from ...], to)
// posix version
exports.resolve = function() {
var resolvedPath = '',
    resolvedAbsolute = false;

for (var i = arguments.length; i >= -1 && !resolvedAbsolute; i--) {
  var path = (i >= 0)
      ? arguments[i]
      : process.cwd();

  // Skip empty and invalid entries
  if (typeof path !== 'string' || !path) {
    continue;
  }

  resolvedPath = path + '/' + resolvedPath;
  resolvedAbsolute = path.charAt(0) === '/';
}

// At this point the path should be resolved to a full absolute path, but
// handle relative paths to be safe (might happen when process.cwd() fails)

// Normalize the path
resolvedPath = normalizeArray(filter(resolvedPath.split('/'), function(p) {
    return !!p;
  }), !resolvedAbsolute).join('/');

  return ((resolvedAbsolute ? '/' : '') + resolvedPath) || '.';
};

// path.normalize(path)
// posix version
exports.normalize = function(path) {
var isAbsolute = path.charAt(0) === '/',
    trailingSlash = path.slice(-1) === '/';

// Normalize the path
path = normalizeArray(filter(path.split('/'), function(p) {
    return !!p;
  }), !isAbsolute).join('/');

  if (!path && !isAbsolute) {
    path = '.';
  }
  if (path && trailingSlash) {
    path += '/';
  }
  
  return (isAbsolute ? '/' : '') + path;
};


// posix version
exports.join = function() {
  var paths = Array.prototype.slice.call(arguments, 0);
  return exports.normalize(filter(paths, function(p, index) {
    return p && typeof p === 'string';
  }).join('/'));
};


exports.dirname = function(path) {
  var dir = splitPathRe.exec(path)[1] || '';
  var isWindows = false;
  if (!dir) {
    // No dirname
    return '.';
  } else if (dir.length === 1 ||
      (isWindows && dir.length <= 3 && dir.charAt(1) === ':')) {
    // It is just a slash or a drive letter with a slash
    return dir;
  } else {
    // It is a full dirname, strip trailing slash
    return dir.substring(0, dir.length - 1);
  }
};


exports.basename = function(path, ext) {
  var f = splitPathRe.exec(path)[2] || '';
  // TODO: make this comparison case-insensitive on windows?
  if (ext && f.substr(-1 * ext.length) === ext) {
    f = f.substr(0, f.length - ext.length);
  }
  return f;
};


exports.extname = function(path) {
  return splitPathRe.exec(path)[3] || '';
};

});

require.define("__browserify_process",function(require,module,exports,__dirname,__filename,process,global){var process = module.exports = {};

process.nextTick = (function () {
    var canSetImmediate = typeof window !== 'undefined'
        && window.setImmediate;
    var canPost = typeof window !== 'undefined'
        && window.postMessage && window.addEventListener
    ;

    if (canSetImmediate) {
        return function (f) { return window.setImmediate(f) };
    }

    if (canPost) {
        var queue = [];
        window.addEventListener('message', function (ev) {
            if (ev.source === window && ev.data === 'browserify-tick') {
                ev.stopPropagation();
                if (queue.length > 0) {
                    var fn = queue.shift();
                    fn();
                }
            }
        }, true);

        return function nextTick(fn) {
            queue.push(fn);
            window.postMessage('browserify-tick', '*');
        };
    }

    return function nextTick(fn) {
        setTimeout(fn, 0);
    };
})();

process.title = 'browser';
process.browser = true;
process.env = {};
process.argv = [];

process.binding = function (name) {
    if (name === 'evals') return (require)('vm')
    else throw new Error('No such module. (Possibly not yet loaded)')
};

(function () {
    var cwd = '/';
    var path;
    process.cwd = function () { return cwd };
    process.chdir = function (dir) {
        if (!path) path = require('path');
        cwd = path.resolve(dir, cwd);
    };
})();

});

require.define("/example/expander/script/expander.js",function(require,module,exports,__dirname,__filename,process,global){(function() {

    /**
     * Expander control
     *
     * Displays a given number
     */
    var expander = function () {

        var state = this.state('open', false);

        _this = this;

        this.onEvent('toggle', 'click', function(event) {
            state.toggle();

            var template = _this.template('template');
            var context  = {
                open: state.get()
            };

            event.element.html(_this.render(template, context));
        });

    };

    module.exports = {
        expander: expander
    };

})();

});

require.define("/lib/cosy.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var evaluator, hashMap, reader, up,
    __hasProp = {}.hasOwnProperty;

  reader = require('./core/reader');

  evaluator = require('./core/evaluator');

  hashMap = require('./core/hashMap').hashMap;

  up = function(startNode, imports) {
    var ast, attributes, frame, name, obj, selector;
    frame = evaluator.use(evaluator.frame(), imports);
    attributes = [];
    for (name in imports) {
      if (!__hasProp.call(imports, name)) continue;
      obj = imports[name];
      attributes.push("[data-cosy-" + name + "]");
    }
    selector = attributes.join(',');
    ast = reader.read(startNode, selector);
    return evaluator.apply(ast, frame);
  };

  module.exports = {
    up: up,
    isAwesome: true,
    snuggle: require('./snuggle')
  };

}).call(this);

});

require.define("/lib/core/reader.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var Cosy, Tree, TreeNode, attrs, cosy, cosyData, css, data, dom, filter, get, getChildren, getCosy, getData, getElement, getNode, hashMap, into, isCosy, isTree, isTreeNode, key, loadNode, map, parseData, read, reduce, rest, second, value, _ref, _ref1, _ref2, _ref3,
    __hasProp = {}.hasOwnProperty;

  _ref = require('../protocol/element'), css = _ref.css, data = _ref.data, cosy = _ref.cosy, attrs = _ref.attrs;

  _ref1 = require('../protocol/map'), key = _ref1.key, value = _ref1.value;

  _ref2 = require('../protocol/list'), into = _ref2.into, second = _ref2.second, rest = _ref2.rest;

  hashMap = require('./hashMap').hashMap;

  _ref3 = require('./list'), map = _ref3.map, reduce = _ref3.reduce, filter = _ref3.filter;

  get = require('../protocol/mutable').get;

  dom = require('../dom/reader');

  getData = function(node, attr) {
    var dataName, getObject, name, parts;
    parts = /^data-(cosy-(.*))/.exec(key(attr));
    name = parts[2];
    dataName = parts[1];
    getObject = function(name, value) {
      var result;
      result = {};
      parts = /^([^-]+)(-(.*))?/.exec(name);
      if ((parts != null) && (parts[3] != null)) {
        result[parts[1]] = getObject(parts[3], value);
      } else {
        result[name] = value;
      }
      return hashMap(result);
    };
    return getObject(name, data(node, dataName));
  };

  cosyData = function(attr) {
    return (/^data-cosy-/.exec(key(attr))) != null;
  };

  parseData = function(node) {
    var result;
    result = cosy(node);
    if (result === '') {
      result = hashMap({});
    }
    if (result == null) {
      result = hashMap({});
    }
    return new Cosy(into(result, reduce(into, map((function(attr) {
      return getData(node, attr);
    }), filter(cosyData, attrs(node))))));
  };

  Tree = (function() {

    function Tree(_tree) {
      this.root = _tree.root;
      this.children = _tree.children;
    }

    return Tree;

  })();

  TreeNode = (function() {

    function TreeNode(_node) {
      this.cosy = _node.cosy;
      this.element = _node.element;
    }

    return TreeNode;

  })();

  Cosy = (function() {

    function Cosy(_cosy) {
      var _key, _value;
      for (_key in _cosy) {
        if (!__hasProp.call(_cosy, _key)) continue;
        _value = _cosy[_key];
        this[_key] = _value;
      }
    }

    return Cosy;

  })();

  isCosy = function(cosy) {
    return cosy instanceof Cosy;
  };

  isTree = function(tree) {
    return tree instanceof Tree;
  };

  isTreeNode = function(root) {
    return root instanceof TreeNode;
  };

  loadNode = function(node) {
    if (node == null) {
      return null;
    }
    return new Tree({
      root: new TreeNode({
        cosy: parseData(node.node),
        element: node.node
      }),
      children: map(loadNode, node.children)
    });
  };

  read = function(node, selector) {
    if (selector == null) {
      selector = "[data-cosy]";
    }
    return loadNode(dom.read(node, selector));
  };

  getNode = function(ast) {
    return ast.root;
  };

  getElement = function(root) {
    return root.element;
  };

  getCosy = function(root) {
    return root.cosy;
  };

  getChildren = function(ast) {
    return ast.children;
  };

  module.exports = {
    read: read,
    isTree: isTree,
    isTreeNode: isTreeNode,
    isCosy: isCosy,
    node: getNode,
    cosy: getCosy,
    children: getChildren,
    element: getElement
  };

}).call(this);

});

require.define("/lib/protocol/element.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var assertFn, assertStr, defProtocol, dispatch, extend, hashMap, into, isFn, isJqueryElement, list, map, mutable, protocol, ref, watchRef, _ref, _ref1, _ref2;

  _ref = require('../core/protocol'), defProtocol = _ref.defProtocol, dispatch = _ref.dispatch, extend = _ref.extend;

  _ref1 = require('../core/reference'), ref = _ref1.ref, watchRef = _ref1.watchRef;

  hashMap = require('../core/hashMap').hashMap;

  list = require('./list');

  into = require('./list').into;

  map = require('../core/list').map;

  mutable = require('./mutable');

  _ref2 = require('../core/native/function'), isFn = _ref2.isFn, assertFn = _ref2.assertFn;

  assertStr = require('../core/native/string').assertStr;

  isJqueryElement = function(value) {
    return (value != null) && (value.jquery != null);
  };

  module.exports = protocol = defProtocol({
    attr: dispatch(function(element, key) {}),
    attrs: dispatch(function(element) {}),
    children: dispatch(function(element) {}),
    cosy: function(element) {
      return protocol.data(element, 'cosy');
    },
    css: dispatch(function(element, selector) {}),
    data: dispatch(function(element, key) {}),
    text: dispatch(function(element) {}),
    value: dispatch(function(element) {}),
    parents: dispatch(function(element, selector) {}),
    siblings: dispatch(function(element, selector) {}),
    matches: dispatch(function(element, selector) {}),
    listen: dispatch(function(element, event, fn) {}),
    remove: dispatch(function(element) {}),
    append: dispatch(function(element, child) {})
  });

  extend(mutable, isJqueryElement, {
    get: function(element) {
      return element.html();
    },
    set: function(element, value) {
      element.trigger('html');
      return element.html(value);
    }
  });

  extend(protocol, isJqueryElement, {
    attr: function(element, key) {
      return watchRef(mutable.set(ref(), element.attr(assertStr(key))), function(reference) {
        return element.attr(key, mutable.get(reference));
      });
    },
    attrs: function(element) {
      var attr, result, _i, _len, _ref3;
      result = {};
      if (element[0].attributes != null) {
        _ref3 = element[0].attributes;
        for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
          attr = _ref3[_i];
          result[attr.name] = attr.value;
        }
      }
      return hashMap(result);
    },
    children: function(element) {
      return element.children();
    },
    css: function(element, selector) {
      return element.find(assertStr(selector, 'Invalid selector'));
    },
    data: function(element, key) {
      return element.data(assertStr(key));
    },
    text: function(element) {
      return watchRef(mutable.set(ref(), element.text()), function(reference) {
        return element.text(mutable.get(reference));
      });
    },
    value: function(element) {
      return watchRef(mutable.set(ref(), element.val()), function(reference) {
        element.trigger('value');
        return element.val(mutable.get(reference));
      });
    },
    parents: function(element, selector) {
      return element.parents(assertStr(selector, 'Invalid selector'));
    },
    siblings: function(element, selector) {
      return element.siblings(assertStr(selector, 'Invalid selector'));
    },
    matches: function(element, selector) {
      return element.is(assertStr(selector, 'Invalid Selector'));
    },
    listen: function(element, event, fn) {
      return element.on(event, fn);
    },
    remove: function(element) {
      element.trigger("remove");
      return element.remove();
    },
    append: function(element, child) {
      element.trigger("append");
      return element.append(child);
    }
  });

  extend(list, isJqueryElement, {
    first: function(jqList) {
      if (jqList.length) {
        return jqList.eq(0);
      } else {
        return null;
      }
    },
    rest: function(jqList) {
      if (jqList.length) {
        return jqList.slice(1);
      } else {
        return null;
      }
    }
  });

}).call(this);

});

require.define("/lib/core/protocol.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var Protocol, addDispatch, assertFn, defProtocol, dispatch, extend, supports,
    __hasProp = {}.hasOwnProperty,
    __slice = [].slice;

  assertFn = require('./native/function').assertFn;

  Protocol = (function() {

    function Protocol(spec) {
      var def, name;
      for (name in spec) {
        if (!__hasProp.call(spec, name)) continue;
        def = spec[name];
        this[name] = def;
        if (def.setName) {
          this[name].setName(name);
        }
      }
      this.supports = function() {
        return false;
      };
    }

    return Protocol;

  })();

  defProtocol = function(spec) {
    return new Protocol(spec);
  };

  dispatch = function(signature) {
    var fn, name;
    name = null;
    fn = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      fn.validate.apply(fn, args);
      return fn.impl.apply(fn, args);
    };
    fn.setName = function(fnName) {
      return name = fnName;
    };
    fn.impl = function(type) {
      throw new Error("Function not implemented " + name + " for " + type);
    };
    fn.validate = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (args.length !== signature.length) {
        throw new Error("Invalid invocation " + name);
      }
    };
    return fn;
  };

  addDispatch = function(proto, pred, name, fn) {
    var chain, supports;
    if (proto[name] == null) {
      throw new Error('Unknown function ' + name);
    }
    if (proto[name].impl == null) {
      throw new Error('Function not extendable ' + name);
    }
    assertFn(pred, 'Invalid predicate');
    assertFn(fn, 'Invalid function');
    chain = proto[name].impl;
    proto[name].impl = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (pred.apply(null, args)) {
        return fn.apply(null, args);
      } else {
        return chain.apply(null, args);
      }
    };
    supports = proto.supports;
    return proto.supports = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (pred.apply(null, args)) {
        return true;
      } else {
        return supports.apply(null, args);
      }
    };
  };

  extend = function(proto, pred, spec) {
    var fn, name, _results;
    _results = [];
    for (name in spec) {
      if (!__hasProp.call(spec, name)) continue;
      fn = spec[name];
      _results.push(addDispatch(proto, pred, name, fn));
    }
    return _results;
  };

  supports = function() {
    var args, proto;
    proto = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    return proto.supports.apply(proto, args);
  };

  module.exports = {
    defProtocol: defProtocol,
    extend: extend,
    dispatch: dispatch,
    supports: supports
  };

}).call(this);

});

require.define("/lib/core/native/function.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var assertFn, isFn;

  isFn = function(value) {
    return typeof value === 'function';
  };

  assertFn = function(value, message) {
    if (message == null) {
      message = 'Invalid function';
    }
    if (!(isFn(value))) {
      throw new Error(message);
    }
    return value;
  };

  module.exports = {
    isFn: isFn,
    assertFn: assertFn
  };

}).call(this);

});

require.define("/lib/core/reference.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var Reference, assertRef, extend, getRef, isFn, isRef, mutable, notifyRef, ref, setRef, unwatchRef, watchRef;

  extend = require('./protocol').extend;

  mutable = require('../protocol/mutable');

  isFn = require('./native/function').isFn;

  Reference = (function() {

    function Reference(value) {
      if (value == null) {
        value = null;
      }
      this.value = value;
      this.metadata = {
        watches: []
      };
    }

    return Reference;

  })();

  ref = function(value) {
    return new Reference(value);
  };

  isRef = function(value) {
    return value instanceof Reference;
  };

  assertRef = function(value) {
    if (!(isRef(value))) {
      throw new Error('Invalid reference');
    }
    return value;
  };

  getRef = function(reference) {
    return (assertRef(reference)).value;
  };

  setRef = function(reference, value) {
    (assertRef(reference)).value = value;
    notifyRef(reference);
    return reference;
  };

  watchRef = function(reference, callback) {
    (assertRef(reference)).metadata.watches.push(callback);
    return reference;
  };

  unwatchRef = function(reference, callback) {
    var fn, index, _i, _len, _ref;
    assertRef(reference);
    _ref = reference.metadata.watches;
    for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
      fn = _ref[index];
      if (fn === callback) {
        delete reference.metadata.watches[index];
      }
    }
    return true;
  };

  notifyRef = function(reference) {
    var callback, _i, _len, _ref;
    _ref = reference.metadata.watches;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      callback = _ref[_i];
      if (isFn(callback)) {
        callback(reference);
      }
    }
    return reference;
  };

  extend(mutable, isRef, {
    set: function(reference, value) {
      return setRef(reference, value);
    },
    get: function(reference) {
      return getRef(reference);
    }
  });

  module.exports = {
    ref: ref,
    isRef: isRef,
    getRef: getRef,
    setRef: setRef,
    watchRef: watchRef,
    notifyRef: notifyRef,
    unwatchRef: unwatchRef
  };

}).call(this);

});

require.define("/lib/protocol/mutable.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var defProtocol, dispatch, extend, isStr, proto, _ref;

  _ref = require('../core/protocol'), defProtocol = _ref.defProtocol, dispatch = _ref.dispatch, extend = _ref.extend;

  isStr = require('../core/native/string').isStr;

  module.exports = proto = defProtocol({
    set: dispatch(function(variable, value) {}),
    get: dispatch(function(variable) {})
  });

  extend(proto, isStr, {
    get: function(str) {
      return str;
    }
  });

}).call(this);

});

require.define("/lib/core/native/string.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var assertStr, isStr;

  isStr = function(value) {
    return typeof value === 'string';
  };

  assertStr = function(value, message) {
    if (message == null) {
      message = 'Invalid string';
    }
    if (!(isStr(value))) {
      throw new Error(message);
    }
    return value;
  };

  module.exports = {
    isStr: isStr,
    assertStr: assertStr
  };

}).call(this);

});

require.define("/lib/core/hashMap.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var HashMap, HashMapItem, extend, hashMap, hashMapItem, isEmpty, isHashMap, isHashMapItem, list, map,
    __hasProp = {}.hasOwnProperty;

  map = require('../protocol/map');

  list = require('../protocol/list');

  extend = require('./protocol').extend;

  HashMap = (function() {

    function HashMap(map) {
      var key, value;
      if (map != null) {
        for (key in map) {
          if (!__hasProp.call(map, key)) continue;
          value = map[key];
          this[key] = value;
        }
      }
    }

    return HashMap;

  })();

  HashMapItem = (function() {

    function HashMapItem() {}

    return HashMapItem;

  })();

  isEmpty = function(map) {
    var key;
    for (key in map) {
      if (!__hasProp.call(map, key)) continue;
      return false;
    }
    return true;
  };

  hashMap = function(map) {
    return new HashMap(map);
  };

  hashMapItem = function(key, value) {
    var item;
    item = new HashMapItem;
    item[0] = key;
    item[1] = value;
    return item;
  };

  isHashMap = function(map) {
    return map instanceof HashMap;
  };

  isHashMapItem = function(item) {
    return item instanceof HashMapItem;
  };

  module.exports = {
    hashMap: hashMap
  };

  extend(map, isHashMap, {
    assoc: function(col, key, value) {
      var newMap;
      newMap = hashMap(col);
      if (isHashMap(col[key])) {
        newMap[key] = list.into(col[key], value);
      } else {
        newMap[key] = value;
      }
      return newMap;
    },
    dissoc: function(col, key) {
      var newMap;
      newMap = hashMap(col);
      delete newMap[key];
      if (!isEmpty(newMap)) {
        return newMap;
      } else {
        return null;
      }
    },
    get: function(col, key, def) {
      if (def == null) {
        def = null;
      }
      if (col[key] != null) {
        return col[key];
      } else {
        return def;
      }
    },
    find: function(col, key) {
      if (col[key] != null) {
        return hashMapItem(key, col[key]);
      } else {
        return null;
      }
    }
  });

  extend(map, isHashMapItem, {
    key: function(item) {
      return item[0];
    },
    value: function(item) {
      return item[1];
    }
  });

  extend(list, isHashMap, {
    first: function(col) {
      var key, value;
      for (key in col) {
        if (!__hasProp.call(col, key)) continue;
        value = col[key];
        return hashMapItem(key, value);
      }
      return null;
    },
    rest: function(col) {
      var colFirst;
      colFirst = list.first(col);
      if (colFirst != null) {
        return map.dissoc(col, map.key(colFirst));
      } else {
        return null;
      }
    },
    conj: function(col, item) {
      var key, value, _ref;
      if (item === null) {
        return col;
      } else {
        if (isHashMapItem(item)) {
          return map.assoc(col, map.key(item), map.value(item));
        } else {
          _ref = list.first(item), key = _ref[0], value = _ref[1];
          return list.conj(map.assoc(col, key, value), list.rest(item));
        }
      }
    }
  });

}).call(this);

});

require.define("/lib/protocol/map.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var defProtocol, dispatch, extend, protocol, _ref;

  _ref = require('../core/protocol'), defProtocol = _ref.defProtocol, dispatch = _ref.dispatch, extend = _ref.extend;

  module.exports = protocol = defProtocol({
    key: dispatch(function(mapItem) {}),
    value: dispatch(function(mapItem) {}),
    assoc: dispatch(function(map, key, value) {}),
    dissoc: dispatch(function(map, key) {}),
    get: dispatch(function(map, key) {}),
    find: dispatch(function(map, key) {})
  });

}).call(this);

});

require.define("/lib/protocol/list.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var defProtocol, dispatch, extend, isArr, proto, _ref;

  _ref = require('../core/protocol'), defProtocol = _ref.defProtocol, dispatch = _ref.dispatch, extend = _ref.extend;

  isArr = require('../core/native/array').isArr;

  module.exports = proto = defProtocol({
    first: dispatch(function(list) {}),
    second: function(list) {
      return proto.first(proto.rest(list));
    },
    rest: dispatch(function(list) {}),
    conj: dispatch(function(list, item) {}),
    cons: function(item, list) {
      return proto.conj(list, item);
    },
    into: function(to, from) {
      if (from !== null) {
        return proto.into(proto.conj(to, proto.first(from)), proto.rest(from));
      } else {
        return to;
      }
    }
  });

  extend(proto, (function(list) {
    return list === null;
  }), {
    first: function() {
      return null;
    },
    rest: function() {
      return null;
    },
    conj: function(list, item) {
      return [item];
    }
  });

  extend(proto, isArr, {
    first: function(list) {
      if ((list.length != null) && list.length) {
        return list[0];
      } else {
        return null;
      }
    },
    rest: function(list) {
      if (list.length > 1) {
        return list.slice(1);
      } else {
        return null;
      }
    },
    conj: function(list, item) {
      var newList;
      newList = list.slice(0);
      newList.push(item);
      return newList;
    }
  });

}).call(this);

});

require.define("/lib/core/native/array.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var assertArr, isArr;

  isArr = Array.isArray || function(value) {
    return (Object.prototype.toString.call(value)) === '[object Array]';
  };

  assertArr = function(value, message) {
    if (message == null) {
      message = 'Invalid array';
    }
    if (!(isArr(value))) {
      throw new Error(message);
    }
    return value;
  };

  module.exports = {
    isArr: isArr,
    assertArr: assertArr
  };

}).call(this);

});

require.define("/lib/core/list.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var cons, doLoop, doSeq, drop, filter, first, lazySeq, map, recur, reduce, rest, take, vec, _ref;

  _ref = require('../protocol/list'), first = _ref.first, rest = _ref.rest, cons = _ref.cons;

  lazySeq = require('./lazySeq').lazySeq;

  map = function(fn, list) {
    if (list === null) {
      return null;
    } else {
      return cons(fn(first(list)), lazySeq(function() {
        return map(fn, rest(list));
      }));
    }
  };

  reduce = function(fn, list, accum) {
    var item;
    if (accum == null) {
      accum = null;
    }
    if (list === null) {
      return accum;
    } else {
      item = first(list);
      accum = accum != null ? fn(item, accum) : item;
      return reduce(fn, rest(list), accum);
    }
  };

  filter = function(pred, list) {
    var item;
    if (list === null) {
      return null;
    } else {
      item = first(list);
      if ((item != null) && (pred(item))) {
        return cons(item, lazySeq(function() {
          return filter(pred, rest(list));
        }));
      } else {
        return filter(pred, rest(list));
      }
    }
  };

  take = function(n, list) {
    if (list === null || n < 1) {
      return null;
    } else {
      return cons(first(list), lazySeq(function() {
        return take(n - 1, rest(list));
      }));
    }
  };

  drop = function(n, list) {
    var step;
    step = function(n, list) {
      if (n < 1) {
        return list;
      } else {
        return step(n - 1, rest(list));
      }
    };
    return lazySeq(function() {
      return step(n, list);
    });
  };

  vec = function(seq) {
    var result;
    result = [];
    doSeq((function(item) {
      return result.push(item);
    }), seq);
    return result;
  };

  doLoop = function(fn) {
    var result;
    while (fn != null) {
      result = fn();
      fn = result != null ? result.recur : void 0;
    }
    return null;
  };

  recur = function(fn) {
    return {
      recur: fn
    };
  };

  doSeq = function(fn, seq) {
    if (seq == null) {
      return null;
    }
    return doLoop(function() {
      fn(first(seq));
      return recur(function() {
        return doSeq(fn, rest(seq));
      });
    });
  };

  module.exports = {
    map: map,
    reduce: reduce,
    filter: filter,
    take: take,
    drop: drop,
    vec: vec,
    doSeq: doSeq
  };

}).call(this);

});

require.define("/lib/core/lazySeq.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var LazySeq, extend, isLazySeq, lazySeq, list;

  list = require('../protocol/list');

  extend = require('./protocol').extend;

  LazySeq = (function() {

    function LazySeq(promise, head) {
      this.promise = promise;
      this.head = (head != null ? head : head = null);
    }

    return LazySeq;

  })();

  isLazySeq = function(variable) {
    return variable instanceof LazySeq;
  };

  lazySeq = function(promise, head) {
    return new LazySeq(promise, head);
  };

  extend(list, isLazySeq, {
    first: function(sequence) {
      var seq;
      if (sequence.head == null) {
        seq = sequence.promise();
        sequence.head = list.first(seq);
        sequence.promise = function() {
          return list.rest(seq);
        };
      }
      return sequence.head;
    },
    rest: function(sequence) {
      list.first(sequence);
      return sequence.promise();
    },
    conj: function(sequence, item) {
      sequence.head = item;
      return sequence;
    }
  });

  module.exports = {
    lazySeq: lazySeq
  };

}).call(this);

});

require.define("/lib/dom/reader.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var css, filter, first, isParent, map, matches, parents, read, _ref, _ref1;

  _ref = require('../protocol/element'), css = _ref.css, parents = _ref.parents, matches = _ref.matches;

  _ref1 = require('../core/list'), filter = _ref1.filter, map = _ref1.map;

  first = require('../protocol/list').first;

  isParent = function(node, element, selector) {
    var cand;
    if (element == null) {
      return false;
    }
    cand = first(parents(element, selector));
    if (cand != null) {
      return node[0] === cand[0];
    } else {
      return true;
    }
  };

  read = function(node, selector) {
    var children;
    if (node === null) {
      return null;
    } else {
      children = map((function(element) {
        return read(element, selector);
      }), filter((function(element) {
        return isParent(node, element, selector);
      }), css(node, selector)));
      return {
        node: node,
        children: children
      };
    }
  };

  module.exports = {
    read: read
  };

}).call(this);

});

require.define("/lib/core/evaluator.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var assertFn, assertStr, assoc, children, cosy, defProtocol, dispatch, doSeq, element, evaluate, extend, filter, frame, get, hashMap, isCosy, isStr, isTree, isTreeNode, list, lookup, lookupRef, map, parse, proto, root, stringify, supports, use, vec, _ref, _ref1, _ref2, _ref3, _ref4,
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty;

  _ref = require('./protocol'), defProtocol = _ref.defProtocol, dispatch = _ref.dispatch, extend = _ref.extend, supports = _ref.supports;

  list = require('../protocol/list');

  _ref1 = require('../protocol/map'), assoc = _ref1.assoc, get = _ref1.get;

  hashMap = require('./hashMap').hashMap;

  _ref2 = require('./native/string'), isStr = _ref2.isStr, assertStr = _ref2.assertStr;

  _ref3 = require('./list'), doSeq = _ref3.doSeq, map = _ref3.map, vec = _ref3.vec, filter = _ref3.filter;

  assertFn = require('./native/function').assertFn;

  _ref4 = require('./reader'), isTreeNode = _ref4.isTreeNode, isTree = _ref4.isTree, isCosy = _ref4.isCosy, root = _ref4.node, children = _ref4.children, cosy = _ref4.cosy, element = _ref4.element;

  parse = function(str) {
    return (assertStr(str)).split(/\s/);
  };

  lookupRef = function(frame, parts) {
    var name, ref, rest;
    name = list.first(parts);
    rest = list.rest(parts);
    ref = get(frame, name);
    if (ref && rest) {
      return lookupRef(use(frame, ref), rest);
    } else {
      return ref;
    }
  };

  lookup = function(frame, str) {
    var location, ref;
    if (!isStr(str)) {
      return str;
    }
    str = str.replace(/^'(.*)'$/, '"$1"');
    ref = lookupRef(frame, str.split(/[.]/));
    if (ref == null) {
      if (/^(true|false|[\d"[{])/i.exec(str)) {
        ref = JSON.parse(str);
      } else {
        location = '';
        if (frame.__node != null) {
          location = ' at ' + frame.__node[0].toString();
        }
        throw new Error(("Symbol " + str + " not found") + location);
      }
    }
    return ref;
  };

  evaluate = function(cmd, frame) {
    var args, filterSymbol, fn, mapSymbol;
    if (isStr(cmd)) {
      cmd = parse(cmd);
    }
    fn = lookup(frame, list.first(cmd));
    assertFn(fn, 'Unknown function ' + list.first(cmd));
    mapSymbol = function(symbol) {
      if ((fn.raw != null) && fn.raw.exec(symbol)) {
        return symbol;
      } else {
        return lookup(frame, symbol);
      }
    };
    filterSymbol = function(symbol) {
      return (symbol != null) && symbol !== '';
    };
    args = vec(map(mapSymbol, filter(filterSymbol, list.rest(cmd))));
    if (get(frame, 'debug')) {
      console.log([list.first(cmd)].concat(args));
    }
    return fn.apply(null, [frame].concat(__slice.call(args)));
  };

  proto = defProtocol({
    apply: dispatch(function(type, frame) {})
  });

  extend(proto, (function(type) {
    return type === null;
  }), {
    apply: function(nil, frame) {
      return frame;
    }
  });

  extend(proto, isStr, {
    apply: function(str, frame) {
      return evaluate(str, frame);
    }
  });

  stringify = function(_obj, prefix) {
    var cmds, key, val;
    if (prefix == null) {
      prefix = '';
    }
    cmds = [];
    if (isStr(_obj)) {
      cmds.push(prefix + _obj);
    } else {
      for (key in _obj) {
        if (!__hasProp.call(_obj, key)) continue;
        val = _obj[key];
        cmds = cmds.concat(stringify(val, prefix + key + ' '));
      }
    }
    return cmds;
  };

  extend(proto, isCosy, {
    apply: function(_cosy, frame) {
      var cmd, cmds, newFrame, _i, _len;
      cmds = stringify(_cosy);
      for (_i = 0, _len = cmds.length; _i < _len; _i++) {
        cmd = cmds[_i];
        newFrame = proto.apply(cmd, frame);
        if (newFrame != null) {
          frame = newFrame;
        }
      }
      return frame;
    }
  });

  extend(proto, isTreeNode, {
    apply: function(node, frame) {
      var newFrame;
      newFrame = assoc(frame, "__node", element(node));
      return proto.apply(cosy(node), newFrame);
    }
  });

  extend(proto, (function(type) {
    return supports(list, type);
  }), {
    apply: function(list, frame) {
      doSeq((function(item) {
        return proto.apply(item, frame);
      }), list);
      return frame;
    }
  });

  extend(proto, isTree, {
    apply: function(tree, frame) {
      var continueFn, newFrame;
      continueFn = function() {};
      frame = assoc(frame, '__continue', (function() {
        return continueFn();
      }));
      newFrame = proto.apply(root(tree), frame);
      newFrame["__parent"] = newFrame;
      if ((newFrame != null ? newFrame.__delay : void 0) != null) {
        continueFn = function(nextFrame) {
          delete newFrame.__delay;
          delete frame.__continue;
          return proto.apply(children(tree), newFrame);
        };
      } else {
        proto.apply(children(tree), newFrame);
      }
      return frame;
    }
  });

  use = function(frame, obj) {
    return list.into(frame, hashMap(obj));
  };

  frame = function() {
    return hashMap({
      use: use
    });
  };

  module.exports = {
    apply: proto.apply,
    use: use,
    frame: frame,
    evaluate: evaluate
  };

}).call(this);

});

require.define("/lib/snuggle.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var assoc, control, core, cosy, evaluator, hashMap, reader, ref, up,
    __hasProp = {}.hasOwnProperty;

  evaluator = require('./core/evaluator');

  reader = require('./core/reader');

  ref = require('./core/reference').ref;

  hashMap = require('./core/hashMap').hashMap;

  assoc = require('./protocol/map').assoc;

  core = require('./snuggle/core');

  cosy = require('./snuggle/cosy');

  control = require('./snuggle/control');

  up = function(startNode, controls, lib, debug) {
    var frame, name, value;
    if (debug == null) {
      debug = false;
    }
    frame = evaluator.frame();
    for (name in lib) {
      if (!__hasProp.call(lib, name)) continue;
      value = lib[name];
      if (core[name] != null) {
        throw new Error("Cannot overwrite " + name + " in core");
      }
      core[name] = value;
    }
    frame = assoc(frame, 'namespace', core);
    frame = assoc(frame, 'cosy', control);
    frame = evaluator.use(frame, cosy);
    frame = evaluator.use(frame, controls);
    frame = assoc(frame, 'global', ref({}));
    frame = assoc(frame, 'debug', debug);
    return up.to(startNode, frame);
  };

  up.to = function(startNode, frame) {
    var attributes, name, obj, selector;
    attributes = [];
    for (name in cosy) {
      if (!__hasProp.call(cosy, name)) continue;
      obj = cosy[name];
      attributes.push("[data-cosy-" + name + "]");
    }
    selector = attributes.join(',');
    frame.__selector = selector;
    return startNode.each(function(index, element) {
      var ast;
      ast = reader.read($(element), selector);
      return evaluator.apply(ast, frame);
    });
  };

  module.exports = {
    up: up
  };

}).call(this);

});

require.define("/lib/snuggle/core.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var query, ref, template;

  query = require('./core/query');

  ref = require('./core/reference');

  template = require('./core/template');

  module.exports = {
    container: query.container,
    role: query.role,
    roles: query.roles,
    query: query.query,
    list: require('./core/list'),
    onEvent: query.onEvent,
    "on": query.on,
    set: ref.set,
    get: ref.get,
    notify: ref.notify,
    copy: ref.copy,
    form: require('./core/form'),
    html: require('./core/html'),
    state: require('./core/state').state,
    template: template.template,
    render: template.render,
    renderRaw: template.renderRaw,
    global: require('./core/global'),
    watch: ref.watch,
    watchRef: ref.watchRef
  };

}).call(this);

});

require.define("/lib/snuggle/core/query.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var apply, container, depreciatedMsgSent, eventFn, onEvent, onEventDepreciated, onRoleEvent, onStdEvent, query, role, roles,
    __slice = [].slice;

  apply = function(ctx, fn) {
    return function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return fn.apply(ctx, args);
    };
  };

  container = function(name, element) {
    if (element == null) {
      element = this.element;
    }
    return element.closest("[data-container=" + name + "]");
  };

  roles = function(name, element) {
    if (element == null) {
      element = this.element;
    }
    return element.find("[data-role=" + name + "]");
  };

  role = function(name, element) {
    return (roles.call(this, name, element)).eq(0);
  };

  query = function(selector) {
    return $(selector);
  };

  eventFn = function(fn) {
    return function(event) {
      return fn({
        event: event,
        element: $(event.target),
        stop: function() {
          return event.preventDefault();
        }
      });
    };
  };

  onRoleEvent = function(element, role, event, fn) {
    return element.on(event, "[data-role=" + role + "]", eventFn(fn));
  };

  onStdEvent = function(element, event, fn) {
    return element.on(event, eventFn(fn));
  };

  onEvent = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    if (args.length === 2) {
      return onStdEvent.apply(null, [this.element].concat(__slice.call(args)));
    } else {
      return onRoleEvent.apply(null, [this.element].concat(__slice.call(args)));
    }
  };

  depreciatedMsgSent = false;

  onEventDepreciated = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    if (depreciatedMsgSent === false) {
      console.log('`on` is deprecated, please use `onEvent`');
      depreciatedMsgSent = true;
    }
    return onEvent.apply(this, args);
  };

  module.exports = {
    container: container,
    role: role,
    roles: roles,
    query: query,
    onEvent: onEvent,
    "on": onEventDepreciated
  };

}).call(this);

});

require.define("/lib/snuggle/core/reference.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var copy, coreWatchRef, get, notify, set, unwatchRef, watch, watchRef, _ref, _ref1;

  _ref = require('../../protocol/mutable'), set = _ref.set, get = _ref.get;

  _ref1 = require('../../core/reference'), coreWatchRef = _ref1.watchRef, unwatchRef = _ref1.unwatchRef;

  copy = function(src, tgt) {
    return set(tgt, get(src));
  };

  notify = function(ref) {
    return copy(ref, ref);
  };

  watch = function(watchedRef, watchFn) {
    return watchRef.call(this, watchedRef, function() {
      return watchFn(get(watchedRef));
    });
  };

  watchRef = function(watchedRef, watchFn) {
    this.destructors.push(function() {
      return unwatchRef(watchedRef, watchFn);
    });
    return coreWatchRef(watchedRef, watchFn);
  };

  module.exports = {
    set: set,
    get: get,
    copy: copy,
    notify: notify,
    watch: watch,
    watchRef: watchRef
  };

}).call(this);

});

require.define("/lib/snuggle/core/template.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var evaluator, hogan, html, reader, render, renderRaw, renderTemplate, template;

  render = require('../../protocol/template').render;

  hogan = require('../../template/hogan');

  evaluator = require('../../core/evaluator');

  reader = require('../../core/reader');

  html = require('./html');

  template = function(id, element) {
    var partial, partialName, tmpl, _ref;
    if (id == null) {
      id = 'template';
    }
    if (element == null) {
      element = this.element;
    }
    tmpl = (element.find("script[data-id=" + id + "]")).eq(0);
    if ('text/mustache' === tmpl.attr('type')) {
      partialName = tmpl.data('partial');
      if (partialName) {
        partial = (_ref = this.frame.partials) != null ? _ref[partialName] : void 0;
        if (partial == null) {
          throw new Error("Partial not found " + partialName);
        }
        return hogan.tmpl(partial);
      } else {
        return hogan.tmpl(tmpl.html());
      }
    } else {
      throw new Error("Unkown type for template " + id);
    }
  };

  renderTemplate = function(tmpl, context) {
    var ast, element, tags;
    html = render(tmpl, context);
    tags = /^<.+>$/i.test($.trim(html.replace(/[\r\n]/gm, " ")));
    if (tags) {
      element = $(html);
    } else {
      element = this.html.span({}, html);
    }
    ast = reader.read(element, this.frame.__selector);
    evaluator.apply(ast, this.frame);
    return element;
  };

  renderRaw = function(tmpl, context) {
    return render(tmpl, context);
  };

  module.exports = {
    template: template,
    render: renderTemplate,
    renderRaw: renderRaw
  };

}).call(this);

});

require.define("/lib/protocol/template.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var defProtocol, dispatch, extend, isJqueryElement, isStr, proto, _ref;

  _ref = require('../core/protocol'), defProtocol = _ref.defProtocol, dispatch = _ref.dispatch, extend = _ref.extend;

  isStr = require('../core/native/string').isStr;

  module.exports = proto = defProtocol({
    render: dispatch(function(template, context) {})
  });

  extend(proto, isStr, {
    render: function(template, context) {
      return template;
    }
  });

  isJqueryElement = function(value) {
    return (value != null) && (value.jquery != null);
  };

  extend(proto, isJqueryElement, {
    render: function(template, context) {
      return template;
    }
  });

}).call(this);

});

require.define("/lib/template/hogan.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var HoganTemplate, assertObj, assertStr, assertTmpl, extend, hogan, isTmpl, renderTmpl, template, tmpl;

  assertObj = require('../core/native/object').assertObj;

  assertStr = require('../core/native/string').assertStr;

  extend = require('../core/protocol').extend;

  hogan = require('hogan.js');

  template = require('../protocol/template');

  HoganTemplate = (function() {

    function HoganTemplate(templateString) {
      assertStr(templateString, 'Invalid template string');
      this.template = hogan.compile(templateString);
    }

    return HoganTemplate;

  })();

  tmpl = function(templateString) {
    return new HoganTemplate(templateString);
  };

  isTmpl = function(value) {
    return value instanceof HoganTemplate;
  };

  assertTmpl = function(value) {
    if (!(isTmpl(value))) {
      throw new Error('Invalid template');
    }
    return value;
  };

  renderTmpl = function(template, context) {
    assertObj(context, 'Invalid context');
    return (assertTmpl(template)).template.render(context);
  };

  extend(template, isTmpl, {
    render: function(template, context) {
      return renderTmpl(template, context);
    }
  });

  module.exports = {
    tmpl: tmpl,
    isTmpl: isTmpl,
    renderTmpl: renderTmpl
  };

}).call(this);

});

require.define("/lib/core/native/object.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var assertObj, isArr, isObj;

  isArr = require('./array').isArr;

  isObj = function(value) {
    return (value != null) && (typeof value === 'object') && (!isArr(value));
  };

  assertObj = function(value, message) {
    if (message == null) {
      message = 'Invalid object';
    }
    if (!(isObj(value))) {
      throw new Error(message);
    }
    return value;
  };

  module.exports = {
    isObj: isObj,
    assertObj: assertObj
  };

}).call(this);

});

require.define("/node_modules/hogan.js/package.json",function(require,module,exports,__dirname,__filename,process,global){module.exports = {"main":"./lib/hogan.js"}
});

require.define("/node_modules/hogan.js/lib/hogan.js",function(require,module,exports,__dirname,__filename,process,global){/*
 *  Copyright 2011 Twitter, Inc.
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

// This file is for use with Node.js. See dist/ for browser files.

var Hogan = require('./compiler');
Hogan.Template = require('./template').Template;
module.exports = Hogan; 
});

require.define("/node_modules/hogan.js/lib/compiler.js",function(require,module,exports,__dirname,__filename,process,global){/*
 *  Copyright 2011 Twitter, Inc.
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

(function (Hogan) {
  // Setup regex  assignments
  // remove whitespace according to Mustache spec
  var rIsWhitespace = /\S/,
      rQuot = /\"/g,
      rNewline =  /\n/g,
      rCr = /\r/g,
      rSlash = /\\/g,
      tagTypes = {
        '#': 1, '^': 2, '/': 3,  '!': 4, '>': 5,
        '<': 6, '=': 7, '_v': 8, '{': 9, '&': 10
      };

  Hogan.scan = function scan(text, delimiters) {
    var len = text.length,
        IN_TEXT = 0,
        IN_TAG_TYPE = 1,
        IN_TAG = 2,
        state = IN_TEXT,
        tagType = null,
        tag = null,
        buf = '',
        tokens = [],
        seenTag = false,
        i = 0,
        lineStart = 0,
        otag = '{{',
        ctag = '}}';

    function addBuf() {
      if (buf.length > 0) {
        tokens.push(new String(buf));
        buf = '';
      }
    }

    function lineIsWhitespace() {
      var isAllWhitespace = true;
      for (var j = lineStart; j < tokens.length; j++) {
        isAllWhitespace =
          (tokens[j].tag && tagTypes[tokens[j].tag] < tagTypes['_v']) ||
          (!tokens[j].tag && tokens[j].match(rIsWhitespace) === null);
        if (!isAllWhitespace) {
          return false;
        }
      }

      return isAllWhitespace;
    }

    function filterLine(haveSeenTag, noNewLine) {
      addBuf();

      if (haveSeenTag && lineIsWhitespace()) {
        for (var j = lineStart, next; j < tokens.length; j++) {
          if (!tokens[j].tag) {
            if ((next = tokens[j+1]) && next.tag == '>') {
              // set indent to token value
              next.indent = tokens[j].toString()
            }
            tokens.splice(j, 1);
          }
        }
      } else if (!noNewLine) {
        tokens.push({tag:'\n'});
      }

      seenTag = false;
      lineStart = tokens.length;
    }

    function changeDelimiters(text, index) {
      var close = '=' + ctag,
          closeIndex = text.indexOf(close, index),
          delimiters = trim(
            text.substring(text.indexOf('=', index) + 1, closeIndex)
          ).split(' ');

      otag = delimiters[0];
      ctag = delimiters[1];

      return closeIndex + close.length - 1;
    }

    if (delimiters) {
      delimiters = delimiters.split(' ');
      otag = delimiters[0];
      ctag = delimiters[1];
    }

    for (i = 0; i < len; i++) {
      if (state == IN_TEXT) {
        if (tagChange(otag, text, i)) {
          --i;
          addBuf();
          state = IN_TAG_TYPE;
        } else {
          if (text.charAt(i) == '\n') {
            filterLine(seenTag);
          } else {
            buf += text.charAt(i);
          }
        }
      } else if (state == IN_TAG_TYPE) {
        i += otag.length - 1;
        tag = tagTypes[text.charAt(i + 1)];
        tagType = tag ? text.charAt(i + 1) : '_v';
        if (tagType == '=') {
          i = changeDelimiters(text, i);
          state = IN_TEXT;
        } else {
          if (tag) {
            i++;
          }
          state = IN_TAG;
        }
        seenTag = i;
      } else {
        if (tagChange(ctag, text, i)) {
          tokens.push({tag: tagType, n: trim(buf), otag: otag, ctag: ctag,
                       i: (tagType == '/') ? seenTag - ctag.length : i + otag.length});
          buf = '';
          i += ctag.length - 1;
          state = IN_TEXT;
          if (tagType == '{') {
            if (ctag == '}}') {
              i++;
            } else {
              cleanTripleStache(tokens[tokens.length - 1]);
            }
          }
        } else {
          buf += text.charAt(i);
        }
      }
    }

    filterLine(seenTag, true);

    return tokens;
  }

  function cleanTripleStache(token) {
    if (token.n.substr(token.n.length - 1) === '}') {
      token.n = token.n.substring(0, token.n.length - 1);
    }
  }

  function trim(s) {
    if (s.trim) {
      return s.trim();
    }

    return s.replace(/^\s*|\s*$/g, '');
  }

  function tagChange(tag, text, index) {
    if (text.charAt(index) != tag.charAt(0)) {
      return false;
    }

    for (var i = 1, l = tag.length; i < l; i++) {
      if (text.charAt(index + i) != tag.charAt(i)) {
        return false;
      }
    }

    return true;
  }

  function buildTree(tokens, kind, stack, customTags) {
    var instructions = [],
        opener = null,
        token = null;

    while (tokens.length > 0) {
      token = tokens.shift();
      if (token.tag == '#' || token.tag == '^' || isOpener(token, customTags)) {
        stack.push(token);
        token.nodes = buildTree(tokens, token.tag, stack, customTags);
        instructions.push(token);
      } else if (token.tag == '/') {
        if (stack.length === 0) {
          throw new Error('Closing tag without opener: /' + token.n);
        }
        opener = stack.pop();
        if (token.n != opener.n && !isCloser(token.n, opener.n, customTags)) {
          throw new Error('Nesting error: ' + opener.n + ' vs. ' + token.n);
        }
        opener.end = token.i;
        return instructions;
      } else {
        instructions.push(token);
      }
    }

    if (stack.length > 0) {
      throw new Error('missing closing tag: ' + stack.pop().n);
    }

    return instructions;
  }

  function isOpener(token, tags) {
    for (var i = 0, l = tags.length; i < l; i++) {
      if (tags[i].o == token.n) {
        token.tag = '#';
        return true;
      }
    }
  }

  function isCloser(close, open, tags) {
    for (var i = 0, l = tags.length; i < l; i++) {
      if (tags[i].c == close && tags[i].o == open) {
        return true;
      }
    }
  }

  function writeCode(tree) {
    return 'i = i || "";var b = i + "";var _ = this;' + walk(tree) + 'return b;';
  }

  Hogan.generate = function (code, text, options) {
    if (options.asString) {
      return 'function(c,p,i){' + code + ';}';
    }

    return new Hogan.Template(new Function('c', 'p', 'i', code), text, Hogan);
  }

  function esc(s) {
    return s.replace(rSlash, '\\\\')
            .replace(rQuot, '\\\"')
            .replace(rNewline, '\\n')
            .replace(rCr, '\\r');
  }

  function chooseMethod(s) {
    return (~s.indexOf('.')) ? 'd' : 'f';
  }

  function walk(tree) {
    var code = '';
    for (var i = 0, l = tree.length; i < l; i++) {
      var tag = tree[i].tag;
      if (tag == '#') {
        code += section(tree[i].nodes, tree[i].n, chooseMethod(tree[i].n),
                        tree[i].i, tree[i].end, tree[i].otag + " " + tree[i].ctag);
      } else if (tag == '^') {
        code += invertedSection(tree[i].nodes, tree[i].n,
                                chooseMethod(tree[i].n));
      } else if (tag == '<' || tag == '>') {
        code += partial(tree[i]);
      } else if (tag == '{' || tag == '&') {
        code += tripleStache(tree[i].n, chooseMethod(tree[i].n));
      } else if (tag == '\n') {
        code += text('"\\n"' + (tree.length-1 == i ? '' : ' + i'));
      } else if (tag == '_v') {
        code += variable(tree[i].n, chooseMethod(tree[i].n));
      } else if (tag === undefined) {
        code += text('"' + esc(tree[i]) + '"');
      }
    }
    return code;
  }

  function section(nodes, id, method, start, end, tags) {
    return 'if(_.s(_.' + method + '("' + esc(id) + '",c,p,1),' +
           'c,p,0,' + start + ',' + end + ', "' + tags + '")){' +
           'b += _.rs(c,p,' +
           'function(c,p){ var b = "";' +
           walk(nodes) +
           'return b;});c.pop();}' +
           'else{b += _.b; _.b = ""};';
  }

  function invertedSection(nodes, id, method) {
    return 'if (!_.s(_.' + method + '("' + esc(id) + '",c,p,1),c,p,1,0,0,"")){' +
           walk(nodes) +
           '};';
  }

  function partial(tok) {
    return 'b += _.rp("' +  esc(tok.n) + '",c,p,"' + (tok.indent || '') + '");';
  }

  function tripleStache(id, method) {
    return 'b += (_.' + method + '("' + esc(id) + '",c,p,0));';
  }

  function variable(id, method) {
    return 'b += (_.v(_.' + method + '("' + esc(id) + '",c,p,0)));';
  }

  function text(id) {
    return 'b += ' + id + ';';
  }

  Hogan.parse = function(tokens, options) {
    options = options || {};
    return buildTree(tokens, '', [], options.sectionTags || []);
  },

  Hogan.cache = {};

  Hogan.compile = function(text, options) {
    // options
    //
    // asString: false (default)
    //
    // sectionTags: [{o: '_foo', c: 'foo'}]
    // An array of object with o and c fields that indicate names for custom
    // section tags. The example above allows parsing of {{_foo}}{{/foo}}.
    //
    // delimiters: A string that overrides the default delimiters.
    // Example: "<% %>"
    //
    options = options || {};

    var key = text + '||' + !!options.asString;

    var t = this.cache[key];

    if (t) {
      return t;
    }

    t = this.generate(writeCode(this.parse(this.scan(text, options.delimiters), options)), text, options);
    return this.cache[key] = t;
  };
})(typeof exports !== 'undefined' ? exports : Hogan);

});

require.define("/node_modules/hogan.js/lib/template.js",function(require,module,exports,__dirname,__filename,process,global){/*
 *  Copyright 2011 Twitter, Inc.
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

var Hogan = {};

(function (Hogan) {
  Hogan.Template = function constructor(renderFunc, text, compiler) {
    if (renderFunc) {
      this.r = renderFunc;
    }
    this.c = compiler;
    this.text = text || '';
  }

  Hogan.Template.prototype = {
    // render: replaced by generated code.
    r: function (context, partials, indent) { return ''; },

    // variable escaping
    v: hoganEscape,

    render: function render(context, partials, indent) {
      return this.ri([context], partials || {}, indent);
    },

    // render internal -- a hook for overrides that catches partials too
    ri: function (context, partials, indent) {
      return this.r(context, partials, indent);
    },

    // tries to find a partial in the curent scope and render it
    rp: function(name, context, partials, indent) {
      var partial = partials[name];

      if (!partial) {
        return '';
      }

      if (this.c && typeof partial == 'string') {
        partial = this.c.compile(partial);
      }

      return partial.ri(context, partials, indent);
    },

    // render a section
    rs: function(context, partials, section) {
      var buf = '',
          tail = context[context.length - 1];

      if (!isArray(tail)) {
        return buf = section(context, partials);
      }

      for (var i = 0; i < tail.length; i++) {
        context.push(tail[i]);
        buf += section(context, partials);
        context.pop();
      }

      return buf;
    },

    // maybe start a section
    s: function(val, ctx, partials, inverted, start, end, tags) {
      var pass;

      if (isArray(val) && val.length === 0) {
        return false;
      }

      if (typeof val == 'function') {
        val = this.ls(val, ctx, partials, inverted, start, end, tags);
      }

      pass = (val === '') || !!val;

      if (!inverted && pass && ctx) {
        ctx.push((typeof val == 'object') ? val : ctx[ctx.length - 1]);
      }

      return pass;
    },

    // find values with dotted names
    d: function(key, ctx, partials, returnFound) {
      var names = key.split('.'),
          val = this.f(names[0], ctx, partials, returnFound),
          cx = null;

      if (key === '.' && isArray(ctx[ctx.length - 2])) {
        return ctx[ctx.length - 1];
      }

      for (var i = 1; i < names.length; i++) {
        if (val && typeof val == 'object' && names[i] in val) {
          cx = val;
          val = val[names[i]];
        } else {
          val = '';
        }
      }

      if (returnFound && !val) {
        return false;
      }

      if (!returnFound && typeof val == 'function') {
        ctx.push(cx);
        val = this.lv(val, ctx, partials);
        ctx.pop();
      }

      return val;
    },

    // find values with normal names
    f: function(key, ctx, partials, returnFound) {
      var val = false,
          v = null,
          found = false;

      for (var i = ctx.length - 1; i >= 0; i--) {
        v = ctx[i];
        if (v && typeof v == 'object' && key in v) {
          val = v[key];
          found = true;
          break;
        }
      }

      if (!found) {
        return (returnFound) ? false : "";
      }

      if (!returnFound && typeof val == 'function') {
        val = this.lv(val, ctx, partials);
      }

      return val;
    },

    // higher order templates
    ho: function(val, cx, partials, text, tags) {
      var compiler = this.c;
      var t = val.call(cx, text, function(t) {
        return compiler.compile(t, {delimiters: tags}).render(cx, partials);
      });
      var s = compiler.compile(t.toString(), {delimiters: tags}).render(cx, partials);
      this.b = s;
      return false;
    },

    // higher order template result buffer
    b: '',

    // lambda replace section
    ls: function(val, ctx, partials, inverted, start, end, tags) {
      var cx = ctx[ctx.length - 1],
          t = null;

      if (!inverted && this.c && val.length > 0) {
        return this.ho(val, cx, partials, this.text.substring(start, end), tags);
      }

      t = val.call(cx);

      if (typeof t == 'function') {
        if (inverted) {
          return true;
        } else if (this.c) {
          return this.ho(t, cx, partials, this.text.substring(start, end), tags);
        }
      }

      return t;
    },

    // lambda replace variable
    lv: function(val, ctx, partials) {
      var cx = ctx[ctx.length - 1];
      var result = val.call(cx);
      if (typeof result == 'function') {
        result = result.call(cx);
      }
      result = result.toString();

      if (this.c && ~result.indexOf("{{")) {
        return this.c.compile(result).render(cx, partials);
      }

      return result;
    }

  };

  var rAmp = /&/g,
      rLt = /</g,
      rGt = />/g,
      rApos =/\'/g,
      rQuot = /\"/g,
      hChars =/[&<>\"\']/;

  function hoganEscape(str) {
    str = String((str === null || str === undefined) ? '' : str);
    return hChars.test(str) ?
      str
        .replace(rAmp,'&amp;')
        .replace(rLt,'&lt;')
        .replace(rGt,'&gt;')
        .replace(rApos,'&#39;')
        .replace(rQuot, '&quot;') :
      str;
  }

  var isArray = Array.isArray || function(a) {
    return Object.prototype.toString.call(a) === '[object Array]';
  };

})(typeof exports !== 'undefined' ? exports : Hogan);


});

require.define("/lib/snuggle/core/html.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var html, tag, tags, _fn, _i, _len;

  html = function(tag, attrs, content) {
    var element;
    element = $("<" + tag + " />");
    element.attr(attrs);
    element.html(content);
    return element;
  };

  tags = ["a", "abbr", "acronym", "address", "applet", "area", "b", "base", "basefont", "bdo", "big", "blockquote", "body", "br", "button", "caption", "center", "cite", "code", "col", "colgroup", "dd", "del", "dfn", "dir", "div", "dl", "dt", "em", "fieldset", "font", "form", "frame", "frameset", "h1", "h2", "h3", "h4", "h5", "h6", "head", "hr", "html", "i", "iframe", "img", "input", "ins", "isindex", "kbd", "label", "legend", "li", "link", "map", "menu", "meta", "noframes", "noscript", "object", "ol", "optgroup", "option", "p", "param", "pre", "q", "s", "samp", "script", "select", "small", "span", "strike", "strong", "style", "sub", "sup", "table", "tbody", "td", "textarea", "tfoot", "th", "thead", "title", "tr", "tt", "u", "ul", "var"];

  _fn = function(tag) {
    return exports[tag] = function(attrs, content) {
      return html(tag, attrs, content);
    };
  };
  for (_i = 0, _len = tags.length; _i < _len; _i++) {
    tag = tags[_i];
    _fn(tag);
  }

}).call(this);

});

require.define("/lib/snuggle/core/list.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var contains, count, get, isArr, isCollection, isList, isRef, push, remove, removeItem, set, _ref;

  isArr = require('../../core/native/array').isArr;

  isCollection = require('../../core/collection').isCollection;

  isRef = require('../../core/reference').isRef;

  _ref = require('../../protocol/mutable'), get = _ref.get, set = _ref.set;

  isList = function(type) {
    return (isArr(type)) || (isCollection(type));
  };

  count = function(list) {
    if (isRef(list)) {
      return count(get(list));
    }
    if (list.length != null) {
      return list.length;
    } else {
      return 0;
    }
  };

  push = function(list, item) {
    var lst;
    if (isRef(list)) {
      lst = (get(list)) || [];
      return set(list, lst.concat([item]));
    } else {
      return list.push(item);
    }
  };

  removeItem = function(list, item) {
    var i, lst, x, _i, _len, _ref1, _results;
    if (isRef(list)) {
      lst = get(list);
      removeItem(lst, item);
      return set(list, lst);
    } else {
      _results = [];
      for (i = _i = 0, _len = list.length; _i < _len; i = ++_i) {
        x = list[i];
        _results.push(item === x ? ([].splice.apply(list, [i, i - i + 1].concat(_ref1 = [])), _ref1) : void 0);
      }
      return _results;
    }
  };

  remove = function(list, index) {
    var lst, _ref1;
    if (isRef(list)) {
      lst = get(list);
      remove(lst, index);
      return set(list, lst);
    } else {
      return ([].splice.apply(list, [index, index - index + 1].concat(_ref1 = [])), _ref1);
    }
  };

  contains = function(list, item) {
    var x, _i, _len;
    if (list == null) {
      return false;
    }
    if (isRef(list)) {
      return contains(get(list), item);
    } else {
      for (_i = 0, _len = list.length; _i < _len; _i++) {
        x = list[_i];
        if (item === x) {
          return true;
        }
      }
    }
    return false;
  };

  module.exports = {
    count: count,
    isList: isList,
    push: push,
    remove: remove,
    removeItem: removeItem,
    contains: contains
  };

}).call(this);

});

require.define("/lib/core/collection.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var Collection, collection, isArr, isCollection, isFn, map, mapItem, mutable, notify, reference, vec, _ref,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __slice = [].slice;

  isArr = require('./native/array').isArr;

  isFn = require('./native/function').isFn;

  mutable = require('../protocol/mutable');

  _ref = require('./list'), vec = _ref.vec, map = _ref.map;

  reference = require('./reference');

  mapItem = function(item) {
    if (reference.isRef(item)) {
      return item;
    } else {
      return reference.ref(item);
    }
  };

  notify = function(fnList, index) {
    var fn, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = fnList.length; _i < _len; _i++) {
      fn = fnList[_i];
      _results.push(typeof fn === "function" ? fn(index) : void 0);
    }
    return _results;
  };

  Collection = (function(_super) {

    __extends(Collection, _super);

    function Collection(ref) {
      var newValues;
      this.ref = ref;
      this.onUpdate = __bind(this.onUpdate, this);

      this.onRemove = __bind(this.onRemove, this);

      this.onPrepend = __bind(this.onPrepend, this);

      this.onAppend = __bind(this.onAppend, this);

      this.removeAll = __bind(this.removeAll, this);

      this.remove = __bind(this.remove, this);

      this.removeFn = __bind(this.removeFn, this);

      this.removeItem = __bind(this.removeItem, this);

      this.indexOf = __bind(this.indexOf, this);

      this.splice = __bind(this.splice, this);

      this.shift = __bind(this.shift, this);

      this.pop = __bind(this.pop, this);

      this.push = __bind(this.push, this);

      Collection.__super__.constructor.call(this);
      newValues = vec(map(mapItem, mutable.get(this.ref)));
      Array.prototype.push.apply(this, newValues);
      this.append = [];
      this.prepend = [];
      this.removed = [];
      this.update = [];
    }

    Collection.prototype.push = function(item) {
      var result;
      result = Collection.__super__.push.call(this, mapItem(item));
      notify(this.append, this.length - 1);
      reference.notifyRef(this.ref);
      return result;
    };

    Collection.prototype.pop = function() {
      var result;
      result = Collection.__super__.pop.call(this);
      if (result != null) {
        notify(this.removed, result);
        reference.notifyRef(this.ref);
        return mutable.get(result);
      }
    };

    Collection.prototype.unshift = function(item) {
      var result;
      result = Collection.__super__.unshift.call(this, mapItem(item));
      notify(this.prepend, 0);
      reference.notifyRef(this.ref);
      return result;
    };

    Collection.prototype.shift = function() {
      var result;
      result = Collection.__super__.shift.call(this);
      if (result != null) {
        notify(this.removed, result);
        reference.notifyRef(this.ref);
        return mutable.get(result);
      }
    };

    Collection.prototype.splice = function() {
      var args, item, result, _i, _j, _len, _len1, _results;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      result = Collection.__super__.splice.apply(this, args);
      if (result != null) {
        for (_i = 0, _len = result.length; _i < _len; _i++) {
          item = result[_i];
          notify(this.removed, item);
        }
        reference.notifyRef(this.ref);
        _results = [];
        for (_j = 0, _len1 = result.length; _j < _len1; _j++) {
          item = result[_j];
          _results.push(mutable.get(item));
        }
        return _results;
      }
    };

    Collection.prototype.indexOf = function(item) {
      var i, x, _i, _len;
      if (reference.isRef(item)) {
        return this.indexOf(mutable.get(item));
      }
      for (i = _i = 0, _len = this.length; _i < _len; i = ++_i) {
        x = this[i];
        if (item === mutable.get(x)) {
          return i;
        }
      }
    };

    Collection.prototype.removeItem = function(item) {
      var i, ref, _ref1;
      i = this.indexOf(item);
      if (i != null) {
        ref = this[i];
        [].splice.apply(this, [i, i - i + 1].concat(_ref1 = [])), _ref1;
        notify(this.removed, ref);
        return true;
      }
    };

    Collection.prototype.removeFn = function(fn) {
      var items, removed, x, _i, _j, _len, _len1;
      removed = false;
      items = [];
      for (_i = 0, _len = this.length; _i < _len; _i++) {
        x = this[_i];
        if (fn(mutable.get(x))) {
          items.push(x);
        }
      }
      for (_j = 0, _len1 = items.length; _j < _len1; _j++) {
        x = items[_j];
        this.removeItem(x);
        removed = true;
      }
      return removed;
    };

    Collection.prototype.remove = function(arg) {
      var removed;
      if (isFn(arg)) {
        removed = this.removeFn(arg);
      } else {
        removed = this.removeItem(arg);
      }
      if (removed) {
        reference.notifyRef(this.ref);
      }
      return removed;
    };

    Collection.prototype.removeAll = function() {
      if (this.length > 0) {
        return this.remove(function() {
          return true;
        });
      } else {
        return notify(this.update);
      }
    };

    Collection.prototype.onAppend = function(fn) {
      return this.append.push(fn);
    };

    Collection.prototype.onPrepend = function(fn) {
      return this.prepend.push(fn);
    };

    Collection.prototype.onRemove = function(fn) {
      return this.removed.push(fn);
    };

    Collection.prototype.onUpdate = function(fn) {
      return this.update.push(fn);
    };

    return Collection;

  })(Array);

  collection = function(ref) {
    return new Collection(ref);
  };

  isCollection = function(type) {
    return type instanceof Collection;
  };

  module.exports = {
    collection: collection,
    isCollection: isCollection
  };

}).call(this);

});

require.define("/lib/snuggle/core/form.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var children, eventFn, filter, formTags, getForm, hashMap, into, isFormElement, map, reduce, reset, submit, toObject, _ref,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  children = require('../../protocol/element').children;

  _ref = require('../../core/list'), filter = _ref.filter, map = _ref.map, reduce = _ref.reduce;

  into = require('../../protocol/list').into;

  hashMap = require('../../core/hashMap').hashMap;

  formTags = ["input", "select", "textarea", "button"];

  isFormElement = function(element) {
    var hasName, _ref1;
    if (element[0] == null) {
      return false;
    }
    hasName = (element.attr('name')) || (element.attr('id'));
    return (_ref1 = element[0].tagName.toLowerCase(), __indexOf.call(formTags, _ref1) >= 0) && hasName;
  };

  getForm = function(element) {
    if (element == null) {
      element = this.element;
    }
    if (element.is('form')) {
      return element;
    }
    return (element.find('form')).eq(0);
  };

  eventFn = function(fn) {
    return function(event) {
      return fn({
        event: event,
        element: $(event.target),
        stop: function() {
          return event.preventDefault();
        }
      });
    };
  };

  submit = function(fn, element) {
    var form;
    form = getForm.call(this, element);
    return form.submit(eventFn(fn));
  };

  reset = function(fn, element) {
    var form;
    form = getForm.call(this, element);
    return form.on('reset', eventFn(fn));
  };

  toObject = function(element) {
    var mapElement;
    if (element == null) {
      element = this.element;
    }
    mapElement = function(elem) {
      var name, obj;
      obj = {};
      name = (elem.attr('name')) || (elem.attr('id'));
      obj[name] = elem.val();
      return hashMap(obj);
    };
    return reduce(into, map(mapElement, filter(isFormElement, map($, (element.find(formTags.join(', '))).toArray()))));
  };

  module.exports = {
    submit: submit,
    reset: reset,
    toObject: toObject,
    getForm: getForm
  };

}).call(this);

});

require.define("/lib/snuggle/core/state.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var State, addState, get, ref, removeState, set, state, watchRef, _ref, _ref1;

  _ref = require('../../core/reference'), ref = _ref.ref, watchRef = _ref.watchRef;

  _ref1 = require('../../protocol/mutable'), get = _ref1.get, set = _ref1.set;

  removeState = function(element, name) {
    element.addClass("is-not-" + name);
    element.removeClass("is-" + name);
    return element.removeAttr("data-is-" + name);
  };

  addState = function(element, name) {
    element.addClass("is-" + name);
    element.removeClass("is-not-" + name);
    return element.attr("data-is-" + name, true);
  };

  State = (function() {

    function State(element, name, def) {
      var value;
      value = ref();
      this.on = function() {
        return set(value, true);
      };
      this.off = function() {
        return set(value, false);
      };
      this.toggle = function() {
        return set(value, !(get(value)));
      };
      this.get = function() {
        return get(value);
      };
      watchRef(value, function() {
        if (get(value)) {
          return addState(element, name);
        } else {
          return removeState(element, name);
        }
      });
      set(value, def);
    }

    return State;

  })();

  state = function(name, def, element) {
    if (element == null) {
      element = this.element;
    }
    return new State(element, name, def);
  };

  module.exports = {
    state: state
  };

}).call(this);

});

require.define("/lib/snuggle/core/global.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var createRef, get, getOrInitRef, map, mutable, set;

  createRef = require('../../core/reference').ref;

  map = require('../../protocol/map');

  mutable = require('../../protocol/mutable');

  get = function(name) {
    var globals, ref;
    globals = mutable.get(map.get(this.frame, 'global'));
    ref = globals[name];
    if (ref != null) {
      return mutable.get(ref);
    } else {
      throw new Error("Unknown ref");
    }
  };

  getOrInitRef = function(name) {
    var globals, ref;
    globals = mutable.get(map.get(this.frame, 'global'));
    ref = globals[name];
    if (ref == null) {
      ref = createRef();
    }
    globals[name] = ref;
    mutable.set(map.get(this.frame, 'global'), globals);
    return ref;
  };

  set = function(name, value) {
    var ref;
    ref = getOrInitRef.call(this, name);
    return mutable.set(ref, value);
  };

  module.exports = {
    getOrInitRef: getOrInitRef,
    get: get,
    set: set
  };

}).call(this);

});

require.define("/lib/snuggle/cosy.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var deprecatedMsgSent, importObj, nsDeprecated, use,
    __slice = [].slice;

  use = require('../core/evaluator').use;

  deprecatedMsgSent = false;

  nsDeprecated = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    if (deprecatedMsgSent === false) {
      console.log('`ns` is deprecated, please use `import`');
      deprecatedMsgSent = true;
    }
    return use.apply(null, args);
  };

  importObj = function() {
    var args, frame, obj;
    frame = arguments[0], obj = arguments[1], args = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
    if (obj == null) {
      return frame;
    }
    frame = use(frame, obj);
    return importObj.apply(null, [frame].concat(__slice.call(args)));
  };

  module.exports = {
    control: require('./cosy/control'),
    "class": require('./cosy/class'),
    props: require('./cosy/props'),
    attach: require('./cosy/attach'),
    call: require('./cosy/call'),
    partial: require('./cosy/partial').partial,
    "import": importObj,
    ns: nsDeprecated
  };

}).call(this);

});

require.define("/lib/snuggle/cosy/control.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var Control, control, evaluate, extend, instance, isFn, isRef, map, mutable, parseArgs, registerChild, use, watchRef, _ref, _ref1,
    __hasProp = {}.hasOwnProperty,
    __slice = [].slice,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  map = require('../../protocol/map');

  mutable = require('../../protocol/mutable');

  _ref = require('../../core/reference'), isRef = _ref.isRef, watchRef = _ref.watchRef;

  _ref1 = require('../../core/evaluator'), evaluate = _ref1.evaluate, use = _ref1.use;

  isFn = require('../../core/native/function').isFn;

  parseArgs = function(args, instance) {
    var arg, newArgs, _i, _len;
    newArgs = [];
    for (_i = 0, _len = args.length; _i < _len; _i++) {
      arg = args[_i];
      newArgs.push((isRef(arg)) && (arg.metadata.controls[instance].passRef !== true) ? mutable.get(arg) : arg);
    }
    return newArgs;
  };

  extend = function(tgtObj, srcObj, ctx) {
    var name, value, _results;
    _results = [];
    for (name in srcObj) {
      if (!__hasProp.call(srcObj, name)) continue;
      value = srcObj[name];
      _results.push((function(name, value) {
        if (isFn(value)) {
          return tgtObj[name] = function() {
            var args;
            args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
            return value.apply(ctx, args);
          };
        } else {
          tgtObj[name] = {};
          return extend(tgtObj[name], value, ctx);
        }
      })(name, value));
    }
    return _results;
  };

  registerChild = function(frame, child) {
    if (frame == null) {
      return;
    }
    if (frame.__control != null) {
      return frame.__control.children.push(child);
    } else if (frame !== frame.__parent) {
      return registerChild(frame.__parent, child);
    }
  };

  instance = 0;

  Control = (function() {

    function Control(frame, fn, args) {
      var apply, arg, index, ns, parts, _base, _base1, _base2, _base3, _i, _j, _len, _len1, _name, _name1, _ref2, _ref3, _ref4, _ref5,
        _this = this;
      this.frame = frame;
      this.destroy = __bind(this.destroy, this);

      this.empty = __bind(this.empty, this);

      if (!isFn(fn)) {
        if (this.frame.__parentNS != null) {
          return evaluate(['control', fn].concat(args), use(this.frame, this.frame.__parentNS));
        } else {
          throw new Error(fn + ' control not found');
        }
      }
      instance += 1;
      this.instance = instance;
      this.destructors = [];
      this.children = [];
      registerChild(this.frame, this);
      this.frame.__control = this;
      apply = function() {
        var newArgs;
        newArgs = parseArgs(args, _this.instance);
        return fn.apply(_this, newArgs);
      };
      ns = map.get(this.frame, 'namespace');
      extend(this, ns, this);
      this.cosy = {
        control: function() {
          var args;
          args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          return evaluate(['control'].concat(args), frame);
        },
        cmd: function(element, cmd) {
          var newFrame;
          newFrame = map.assoc(frame, "__node", element);
          return evaluate(cmd, newFrame);
        }
      };
      this.props = map.get(this.frame, 'refs');
      this.element = map.get(this.frame, '__node');
      for (index = _i = 0, _len = args.length; _i < _len; index = ++_i) {
        arg = args[index];
        parts = /^([&])?(@|%)(.*)$/.exec(arg);
        if (isRef(args[index])) {
          if ((_ref2 = (_base = args[index].metadata).controls) == null) {
            _base.controls = {};
          }
          if ((_ref3 = (_base1 = args[index].metadata.controls)[_name = this.instance]) == null) {
            _base1[_name] = {};
          }
          args[index].metadata.controls[this.instance].passRef = true;
        }
        if ((parts != null) && parts[2] === '@' && (parts[3] != null)) {
          args[index] = this.props[parts[3]];
        }
        if ((parts != null) && parts[2] === '%' && (parts[3] != null)) {
          args[index] = this.global.getOrInitRef(parts[3]);
        }
        if (isRef(args[index])) {
          if ((_ref4 = (_base2 = args[index].metadata).controls) == null) {
            _base2.controls = {};
          }
          if ((_ref5 = (_base3 = args[index].metadata.controls)[_name1 = this.instance]) == null) {
            _base3[_name1] = {};
          }
          if ((parts != null) && parts[1] === '&') {
            args[index].metadata.controls[this.instance].passRef = true;
          }
          this.destructors.push((function(controls, index) {
            return function() {
              if (controls[index] != null) {
                return delete controls[index];
              }
            };
          })(args[index].metadata.controls, this.instance));
        }
      }
      for (_j = 0, _len1 = args.length; _j < _len1; _j++) {
        arg = args[_j];
        if (isRef(arg)) {
          this.watchRef(arg, apply);
        }
      }
      this.isInitialising = true;
      apply();
      this.isInitialising = false;
    }

    Control.prototype.empty = function() {
      var child;
      while (child = this.children.pop()) {
        child.destroy();
      }
      return this.element.html('');
    };

    Control.prototype.destroy = function() {
      var fn, _i, _len, _ref2;
      this.empty();
      _ref2 = this.destructors;
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        fn = _ref2[_i];
        fn();
      }
      return this.element.remove();
    };

    return Control;

  })();

  control = function() {
    var args, fn, frame;
    frame = arguments[0], fn = arguments[1], args = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
    new Control(frame, fn, args);
    return frame;
  };

  control.raw = /^&?[%@].+$/;

  module.exports = control;

}).call(this);

});

require.define("/lib/snuggle/cosy/class.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var classControl, cosyClass, evaluate, isFn, use, _ref,
    __slice = [].slice;

  isFn = require('../../core/native/function').isFn;

  _ref = require('../../core/evaluator'), evaluate = _ref.evaluate, use = _ref.use;

  classControl = function(constructor) {
    return function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (this.isInitialising) {
        this.isInitialising = false;
        return this.frame["this"] = (function(func, args, ctor) {
          ctor.prototype = func.prototype;
          var child = new ctor, result = func.apply(child, args), t = typeof result;
          return t == "object" || t == "function" ? result || child : child;
        })(constructor, [this].concat(__slice.call(args)), function(){});
      } else if (isFn(this.update)) {
        return this.update.apply(this, args);
      }
    };
  };

  cosyClass = function() {
    var args, constructor, control, frame;
    frame = arguments[0], constructor = arguments[1], args = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
    control = classControl(constructor);
    return frame.control.apply(frame, [frame, control].concat(__slice.call(args)));
  };

  cosyClass.raw = /^&?[%@].+$/;

  module.exports = cosyClass;

}).call(this);

});

require.define("/lib/snuggle/cosy/props.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var assoc, get, isRef, props, ref, _ref, _ref1,
    __slice = [].slice;

  _ref = require('../../core/reference'), ref = _ref.ref, isRef = _ref.isRef;

  _ref1 = require('../../protocol/map'), get = _ref1.get, assoc = _ref1.assoc;

  props = function() {
    var arg, args, frame, refs, _i, _len;
    frame = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    refs = (get(frame, 'refs')) || {};
    for (_i = 0, _len = args.length; _i < _len; _i++) {
      arg = args[_i];
      if (!isRef(refs[arg])) {
        refs[arg] = ref();
      }
    }
    frame['refs'] = refs;
    return frame;
  };

  props.raw = /^[^"'].*$/;

  module.exports = props;

}).call(this);

});

require.define("/lib/snuggle/cosy/attach.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var attach;

  attach = function(frame, delay) {
    frame.__node[0].frame = frame;
    if (delay === 'delay') {
      frame.__delay = true;
    }
    return frame;
  };

  module.exports = attach;

}).call(this);

});

require.define("/lib/snuggle/cosy/call.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var call,
    __slice = [].slice;

  call = function() {
    var args, fn, frame;
    frame = arguments[0], fn = arguments[1], args = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
    fn.apply(null, [frame.__node].concat(__slice.call(args)));
    return frame;
  };

  module.exports = call;

}).call(this);

});

require.define("/lib/snuggle/cosy/partial.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var partial;

  partial = function(frame, name) {
    var _base, _ref;
    if ((_ref = (_base = frame.__parent).partials) == null) {
      _base.partials = {};
    }
    frame.__parent.partials[name] = frame.__node.html();
    return frame;
  };

  partial.raw = /^[^"'].*$/;

  module.exports = {
    partial: partial
  };

}).call(this);

});

require.define("/lib/snuggle/control.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  module.exports = {
    List: (require('./control/list')).List,
    Tree: (require('./control/tree')).Tree
  };

}).call(this);

});

require.define("/lib/snuggle/control/list.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var List, collection, createRef, instance, isCollection, isRef, mutable, notifyRef, _ref, _ref1,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  _ref = require('../../core/collection'), collection = _ref.collection, isCollection = _ref.isCollection;

  mutable = require('../../protocol/mutable');

  _ref1 = require('../../core/reference'), isRef = _ref1.isRef, createRef = _ref1.ref, notifyRef = _ref1.notifyRef;

  instance = 0;

  List = (function() {

    function List(control, ref, itemTemplate) {
      var data, element, index, item, itemData, items, _base, _i, _len, _ref2, _ref3;
      this.control = control;
      this.itemTemplate = itemTemplate;
      this.renderAll = __bind(this.renderAll, this);

      this.remove = __bind(this.remove, this);

      this.prepend = __bind(this.prepend, this);

      this.append = __bind(this.append, this);

      this.render = __bind(this.render, this);

      this.filter = __bind(this.filter, this);

      if (!isRef(ref)) {
        throw new Error("First argument must be a reference");
      }
      instance += 1;
      this.instance = instance;
      this.ref = ref;
      this.collection = mutable.get(ref);
      if (!isCollection(this.collection)) {
        this.collection = collection(ref);
        mutable.set(ref, this.collection);
      }
      items = this.control.element.children('[data-item]');
      for (index = _i = 0, _len = items.length; _i < _len; index = ++_i) {
        item = items[index];
        element = items.eq(index);
        itemData = (element.data('item')) || {};
        data = createRef(itemData);
        if ((_ref2 = (_base = data.metadata).listElements) == null) {
          _base.listElements = {};
        }
        data.metadata.listElements[this.instance] = element;
        this.collection.push(data);
      }
      if ((_ref3 = this.itemTemplate) == null) {
        this.itemTemplate = this.control.template('item');
      }
      this.collection.onAppend(this.append);
      this.collection.onPrepend(this.prepend);
      this.collection.onRemove(this.remove);
      this.collection.onUpdate(this.update);
      this.renderAll();
    }

    List.prototype.filter = function(item) {
      return true;
    };

    List.prototype.render = function(index) {
      var control, item, node, oldNode, _base, _i, _len, _ref2, _ref3,
        _this = this;
      item = this.collection[index];
      if (!this.filter(mutable.get(item))) {
        return;
      }
      this.control.frame.item = item;
      if ((_ref2 = (_base = item.metadata).listElements) == null) {
        _base.listElements = {};
      }
      node = this.control.render(this.itemTemplate, mutable.get(item));
      oldNode = item.metadata.listElements[this.instance];
      item.metadata.listElements[this.instance] = node;
      if (oldNode != null) {
        node.insertAfter(oldNode);
        _ref3 = this.control.children;
        for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
          control = _ref3[_i];
          if (oldNode === control.element) {
            control.destroy();
            oldNode = null;
          }
        }
        if (oldNode) {
          oldNode.remove();
        }
      } else {
        this.control.watchRef(item, function() {
          _this.render(index);
          return notifyRef(_this.ref);
        });
      }
      return node;
    };

    List.prototype.append = function(index) {
      var node;
      node = this.render(index);
      if (node != null) {
        return this.control.element.append(node);
      }
    };

    List.prototype.prepend = function(index) {
      var node;
      node = this.render(index);
      if (node != null) {
        return this.control.element.prepend(node);
      }
    };

    List.prototype.remove = function(ref) {
      var control, element, _i, _len, _ref2, _ref3, _ref4;
      if (((_ref2 = ref.metadata) != null ? (_ref3 = _ref2.listElements) != null ? _ref3[this.instance] : void 0 : void 0) == null) {
        return;
      }
      element = ref.metadata.listElements[this.instance];
      delete ref.metadata.listElements[this.instance];
      _ref4 = this.control.children;
      for (_i = 0, _len = _ref4.length; _i < _len; _i++) {
        control = _ref4[_i];
        if (element === control.element) {
          control.destroy();
          element = null;
        }
      }
      if (element != null) {
        return element.remove();
      }
    };

    List.prototype.renderAll = function() {
      var index, item, _i, _len, _ref2, _ref3, _ref4, _results;
      this.control.element.html('');
      _ref2 = this.collection;
      _results = [];
      for (index = _i = 0, _len = _ref2.length; _i < _len; index = ++_i) {
        item = _ref2[index];
        if (((_ref3 = item.metadata) != null ? (_ref4 = _ref3.listElements) != null ? _ref4[this.instance] : void 0 : void 0) != null) {
          _results.push(this.control.element.append(item.metadata.listElements[this.instance]));
        } else {
          _results.push(this.append(index));
        }
      }
      return _results;
    };

    return List;

  })();

  module.exports = {
    List: List
  };

}).call(this);

});

require.define("/lib/snuggle/control/tree.js",function(require,module,exports,__dirname,__filename,process,global){// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var List, Tree, createRef, isRef, _ref;

  List = require('./list').List;

  _ref = require('../../core/reference'), isRef = _ref.isRef, createRef = _ref.ref;

  Tree = (function() {

    function Tree(control, ref, template) {
      var childElement, list;
      this.control = control;
      list = new List(this.control, ref, template);
      childElement = this.control.role('children');
      if (childElement.length > 0) {
        ref.value.children = createRef();
        this.control.cosy.cmd(childElement, ['class', Tree, ref.value.children, list.itemTemplate]);
      }
    }

    return Tree;

  })();

  module.exports = {
    Tree: Tree
  };

}).call(this);

});

require.define("/example/expander/script/bootstrap.js",function(require,module,exports,__dirname,__filename,process,global){(function($, snuggle) {

    // Define the controls
    var controls = {
        example: {
            expander: require('./expander.js').expander
        }
    };

    // Snuggle up!
    snuggle.up($('body'), controls, {}, false);

})(jQuery, require('../lib/cosy.js').snuggle);

});
require("/example/expander/script/bootstrap.js");
})();
