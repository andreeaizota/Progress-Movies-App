 
 /*------------------------------------------------------------------------
    File        : IncorrectMovieError
    Purpose     : Hangling errors if a Movie with the specified MovieId does
                            not exist in the database
    Syntax      : 
    Description : 
    Author(s)   : aIzota
    Created     : Tue Nov 24 14:37:01 EET 2020
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

class Errors.IncorrectMovieError inherits Progress.Lang.AppError:         
    constructor public IncorrectMovieError (  ):
        super ().
        
    end constructor.
       
        
    constructor public IncorrectMovieError (cTableName as character):
        super ().
        AddMessage("Invalid MovieId for " + cTableName, 1).
        message "Invalid MovieId for " + cTableName.
        
    end constructor.
    

    destructor public IncorrectMovieError ( ):

    end destructor.

end class.