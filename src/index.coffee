# The hostMapping module can be used to retrieve the correct server name and
# configuration depending on your environment.
# The corresponding settings will need to be provided in the root settings module
#
( ( factory ) ->
    if typeof exports is "object"
        module.exports = factory(
            require "madLib-console"
            require "madlib-settings"
            require "madLib-object-utils"
        )
    else if typeof define is "function" and define.amd
        define( [
            "madLib-console"
            "madlib-settings"
            "madLib-object-utils"
        ], factory )

)( ( console, settings, objectUtils ) ->

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

    class HostMapping
        overrideMapping: ( newMapping ) ->
            settings.set( "currentHostMapping", newMapping )

        determineTarget: ( hostname ) ->
            # Non browser environments or developer builds will want to override
            # detected settings
            #
            overrideMapping = settings.get( "overrideMapping" )
            if overrideMapping?
                settings.set( "currentHostMapping", overrideMapping )

                console.log( "[hostMapping] Override active: #{settings.overrideMapping}" )
            else
                allHostMappings = settings.get( "hostMapping" )

                # Determine target based on hostname for browsers and mobile web views
                #
                if not hostname? and document?
                    hostname = document.location.hostname if document?

                if allHostMappings[ hostname ]?
                    settings.set( "currentHostMapping", allHostMappings[ hostname ] )
                    console.log( "[hostMapping] Target found: #{settings.currentMapping}" )

                else
                    settings.set( "currentHostMapping", "production" )
                    console.log( "[hostMapping] No target found, defaulting to production" )

        getHostName: ( hostType = "api" ) ->
            # Determine the target environment if needed
            #
            @determineTarget() if not settings.get( "currentHostMapping" )?

            allHostConfigs     = settings.get( "hostConfig" )
            currentHostMapping = settings.get( "currentHostMapping" )

            objectUtils.getValue( "#{currentHostMapping}.#{hostType}", allHostConfigs )

        getXdmSettings: ( hostName ) ->
            # Extract the hostName (without protocol and paths)
            #
            cleanHostName = @extractHostName( hostName )
            allXdmConfigs = settings.get( "xdmConfig" )

            return allXdmConfigs[ cleanHostName ]

        extractHostName: ( url ) ->
            url.replace( /(^https?:)?\/\//, "" ).split( "/" ).slice( 0, 1 ).pop().split( ":" ).slice( 0, 1 ).pop()

    return new HostMapping()
)