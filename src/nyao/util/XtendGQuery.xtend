package nyao.util

import com.google.gwt.query.client.GQuery
import com.google.gwt.core.client.JsArray
import com.google.gwt.core.client.JavaScriptObject
import java.util.List
import java.util.ArrayList

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
    
    def static <T> List<T> map(JsArray<? extends JavaScriptObject> items, (JavaScriptObject) => T f) {
        val result = new ArrayList<T>()
        var i = 0
        while (i < items.length) {
            val r = items.get(i)
            result.add(f.apply(r))
            i = i + 1
        }
        result
    }
}
