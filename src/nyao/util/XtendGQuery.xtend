package nyao.util

import com.google.gwt.core.client.JsArray
import com.google.gwt.core.client.JavaScriptObject
import java.util.List
import java.util.ArrayList
import com.google.gwt.query.client.GQuery

import static extension nyao.util.XtendGQuery.*
import static extension nyao.util.ConversionJavaToXtend.*

class XtendGQuery {
    
    def static <T extends JavaScriptObject> each(JsArray<T> items, (T) => void f) {
        var i = 0
        while (i < items.lengthOr0) {
            val r = items.get(i)
            f.apply(r)
            i = i + 1
        }
    }
    
    def static <T extends JavaScriptObject> List<T> toList(JsArray<T> items) {
        val result = new ArrayList<T>()
        items.each([result.add(it)])
        result
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
    
    def static <T extends JavaScriptObject> append(GQuery gq, Iterable<T> items, (T) => GQuery f) {
        items.forEach([gq.append(f.apply(it))])
        gq
    }
    
    def static append(GQuery gq, Iterable<GQuery> items) {
        items.forEach([gq.append(it)])
        gq
    }
    
    def static appendIf(GQuery gq, GQuery item, () => boolean cond) {
        if (cond.apply) {
            gq.append(item)
        }
        gq
    }
    
    def static <T extends JavaScriptObject> List<T> filter(JsArray<T> items, (T) => Boolean f) {
        val result = new ArrayList<T>()
        items.each([
            if (f.apply(it)) {
                result.add(it)
            }
        ])
        result
    }
    
    def static <T extends JavaScriptObject> boolean exists(JsArray<T> items, (T) => Boolean f) {
        find(items, f) != null
    }
    
    def static <T extends JavaScriptObject> T find(JsArray<T> items, (T) => Boolean f) {
        var i = 0
        while (i < items.lengthOr0) {
            val r = items.get(i)
            if (f.apply(r)) return r;
            i = i + 1
        }
        null as T
    }
}
