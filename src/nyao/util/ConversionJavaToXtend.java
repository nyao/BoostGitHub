package nyao.util;

import java.util.List;

import static com.google.gwt.query.client.GQuery.*;

import com.github.nyao.gwtgithub.client.GitHubApi;
import com.github.nyao.gwtgithub.client.models.AJSON;
import com.github.nyao.gwtgithub.client.models.Repo;
import com.github.nyao.gwtgithub.client.models.gitdata.Reference;
import com.google.gwt.core.client.JsArray;
import com.google.gwt.query.client.Function;
import com.google.gwt.query.client.GQuery;
import com.google.gwt.user.client.Element;

public final class ConversionJavaToXtend {

    public static <T extends GQuery> T gqAs(GQuery src, Class<T> plugin) {
        return src.as(plugin);
    }
    
    public static String gqVal(GQuery src) {
        return src.val();
    }

    public static GQuery gqVal(GQuery src, String name) {
        return src.val(name);
    }
    
    public native static void callTableDnD(String src, GitHubApi api, Repo repo, Reference ref) /*-{
        $wnd.jQuery(src).tableDnD({
            onDrop: function(table, row) {
                @nyao.client.BoostGitHub::setTimer(Lcom/github/nyao/gwtgithub/client/GitHubApi;Lcom/github/nyao/gwtgithub/client/models/Repo;Lcom/github/nyao/gwtgithub/client/models/gitdata/Reference;)(api, repo, ref);
            }
        });
    }-*/;
    
    public native static void calltableDnDUpdate(String src, GitHubApi api, Repo repo, Reference ref) /*-{
        $wnd.jQuery(src).tableDnDUpdate({
            onDrop: function(table, row) {
                @nyao.client.BoostGitHub::setTimer(Lcom/github/nyao/gwtgithub/client/GitHubApi;Lcom/github/nyao/gwtgithub/client/models/Repo;Lcom/github/nyao/gwtgithub/client/models/gitdata/Reference;)(api, repo, ref);
            }
        });
    }-*/;

    public static List<String> mapByAttr(GQuery gq, final String key) {
        List<String> result = gq.map(new Function() {
            @Override
            public Object f(Element e, int i) {
                return $(e).attr(key);
            }
        });
        return result;
    }

    public static String[] mapByAttrToString(GQuery gq, final String key) {
        return mapByAttr(gq, key).toArray(new String[0]);
    }
    
    public static final native int lengthOr0(JsArray<?> items) /*-{
      if (items.length == null) {
          return 0;
      } else {
          return items.length;
      }
    }-*/;
}
