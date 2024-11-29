//
//  GetSPKObjectIDs.c
//  SwiftSPICE
//
//  Created by Joe Rupertus on 11/28/24.
//

#include "SpiceUsr.h"

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