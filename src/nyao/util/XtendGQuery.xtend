package nyao.util

import com.google.gwt.query.client.GQuery
import com.google.gwt.core.client.JsArray
import com.google.gwt.core.client.JavaScriptObject

class XtendGQuery {
    
    def static getValue(GQuery gq) {
        gq.vals.get(0)
    }
    
    def static each(JsArray<? extends JavaScriptObject> items, (JavaScriptObject) => void f) {
        var i = 0
        while (i < items.length) {
            val r = items.get(i)
            f.apply(r)
            i = i + 1
        }
    }
}
