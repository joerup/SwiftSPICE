//
//  SPKUtils.c
//  SwiftSPICE
//
//  Created by Joe Rupertus on 11/29/24.
//

#include "SPKUtils.h"

// Retrieves object IDs from a given SPK file
void getSPKObjectIDs(ConstSpiceChar *spkFilename, SpiceInt *ids, SpiceInt *count) {
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
