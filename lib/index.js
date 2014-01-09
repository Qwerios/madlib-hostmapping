(function() {
  (function(factory) {
    if (typeof exports === "object") {
      return module.exports = factory(require("madLib-console"), require("madlib-settings"), require("madLib-object-utils"));
    } else if (typeof define === "function" && define.amd) {
      return define(["madLib-console", "madlib-settings", "madLib-object-utils"], factory);
    }
  })(function(console, settings, objectUtils) {
    var HostMapping;
    settings.init("hostConfig", {});
    settings.init("hostMapping", {});
    settings.init("xdmConfig", {});
    HostMapping = (function() {
      function HostMapping() {}

      HostMapping.prototype.overrideMapping = function(newMapping) {
        return settings.set("currentHostMapping", newMapping);
      };

      HostMapping.prototype.determineTarget = function(hostname) {
        var allHostMappings;
        overrideMapping(settings.get("overrideMapping"));
        if (typeof overrideMapping !== "undefined" && overrideMapping !== null) {
          settings.set("currentHostMapping", overrideMapping);
          return console.log("[hostMapping] Override active: " + settings.overrideMapping);
        } else {
          allHostMappings = settings.get("hostMapping");
          if ((hostname == null) && (typeof document !== "undefined" && document !== null)) {
            if (typeof document !== "undefined" && document !== null) {
              hostname = document.location.hostname;
            }
          }
          if (allHostMappings[hostname] != null) {
            settings.set("currentHostMapping", allHostMappings[hostname]);
            return console.log("[hostMapping] Target found: " + settings.currentMapping);
          } else {
            settings.set("currentHostMapping", "production");
            return console.log("[hostMapping] No target found, defaulting to production");
          }
        }
      };

      HostMapping.prototype.getHostName = function(hostType) {
        var allHostConfigs, currentHostMapping;
        if (hostType == null) {
          hostType = "api";
        }
        if (settings.get("currentHostMapping") == null) {
          this.determineTarget();
        }
        allHostConfigs = settings.get("hostConfig");
        currentHostMapping = settings.get("currentHostMapping");
        return objectUtils.getValue("" + currentHostMapping + "." + hostType, allHostConfigs);
      };

      HostMapping.prototype.getXdmSettings = function(hostName) {
        var allXdmConfigs, cleanHostName;
        cleanHostName = this.extractHostName(hostName);
        allXdmConfigs = settings.get("xdmConfig");
        return allXdmConfigs[cleanHostName];
      };

      HostMapping.prototype.extractHostName = function(url) {
        return url.replace(/(^https?:)?\/\//, "").split("/").slice(0, 1).pop().split(":").slice(0, 1).pop();
      };

      return HostMapping;

    })();
    return new HostMapping();
  });

}).call(this);
