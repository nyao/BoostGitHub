package nyao.util;

import com.google.gwt.query.client.GQuery;

public final class ConversionJavaToXtend {

    public static <T extends GQuery> T gqAs(GQuery src, Class<T> plugin) {
        return src.as(plugin);
    }
    
    public static String gqVal(GQuery src) {
        return src.val();
    }
}
