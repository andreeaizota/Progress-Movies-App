@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
 
 /*------------------------------------------------------------------------
    File        : HomePageBusiness
    Purpose     : Business class for the home page
    Syntax      : 
    Description : 
    Author(s)   : aIzota
    Created     : Tue Nov 24 14:17:16 EET 2020
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using DataAccess.*.

block-level on error undo, throw.

class BusinessLogic.HomePageBusiness: 
    define private property ioMoviesDataAccess as MoviesDataAccess
        get.
        set.
        
    define private property ioActorDataAccess as ActorDataAccess
        get.
        set.
        
        
    /* Defining internal temp tables and datasets */
    define temp-table ttGetAllMovies like Movie.
    define temp-table ttRecentMovies like Movie.
    define temp-table ttFavoritesMovies like Movie.
    define temp-table ttGetAllActors like Actor.
        
     
    /* Default constructor */      
    constructor public HomePageBusiness (  ):
        super ().
        ioMoviesDataAccess = new MoviesDataAccess().
        ioActorDataAccess = new ActorDataAccess().
        
    end constructor.


    /* Destructor executed when the object is deleted */
    destructor public HomePageBusiness ( ):
        delete object ioMoviesDataAccess.
        delete object ioActorDataAccess.
        empty temp-table ttGetAllMovies.
        empty temp-table ttRecentMovies.
        empty temp-table ttFavoritesMovies.
        empty temp-table ttGetAllActors.
    end destructor.
   
   
   /*  API to get the recent Movies 
        * input:
        *           void
        * output:
        *           table ttGetRecentMovies
        *           cSuccessMessage character
        *           lSuccess logical
    */
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void getWhatsNew(output table ttRecentMovies, output cSuccessMessage as character, output lSuccess as logical):
        ioMoviesDataAccess:getRecentMovies(input-output table ttRecentMovies by-reference, cSuccessMessage, lSuccess).

    end method.
    
    
    /*  API to get the fan favorites Movies 
        * input:
        *           void
        * output:
        *           table ttFavoritesMovies
        *           cSuccessMessage character
        *           lSuccess logical
    */
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void getFanFavorites(output table ttFavoritesMovies, output cSuccessMessage as character, output lSuccess as logical):
        ioMoviesDataAccess:getFanFavoritesMovies(input-output table ttFavoritesMovies by-reference, cSuccessMessage, lSuccess).

    end method.
    
    
    /*  API to get what to watch when it comes to Movies 
        * input:
        *           void
        * output:
        *           table ttGetAllMovies
        *           cSuccessMessage character
        *           lSuccess logical
    */
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void getWhatToWatch(output table ttGetAllMovies, output cSuccessMessage as character, output lSuccess as logical):
        ioMoviesDataAccess:getAllMovies(input-output table ttGetAllMovies by-reference, cSuccessMessage, lSuccess).

    end method.
    
    
    /*  API to get the celebrities 
        * input:
        *           void
        * output:
        *           table ttGetAllActors
        *           cSuccessMessage character
        *           lSuccess logical
    */
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void getCelebitries(output table ttGetAllActors, output cSuccessMessage as character, output lSuccess as logical):
        ioActorDataAccess:getAllActors(input-output table ttGetAllActors by-reference, cSuccessMessage, lSuccess).

    end method.

end class.