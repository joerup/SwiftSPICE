//
//  BeEpochInSPK.h
//  SwiftSPICE
//
//  Created by Joe Rupertus on 11/28/24.
//

#include "SpiceUsr.h"

SpiceBoolean BeEpochInSPK(ConstSpiceChar *spkFilename, SpiceInt bodyID, SpiceDouble epochPoint)
{
    // Local parameters
    #define MAXIV 100
    #define WINSIZ (2*MAXIV)
    // Local variables
    SpiceBoolean epochWithinSPK;
    SPICEDOUBLE_CELL(cover, WINSIZ);
    // Obtain window segments for the specified bodyID in the specified spkFilename
    spkcov_c(spkFilename, bodyID, &cover);
    // Determine if the specified epochPoint is within any bodyID window segment
    epochWithinSPK = wnelmd_c(epochPoint, &cover);
    return (epochWithinSPK);
}
