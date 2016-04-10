 
 /*------------------------------------------------------------------------
    File        : AddressTypeEnum
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Sat Apr 09 13:58:07 CEST 2016
    Notes       : this not an enum but is just there to provide the  
                  GetValues method as an example for restrictions
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

class bfv.web.wsdl.sample.AddressTypeEnum: 
  
  method public static character GetValues():
    return "1,2,3".
  end method.
  
end class.