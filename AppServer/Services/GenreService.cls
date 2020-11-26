@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
 
 /*------------------------------------------------------------------------
    File        : GenreService
    Purpose     : Class that provides the necessary services for Genre
    Syntax      : 
    Description : 
    Author(s)   : aIzota
    Created     : Tue Nov 24 08:51:59 EET 2020
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

class Services.GenreService: 
    /* Defining internal buffers */
    define buffer ibGenre for Genre.
    
    
    /* Defining internal temp tables and datasets */
    define temp-table ttGetAllGenres like Genre.
    define temp-table ttAddGenre like Genre.
    define temp-table ttUpdateGenre like Genre.
    define dataset dsGenreSet for ttUpdateGenre.
    
    
    /* Default constructor */
    constructor public GenreService (  ):
        super ().
        
    end constructor.


    /* Destructor executed when the object is deleted */
    destructor public GenreService ( ):
        empty temp-table ttGetAllGenres.
        empty temp-table ttAddGenre.
        empty temp-table ttUpdateGenre.
    end destructor.

    
    /*  REST Service to get all the Genres 
        * input:
        *           void
        * output:
        *           table ttGetAllGenres
        *           cSuccessMessage character
        *           lSuccess logical
    */
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void getAllGenres(output table ttGetAllGenres, output cSuccessMessage as character, output lSuccess as logical):
        empty temp-table ttGetAllGenres.
        
        for each ibGenre no-lock:
            create ttGetAllGenres.
            buffer-copy ibGenre to ttGetAllGenres.
            
            /* Catch if a errror occurs when copying data for fetching Genres */
            catch eSysError as Progress.Lang.Error:
                message "ERROR Fetch all Genres: error ocured when copying data.".
                cSuccessMessage = "Error, records not fetched!".
                lSuccess = false.
            end catch.
        end. /* for each */
        
        cSuccessMessage = "Records fetched successfully!".
        lSuccess = true.
    end. /* method getAllGenres */
    
    
    /*  REST Service to add a new Genre 
        * input:
        *           cGenre character
        * output:
        *           cSuccessMessage character
        *           lSuccess logical
    */
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void addGenre(input cGenre as character, output cSuccessMessage as character, output lSuccess as logical):
        create ttAddGenre.
        assign
            ttAddGenre.GenreId = next-value(NextGenreId)
            ttAddGenre.Genre = cGenre.
            
        buffer-copy ttAddGenre to ibGenre.    
        
        /* Catch if a errror occurs when creating a new Genre record */
        catch eSysError as Progress.Lang.Error:
            message "ERROR Add new Genre: error ocured when creating a new record.".
            cSuccessMessage = "Error, record not added!".
            lSuccess = false.
            return.
        end catch.
        finally:        
            cSuccessMessage = "Record created successfully!".
            lSuccess = true.
        end finally. 
    end. /* method addGenre */


    /*  REST Service to delete an Genre by Id
        * input:
        *           iGenreId integer
        * output:
        *           cSuccessMessage character
        *           lSuccess logical
    */
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void deleteGenre(input iGenreId as integer, output cSuccessMessage as character, output lSuccess as logical):
        /* Find Genre to be deleted in database */
        find first ibGenre where ibGenre.GenreId = iGenreId exclusive-lock no-error.    
        
        if available ibGenre then do:
            if not locked ibGenre then do:
                delete ibGenre.
                cSuccessMessage = "Genre deleted!".
                lSuccess = true.
            end. /* if not locked */
            else do:
                cSuccessMessage = "ERROR Delete Genre: Record is used by someone else!".
                lSuccess = false.
            end. /* else do */
        end. /* if not available */
        else do:
            cSuccessMessage = "ERROR Delete Genre: Record not found!".
            lSuccess = false.
        end. /* else do */
    end. /* method deleteGenre */
    
    
    /*  REST Service to update an Genre by Id
        * input:
        *           iGenreId integer
        *           dataset dsGenreSet
        * output:
        *           cSuccessMessage character
        *           lSuccess logical
    */
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void updateGenre(input iGenreId as integer, input dataset dsGenreSet, output cSuccessMessage as character, output lSuccess as logical):
        /* Get the data that was sent */
        find first ttUpdateGenre.
        /* Find Genre to be updated in database */
        find first ibGenre where ibGenre.GenreId = iGenreId exclusive-lock no-error.    
        
        assign ttUpdateGenre.GenreId = iGenreId.
        
        if available ibGenre then do:
            if not locked ibGenre then do:
                buffer-copy ttUpdateGenre to ibGenre.
                
                cSuccessMessage = "Genre updated!".
                lSuccess = true.
            end. /* if not locked */
            else do:
                cSuccessMessage = "ERROR Update Genre: Record is used by someone else!".
                lSuccess = false.
            end. /* else do */
        end. /* if not available */
        else do:
            cSuccessMessage = "ERROR Update Genre: Record not found!".
            lSuccess = false.
        end. /* else do */
    end. /* method updateGenre */
    
end class.