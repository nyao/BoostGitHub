package nyao.client.model;

import com.google.gwt.core.client.JavaScriptObject;
import com.google.gwt.core.client.JsArray;
import com.google.gwt.core.client.JsArrayInteger;

public class Orders extends JavaScriptObject {
    protected Orders() {
    }
    public final native JsArray<Order> getOrders() /*-{ return this.orders; }-*/;
    
    public static class Order extends JavaScriptObject {
        protected Order() {
        }
        public final native int getMilestone() /*-{ return this.milestone; }-*/;
        public final native JsArrayInteger getIssues() /*-{ return this.issues; }-*/;
    }
}
