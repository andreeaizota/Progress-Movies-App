 
 /*------------------------------------------------------------------------
    File        : MoviesDataAccess
    Purpose     : Class that assures data access for Movie
    Syntax      : 
    Description : 
    Author(s)   : aIzota
    Created     : Tue Nov 24 16:34:04 EET 2020
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

class DataAccess.MoviesDataAccess: 
    /* Defining internal buffers */
    define buffer ibMovie for Movie.
    define buffer ibRole for Role.
    define buffer ibActor for Actor.
    define buffer ibAMG for AMG.
    define buffer ibGenre for Genre.
        
    
    /* Defining internal temp tables and datasets */
    define temp-table ttGetAllMovies like Movie.
    define temp-table ttGetRecentMovies like Movie.
    define temp-table ttGetFanFavoritesMovies like Movie.
    define temp-table ttGetByNameOrActorMovies like Movie.
    define temp-table ttGetByRatingMovies like Movie.
    define temp-table ttGetByGenreMovies like Movie.
    
    
    /* Default constructor */    
    constructor public MoviesDataAccess (  ):
        super ().
        
    end constructor.


    /* Destructor executed when the object is deleted */
	destructor public MoviesDataAccess ( ):
        empty temp-table ttGetAllMovies.
        empty temp-table ttGetRecentMovies.
        empty temp-table ttGetFanFavoritesMovies.
        empty temp-table ttGetByNameOrActorMovies.
        empty temp-table ttGetByGenreMovies.
        empty temp-table ttGetByRatingMovies.
	end destructor.
    
    
    /*  REST Service to get the recent Movies 
        * input:
        *           void
        * output:
        *           table ttGetRecentMovies
        *           cSuccessMessage character
        *           lSuccess logical
    */
    method public void getRecentMovies(input-output table ttGetRecentMovies, output cSuccessMessage as character, output lSuccess as logical):
        /* Variable to count number of records because I want to get only 6 records */ 
        define variable iiCountRecords as integer initial 1 no-undo.
        empty temp-table ttGetRecentMovies.
        
        for each ibMovie no-lock by ibMovie.ReleaseDate descending:
            if iiCountRecords > 6 then leave.
            
            create ttGetRecentMovies.
            buffer-copy ibMovie to ttGetRecentMovies.
            
            iiCountRecords = iiCountRecords + 1.
            
            /* Catch if an errror occurs when copying data for fetching Movies */
            catch eSysError as Progress.Lang.Error:
                message "ERROR Fetch recent Movies: error ocured when copying data.".
                cSuccessMessage = "Error, records not fetched! (recentMovies)".
                lSuccess = false.
            end catch.
        end. /* for each */
        
        cSuccessMessage = "Records fetched successfully!".
        lSuccess = true.
    end method. /* getRecentMovies */
    
    
   /*  REST Service to get the Movies with the highest ratings
        * input:
        *           void
        * output:
        *           table ttGetFanFavoritesMovies
        *           cSuccessMessage character
        *           lSuccess logical
    */
    method public void getFanFavoritesMovies(input-output table  ttGetFanFavoritesMovies, output cSuccessMessage as character, output lSuccess as logical):
        /* Variable to count number of records because I want to get only 6 records */ 
        define variable iiCountRecords as integer initial 1 no-undo.
        empty temp-table ttGetFanFavoritesMovies.
        
        for each ibMovie no-lock by ibMovie.Rating descending:
            if iiCountRecords > 6 then leave.
            
            create ttGetFanFavoritesMovies.
            buffer-copy ibMovie to ttGetFanFavoritesMovies.
            
            iiCountRecords = iiCountRecords + 1.
            
            /* Catch if an errror occurs when copying data for fetching Movies */
            catch eSysError as Progress.Lang.Error:
                message "ERROR Fetch favorite Movies: error ocured when copying data.".
                cSuccessMessage = "Error, records not fetched! (favoritesMovies)".
                lSuccess = false.
            end catch.
        end. /* for each */
        
        cSuccessMessage = "Records fetched successfully!".
        lSuccess = true.
    end method. /* getFanFavoritesMovies */
    
    
    /*  REST Service to get all the Movies 
        * input:
        *           void
        * output:
        *           table ttGetAllMovies
        *           cSuccessMessage character
        *           lSuccess logical
    */
    method public void getAllMovies(input-output table ttGetAllMovies, output cSuccessMessage as character, output lSuccess as logical):
        empty temp-table ttGetAllMovies.
        
        for each ibMovie no-lock:
            create ttGetAllMovies.
            buffer-copy ibMovie to ttGetAllMovies.
            
            /* Catch if an errror occurs when copying data for fetching Movies */
            catch eSysError as Progress.Lang.Error:
                message "ERROR Fetch all Movies: error ocured when copying data.".
                cSuccessMessage = "Error, records not fetched!".
                lSuccess = false.
            end catch.
        end. /* for each */
        
        cSuccessMessage = "Records fetched successfully!".
        lSuccess = true.
    end method. /* getAllMovies */
    
    
    
   /*  REST Service to get all the Movies containing the string given as paramter either
        *   in the movie's name, either in the name of an actor playing in the movie
        * input:
        *           cName character
        * output:
        *           table ttGetByNameOrActorMovies
        *           cSuccessMessage character
        *           lSuccess logical
    */
    method public void getMoviesByNameOrActor(input cName as character, input-output table ttGetByNameOrActorMovies, output cSuccessMessage as character, output lSuccess as logical):
        empty temp-table ttGetByNameOrActorMovies.
        
        for each ibMovie no-lock:
            /* Check if given string is substring of the movie's name */
            if ibMovie.Name matches ("*" + cName + "*") then do on error undo:
                create ttGetByNameOrActorMovies.
                buffer-copy ibMovie to ttGetByNameOrActorMovies.
                
                /* Catch if an errror occurs when copying data for fetching Movies */
                catch eSysError as Progress.Lang.Error:
                    message "ERROR Search Movies: error ocured when copying data.".
                    cSuccessMessage = "Error, records not fetched!".
                    lSuccess = false.
                end catch.
            end. /* if */
            else do:
                insideBlock:
                for each ibRole of ibMovie no-lock, each ibActor of ibRole no-lock:
                    /* Check if given string is substring of an actor's name */
                    if ibActor.FirstName + " " + ibActor.LastName matches ("*" + cName + "*") then do on error undo:
                        create ttGetByNameOrActorMovies.
                        buffer-copy ibMovie to ttGetByNameOrActorMovies.
                        
                        /* Catch if an errror occurs when copying data for fetching Movies */
                        catch eSysError as Progress.Lang.Error:
                            message "ERROR Search Movies: error ocured when copying data.".
                            cSuccessMessage = "Error, records not fetched!".
                            lSuccess = false.
                        end catch.
                        finally:
                            /* When an actor having a correspoding name is found, leave the for each
                               because I don't want to have the movie duplicated in the result table */
                            leave insideBlock.    
                        end finally.
                    end. /* if */
                end. /* for each */
            end. /*else */
        end. /* for each */
        
        cSuccessMessage = "Records found successfully!".
        lSuccess = true.
    end method. /* getMoviesByNameOrActor */
    
    
    /*  REST Service to get Movies filtered by rating 
        * input:
        *           cRatingInterval character
        * output:
        *           table ttGetByRatingMovies
        *           cSuccessMessage character
        *           lSuccess logical
    */
    method public void getMoviesByRating(input cRatingInterval as character, input-output table ttGetByRatingMovies,
                                            output cSuccessMessage as character, output lSuccess as logical):
        define variable iiMinRating as integer no-undo.
        define variable iiMaxRating as integer no-undo.
    
        assign 
            iiMinRating = integer(entry(1, cRatingInterval))
            iiMaxRating = integer(entry(2, cRatingInterval)).
        
        empty temp-table ttGetByRatingMovies.
        
        for each ibMovie where (ibMovie.Rating >= iiMinRating and ibMovie.Rating <= iiMaxRating) no-lock:
            create ttGetByRatingMovies.
            buffer-copy ibMovie to ttGetByRatingMovies.
            
            /* Catch if an errror occurs when copying data for fetching Movies */
            catch eSysError as Progress.Lang.Error:
                message "ERROR Fetch Movies by Rating: error ocured when copying data.".
                cSuccessMessage = "Error, records not fetched! (by rating)".
                lSuccess = false.
            end catch.
        end. /* for each */
        
        cSuccessMessage = "Records fetched successfully!".
        lSuccess = true.
    end method. /* getMoviesByRating */
    
    
    /*  REST Service to get Movies filtered by genre 
        * input:
        *           cGenre character
        * output:
        *           table ttGetByGenreMovies
        *           cSuccessMessage character
        *           lSuccess logical
    */
    method public void getMoviesByGenre(input cGenre as character, input-output table ttGetByGenreMovies,
                                            output cSuccessMessage as character, output lSuccess as logical):
        define variable iiCurrentEntry as integer no-undo.
        define variable ilFoundCurrentGenre as logical no-undo.
        
        empty temp-table ttGetByGenreMovies.
        
        outsideBlock:
        for each ibMovie no-lock: 
            repeatBlock:
            repeat iiCurrentEntry = 1 to num-entries(cGenre):  
                ilFoundCurrentGenre = false.  
                        
                for each ibAMG of ibMovie no-lock:
                    if can-find(ibGenre where 
                                        (ibGenre.GenreId = ibAMG.GenreId and ibGenre.Genre = entry(iiCurrentEntry, cGenre))
                                         no-lock) then do:
                        ilFoundCurrentGenre = true.
                        next repeatBlock.
                    end. /* if */ 
                end. /* for each */
                
                if ilFoundCurrentGenre = false then
                    next outsideBlock.
            end. /* repeat */
            
            create ttGetByGenreMovies.
            buffer-copy ibMovie to ttGetByGenreMovies.
            
            /* Catch if an errror occurs when copying data for fetching Movies */
            catch eSysError as Progress.Lang.Error:
                message "ERROR Fetch Movies by genre: error ocured when copying data.".
                cSuccessMessage = "Error, records not fetched!(by genre)".
                lSuccess = false.
            end catch.
        end. /* for each */
        
        cSuccessMessage = "Records fetched successfully!".
        lSuccess = true.
    end method. /* getMoviesByGenre */    
    
    
    /*  REST Service to update the rating of a movie 
        * input:
        *           iNewRating as integer
        * output:
        *           cSuccessMessage character
        *           lSuccess logical
    */
    method public void updateRating(input iNewRating as decimal, input iMovieId as integer, output cSuccessMessage as character, output lSuccess as logical):
        /* Find Movie to be updated in database */
        find first ibMovie where ibMovie.MovieId = iMovieId exclusive-lock no-error.    
        
        if available ibMovie then do:
            if not locked ibMovie then do:
                assign ibMovie.Rating = iNewRating. 
                cSuccessMessage = "Movie rating updated!".
                lSuccess = true.
            end. /* if not locked */
            else do:
                cSuccessMessage = "ERROR Update Movie Rating: Record is used by someone else!".
                lSuccess = false.
            end. /* else do */
        end. /* if not available */
        else do:
            cSuccessMessage = "ERROR Update Movie Rating: Record not found!".
            lSuccess = false.
        end. /* else do */
    end method. /* updateRating */    
    
end class.