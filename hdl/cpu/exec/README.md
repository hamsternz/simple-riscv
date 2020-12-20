## exec - the execution unit

The execution unit. This takes the decoded instructions, and if 
it is the correct instruction (i.e. the address matches that of
the current PC) then it performs the required actions and updates
 the internal state.

The functional units use a "active", "complete" and "failed" signalling.

Active is asserted when the inputs are correctly configured.

The unit should then assert either "complete" (i.e. the operation
 succeeded, 
and we can progress to the next instruction). Or "failed" if the 
intruction didn't complete and an exception needs to be raised.
