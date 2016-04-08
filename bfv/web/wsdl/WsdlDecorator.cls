 
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
  
  
  method private void applyRules(node as handle, currentPath as character):
    
    for each ttwsdlrule:
      
      if (isPathMatch(currentPath, ttwsdlrule.rulePath)) then do:
        
        if (lookup(ttwsdlrule.ruletype, supportedRules) > 0) then
          dynamic-invoke(this-object, "apply" + ttwsdlrule.ruletype + "Rule", node, ttwsdlrule.rulevalue).
                  
      end.
        
    end.
     
  end method.
  
  
  method private void applyRemoveRule(node as handle, ruleString as character):
    
    if (lookup(ruleString, node:attribute-names) > 0) then
      node:remove-attribute(ruleString).
    
  end method.

  
  method private void applyAddRule(node as handle, ruleString as character):
    
    define variable attributeName  as character no-undo.
    define variable attributeValue as character no-undo.
    
    if (num-entries(ruleString, "=") <> 2) then 
      return.
      
    node:set-attribute(
      entry(1, ruleString, "="),
      entry(2, ruleString, "=")      
    ).
    
  end method.
  
  
  method private void applyRestrictRule(node as handle, ruleString as character):
    
    define variable typevalue as character no-undo.
    define variable restrictType as character no-undo.
    define variable restrictValue as character no-undo.
    
    restrictType = entry(1, ruleString, "=").
    restrictValue = substring(ruleString, index(ruleString, "=") + 1).
    
    case restrictType:
      
      when "values" then
        addValueRestriction(node, restrictValue).
        
      when "class" then 
        addClassRestriction(node, restrictValue).
          
    end.
          
  end method.
  
  
  method private void addValueRestriction(node as handle, restrictValues as character):
    
    define variable simpleTypeNode as handle no-undo.
    define variable restrictionNode as handle no-undo.
    define variable enumNode as handle no-undo.
    define variable nodeType as character no-undo.
    define variable i as integer no-undo.
    define variable numValues as integer no-undo.
    
    simpleTypeNode = createNode(node, "simpleType").
    
    nodeType = node:get-attribute("type").
    restrictionNode = createNode(simpleTypeNode, "restriction").
    restrictionNode:set-attribute("base", nodeType).
    node:remove-attribute("type").
    
    numValues = num-entries(restrictValues).
    do i = 1 to numValues:
      enumNode = createNode(restrictionNode, "enumeration").
      enumNode:set-attribute("value", trim(entry(i, restrictValues))).
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
  
    
  method private handle createNode(parentNode as handle, nodeName as character):
    
    define variable node as handle no-undo.
    
    create x-noderef node.
    parentNode:owner-document:create-node(node, nodeName, "element").
    parentNode:append-child(node).
    
    return node.
    
  end method.
  
  
  method private logical isPathMatch(currentPath as character, rulePath as character):
    
    return (currentPath = rulePath or currentPath matches rulePath).
    
  end method.
  
end class.