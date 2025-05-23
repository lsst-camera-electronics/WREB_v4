
#ifndef __AXI_STREAM_SIM_OB_H__
#define __AXI_STREAM_SIM_OB_H__

#include <vhpi_user.h>
#include "AxiStreamSharedMem.h"

// Signals
#define s_obClk            0
#define s_obReset          1
#define s_obValid          2
#define s_obDest           3
#define s_obEof            4
#define s_obData           5
#define s_obReady          6
#define s_streamId         7

// Structure to track state
typedef struct {

   // Shared memory
   uint                smemFd;
   AxiStreamSharedMem *smem;
   char                smemFile[1000];

   // Current state of clock
   uint currClk;
   uint obCount;
  
} AxiStreamSimObData;

// Init function
void AxiStreamSimObInit(vhpiHandleT compInst);


// Callback function for updating
void AxiStreamSimObUpdate ( void *userPtr );

#endif

