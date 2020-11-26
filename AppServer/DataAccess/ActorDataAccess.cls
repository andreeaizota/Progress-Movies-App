 
 /*------------------------------------------------------------------------
    File        : ActorDataAccess
    Purpose     : Class that assures data access for Actor
    Syntax      : 
    Description : 
    Author(s)   : aIzota
    Created     : Tue Nov 24 20:36:07 EET 2020
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

class DataAccess.ActorDataAccess: 
    /* Defining internal buffers */
    define buffer ibActor for Actor.
    define buffer ibMovie for Movie.
    define buffer ibRole for Role.
    
    
    /* Defining internal temp tables and datasets */
    define temp-table ttGetAllActors like Actor.
    define temp-table ttByNameActors like Actor.
    define temp-table ttByMovieActors like Actor.
    define temp-table ttByRoleActors like Actor.
    define temp-table ttInfoActor like Actor.
    define temp-table ttMoviesActor like Movie.
    define temp-table ttRolesActor like Role.
    
    define dataset dsInfoActor for ttInfoActor, ttMoviesActor, ttRolesActor
        data-relation ActorRole for ttInfoActor, ttRolesActor
        relation-fields (ActorId, ActorId) nested
        data-relation RoleMovie for ttRolesActor, ttMoviesActor
        relation-fields (MovieId, MovieId) nested.
    
        
    /* Default constructor */
    constructor public ActorDataAccess (  ):
        super ().
        
    end constructor.


    /* Destructor executed when the object is deleted */
    destructor public ActorDataAccess ( ):
        empty temp-table ttGetAllActors.
        empty temp-table ttByNameActors.
        empty temp-table ttByMovieActors.
        empty temp-table ttByRoleActors.
        empty temp-table ttInfoActor.
        empty temp-table ttMoviesActor.
        empty temp-table ttRolesActor.
    end destructor.
    
    
    /*  REST Service to get all the actors 
        * input:
        *           void
        * output:
        *           table ttGetAllActors
        *           cSuccessMessage character
        *           lSuccess logical
    */
    method public void getAllActors(input-output table ttGetAllActors, output cSuccessMessage as character, output lSuccess as logical):
        empty temp-table ttGetAllActors.
        
        for each ibActor no-lock:
            create ttGetAllActors.
            buffer-copy ibActor to ttGetAllActors.
            
            /* Catch if an errror occurs when copying data for fetching actors */
            catch eSysError as Progress.Lang.Error:
                message "ERROR Fetch all actors: error ocured when copying data.".
                cSuccessMessage = "Error, records not fetched!".
                lSuccess = false.
            end catch.
        end. /* for each */
        
        cSuccessMessage = "Records fetched successfully!".
        lSuccess = true.
    end method. /* getAllActors */


   /*  REST Service to get actors by name
        * input:
        *           cName character
        * output:
        *           table ttByNameActors
        *           cSuccessMessage character
        *           lSuccess logical
    */
    method public void getActorsByName(input cName as character, input-output table ttByNameActors, output cSuccessMessage as character, output lSuccess as logical):
        empty temp-table ttByNameActors.
        
        for each ibActor where ibActor.FirstName + " " + ibActor.LastName matches ("*" + cName + "*") no-lock:
            create ttByNameActors.
            buffer-copy ibActor to ttByNameActors.
            
            /* Catch if an errror occurs when copying data for fetching actors */
            catch eSysError as Progress.Lang.Error:
                message "ERROR Fetch actors by name: error ocured when copying data.".
                cSuccessMessage = "Error, records not fetched! (by name)".
                lSuccess = false.
            end catch.
        end. /* for each */
        
        cSuccessMessage = "Records fetched successfully!".
        lSuccess = true.
    end method. /* getActorsByName */
    
    
   /*  REST Service to get actors by movie
        * input:
        *           cMovieName character
        * output:
        *           table ttByMovieActors
        *           cSuccessMessage character
        *           lSuccess logical
    */
    method public void getActorsByMovie(input cMovieName as character, input-output table ttByMovieActors, output cSuccessMessage as character, output lSuccess as logical):
        empty temp-table ttByMovieActors.
        
        outsideBlock:
        for each ibActor no-lock, each ibRole of ibActor no-lock,
            each ibMovie of ibRole where ibMovie.Name matches ("*" + cMovieName + "*") no-lock :
            create ttByMovieActors.
            buffer-copy ibActor to ttByMovieActors.
            next outsideBlock. /* to assure each actor appears exactly one time */
            
            /* Catch if an errror occurs when copying data for fetching actors */
            catch eSysError as Progress.Lang.Error:
                message "ERROR Fetch actors by movie: error ocured when copying data.".
                cSuccessMessage = "Error, records not fetched! (by movie)".
                lSuccess = false.
            end catch.
        end. /* for each */
        
        cSuccessMessage = "Records fetched successfully!".
        lSuccess = true.
    end method. /* getActorsByMovie */
    
    
    /*  REST Service to get actors by role
        * input:
        *           cRole character
        * output:
        *           table ttByRoleActors
        *           cSuccessMessage character
        *           lSuccess logical
    */
    method public void getActorsByRole(input cRole as character, input-output table ttByRoleActors, output cSuccessMessage as character, output lSuccess as logical):
        empty temp-table ttByRoleActors.
        
        for each ibActor no-lock, each ibRole of ibActor where ibRole.Role matches ("*" + cRole + "*") no-lock :
            create ttByRoleActors.
            buffer-copy ibActor to ttByRoleActors.
            
            /* Catch if an errror occurs when copying data for fetching actors */
            catch eSysError as Progress.Lang.Error:
                message "ERROR Fetch actors by role: error ocured when copying data.".
                cSuccessMessage = "Error, records not fetched! (by role)".
                lSuccess = false.
            end catch.
        end. /* for each */
        
        cSuccessMessage = "Records fetched successfully!".
        lSuccess = true.
    end method. /* getActorsByRole */
    
    
    /*  REST Service to get actor's information after search
        * input:
        *           iActorId integer
        * output:
        *           dataset dsInfoActor
        *           cSuccessMessage character
        *           lSuccess logical
    */
    method public void getInfoById(input iActorId as integer, input-output dataset dsInfoActor, output cSuccessMessage as character, output lSuccess as logical):
        empty temp-table ttInfoActor.
        empty temp-table ttMoviesActor.
        empty temp-table ttRolesActor.
        
        find first ibActor where ibActor.ActorId = iActorId no-lock.
        create ttInfoActor.
        buffer-copy ibActor to ttInfoActor.
        
        if available ibActor then do on error undo, throw:
            if not locked ibActor then do on error undo, throw:
                for each ibRole of ibActor no-lock on error undo, throw:
                    create ttRolesActor.
                    buffer-copy ibRole to ttRolesActor.
                    
                    for each ibMovie of ibRole no-lock on error undo, throw:
                        create ttMoviesActor.
                        buffer-copy ibMovie to ttMoviesActor.
                    end. /* for each */
                    
                end. /* for each */
            end. /* if not locked */
            else do:
                cSuccessMessage = "Error, record not available".
                lSuccess = false.
            end. /* else do */
        end. /* if available */
        else do:
            cSuccessMessage = "Error, the record is used by someone else".
            lSuccess = false.
        end. /* else do */
        
    end method. /* getInfoById*/
    
    
end class.