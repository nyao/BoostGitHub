package nyao.client.ui

import com.github.nyao.gwtgithub.client.GitHubApi
import com.github.nyao.gwtgithub.client.models.issues.Issue
import com.github.nyao.gwtgithub.client.models.issues.Label
import com.github.nyao.gwtgithub.client.models.repos.Repo
import com.github.nyao.gwtgithub.client.values.issues.IssueValue
import com.google.gwt.query.client.GQuery
import java.util.List
import org.eclipse.xtend.lib.Property

import static com.google.gwt.query.client.GQuery.*
import static nyao.util.SimpleAsyncCallback.*
import static nyao.util.XtendFunction.*

import static extension nyao.util.ConversionJavaToXtend.*
import static extension nyao.util.XtendGQuery.*

class EditIssueForm {
    val GitHubApi api
    val List<Label> ls
    val Repo repo
    val Issue issue
    val IssueUI issueUI
    @Property GQuery elm
    
    new(GitHubApi api, Repo r, Issue issue, List<Label> ls, IssueUI issueUI) {
        this.api = api
        this.repo = r
        this.issue = issue
        this.ls = ls
        this.issueUI = issueUI
        
        elm = 
        $("<table>").addClass("edit")
            .append($("<tr>")
                .append($("<td>")
                    .append($("<input>").addClass("span5 edit-title")
                                        .attr("type", "text")
                                        .attr("placeholder", "Title")
                                        .gqVal(issue.title)
                    ))
            )
            .append($("<tr>")
                .append($("<td>")
                    .append($("<textarea>").addClass("span5 edit-body")
                                           .attr("rows", "3")
                                           .attr("placeholder", "Body")
                                           .gqVal(issue.body)
                    ))
            )
            .append($("<tr>")
                .append($("<td>")
                    .append(this.ls, [l|
                        val exist = issue.labels.exists([l.name == it.name])
                        val opacity = if (exist) "1" else "0.25"
                        val cssClass = if (exist) "label-selected" else ""
                        $("<span>").addClass("btn label " + cssClass)
                                   .css("background-color", "#" + l.color)
                                   .css("background-image", "none")
                                   .css("opacity", opacity)
                                   .attr("name", "" + l.name)
                                   .text(l.name)
                                   .click(clickEvent[
                                       val target = $(it.eventTarget)
                                       if (target.hasClass("label-selected")) {
                                           target.css("opacity", "0.25")
                                                 .removeClass("label-selected")
                                       } else {
                                           target.css("opacity", "1")
                                                 .addClass("label-selected")
                                       }
                                       true
                                   ])
                    ])
                )
            )
            .append($("<tr>")
                .append($("<td>")
                    .append($("<button>").addClass("btn btn-primary").text("submit")
                        .click(submitEdit)
                    )
                    .append($("<button>").addClass("btn").text("cancel")
                        .click(clickEvent[elm.fadeOut(1000);true])
                    )
                )
            )
    }
    
    def submitEdit() {
        clickEvent[
            val prop = new IssueValue => [
                setTitle(elm.find(".edit-title").gqVal)
                setBody(elm.find(".edit-body").gqVal)
                setLabels(elm.find(".label-selected").mapByAttrToString("name"))
            ]
            api.editIssue(repo, issue, prop, callback[
                elm.fadeOut(1000)
                issueUI.issue = it
                issueUI.makeIssueUI
            ])
            true
        ]
    }
    
}
