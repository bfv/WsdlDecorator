

using bfv.web.wsdl.WsdlDecorator from propath.
using bfv.web.wsdl.WsdlProcessor from propath.
using bfv.web.wsdl.IWsdlRuleProvider from propath.
using bfv.web.wsdl.sample.PersonRuleProvider from propath.
using bfv.sys.log.ILogger from propath.
using bfv.sys.log.Logger from propath.
using bfv.web.wsdl.WsdlJsonRuleProvider from propath.

define variable decorator as WsdlDecorator no-undo.
define variable parser as WsdlProcessor no-undo.
define variable wsdl as longchar no-undo.
define variable provider  as IWsdlRuleProvider no-undo.
define variable logger as ILogger no-undo.


provider = new WsdlJsonRuleProvider("./bfv/web/wsdl/sample/person.rules.json").
logger = new Logger("c:/tmp/person.log").

decorator = new WsdlDecorator(provider, logger).
parser = new WsdlProcessor().

wsdl = parser:Decorate(decorator, "file:///C:\dev\wsdldecorator\src\wsdldecorator\bfv\web\wsdl\sample\wsperson.wsdl").

copy-lob wsdl to file "C:\dev\wsdldecorator\src\wsdldecorator\bfv\web\wsdl\sample\wsperson.wsdl.out".
    
message "done" view-as alert-box.
