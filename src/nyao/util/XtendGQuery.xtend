package nyao.util

import com.google.gwt.core.client.JsArray
import com.google.gwt.core.client.JavaScriptObject
import java.util.List
import java.util.ArrayList
import com.google.gwt.query.client.GQuery

import static extension nyao.util.XtendGQuery.*

class XtendGQuery {
    
    def static <T extends JavaScriptObject> each(JsArray<T> items, (T) => void f) {
        var i = 0
        while (i < items.length) {
            val r = items.get(i)
            f.apply(r)
            i = i + 1
        }
    }
    
    def static <T, K extends JavaScriptObject> List<T> map(JsArray<K> items, (K) => T f) {
        val result = new ArrayList<T>()
        items.each([result.add(f.apply(it))])
        result
    }
    
    def static <T extends JavaScriptObject> append(GQuery gq, JsArray<T> items, (T) => GQuery f) {
        items.each([gq.append(f.apply(it))])
        gq
    }
}
