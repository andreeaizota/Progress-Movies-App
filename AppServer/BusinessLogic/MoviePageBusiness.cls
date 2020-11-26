@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
 
 /*------------------------------------------------------------------------
    File        : MoviePageBusiness
    Purpose     : Business class for the page of a movie
    Syntax      : 
    Description : 
    Author(s)   : aIzota
    Created     : Thu Nov 26 10:39:26 EET 2020
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using DataAccess.*.
using Errors.*.

block-level on error undo, throw.

class BusinessLogic.MoviePageBusiness: 
    define private property ioMoviesDataAccess as MoviesDataAccess
        get.
        set.
        
    
    define private property ioReviewDataAccess as ReviewDataAccess
        get.
        set.  
    
    
    /* Defining internal buffers */
    define buffer ibReview for Review.
    define buffer ibMovie for Movie.
    
    
    /* Default constructor */        
    constructor public MoviePageBusiness (  ):
        super ().
        ioMoviesDataAccess = new MoviesDataAccess().
        ioReviewDataAccess = new ReviewDataAccess().
        
    end constructor.


    /* Destructor executed when the object is deleted */
    destructor public MoviePageBusiness ( ):
        delete object ioMoviesDataAccess.
        delete object ioReviewDataAccess.
    end destructor.
    
    
   /*  API to add a review to a movie
        * input:
        *           iMovieId integer
        *           cTextR character
        *           iRating integer
        * output:
        *           cSuccessMessage character
        *           lSuccess logical
    */
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void addReviewToMovie(input iMovieId as integer, input cTextR as character, input iRating as integer,
                                 output cSuccessMessage as character, output lSuccess as logical):
        define variable cSuccessMessage1 as character no-undo.
        define variable cSuccessMessage2 as character no-undo. 
        define variable lSuccess1 as logical no-undo.
        define variable lSuccess2 as logical no-undo. 
        define variable iNewRating as decimal no-undo.
        define variable iCurrentNumberOfReviews as integer no-undo initial 0.
        
        /* Validation for rating to be between 1 and 10 */
        if iRating < 1 or iRating > 10 then do:
            cSuccessMessage = "Rating must be between 1 and 10".
            lSuccess = false.
            return error new RatingError().
        end. /* if */
        else do: 
            /* Add review in DB */
            ioReviewDataAccess:addReview(iMovieId, cTextR, iRating, cSuccessMessage1, lSuccess1).
            
            /* If review was added, update the rating of the movie */
            if lSuccess1 = true then do:
                /* Count number of reviews */
                for each ibReview where ibReview.MovieId = iMovieId no-lock:
                    iCurrentNumberOfReviews = iCurrentNumberOfReviews + 1.
                end. /* for each */
                
                /* Compute the new rating */
                find first ibMovie where ibMovie.MovieId = iMovieId no-lock.
                iNewRating = (ibMovie.Rating * (iCurrentNumberOfReviews - 1) + iRating) / iCurrentNumberOfReviews.
                
                /* Update the rating in DB */
                ioMoviesDataAccess:updateRating(iNewRating, iMovieId, cSuccessMessage2, lSuccess2).
                
                if lSuccess2 = false then do:
                    cSuccessMessage = cSuccessMessage2.
                    lSuccess = false.
                end. /* if lSuccess2 = true */
                else do:
                    cSuccessMessage = cSuccessMessage1.
                    lSuccess = true.
                end. /* else do */
            end. /* if lSuccess1 = true */
            else do:
                cSuccessMessage = cSuccessMessage1.
                lSuccess = false.
            end. /* else do */
        end. /* else do */
        
    end method. /* addReviewToMovie */

end class.