//
//  SPKUtils.h
//  SwiftSPICE
//
//  Created by Joe Rupertus on 11/29/24.
//

#ifndef CSPICEEXTENSIONS_H
#define CSPICEEXTENSIONS_H

#include "SpiceUsr.h"

void getSPKObjectIDs(ConstSpiceChar *spkFilename, SpiceInt *ids, SpiceInt *count);

#endif /* CSPICEEXTENSIONS_H */
