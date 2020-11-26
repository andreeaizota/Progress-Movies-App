 
 /*------------------------------------------------------------------------
    File        : IncorrectActorError
    Purpose     : Hangling errors if an Actor with the specified ActorId does
                            not exist in the database
    Syntax      : 
    Description : 
    Author(s)   : aIzota
    Created     : Tue Nov 24 15:02:59 EET 2020
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

class Errors.IncorrectActorError inherits Progress.Lang.AppError:         
    constructor public IncorrectActorError (  ):
        super ().
        
    end constructor.
    
    constructor public IncorrectActorError (cTableName as character):
        super ().
        AddMessage("Invalid ActorId for " + cTableName, 1).
        message "Invalid ActorId for " + cTableName.
        
    end constructor.
    

    destructor public IncorrectActorError ( ):

    end destructor.

end class.