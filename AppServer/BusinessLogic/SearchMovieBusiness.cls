@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
 
 /*------------------------------------------------------------------------
    File        : SearchMovieBusiness
    Purpose     : Business class for searching movies
    Syntax      : 
    Description : 
    Author(s)   : aIzota
    Created     : Tue Nov 24 20:49:23 EET 2020
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using DataAccess.*.

block-level on error undo, throw.

class BusinessLogic.SearchMovieBusiness: 
    define private property ioMoviesDataAccess as MoviesDataAccess
        get.
        set.
    
    
    /* Defining internal temp tables and datasets */
    define temp-table ttGetMoviesByNameOrActor like Movie.
    define temp-table ttRecentMovies like Movie.
    define temp-table ttFavoritesMovies like Movie.
    define temp-table ttFilteredMovies like Movie.
    define temp-table ttMoviesByRating like Movie.
    define temp-table ttMoviesByGenre like Movie.
        
     
    /* Default constructor */      
    constructor public SearchMovieBusiness (  ):
        super ().
        ioMoviesDataAccess = new MoviesDataAccess().
        
    end constructor.


    /* Destructor executed when the object is deleted */
    destructor public SearchMovieBusiness ( ):
        delete object ioMoviesDataAccess.
        empty temp-table ttGetMoviesByNameOrActor.
        empty temp-table ttRecentMovies.
        empty temp-table ttFavoritesMovies.
        empty temp-table ttGetMoviesByNameOrActor.
        empty temp-table ttFilteredMovies.
        empty temp-table ttMoviesByRating.
        empty temp-table ttMoviesByGenre.
    end destructor.
   
   
   /*  API to get Movies by name and/or by Actor's name
        * input:
        *           void
        * output:
        *           table ttGetRecentMovies
        *           cSuccessMessage character
        *           lSuccess logical
    */
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void searchMovies(input cName as character, output table ttGetMoviesByNameOrActor, output cSuccessMessage as character, output lSuccess as logical):
        ioMoviesDataAccess:getMoviesByNameOrActor(cName, input-output table ttGetMoviesByNameOrActor by-reference, cSuccessMessage, lSuccess).

    end method.



    /*  API to get Movies filtered by rating and/or genre
        * input:
        *           void
        * output:
        *           table ttGetRecentMovies
        *           cSuccessMessage character
        *           lSuccess logical
    */
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void filterMovies(input cRatingInterval as character, input cGenres as character, 
                                    output table ttFilteredMovies, output cSuccessMessage as character, output lSuccess as logical):
        define variable cSuccessMessage1 as character no-undo.
        define variable cSuccessMessage2 as character no-undo. 
        define variable lSuccess1 as logical no-undo.
        define variable lSuccess2 as logical no-undo.                           
        
        empty temp-table ttFilteredMovies.
                                             
        ioMoviesDataAccess:getMoviesByRating(cRatingInterval, input-output table ttMoviesByRating by-reference, cSuccessMessage1, lSuccess1).
        ioMoviesDataAccess:getMoviesByGenre(cGenres, input-output table ttMoviesByGenre by-reference, cSuccessMessage2, lSuccess2).
        
        if lSuccess1 = true and lSuccess2 = true then do:
            for each ttMoviesByRating no-lock:
                if can-find(ttMoviesByGenre where ttMoviesByGenre.MovieId = ttMoviesByRating.MovieId) then do on error undo:
                    create ttFilteredMovies.
                    buffer-copy ttMoviesByRating to ttFilteredMovies.
                    
                    /* Catch if an errror occurs when copying data for fetching Movies */
                    catch eSysError as Progress.Lang.Error:
                        message "ERROR Fetch filtered Movies: error ocured when copying data.".
                        cSuccessMessage = "Error, records not fetched!(filtered movies)".
                        lSuccess = false.
                    end catch.
                end. /* if */
            end. /* for each */
             
            cSuccessMessage = "Records fetched successfully!".
            lSuccess = true.
        end. /* if */
        else if lSuccess1 = false then do:
            cSuccessMessage = cSuccessMessage1.
            lSuccess = false.
        end. /* else if */
        else do:
            cSuccessMessage = cSuccessMessage2.
            lSuccess = false.
        end. /* else */
    end method.

end class.