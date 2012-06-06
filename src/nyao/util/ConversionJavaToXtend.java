package nyao.util;

import com.google.gwt.query.client.GQuery;

public final class ConversionJavaToXtend {

    public static <T extends GQuery> T gqAs(GQuery src, Class<T> plugin) {
        return src.as(plugin);
    }
    
    public static String gqVal(GQuery src) {
        return src.val();
    }

    public static void gqVal(GQuery src, String name) {
        src.val(name);
    }
    
    public native static void callTableDnD(String src) /*-{
        $wnd.jQuery(src).tableDnD();
    }-*/;
}
