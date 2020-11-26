@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
 
 /*------------------------------------------------------------------------
    File        : DirectorService
    Purpose     : Class that provides the necessary services for Director
    Syntax      : 
    Description : 
    Author(s)   : aIzota
    Created     : Tue Nov 24 08:08:13 EET 2020
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

class Services.DirectorService:       
    /* Defining internal buffers */
    define buffer ibDirector for Director.
    
    
    /* Defining internal temp tables and datasets */
    define temp-table ttGetAllDirectors like Director.
    define temp-table ttAddDirector like Director.
    define temp-table ttUpdateDirector like Director.
    define dataset dsDirectorSet for ttUpdateDirector.
    
    
    /* Default constructor */  
    constructor public DirectorService (  ):
        super ().
        
    end constructor.

    /* Destructor executed when the object is deleted */
    destructor public DirectorService ( ):
        empty temp-table ttGetAllDirectors.
        empty temp-table ttAddDirector.
        empty temp-table ttUpdateDirector.
    end destructor.

    
    /*  REST Service to get all the Directors 
        * input:
        *           void
        * output:
        *           table ttGetAllDirectors
        *           cSuccessMessage character
        *           lSuccess logical
    */
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void getAllDirectors(output table ttGetAllDirectors, output cSuccessMessage as character, output lSuccess as logical):
        empty temp-table ttGetAllDirectors.
        
        for each ibDirector no-lock:
            create ttGetAllDirectors.
            buffer-copy ibDirector to ttGetAllDirectors.
            
            /* Catch if a errror occurs when copying data for fetching Directors */
            catch eSysError as Progress.Lang.Error:
                message "ERROR Fetch all Directors: error ocured when copying data.".
                cSuccessMessage = "Error, records not fetched!".
                lSuccess = false.
            end catch.
        end. /* for each */
        
        cSuccessMessage = "Records fetched successfully!".
        lSuccess = true.
    end. /* method getAllDirectors */
    
    
    /*  REST Service to add a new Director 
        * input:
        *           cFirstName character
        *           cLastName character
        * output:
        *           cSuccessMessage character
        *           lSuccess logical
    */
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void addDirector(input cFirstName as character, input cLastName as character, output cSuccessMessage as character, output lSuccess as logical):
        create ttAddDirector.
        assign
            ttAddDirector.DirectorId = next-value(NextDirectorId)
            ttAddDirector.FirstName = cFirstName
            ttAddDirector.LastName = cLastName.
            
        buffer-copy ttAddDirector to ibDirector.    
        
        /* Catch if a errror occurs when creating a new Director record */
        catch eSysError as Progress.Lang.Error:
            message "ERROR Add new Director: error ocured when creating a new record.".
            cSuccessMessage = "Error, record not added!".
            lSuccess = false.
            return.
        end catch.
        finally:        
            cSuccessMessage = "Record created successfully!".
            lSuccess = true.
        end finally. 
    end. /* method addDirector */


    /*  REST Service to delete an Director by Id
        * input:
        *           iDirectorId integer
        * output:
        *           cSuccessMessage character
        *           lSuccess logical
    */
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void deleteDirector(input iDirectorId as integer, output cSuccessMessage as character, output lSuccess as logical):
        /* Find Director to be deleted in database */
        find first ibDirector where ibDirector.DirectorId = iDirectorId exclusive-lock no-error.    
        
        if available ibDirector then do:
            if not locked ibDirector then do:
                delete ibDirector.
                cSuccessMessage = "Director deleted!".
                lSuccess = true.
            end. /* if not locked */
            else do:
                cSuccessMessage = "ERROR Delete Director: Record is used by someone else!".
                lSuccess = false.
            end. /* else do */
        end. /* if not available */
        else do:
            cSuccessMessage = "ERROR Delete Director: Record not found!".
            lSuccess = false.
        end. /* else do */
    end. /* method deleteDirector */
    
    
    /*  REST Service to update an Director by Id
        * input:
        *           iDirectorId integer
        *           dataset dsDirectorSet
        * output:
        *           cSuccessMessage character
        *           lSuccess logical
    */
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void updateDirector(input iDirectorId as integer, input dataset dsDirectorSet, output cSuccessMessage as character, output lSuccess as logical):
        /* Get the data that was sent */
        find first ttUpdateDirector.
        /* Find Director to be updated in database */
        find first ibDirector where ibDirector.DirectorId = iDirectorId exclusive-lock no-error.    
        
        assign ttUpdateDirector.DirectorId = iDirectorId.
        
        if available ibDirector then do:
            if not locked ibDirector then do:
                buffer-copy ttUpdateDirector to ibDirector.
                
                cSuccessMessage = "Director updated!".
                lSuccess = true.
            end. /* if not locked */
            else do:
                cSuccessMessage = "ERROR Update Director: Record is used by someone else!".
                lSuccess = false.
            end. /* else do */
        end. /* if not available */
        else do:
            cSuccessMessage = "ERROR Update Director: Record not found!".
            lSuccess = false.
        end. /* else do */
    end. /* method updateDirector */

end class.