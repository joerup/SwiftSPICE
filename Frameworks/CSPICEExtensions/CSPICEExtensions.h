//
//  CSPICEExtensions.h
//  SwiftSPICE
//
//  Created by Joe Rupertus on 11/28/24.
//

#ifndef CSPICEEXTENSIONS_H
#define CSPICEEXTENSIONS_H

#include "SpiceUsr.h"

SpiceBoolean BeEpochInSPK(ConstSpiceChar *spkFilename, SpiceInt bodyID, SpiceDouble epochPoint);

void GetSPKObjectIDs(const char *spkFilename, SpiceInt *ids, SpiceInt *count);

#endif /* CSPICEEXTENSIONS_H */
