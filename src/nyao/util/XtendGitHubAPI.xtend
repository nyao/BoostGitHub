package nyao.util

import static com.google.gwt.query.client.GQuery.*

import com.google.gwt.query.client.GQuery
import com.github.nyao.gwtgithub.client.models.Issue

class XtendGitHubAPI {
    
    def static GQuery elm(Issue issue) {
        $("#issue-" + issue.number)
    }
}
