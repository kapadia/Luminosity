

(function(/*! Stitch !*/) {
  if (!this.specs) {
    var modules = {}, cache = {}, require = function(name, root) {
      var path = expand(root, name), module = cache[path], fn;
      if (module) {
        return module.exports;
      } else if (fn = modules[path] || modules[path = expand(path, './index')]) {
        module = {id: path, exports: {}};
        try {
          cache[path] = module;
          fn(module.exports, function(name) {
            return require(name, dirname(path));
          }, module);
          return module.exports;
        } catch (err) {
          delete cache[path];
          throw err;
        }
      } else {
        throw 'module \'' + name + '\' not found';
      }
    }, expand = function(root, name) {
      var results = [], parts, part;
      if (/^\.\.?(\/|$)/.test(name)) {
        parts = [root, name].join('/').split('/');
      } else {
        parts = name.split('/');
      }
      for (var i = 0, length = parts.length; i < length; i++) {
        part = parts[i];
        if (part == '..') {
          results.pop();
        } else if (part != '.' && part != '') {
          results.push(part);
        }
      }
      return results.join('/');
    }, dirname = function(path) {
      return path.split('/').slice(0, -1).join('/');
    };
    this.specs = function(name) {
      return require(name, '');
    }
    this.specs.define = function(bundle) {
      for (var key in bundle)
        modules[key] = bundle[key];
    };
    this.specs.modules = modules;
    this.specs.cache   = cache;
  }
  return this.specs.define;
}).call(this)({
  "controllers/BinaryTable": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('BinaryTable', function() {
    var BinaryTable;
    BinaryTable = require('controllers/binarytable');
    return it('can noop', function() {});
  });

}).call(this);
}, "controllers/CompressedImage": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('CompressedImage', function() {
    var CompressedImage;
    CompressedImage = require('controllers/compressedimage');
    return it('can noop', function() {});
  });

}).call(this);
}, "controllers/DataCube": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('DataCube', function() {
    var DataCube;
    DataCube = require('controllers/datacube');
    return it('can noop', function() {});
  });

}).call(this);
}, "controllers/Drop": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('Drop', function() {
    var Drop;
    Drop = require('controllers/drop');
    return it('can noop', function() {});
  });

}).call(this);
}, "controllers/FitsHandler": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('FitsHandler', function() {
    var FitsHandler;
    FitsHandler = require('controllers/fitshandler');
    return it('can noop', function() {});
  });

}).call(this);
}, "controllers/Image": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('Image', function() {
    var Image;
    Image = require('controllers/image');
    return it('can noop', function() {});
  });

}).call(this);
}, "controllers/Table": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('Table', function() {
    var Table;
    Table = require('controllers/table');
    return it('can noop', function() {});
  });

}).call(this);
}, "models/Source": function(exports, require, module) {(function() {
  var require;

  require = window.require;

  describe('Source', function() {
    var Source;
    Source = require('models/source');
    return it('can noop', function() {});
  });

}).call(this);
}
});

require('lib/setup'); for (var key in specs.modules) specs(key);