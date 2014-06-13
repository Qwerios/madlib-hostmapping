(function() {
  (function(factory) {
    if (typeof exports === "object") {
      return module.exports = factory(require("madlib-console"), require("madlib-object-utils"));
    } else if (typeof define === "function" && define.amd) {
      return define(["madlib-console", "madlib-object-utils"], factory);
    }
  })(function(console, objectUtils) {

    /**
     *   The hostMapping module can be used to retrieve the correct server name and
     *   configuration depending on your environment.
     *   An instance of the madlib-settings module needs to be provided
     *
     *   @author     mdoeswijk
     *   @class      HostMapping
     *   @constructor
     *   @version    0.1
     */
    var HostMapping;
    return HostMapping = (function() {

      /**
       *   The class constructor. You need to supply your instance of madlib-settings
       *
       *   @function constructor
       *
       *   @params settings    {Object}    madlib-settings instance
       *
       *   @return None
       *
       */
      function HostMapping(settings) {
        settings.init("hostConfig", {});
        settings.init("hostMapping", {});
        settings.init("xdmConfig", {});
        this.settings = settings;
      }


      /**
       *   Overrides the built-in host mapping detection.
       *
       *   @function overrideMapping
       *
       *   @params newMapping    {String}    The mapping to use
       *
       *   @return None
       *
       */

      HostMapping.prototype.overrideMapping = function(newMapping) {
        return this.settings.set("overrideMapping", newMapping);
      };


      /**
       *   Determines the target host using the built-in host mapping detection.
       *
       *   @function determineTarget
       *
       *   @params {String} [hostname]  You can use hostname based detection for non-browser environments like NodeJS
       *
       *   @return None
       *
       */

      HostMapping.prototype.determineTarget = function(hostname) {
        var allHostMappings, currentMapping, overrideMapping;
        overrideMapping = this.settings.get("overrideMapping");
        if (overrideMapping != null) {
          this.settings.set("currentHostMapping", overrideMapping);
          return console.log("[hostMapping] Override active: " + overrideMapping);
        } else {
          allHostMappings = this.settings.get("hostMapping");
          if ((hostname == null) && (typeof document !== "undefined" && document !== null)) {
            if (typeof document !== "undefined" && document !== null) {
              hostname = document.location.hostname;
            }
          }
          if (allHostMappings[hostname] != null) {
            this.settings.set("currentHostMapping", allHostMappings[hostname]);
            currentMapping = this.settings.get("currentHostMapping");
            return console.log("[hostMapping] Target found: " + currentMapping);
          } else {
            this.settings.set("currentHostMapping", "production");
            return console.log("[hostMapping] No target found, defaulting to production");
          }
        }
      };


      /**
       *   Returns the hostname for the chosen type. Will determine target host if not known yet
       *
       *   @function getHostname
       *
       *   @params {String} [hostType]  Which host type to retrieve the name for. Defaults to 'api'
       *
       *   @return {String} The host name
       *
       */

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


      /**
       *   The currently determined target mapping
       *
       *   @function getCurrentHostMapping
       *
       *   @return {String}    The current mapping
       *
       */

      HostMapping.prototype.getCurrentHostMapping = function() {
        return this.settings.get("currentHostMapping");
      };


      /**
       *   Retrieves the cross domain settings for the provided host name
       *   The madlib-settings instance provided to the class constructor is
       *   the source of the settings
       *
       *   @function getXdmSettings
       *
       *   @params {String} [hostname]  The host name to retrieve the settings fot
       *
       *   @return {Object} The found settings
       *
       */

      HostMapping.prototype.getXdmSettings = function(hostName) {
        var allXdmConfigs, cleanHostName;
        cleanHostName = this.extractHostName(hostName);
        allXdmConfigs = this.settings.get("xdmConfig");
        return allXdmConfigs[cleanHostName];
      };


      /**
       *   Extracts the host name from the provided url
       *
       *   @function determineTarget
       *
       *   @params {String} url  The URL to extract the host name from
       *
       *   @return {String} The hostname
       *
       */

      HostMapping.prototype.extractHostName = function(url) {
        return url.replace(/(^https?:)?\/\//, "").split("/").slice(0, 1).pop().split(":").slice(0, 1).pop();
      };

      return HostMapping;

    })();
  });

}).call(this);
