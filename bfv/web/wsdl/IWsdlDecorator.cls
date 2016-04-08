
/*------------------------------------------------------------------------
    File        : IWsdlDecorator
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Thu Apr 07 19:40:48 CEST 2016
    Notes       : 
  ----------------------------------------------------------------------*/


interface bfv.web.wsdl.IWsdlDecorator:  
  
  define public property XmlSchemaPrefix as character get. set.
  method public void Decorate(node as handle, currentPath as character).
  
end interface.