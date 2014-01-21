chai        = require "chai"
settings    = require "madlib-settings"
HostMapping = require "../lib/index.js"

describe( "HostMapping", () ->
    describe( "#checkMapping()", () ->
        # Default hostmapping will be production
        #
        hostMapping = new HostMapping( settings )
        hostMapping.determineTarget()

        defaultMapping = hostMapping.getCurrentHostMapping()
        it( "Mapping should be production", () ->
            chai.expect( defaultMapping ).to.eql( "production" )
        )

        hostMapping.overrideMapping( "testing" )
        hostMapping.determineTarget()

        overrideMapping = hostMapping.getCurrentHostMapping()
        it( "Mapping should be overridden", () ->
            chai.expect( overrideMapping ).to.eql( "testing" )
        )
    )
)