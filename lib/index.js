(function() {
  (function(factory) {
    if (typeof exports === "object") {
      return module.exports = factory(require("madLib-console"), require("madLib-object-utils"));
    } else if (typeof define === "function" && define.amd) {
      return define(["madLib-console", "madLib-object-utils"], factory);
    }
  })(function(console, objectUtils) {
    var HostMapping;
    return HostMapping = (function() {
      function HostMapping(settings) {
        settings.init("hostConfig", {});
        settings.init("hostMapping", {});
        settings.init("xdmConfig", {});
        this.settings = settings;
      }

      HostMapping.prototype.overrideMapping = function(newMapping) {
        return this.settings.set("currentHostMapping", newMapping);
      };

      HostMapping.prototype.determineTarget = function(hostname) {
        var allHostMappings, overrideMapping;
        overrideMapping = this.settings.get("overrideMapping");
        if (overrideMapping != null) {
          this.settings.set("currentHostMapping", overrideMapping);
          return console.log("[hostMapping] Override active: " + this.settings.overrideMapping);
        } else {
          allHostMappings = this.settings.get("hostMapping");
          if ((hostname == null) && (typeof document !== "undefined" && document !== null)) {
            if (typeof document !== "undefined" && document !== null) {
              hostname = document.location.hostname;
            }
          }
          if (allHostMappings[hostname] != null) {
            this.settings.set("currentHostMapping", allHostMappings[hostname]);
            return console.log("[hostMapping] Target found: " + this.settings.currentMapping);
          } else {
            this.settings.set("currentHostMapping", "production");
            return console.log("[hostMapping] No target found, defaulting to production");
          }
        }
      };

      HostMapping.prototype.getHostName = function(hostType) {
        var allHostConfigs, currentHostMapping;
        if (hostType == null) {
          hostType = "api";
        }
        if (this.settings.get("currentHostMapping") == null) {
          this.determineTarget();
        }
        allHostConfigs = this.settings.get("hostConfig");
        currentHostMapping = this.settings.get("currentHostMapping");
        return objectUtils.getValue("" + currentHostMapping + "." + hostType, allHostConfigs);
      };

      HostMapping.prototype.getXdmSettings = function(hostName) {
        var allXdmConfigs, cleanHostName;
        cleanHostName = this.extractHostName(hostName);
        allXdmConfigs = this.settings.get("xdmConfig");
        return allXdmConfigs[cleanHostName];
      };

      HostMapping.prototype.extractHostName = function(url) {
        return url.replace(/(^https?:)?\/\//, "").split("/").slice(0, 1).pop().split(":").slice(0, 1).pop();
      };

      return HostMapping;

    })();
  });

}).call(this);
