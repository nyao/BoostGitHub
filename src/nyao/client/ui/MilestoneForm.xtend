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
    val List<IssueUI> iUIs
    val Repo repo
    val form = $("#milestone-form")
    
    new(GitHubApi api, Repo r, JsArray<Milestone> ms, List<IssueUI> iUIs) {
        this.api = api
        this.repo = r
        this.iUIs = iUIs
        
        $("#milestones-button .dropdown-menu .item").remove
        $("#milestones-button .dropdown-menu").append(ms, [m| listItem(m)])
        $("#milestones-button [name='new']").unbind("click")
        $("#milestones-button [name='new']").click(clickItem(null))
        form.find("[name='submit']").unbind("click")
        form.find("[name='submit']").click(submit)
        form.find("[name='cancel']").unbind("click")
        form.find("[name='cancel']").click(clickEvent[form.fadeOut(1000);true])
    }
    
    def listItem(Milestone m) {
        $("<li>").append($("<a>")
                 .addClass("item")
                 .text(m.title)
                 .attr("name", m.number)
                 .attr("href", "#")
                 .click(clickItem(m)))
    }
    
    def clickItem(Milestone m) {
        clickEvent[
            form.find("[name='title']").gqVal(m?.title)
            form.find("[name='description']").gqVal(m?.description)
            form.attr("target", m?.number)
            form.fadeIn(1000)
            true;
        ]
    }
    
    def submit() {
        clickEvent[ev|
            val prop = new MilestoneForSave => [
                setTitle(form.find("[name='title']").gqVal)
                setDescription(form.find("[name='description']").gqVal)
            ]
            val targetNumber = if (form.attr("target").equals("0")) {null} else form.attr("target")
            api.saveMilestone(repo, targetNumber, prop, callback[m|
                if ($("#Issues .milestones ." + m.cssClass).isEmpty) {
                    $("#Issues .milestones").append(new MilestoneUI(m).elm)
                } else {
                    $("#Issues .milestones ." + m.cssClass + " h2").text(m.title)
                }
                iUIs.forEach([iUI|iUI.addMilestone(m)])
                form.fadeOut(1000)
            ])
            true
        ]
    }
}