 
 /*------------------------------------------------------------------------
    File        : RatingError
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : aIzota
    Created     : Tue Nov 24 15:53:34 EET 2020
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

class Errors.RatingError inherits Progress.Lang.AppError: 
    constructor public RatingError (  ):
        super ().
        AddMessage("Rating must be between 1 and 10", 1).
        message "Rating must be between 1 and 10".
        
    end constructor.


    destructor public RatingError ( ):

    end destructor.

end class.