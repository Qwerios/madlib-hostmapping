( ( factory ) ->
    if typeof exports is "object"
        module.exports = factory(
            require "madlib-console"
            require "madlib-object-utils"
        )
    else if typeof define is "function" and define.amd
        define( [
            "madlib-console"
            "madlib-object-utils"
        ], factory )

)( ( console, objectUtils ) ->
    ###*
    #   The hostMapping module can be used to retrieve the correct server name and
    #   configuration depending on your environment.
    #   An instance of the madlib-settings module needs to be provided
    #
    #   @author     mdoeswijk
    #   @class      HostMapping
    #   @constructor
    #   @version    0.1
    ###
    class HostMapping
        ###*
        #   The class constructor. You need to supply your instance of madlib-settings
        #
        #   @function constructor
        #
        #   @params settings    {Object}    madlib-settings instance
        #
        #   @return None
        #
        ###
        constructor: ( settings ) ->
            # Initialise the hostMapping and hostConfig settings
            #
            # An example configuration could look like this:
            #
            #   hostMapping:
            #       "www.myhost.com":   "production"
            #       "acc.myhost.com":   "acceptance"
            #       "tst.myhost.com":   "testing"
            #       "localhost":        "development"
            #
            #   hostConfig:
            #       "production":
            #           "api":      "https://api.myhost.com"
            #           "content":  "http://www.myhost.com"
            #       "acceptance":
            #           "api":      "https://api-acc.myhost.com"
            #           "content":  "http://acc.myhost.com"
            #       "testing":
            #           "api":      "https://api-tst.myhost.com"
            #           "content":  "http://tst.myhost.com"
            #       "development":
            #           "api":      "https://api-tst.myhost.com"
            #           "content":  "http://localhost"
            #
            settings.init( "hostConfig",  {} )
            settings.init( "hostMapping", {} )

            # The cross-domain configuration determines what XDM options are available
            # for a host
            #
            # An example configuration could look like this:
            #
            #   xdmConfig:
            #       "api.essent.nl":
            #           cors:           true
            #           xdmVersion:     2
            #           xdmProvider:    "https://api.myhost.com/support/xdm/services.html"
            #
            settings.init( "xdmConfig", {} )

            # Store local reference to settings
            #
            @settings = settings

        ###*
        #   Overrides the built-in host mapping detection.
        #
        #   @function overrideMapping
        #
        #   @params newMapping    {String}    The mapping to use
        #
        #   @return None
        #
        ###
        overrideMapping: ( newMapping ) ->
            @settings.set( "overrideMapping", newMapping )

        ###*
        #   Determines the target host using the built-in host mapping detection.
        #
        #   @function determineTarget
        #
        #   @params {String} [hostname]  You can use hostname based detection for non-browser environments like NodeJS
        #
        #   @return None
        #
        ###
        determineTarget: ( hostname ) ->
            # Non browser environments or developer builds will want to override
            # detected settings
            #
            overrideMapping = @settings.get( "overrideMapping" )
            if overrideMapping?
                @settings.set( "currentHostMapping", overrideMapping )

                console.log( "[hostMapping] Override active: #{overrideMapping}" )
            else
                allHostMappings = @settings.get( "hostMapping" )

                # Determine target based on hostname for browsers and mobile web views
                #
                if not hostname? and document?
                    hostname = document.location.hostname if document?

                if allHostMappings[ hostname ]?
                    @settings.set( "currentHostMapping", allHostMappings[ hostname ] )
                    currentMapping = @settings.get( "currentHostMapping" )
                    console.log( "[hostMapping] Target found: #{currentMapping}" )

                else
                    @settings.set( "currentHostMapping", "production" )
                    console.log( "[hostMapping] No target found, defaulting to production" )

        ###*
        #   Returns the hostname for the chosen type. Will determine target host if not known yet
        #
        #   @function getHostname
        #
        #   @params {String} [hostType]  Which host type to retrieve the name for. Defaults to 'api'
        #
        #   @return {String} The host name
        #
        ###
        getHostName: ( hostType = "api" ) ->
            # Determine the target environment if needed
            #
            @determineTarget() if not @settings.get( "currentHostMapping" )?

            allHostConfigs     = @settings.get( "hostConfig" )
            currentHostMapping = @settings.get( "currentHostMapping" )

            objectUtils.getValue( "#{currentHostMapping}.#{hostType}", allHostConfigs )

        ###*
        #   The currently determined target mapping
        #
        #   @function getCurrentHostMapping
        #
        #   @return {String}    The current mapping
        #
        ###
        getCurrentHostMapping: () ->
            @settings.get( "currentHostMapping" )

        ###*
        #   Retrieves the cross domain settings for the provided host name
        #   The madlib-settings instance provided to the class constructor is
        #   the source of the settings
        #
        #   @function getXdmSettings
        #
        #   @params {String} [hostname]  The host name to retrieve the settings fot
        #
        #   @return {Object} The found settings
        #
        ###
        getXdmSettings: ( hostName ) ->
            # Extract the hostName (without protocol and paths)
            #
            cleanHostName = @extractHostName( hostName )
            allXdmConfigs = @settings.get( "xdmConfig" )

            return allXdmConfigs[ cleanHostName ]

        ###*
        #   Extracts the host name from the provided url
        #
        #   @function determineTarget
        #
        #   @params {String} url  The URL to extract the host name from
        #
        #   @return {String} The hostname
        #
        ###
        extractHostName: ( url ) ->
            url.replace( /(^https?:)?\/\//, "" ).split( "/" ).slice( 0, 1 ).pop().split( ":" ).slice( 0, 1 ).pop()
)