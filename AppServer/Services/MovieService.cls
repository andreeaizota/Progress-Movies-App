@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
 
 /*------------------------------------------------------------------------
    File        : MovieService
    Purpose     : Class that provides the necessary services for Movie
    Syntax      : 
    Description : 
    Author(s)   : aIzota
    Created     : Tue Nov 24 07:43:07 EET 2020
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

class Services.MovieService: 
    /* Defining internal buffers */
    define buffer ibMovie for Movie.
    
    
    /* Defining internal temp tables and datasets */
    define temp-table ttGetAllMovies like Movie.
    define temp-table ttGetRecentMovies like Movie.
    define temp-table ttAddMovie like Movie.
    define temp-table ttUpdateMovie like Movie.
    define dataset dsMovieSet for ttUpdateMovie.
    
    
    /* Default constructor */
    constructor public MovieService (  ):
        super ().
        
    end constructor.

    
    /* Destructor executed when the object is deleted */
    destructor public MovieService ( ):
        empty temp-table ttGetAllMovies.
        empty temp-table ttAddMovie.
        empty temp-table ttUpdateMovie.
    end destructor.

    
    /*  REST Service to get all the Movies 
        * input:
        *           void
        * output:
        *           table ttGetAllMovies
        *           cSuccessMessage character
        *           lSuccess logical
    */
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void getAllMovies(output table ttGetAllMovies, output cSuccessMessage as character, output lSuccess as logical):
        empty temp-table ttGetAllMovies.
        
        for each ibMovie no-lock:
            create ttGetAllMovies.
            buffer-copy ibMovie to ttGetAllMovies.
            
            /* Catch if a errror occurs when copying data for fetching Movies */
            catch eSysError as Progress.Lang.Error:
                message "ERROR Fetch all Movies: error ocured when copying data.".
                cSuccessMessage = "Error, records not fetched!".
                lSuccess = false.
            end catch.
        end. /* for each */
        
        cSuccessMessage = "Records fetched successfully!".
        lSuccess = true.
    end. /* method getAllMovies */
    
    
    /*  REST Service to add a new Movie 
        * input:
        *           cName character
        *           dReleaseDate date
        *           dRating decimal
        * output:
        *           cSuccessMessage character
        *           lSuccess logical
    */
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void addMovie(input cName as character, input dReleaseDate as date, input dRating as decimal,
                                 output cSuccessMessage as character, output lSuccess as logical):
        create ttAddMovie.
        assign
            ttAddMovie.MovieId = next-value(NextMovieId)
            ttAddMovie.Name = cName
            ttAddMovie.ReleaseDate = dReleaseDate
            ttAddMovie.Rating = dRating.
            
        buffer-copy ttAddMovie to ibMovie.    
        
        /* Catch if a errror occurs when creating a new Movie record */
        catch eSysError as Progress.Lang.Error:
            message "ERROR Add new Movie: error ocured when creating a new record.".
            cSuccessMessage = "Error, record not added!".
            lSuccess = false.
            return.
        end catch.
        finally:        
            cSuccessMessage = "Record created successfully!".
            lSuccess = true.
        end finally. 
    end. /* method addMovie */


    /*  REST Service to delete an Movie by Id
        * input:
        *           iMovieId integer
        * output:
        *           cSuccessMessage character
        *           lSuccess logical
    */
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void deleteMovie(input iMovieId as integer, output cSuccessMessage as character, output lSuccess as logical):
        /* Find Movie to be deleted in database */
        find first ibMovie where ibMovie.MovieId = iMovieId exclusive-lock no-error.    
        
        if available ibMovie then do:
            if not locked ibMovie then do:
                delete ibMovie.
                cSuccessMessage = "Movie deleted!".
                lSuccess = true.
            end. /* if not locked */
            else do:
                cSuccessMessage = "ERROR Delete Movie: Record is used by someone else!".
                lSuccess = false.
            end. /* else do */
        end. /* if not available */
        else do:
            cSuccessMessage = "ERROR Delete Movie: Record not found!".
            lSuccess = false.
        end. /* else do */
    end. /* method deleteMovie */
    
    
    /*  REST Service to update an Movie by Id
        * input:
        *           iMovieId integer
        *           dataset dsMovieSet
        * output:
        *           cSuccessMessage character
        *           lSuccess logical
    */
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void updateMovie(input iMovieId as integer, input dataset dsMovieSet, output cSuccessMessage as character, output lSuccess as logical):
        /* Get the data that was sent */
        find first ttUpdateMovie.
        /* Find Movie to be updated in database */
        find first ibMovie where ibMovie.MovieId = iMovieId exclusive-lock no-error.    
        
        assign ttUpdateMovie.MovieId = iMovieId.
        
        if available ibMovie then do:
            if not locked ibMovie then do:
                buffer-copy ttUpdateMovie to ibMovie.
                
                cSuccessMessage = "Movie updated!".
                lSuccess = true.
            end. /* if not locked */
            else do:
                cSuccessMessage = "ERROR Update Movie: Record is used by someone else!".
                lSuccess = false.
            end. /* else do */
        end. /* if not available */
        else do:
            cSuccessMessage = "ERROR Update Movie: Record not found!".
            lSuccess = false.
        end. /* else do */
    end. /* method updateMovie */

end class.