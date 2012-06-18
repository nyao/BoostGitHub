package nyao.util

import com.google.gwt.query.client.Function
import com.google.gwt.user.client.Event
import com.google.gwt.dom.client.Element

class XtendFunction extends Function {
    
    def static Function clickEvent((Event)=>boolean f) {
        val x = new XtendFunction()
        x.f(f)
        return x
    }
    
    def static Function event((Element) => void f) {
        val x = new XtendFunction()
        x.f(f)
        return x
    }
    
    (Event)=>boolean clickEvent = []
    (Element) => void simpleF
    
    def void f((Event)=>boolean f) {
        this.clickEvent = f
    }
    
    def void f((Element)=>void f) {
        this.simpleF = f
    }
    
    override f(Event result) {
        this.clickEvent.apply(result)
    }
    
    override f(Element result) {
        this.simpleF.apply(result)
    }
}
