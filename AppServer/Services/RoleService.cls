@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
 
 /*------------------------------------------------------------------------
    File        : RoleService
    Purpose     : Class that provides the necessary services for Role
    Syntax      : 
    Description : 
    Author(s)   : aIzota
    Created     : Tue Nov 24 09:09:45 EET 2020
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using Errors.*.

block-level on error undo, throw.

class Services.RoleService: 
    /* Defining internal buffers */
    define buffer ibRole for Role.
    define buffer ibActor for Actor.
    define buffer ibMovie for Movie.
    
    
    /* Defining internal temp tables and datasets */
    define temp-table ttGetAllRoles like Role.
    define temp-table ttAddRole like Role.
    define temp-table ttUpdateRole like Role.
    define dataset dsRoleSet for ttUpdateRole.
    
    
    /* Default constructor */
    constructor public RoleService (  ):
        super ().
        
    end constructor.


    /* Destructor executed when the object is deleted */
    destructor public RoleService ( ):
        empty temp-table ttGetAllRoles.
        empty temp-table ttAddRole.
        empty temp-table ttUpdateRole.
    end destructor.

    
    /*  REST Service to get all the Roles 
        * input:
        *           void
        * output:
        *           table ttGetAllRoles
        *           cSuccessMessage character
        *           lSuccess logical
    */
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void getAllRoles(output table ttGetAllRoles, output cSuccessMessage as character, output lSuccess as logical):
        empty temp-table ttGetAllRoles.
        
        for each ibRole no-lock:
            create ttGetAllRoles.
            buffer-copy ibRole to ttGetAllRoles.
            
            /* Catch if a errror occurs when copying data for fetching Roles */
            catch eSysError as Progress.Lang.Error:
                message "ERROR Fetch all Roles: error ocured when copying data.".
                cSuccessMessage = "Error, records not fetched!".
                lSuccess = false.
            end catch.
        end. /* for each */
        
        cSuccessMessage = "Records fetched successfully!".
        lSuccess = true.
    end. /* method getAllRoles */
    
    
    /*  REST Service to add a new Role 
        * input:
        *           iActorId integer
        *           iMovieId integer
        *           cRole character
        * output:
        *           cSuccessMessage character
        *           lSuccess logical
    */
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void addRole(input iActorId as integer, input iMovieId as integer, input cRole as character, 
                                output cSuccessMessage as character, output lSuccess as logical):
        /* Check if the ActorId is in the database */
        if not can-find(ibActor where ibActor.ActorId = iActorId no-lock) then do:
            cSuccessMessage = "Error, record not added!".
            lSuccess = false.
            return error new IncorrectActorError("Role").
        end.
        
        /* Check if the MovieId is in the database */
        if not can-find(ibMovie where ibMovie.MovieId = iMovieId no-lock) then do:
            cSuccessMessage = "Error, record not added!".
            lSuccess = false.
            return error new IncorrectMovieError("Role").
        end.
        
        create ttAddRole.
        assign
            ttAddRole.RoleId = next-value(NextRoleId)
            ttAddRole.ActorId = iActorId
            ttAddRole.MovieId = iMovieId
            ttAddRole.Role = cRole.
            
        buffer-copy ttAddRole to ibRole.    
        
        cSuccessMessage = "Record created successfully!".
        lSuccess = true.
        
        /* Catch if a errror occurs when creating a new Role record */
        catch eSysError as Progress.Lang.Error:
            message "ERROR Add new Role: error ocured when creating a new record.".
            cSuccessMessage = "Error, record not added!".
            lSuccess = false.
            return.
        end catch.  
            
    end. /* method addRole */


    /*  REST Service to delete an Role by Id
        * input:
        *           iRoleId integer
        * output:
        *           cSuccessMessage character
        *           lSuccess logical
    */
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void deleteRole(input iRoleId as integer, output cSuccessMessage as character, output lSuccess as logical):
        /* Find Role to be deleted in database */
        find first ibRole where ibRole.RoleId = iRoleId exclusive-lock no-error.    
        
        if available ibRole then do:
            if not locked ibRole then do:
                delete ibRole.
                cSuccessMessage = "Role deleted!".
                lSuccess = true.
            end. /* if not locked */
            else do:
                cSuccessMessage = "ERROR Delete Role: Record is used by someone else!".
                lSuccess = false.
            end. /* else do */
        end. /* if not available */
        else do:
            cSuccessMessage = "ERROR Delete Role: Record not found!".
            lSuccess = false.
        end. /* else do */
    end. /* method deleteRole */
    
    
    /*  REST Service to update an Role by Id
        * input:
        *           iRoleId integer
        *           dataset dsRoleSet
        * output:
        *           cSuccessMessage character
        *           lSuccess logical
    */
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void updateRole(input iRoleId as integer, input dataset dsRoleSet, output cSuccessMessage as character, output lSuccess as logical):
        /* Get the data that was sent */
        find first ttUpdateRole.
        /* Find Role to be updated in database */
        find first ibRole where ibRole.RoleId = iRoleId exclusive-lock no-error.    
        
        assign ttUpdateRole.RoleId = iRoleId.
        
        if available ibRole then do:
            if not locked ibRole then do:
                buffer-copy ttUpdateRole to ibRole.
                
                cSuccessMessage = "Role updated!".
                lSuccess = true.
            end. /* if not locked */
            else do:
                cSuccessMessage = "ERROR Update Role: Record is used by someone else!".
                lSuccess = false.
            end. /* else do */
        end. /* if not available */
        else do:
            cSuccessMessage = "ERROR Update Role: Record not found!".
            lSuccess = false.
        end. /* else do */
    end. /* method updateRole */
end class.