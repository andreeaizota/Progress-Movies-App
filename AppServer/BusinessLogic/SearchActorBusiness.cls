@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
 
 /*------------------------------------------------------------------------
    File        : SearchActorBusiness
    Purpose     : Business class for searching actors
    Syntax      : 
    Description : 
    Author(s)   : aIzota
    Created     : Thu Nov 26 00:03:19 EET 2020
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using DataAccess.*.

block-level on error undo, throw.

class BusinessLogic.SearchActorBusiness:   
    define private property ioActorDataAccess as ActorDataAccess
        get.
        set.
          
    
    /* Defining internal temp tables and datasets */
    define temp-table ttActorsByName like Actor.
    define temp-table ttActorsByMovie like Actor.
    define temp-table ttActorsByRole like Actor.
    define temp-table ttActors like Actor.
    define temp-table ttInfoActor like Actor.
    define temp-table ttMoviesActor like Movie.
    define temp-table ttRolesActor like Role.
    
    define dataset dsInfoActor for ttInfoActor, ttMoviesActor, ttRolesActor
        data-relation ActorRole for ttInfoActor, ttRolesActor
        relation-fields (ActorId, ActorId) nested
        data-relation RoleMovie for ttRolesActor, ttMoviesActor
        relation-fields (MovieId, MovieId) nested.
          
          
    /* Default constructor */     
    constructor public SearchActorBusiness (  ):
        super ().
        ioActorDataAccess = new ActorDataAccess().        
        
    end constructor.


    /* Destructor executed when the object is deleted */
    destructor public SearchActorBusiness ( ):
        delete object ioActorDataAccess.
        empty temp-table ttActorsByName.
        empty temp-table ttActorsByMovie.
        empty temp-table ttActorsByRole.
        empty temp-table ttActors.
        empty temp-table ttInfoActor.
        empty temp-table ttMoviesActor.
        empty temp-table ttRolesActor.
    end destructor.

    
    /*  API to get Actors by name, movie or role
        * input:
        *           cSearchCondition character
        *           cValue character
        * output:
        *           table ttActors
        *           cSuccessMessage character
        *           lSuccess logical
    */
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void searchActors(input cSearchCondition as character, input cValue as character, 
            output table ttActors, output cSuccessMessage as character, output lSuccess as logical):
        empty temp-table ttActors.
        
        case cSearchCondition:
            when "Name" then 
                ioActorDataAccess:getActorsByName(cValue, input-output table ttActors by-reference, cSuccessMessage, lSuccess).
            when "Movie" then 
                ioActorDataAccess:getActorsByMovie(cValue, input-output table ttActors by-reference, cSuccessMessage, lSuccess).
            when "Role" then
                ioActorDataAccess:getActorsByRole(cValue, input-output table ttActors by-reference, cSuccessMessage, lSuccess).
            otherwise do:
                cSuccessMessage = "ERROR: Incorrect search condition for actors".
                lSuccess = false.
                return error new Progress.Lang.AppError("Incorrect search condition for actors").
            end. /* otherwisw do */
        end case.
    end method. /* searchActors */
    
    
    /*  API to get information for an actor (details, roles,movies)
        * input:
        *           iActorId integer
        * output:
        *           dataset dsInfoActor
        *           cSuccessMessage character
        *           lSuccess logical
    */
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void getActorInfoById(input iActorId as integer, output dataset dsInfoActor, output cSuccessMessage as character, output lSuccess as logical):
        ioActorDataAccess:getInfoById(iActorId, dataset dsInfoActor by-reference, cSuccessMessage, lSuccess).
        
        /* Catch if an errror occurs when copying data for actor's info */
        catch eSysError as Progress.Lang.Error:
            message "ERROR Fetch info for actor: error ocured when copying data.".
            cSuccessMessage = "Error, records not fetched! (actor's info)".
            lSuccess = false.
        end catch.
    end method. /* getActorInfoById */
    
end class.