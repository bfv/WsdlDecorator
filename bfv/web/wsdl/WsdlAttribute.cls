 
 /*------------------------------------------------------------------------
    File        : Attribute
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Sun Apr 10 12:09:01 CEST 2016
    Notes       : 
  ----------------------------------------------------------------------*/


block-level on error undo, throw.

class bfv.web.wsdl.WsdlAttribute: 
  
  define public property Name as character no-undo get. set.
  define public property Value as character no-undo get. set.
  
  constructor WsdlAttribute():
  end.

  constructor WsdlAttribute(nameIn as character, valueIn as character):
    this-object:Name = nameIn.
    this-object:Value = valueIn.  
  end.
    
end class.