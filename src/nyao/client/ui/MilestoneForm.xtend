package nyao.client.ui

import static com.google.gwt.query.client.GQuery.*
import static nyao.util.SimpleAsyncCallback.*
import static nyao.util.XtendFunction.*

import static extension nyao.util.ConversionJavaToXtend.*
import static extension nyao.util.XtendGQuery.*
import static extension nyao.util.XtendGitHubAPI.*

import com.github.nyao.gwtgithub.client.models.Milestone
import com.github.nyao.gwtgithub.client.models.Repo
import java.util.List
import com.github.nyao.gwtgithub.client.values.MilestoneForSave
import com.github.nyao.gwtgithub.client.GitHubApi
import com.google.gwt.core.client.JsArray

class MilestoneForm {
    val GitHubApi api
    
    new(GitHubApi api, Repo r, JsArray<Milestone> mss, List<IssueUI> issueList) {
        this.api = api
        
        $("#milestones-button .dropdown-menu").append(mss, [ms| milestoneListItem(ms, r, issueList)])
        val form = $("#milestone-form")
        $("#milestones-button [name='new']").click(milestoneClick(null, r, issueList))
        form.find("[name='submit']").click(submitMilestone(r, issueList))
        form.find("[name='cancel']").click(clickEvent[form.fadeOut(1000);true])
    }
    
    def milestoneListItem(Milestone ms, Repo r, List<IssueUI> issueList) {
        $("<li>").append($("<a>")
                             .text(ms.title)
                             .attr("name", ms.number)
                             .attr("href", "#")
                             .click(milestoneClick(ms, r, issueList)))
    }
    
    def milestoneClick(Milestone m, Repo r, List<IssueUI> issueList) {
        clickEvent[
            val form = $("#milestone-form")
            form.find("[name='title']").gqVal(m?.title)
            form.find("[name='description']").gqVal(m?.description)
            form.attr("target", m?.number)
            form.fadeIn(1000)
            true;
        ]
    }
    
    def submitMilestone(Repo r, List<IssueUI> issueList) {
        val form = $("#milestone-form")
        clickEvent[ev|
            val prop = new MilestoneForSave => [
                setTitle(form.find("[name='title']").gqVal)
                setDescription(form.find("[name='description']").gqVal)
            ]
            val targetNumber = if (form.attr("target").equals("0")) {null} else form.attr("target")
            api.saveMilestone(r, targetNumber, prop, callback[ms|
                if ($("#Issues .milestones ." + ms.cssClass).isEmpty) {
                    $("#Issues .milestones").append(aMilestone(ms))
                } else {
                    $("#Issues .milestones ." + ms.cssClass + " h2").text(ms.title)
                }
                issueList.forEach([issueUI|issueUI.addMilestone(ms)])
                form.fadeOut(1000)
            ])
            true
        ]
    }
    
    def aMilestone(Milestone m) {
        $("<div>").addClass(m.cssClass)
            .append($("<h2>").text(m.title))
            .append($("<table>").addClass("table table-bordered table-striped")
                .append($("<tbody>")))
    }
}