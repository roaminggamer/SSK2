local myCC = ssk.cc:newCalculator()
myCC:addNames( "bullet", "target" )
myCC:collidesWith( "target", { "bullet" } )


return myCC