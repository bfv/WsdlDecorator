 
 /*------------------------------------------------------------------------
    File        : Logger
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Sat Apr 09 14:47:28 CEST 2016
    Notes       : 
  ----------------------------------------------------------------------*/

using bfv.sys.log.ILogger.

block-level on error undo, throw.

class bfv.sys.log.Logger implements ILogger: 
  
  define private stream logstream.
  
  constructor Logger(logfile as character):
    output stream logstream to value(logfile).
  end.
  
  destructor Logger():
    output stream logstream close.  
  end.
  
  
	method public void Log(logText as character ):
		put stream logstream unformatted iso-date(now) + "  " + logText + "~n".
	end method.
  
  
end class.