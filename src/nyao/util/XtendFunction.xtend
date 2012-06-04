package nyao.util

import com.google.gwt.query.client.Function
import com.google.gwt.user.client.Event

class XtendFunction extends Function {
    
    def static Function clickEvent((Event)=>boolean onSuccess) {
        val x = new XtendFunction()
        x.f(onSuccess)
        return x
    }
    
    (Event)=>boolean f = []
    
    def void f((Event)=>boolean onSuccess) {
        this.f = onSuccess
    }
    
    override f(Event result) {
        this.f.apply(result)
    }
}
