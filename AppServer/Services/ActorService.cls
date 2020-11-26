@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
 
 /*------------------------------------------------------------------------
    File        : ActorService
    Purpose     : Class that provides the necessary services for Actor
    Syntax      : 
    Description : 
    Author(s)   : aIzota
    Created     : Sun Nov 22 22:54:06 EET 2020
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

class Services.ActorService: 
    /* Defining internal buffers */
    define buffer ibActor for Actor.
    
    
    /* Defining internal temp tables and datasets */
    define temp-table ttGetAllActors like Actor.
    define temp-table ttAddActor like Actor.
    define temp-table ttUpdateActor like Actor.
    define dataset dsActorSet for ttUpdateActor.
    
    
    /* Default constructor */
    constructor public ActorService (  ):
        super ().
        
    end constructor.


    /* Destructor executed when the object is deleted */
    destructor public ActorService ( ):
        empty temp-table ttGetAllActors.
        empty temp-table ttAddActor.
        empty temp-table ttUpdateActor.
    end destructor.

    
    /*  REST Service to get all the actors 
        * input:
        *           void
        * output:
        *           table ttGetAllActors
        *           cSuccessMessage character
        *           lSuccess logical
    */
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void getAllActors(output table ttGetAllActors, output cSuccessMessage as character, output lSuccess as logical):
        empty temp-table ttGetAllActors.
        
        for each ibActor no-lock:
            create ttGetAllActors.
            buffer-copy ibActor to ttGetAllActors.
            
            /* Catch if a errror occurs when copying data for fetching actors */
            catch eSysError as Progress.Lang.Error:
                message "ERROR Fetch all actors: error ocured when copying data.".
                cSuccessMessage = "Error, records not fetched!".
                lSuccess = false.
            end catch.
        end. /* for each */
        
        cSuccessMessage = "Records fetched successfully!".
        lSuccess = true.
    end. /* method getAllActors */
    
    
    /*  REST Service to add a new actor 
        * input:
        *           cFirstName character
        *           cLastName character
        *           iAge integer
        *           cGender character
        * output:
        *           cSuccessMessage character
        *           lSuccess logical
    */
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void addActor(input cFirstName as character, input cLastName as character, input iAge as integer,
                                input cGender as character, output cSuccessMessage as character, output lSuccess as logical):
        create ttAddActor.
        assign
            ttAddActor.ActorId = next-value(NextActorId)
            ttAddActor.FirstName = cFirstName
            ttAddActor.LastName = cLastName
            ttAddActor.Age = iAge
            ttAddActor.Gender = cGender.
            
        buffer-copy ttAddActor to ibActor.    
        
        /* Catch if a errror occurs when creating a new actor record */
        catch eSysError as Progress.Lang.Error:
            message "ERROR Add new actor: error ocured when creating a new record.".
            cSuccessMessage = "Error, record not added!".
            lSuccess = false.
            return.
        end catch.
        finally:        
            cSuccessMessage = "Record created successfully!".
            lSuccess = true.
        end finally. 
    end. /* method addActor */


    /*  REST Service to delete an actor by Id
        * input:
        *           iActorId integer
        * output:
        *           cSuccessMessage character
        *           lSuccess logical
    */
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void deleteActor(input iActorId as integer, output cSuccessMessage as character, output lSuccess as logical):
        /* Find actor to be deleted in database */
        find first ibActor where ibActor.ActorId = iActorId exclusive-lock no-error.    
        
        if available ibActor then do:
            if not locked ibActor then do:
                delete ibActor.
                cSuccessMessage = "Actor deleted!".
                lSuccess = true.
            end. /* if not locked */
            else do:
                cSuccessMessage = "ERROR Delete actor: Record is used by someone else!".
                lSuccess = false.
            end. /* else do */
        end. /* if not available */
        else do:
            cSuccessMessage = "ERROR Delete actor: Record not found!".
            lSuccess = false.
        end. /* else do */
    end. /* method deleteActor */
    
    
    /*  REST Service to update an actor by Id
        * input:
        *           iActorId integer
        *           dataset dsActorSet
        * output:
        *           cSuccessMessage character
        *           lSuccess logical
    */
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void updateActor(input iActorId as integer, input dataset dsActorSet, output cSuccessMessage as character, output lSuccess as logical):
        /* Get the data that was sent */
        find first ttUpdateActor.
        /* Find actor to be updated in database */
        find first ibActor where ibActor.ActorId = iActorId exclusive-lock no-error.    
        
        assign ttUpdateActor.ActorId = iActorId.
        
        if available ibActor then do:
            if not locked ibActor then do:
                buffer-copy ttUpdateActor to ibActor.
                
                cSuccessMessage = "Actor updated!".
                lSuccess = true.
            end. /* if not locked */
            else do:
                cSuccessMessage = "ERROR Update actor: Record is used by someone else!".
                lSuccess = false.
            end. /* else do */
        end. /* if not available */
        else do:
            cSuccessMessage = "ERROR Update actor: Record not found!".
            lSuccess = false.
        end. /* else do */
    end. /* method updateActor */
    
end class.