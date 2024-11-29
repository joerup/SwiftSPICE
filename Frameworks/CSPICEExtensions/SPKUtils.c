//
//  SPKUtils.c
//  SwiftSPICE
//
//  Created by Joe Rupertus on 11/29/24.
//

#include "SPKUtils.h"

// Determines whether there is a valid ephemeris in a given SPK file for a given object and epoch
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

// Retrieves object IDs from a given SPK file
void GetSPKObjectIDs(const char *spkFilename, SpiceInt *ids, SpiceInt *count) {
    #define MAX_IDS 1000
    SPICEINT_CELL(idset, MAX_IDS);
    
    // Retrieve object IDs from the SPK file
    spkobj_c(spkFilename, &idset);
    
    // Get the number of IDs in the cell
    *count = card_c(&idset);
    
    // Populate the provided array with IDs
    for (SpiceInt i = 0; i < *count; i++) {
        ids[i] = SPICE_CELL_ELEM_I(&idset, i);
    }
}
