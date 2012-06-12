package nyao.client.ui

import com.google.gwt.query.client.GQuery
import com.github.nyao.gwtgithub.client.models.Milestone

import static com.google.gwt.query.client.GQuery.*
import static nyao.util.SimpleAsyncCallback.*
import static nyao.util.XtendFunction.*

import static extension nyao.util.ConversionJavaToXtend.*
import static extension nyao.util.XtendGQuery.*
import static extension nyao.util.XtendGitHubAPI.*

class MilestoneUI {
    val Milestone milestone
    @Property GQuery elm
    
    new(Milestone m) {
        this.milestone = m
        
        elm =
        $("<div>").addClass(m.cssClass)
            .append($("<h2>").text(m.title))
            .append($("<table>").addClass("table table-bordered table-striped")
                .append($("<tbody>")))
    }
}
