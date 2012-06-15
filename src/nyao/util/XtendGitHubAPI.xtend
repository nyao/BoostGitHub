package nyao.util

import com.github.nyao.gwtgithub.client.models.issues.Milestone

class XtendGitHubAPI {
    def static cssClass(Milestone m) {
        if (m == null || m.title.equals("Backlog")) "Backlog"
        else "milestone-" + m.number
    }
}
