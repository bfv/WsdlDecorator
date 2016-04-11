 
 /*------------------------------------------------------------------------
    File        : WsdlJsonRuleProvider
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Mon Apr 11 10:34:24 CEST 2016
    Notes       : 
  ----------------------------------------------------------------------*/

using bfv.web.wsdl.WsdlRuleProviderBase from propath.

block-level on error undo, throw.

class bfv.web.wsdl.WsdlJsonRuleProvider inherits WsdlRuleProviderBase: 
  
  constructor public WsdlJsonRuleProvider(jsonFilename as character):
    temp-table ttwsdlrule:read-json("file", jsonFilename).
  end.
  
end class.