 
 /*------------------------------------------------------------------------
    File        : ReviewDataAccess
    Purpose     : Class that assures data access for Review
    Syntax      : 
    Description : 
    Author(s)   : aIzota
    Created     : Thu Nov 26 10:49:04 EET 2020
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using Errors.*.

block-level on error undo, throw.

class DataAccess.ReviewDataAccess: 
    /* Defining internal buffers */
    define buffer ibReview for Review.
    define buffer ibMovie for Movie.
    
    
   /* Defining internal temp tables and datasets */     
    define temp-table ttAddReview like Review.    
        
        
    /* Default constructor */    
    constructor public ReviewDataAccess (  ):
        super ().
        
    end constructor.


    /* Destructor executed when the object is deleted */
    destructor public ReviewDataAccess ( ):

    end destructor.


    /*  REST Service to add a new Review 
        * input:
        *           iMovieId integer
        *           cTextR character
        *           iRating integer
        * output:
        *           cSuccessMessage character
        *           lSuccess logical
    */
    method public void addReview(input iMovieId as integer, input cTextR as character, input iRating as integer,
                                 output cSuccessMessage as character, output lSuccess as logical):
        /* Check if the MovieId is in the database */
        if not can-find(ibMovie where ibMovie.MovieId = iMovieId no-lock) then do:
            cSuccessMessage = "Error, Review not added!".
            lSuccess = false.
            return error new IncorrectMovieError("Review").
        end.
        
        /* Adding a new record */ 
        create ttAddReview.
        assign
            ttAddReview.ReviewId = next-value(NextReviewId)
            ttAddReview.MovieId = iMovieId
            ttAddReview.TextR = cTextR
            ttAddReview.ReviewDate = today.
            ttAddReview.Rating = iRating.
            
        buffer-copy ttAddReview to ibReview.    
        
        /* Catch if a errror occurs when creating a new Review record */
        catch eSysError as Progress.Lang.Error:
            message "ERROR Add new Review: error ocured when creating a new record.".
            cSuccessMessage = "Error, Review not added!".
            lSuccess = false.
            return.
        end catch.
        finally:        
            cSuccessMessage = "Record created successfully!".
            lSuccess = true.
        end finally. 
    end. /* method addReview */
end class.