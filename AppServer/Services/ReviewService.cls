@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
 
 /*------------------------------------------------------------------------
    File        : Review
    Purpose     : Class that provides the necessary services for Review
    Syntax      : 
    Description : 
    Author(s)   : aIzota
    Created     : Tue Nov 24 08:26:57 EET 2020
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using Errors.*.

block-level on error undo, throw.

class Services.ReviewService: 
    /* Defining internal buffers */
    define buffer ibReview for Review.
    define buffer ibMovie for Movie.
    
    
    /* Defining internal temp tables and datasets */
    define temp-table ttGetAllReviews like Review.
    define temp-table ttAddReview like Review.
    define temp-table ttUpdateReview like Review.
    define dataset dsReviewSet for ttUpdateReview.
    
    
    /* Default constructor */
    constructor public ReviewService (  ):
        super ().
        
    end constructor.


    /* Destructor executed when the object is deleted */
    destructor public ReviewService ( ):
        empty temp-table ttGetAllReviews.
        empty temp-table ttAddReview.
        empty temp-table ttUpdateReview.
    end destructor.

    
    /*  REST Service to get all the Reviews 
        * input:
        *           void
        * output:
        *           table ttGetAllReviews
        *           cSuccessMessage character
        *           lSuccess logical
    */
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void getAllReviews(output table ttGetAllReviews, output cSuccessMessage as character, output lSuccess as logical):
        empty temp-table ttGetAllReviews.
        
        for each ibReview no-lock:
            create ttGetAllReviews.
            buffer-copy ibReview to ttGetAllReviews.
            
            /* Catch if a errror occurs when copying data for fetching Reviews */
            catch eSysError as Progress.Lang.Error:
                message "ERROR Fetch all Reviews: error ocured when copying data.".
                cSuccessMessage = "Error, records not fetched!".
                lSuccess = false.
            end catch.
        end. /* for each */
        
        cSuccessMessage = "Records fetched successfully!".
        lSuccess = true.
    end. /* method getAllReviews */
    
    
    /*  REST Service to add a new Review 
        * input:
        *           iMovieId integer
        *           cTextR character
        *           iRating integer
        * output:
        *           cSuccessMessage character
        *           lSuccess logical
    */
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void addReview(input iMovieId as integer, input cTextR as character, input iRating as integer,
                                 output cSuccessMessage as character, output lSuccess as logical):
        /* Check if the MovieId is in the database */
        if not can-find(ibMovie where ibMovie.MovieId = iMovieId no-lock) then do:
            cSuccessMessage = "Error, record not added!".
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
            cSuccessMessage = "Error, record not added!".
            lSuccess = false.
            return.
        end catch.
        finally:        
            cSuccessMessage = "Record created successfully!".
            lSuccess = true.
        end finally. 
    end. /* method addReview */


    /*  REST Service to delete an Review by Id
        * input:
        *           iReviewId integer
        * output:
        *           cSuccessMessage character
        *           lSuccess logical
    */
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void deleteReview(input iReviewId as integer, output cSuccessMessage as character, output lSuccess as logical):
        /* Find Review to be deleted in database */
        find first ibReview where ibReview.ReviewId = iReviewId exclusive-lock no-error.    
        
        if available ibReview then do:
            if not locked ibReview then do:
                delete ibReview.
                cSuccessMessage = "Review deleted!".
                lSuccess = true.
            end. /* if not locked */
            else do:
                cSuccessMessage = "ERROR Delete Review: Record is used by someone else!".
                lSuccess = false.
            end. /* else do */
        end. /* if not available */
        else do:
            cSuccessMessage = "ERROR Delete Review: Record not found!".
            lSuccess = false.
        end. /* else do */
    end. /* method deleteReview */
    
    
    /*  REST Service to update an Review by Id
        * input:
        *           iReviewId integer
        *           dataset dsReviewSet
        * output:
        *           cSuccessMessage character
        *           lSuccess logical
    */
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    method public void updateReview(input iReviewId as integer, input dataset dsReviewSet, output cSuccessMessage as character, output lSuccess as logical):
        /* Get the data that was sent */
        find first ttUpdateReview.
        
        if not can-find(ibMovie where ibMovie.MovieId = ttUpdateReview.MovieId no-lock) then do:
            cSuccessMessage = "Error, record not updated!".
            lSuccess = false.
            return error new IncorrectMovieError("Review").
        end.
        
        /* Find Review to be updated in database */
        find first ibReview where ibReview.ReviewId = iReviewId exclusive-lock no-error.    
        
        assign 
            ttUpdateReview.ReviewId = iReviewId
            ttUpdateReview.ReviewDate = today.
        
        if available ibReview then do:
            if not locked ibReview then do:
                buffer-copy ttUpdateReview to ibReview.
                
                cSuccessMessage = "Review updated!".
                lSuccess = true.
            end. /* if not locked */
            else do:
                cSuccessMessage = "ERROR Update Review: Record is used by someone else!".
                lSuccess = false.
            end. /* else do */
        end. /* if not available */
        else do:
            cSuccessMessage = "ERROR Update Review: Record not found!".
            lSuccess = false.
        end. /* else do */
    end. /* method updateReview */

end class.