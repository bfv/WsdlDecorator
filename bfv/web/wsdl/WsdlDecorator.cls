 
 /*------------------------------------------------------------------------
    File        : WsdlDecorator
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Thu Apr 07 19:44:45 CEST 2016
    Notes       : 
  ----------------------------------------------------------------------*/

using bfv.web.wsdl.IWsdlDecorator.
using bfv.web.wsdl.WsdlDecorator.
using bfv.web.wsdl.IWsdlRuleProvider.

block-level on error undo, throw.

class bfv.web.wsdl.WsdlDecorator implements IWsdlDecorator: 
  
  {bfv/web/wsdl/ttwsdlrule.i}
  
  define public property XmlSchemaPrefix as character get. set.
  
  
  define private variable supportedRules as character no-undo.
  define private variable removeAttributes as character no-undo.
  
    
  constructor WsdlDecorator(provider as IWsdlRuleProvider):
    
    removeAttributes = "~~prodata:,nillable".  
    supportedRules = "add,remove,restrict".
    
    provider:GetRules(output table ttwsdlrule).
         
  end.
  
    
	method public void Decorate(node as handle, currentPath as character):
		
		define variable i as integer no-undo.
    define variable numAttributes as integer no-undo.
    define variable attributeName as character no-undo.
    define variable attributeNames as character no-undo.
    
		/* process attributes */
		numAttributes = num-entries(node:attribute-names).
		attributeNames = node:attribute-names.
		do i = 1 to numAttributes:
		  
		  attributeName = entry(i, attributeNames).
		  
		  if (isRemovableAttribute(attributeName)) then 
		    node:remove-attribute(attributeName).
		    
		end.
		
    applyRules(node, currentPath).
        
	end method.
	
	
	method private logical isRemovableAttribute(attributeName as character):
    
    define variable i as integer no-undo.
    define variable numRemoveAttributes as integer no-undo.
    define variable removeAttribute as character no-undo.
    
    numRemoveAttributes = num-entries(removeAttributes).
    do i = 1 to numRemoveAttributes:
      
      removeAttribute = entry(i, removeAttributes).
      
      if (attributeName = removeAttribute) then 
        return true.
        
      if (removeAttribute begins "~~" and attributeName begins substring(removeAttribute, 2)) then
        return true.
      
    end.
    
    return false.
    
  end method.
  
  
  method private void applyRules(node as handle, currentpath as character):
    
    for each ttwsdlrule:
      
      if (isPathMatch(ttwsdlrule.rulepath, currentpath)) then do:
        
        if (lookup(ttwsdlrule.ruletype, supportedRules) > 0) then
          dynamic-invoke(this-object, "apply" + ttwsdlrule.ruletype + "Rule", node, ttwsdlrule.rulevalue).
                  
      end.
        
    end.
     
  end method.
  
  
  method private void applyRemoveRule(node as handle, rulestring as character):
    
    if (lookup(rulestring, node:attribute-names) > 0) then
      node:remove-attribute(rulestring).
    
  end method.

  
  method private void applyAddRule(node as handle, rulestring as character):
    
    define variable attributeName as character no-undo.
    define variable attributeValue as character no-undo.
    
    if (num-entries(rulestring, "=") <> 2) then 
      return.
      
    node:set-attribute(
      entry(1, rulestring, "="),
      entry(2, rulestring, "=")      
    ).
    
  end method.
  
  
  method private void applyRestrictRule(node as handle, rulestring as character):
    
    define variable typevalue as character no-undo.
    define variable restricttype as character no-undo.
    define variable restrictvalue as character no-undo.
    
    restricttype = entry(1, rulestring, "=").
    restrictvalue = substring(rulestring, index(rulestring, "=") + 1).
    
    case restricttype:
      
      when "values" then
        addValueRestriction(node, restrictvalue).
        
      when "class" then 
        addClassRestriction(node, restrictvalue).
          
    end.
          
  end method.
  
  
  method private void addValueRestriction(node as handle, restrictvalues as character):
    
    define variable simpleTypeNode as handle no-undo.
    define variable restrictionNode as handle no-undo.
    define variable enumNode as handle no-undo.
    define variable nodetype as character no-undo.
    define variable i as integer no-undo.
    define variable numValues as integer no-undo.
    
    simpleTypeNode = createNode(node, "simpleType").
    
    nodetype = node:get-attribute("type").
    restrictionNode = createNode(simpleTypeNode, "restriction").
    restrictionNode:set-attribute("base", nodetype).
    node:remove-attribute("type").
    
    numValues = num-entries(restrictvalues).
    do i = 1 to numValues:
      enumNode = createNode(restrictionNode, "enumeration").
      enumNode:set-attribute("value", trim(entry(i, restrictvalues))).
    end.
    
    delete object simpleTypeNode no-error.
    delete object restrictionNode no-error.
    
  end method.
  
  
  method private void addClassRestriction(node as handle, restrictOperation as character):
    
    define variable restrictValues as character no-undo.
    
    if (restrictOperation matches "*()") then do:
      
      restrictValues = dynamic-invoke(
        entry(1, restrictOperation, ":"),
        replace(entry(2, restrictOperation, ":"), "()", "")
      ).
      
    end.
    else do:
      
      restrictValues = dynamic-property(
        entry(1, restrictOperation, ":"),
        replace(entry(2, restrictOperation, ":"), "()", "")
      ).
      
    end.
    
    if (restrictValues > "") then 
      addValueRestriction(node, restrictValues).
    
  end method.
  
    
  method private handle createNode(parentnode as handle, nodename as character):
    
    define variable node as handle no-undo.
    
    create x-noderef node.
    parentnode:owner-document:create-node(node, nodename, "element").
    parentnode:append-child(node).
    
    return node.
    
  end method.
  
  
  method private logical isPathMatch(rulepath as character, currentpath as character):
    
    return (rulepath = currentpath).
    
  end method.
  
end class.