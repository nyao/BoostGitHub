package nyao.client.ui

import com.github.nyao.gwtgithub.client.models.Milestone
import com.github.nyao.gwtgithub.client.models.Repo
import java.util.List
import com.github.nyao.gwtgithub.client.values.MilestoneForSave
import com.github.nyao.gwtgithub.client.GitHubApi
import com.google.gwt.core.client.JsArray

import static com.google.gwt.query.client.GQuery.*
import static nyao.util.SimpleAsyncCallback.*
import static nyao.util.XtendFunction.*

import static extension nyao.util.ConversionJavaToXtend.*
import static extension nyao.util.XtendGQuery.*
import static extension nyao.util.XtendGitHubAPI.*

class MilestoneForm {
    val GitHubApi api
    val List<IssueUI> issueList
    val Repo repo
    
    new(GitHubApi api, Repo r, JsArray<Milestone> mss, List<IssueUI> issueList) {
        this.api = api
        this.repo = r
        this.issueList = issueList
        
        $("#milestones-button .dropdown-menu").append(mss, [ms| listItem(ms)])
        val form = $("#milestone-form")
        $("#milestones-button [name='new']").click(clickItem(null))
        form.find("[name='submit']").click(submit)
        form.find("[name='cancel']").click(clickEvent[form.fadeOut(1000);true])
    }
    
    def listItem(Milestone ms) {
        $("<li>").append($("<a>")
                 .text(ms.title)
                 .attr("name", ms.number)
                 .attr("href", "#")
                 .click(clickItem(ms)))
    }
    
    def clickItem(Milestone m) {
        clickEvent[
            val form = $("#milestone-form")
            form.find("[name='title']").gqVal(m?.title)
            form.find("[name='description']").gqVal(m?.description)
            form.attr("target", m?.number)
            form.fadeIn(1000)
            true;
        ]
    }
    
    def submit() {
        val form = $("#milestone-form")
        clickEvent[ev|
            val prop = new MilestoneForSave => [
                setTitle(form.find("[name='title']").gqVal)
                setDescription(form.find("[name='description']").gqVal)
            ]
            val targetNumber = if (form.attr("target").equals("0")) {null} else form.attr("target")
            api.saveMilestone(repo, targetNumber, prop, callback[ms|
                if ($("#Issues .milestones ." + ms.cssClass).isEmpty) {
                    $("#Issues .milestones").append(new MilestoneUI(ms).elm)
                } else {
                    $("#Issues .milestones ." + ms.cssClass + " h2").text(ms.title)
                }
                issueList.forEach([issueUI|issueUI.addMilestone(ms)])
                form.fadeOut(1000)
            ])
            true
        ]
    }
}