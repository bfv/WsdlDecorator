 
 /*------------------------------------------------------------------------
    File        : WsdlProcessor
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Thu Apr 07 15:04:22 CEST 2016
    Notes       : 
  ----------------------------------------------------------------------*/

using bfv.web.wsdl.WsdlProcessor from propath.
using bfv.web.wsdl.IWsdlDecorator from propath.

block-level on error undo, throw.

class bfv.web.wsdl.WsdlProcessor: 
  
  define private variable sourceDoc as handle no-undo.
  define private variable targetDoc as handle no-undo.
  define private variable sourceRootNode as handle no-undo.
  define private variable targetRootNode as handle no-undo.
  define private variable tmpNode as handle no-undo.
  define private variable valueNode as handle no-undo.
  define private variable targetValueNode as handle no-undo.
  define private variable currentPath as character no-undo.
  define private variable decorator as IWsdlDecorator no-undo.
  define private variable xmlSchemaPrefix as character no-undo.
  
  
  destructor WsdlProcessor():
    delete object sourceDoc no-error.
    delete object targetDoc no-error.
    delete object sourceRootNode no-error.
    delete object tmpNode no-error.
    delete object valueNode no-error.
    delete object targetValueNode no-error.
  end.
  
  
  method public longchar Decorate(decoratorIn as IWsdlDecorator, wsdlIn as longchar):
    
    decorator = decoratorIn.
    
    init().
    
    loadSourceDocument(wsdlIn).
    initializeTargetDocument().
    parseSourceDocument().
    
    return writeTargetDocument().
    
  end.
  
  
  method private void init():
    create x-noderef tmpNode.
    create x-noderef valueNode.
    create x-noderef targetValueNode.
  end method.
  
  
  
  method private void loadSourceDocument(wsdl as longchar):
    
    define variable wsdlFile as character no-undo.
    
    if (wsdl begins "file:///") then do:
      wsdlFile = substring(wsdl, if (opsys = "win32") then 9 else 8).
      copy-lob file wsdlFile to wsdl.
    end.
    
    create x-document sourceDoc.
    sourceDoc:load("longchar", wsdl, false).
    
    create x-noderef sourceRootNode.
    sourceDoc:get-document-element(sourceRootNode).
    
    getXmlSchemaPrefix(sourceRootNode).
    
  end method.
  
  
  method private void initializeTargetDocument(): 
    create x-document targetDoc.
  end method.
  
  
  method private void parseSourceDocument():
    
    define variable i as integer no-undo.
    
    targetDoc:encoding = sourceDoc:encoding.
    
    /* setup the root node for the target */
    targetRootNode = copyNode(sourceRootNode, ?).
    targetDoc:append-child(targetRootNode).
    
    /* iterate children, call traverseNode for element's */
    do i = 1 to sourceRootNode:num-children:
      sourceRootNode:get-child(tmpNode, i).
      if (tmpNode:subtype = "element") then
        traverseNode(tmpNode, targetRootNode).  
    end.
    
  end method.
  
  
  method private void traverseNode(currentsource as handle, currenttarget as handle):
    
    define variable i as integer no-undo.
    define variable childNode as handle no-undo.
    define variable copiedNode as handle no-undo.
    define variable pathWasExpanded as logical no-undo.
    
    create x-noderef copiedNode.
    
    pathWasExpanded = addTocurrentPath(currentsource).
    getXmlSchemaPrefix(currentsource).
    
    /* copy first */
    copiedNode = copyNode(currentsource, ?).
    currenttarget:append-child(copiedNode).
    
    /* recurse through childs */
    if (currentsource:num-children > 0) then do:
      create x-noderef childNode.
      
      do i = 1 to currentsource:num-children:
        currentsource:get-child(childNode, i).
        if (childNode:subtype = "element") then 
          traverseNode(childNode, copiedNode). 
      end.
    
    end.
        
    if (pathWasExpanded) then
      removeFromcurrentPath(currentsource).
    
    finally:
      delete object childNode no-error.
      delete object copiedNode no-error.
    end.
    
  end method.

  
  method private handle copyNode(sourceNode as handle, targetNode as handle):
    
    define variable i as integer no-undo.
    define variable numEntries as integer no-undo.
    define variable attributeName as character no-undo.
    define variable hasNameAtrribute as logical no-undo.
    
    
    if (not valid-handle(targetNode)) then do:
      create x-noderef targetNode.
      targetDoc:create-node(targetNode, sourceNode:name, sourceNode:subtype).
    end.
    
    /* copy attributes */
    numEntries = num-entries(sourceNode:attribute-names).
    do i = 1 to numEntries:
      
      attributeName = entry(i, sourceNode:attribute-names).    
      if (attributeName = "name") then
        hasNameAtrribute = true.
        
      targetNode:set-attribute(attributeName, sourceNode:get-attribute(attributeName)).
    end.
    
    if (valid-object(decorator) and hasNameAtrribute) then 
      decorator:Decorate(targetNode, currentPath).
    
    /* copy content */   
    do i = 1 to sourceNode:num-children:
      
      sourceNode:get-child(valueNode, i).      
      if (valueNode:subtype = "text" and trim(valueNode:node-value) > "") then do:
        targetDoc:create-node(targetValueNode, ?, "text").
        targetValueNode:node-value =  trim(valueNode:node-value).
        targetNode:append-child(targetValueNode).
      end.
      
    end.
    
    return targetNode.
    
  end method.


  method private longchar writeTargetDocument():
    
    define variable resultWsdl as longchar no-undo.
    
    targetDoc:save("longchar", resultWsdl).
    
    return resultWsdl.
    
  end method.
  
  
  method private logical addTocurrentPath(node as handle): 
    
    define variable hasNameAttribute as logical no-undo.
    
    hasNameAttribute = (lookup("name", node:attribute-names) > 0).
    if (hasNameAttribute) then
      currentPath = currentPath + "/" + node:get-attribute("name").
    
    return hasNameAttribute.
    
  end method.
  
  
  method private void removeFromcurrentPath(node as handle):    
    currentPath = substring(currentPath, 1, r-index(currentPath, "/") - 1).
  end method.
  
  
  method private character getXmlSchemaPrefix(node as handle):
    
    define variable i as integer no-undo.
    define variable numAttributes as integer no-undo.
    define variable attributeName as character no-undo.
    define variable attributeValue as character no-undo.
    
    numAttributes = num-entries(node:attribute-names).
    loopattr:
    do i = 1 to numAttributes:
      
      attributeName = entry(i, node:attribute-names).
      attributeValue = node:get-attribute(attributeName).
      
      if (attributeValue = "http://www.w3.org/2001/XMLSchema") then do:
        
        if (num-entries(attributeName, ":") = 2) then
          xmlSchemaPrefix = entry(2, attributeName, ":").
        else 
          xmlSchemaPrefix = "".
          
        leave loopattr.
      end.
      
    end.
    
    if (valid-object(decorator)) then
      decorator:XmlSchemaPrefix = xmlSchemaPrefix.
    
    return xmlSchemaPrefix.
      
  end method.
  
end class.