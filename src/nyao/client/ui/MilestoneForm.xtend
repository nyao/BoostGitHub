package nyao.client.ui

import com.github.nyao.gwtgithub.client.GitHubApi
import com.github.nyao.gwtgithub.client.models.issues.Milestone
import com.github.nyao.gwtgithub.client.models.repos.Repo
import com.github.nyao.gwtgithub.client.values.issues.MilestoneValue
import java.util.List

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
    val List<Milestone> ms
    
    new(GitHubApi api, Repo r, List<Milestone> ms, List<IssueUI> iUIs) {
        this.api = api
        this.repo = r
        this.iUIs = iUIs
        this.ms = ms
        
        buildList
        $("#milestones-button [name='new']").unbind("click")
        $("#milestones-button [name='new']").click(clickItem(null))
        form.find("[name='submit']").unbind("click")
        form.find("[name='submit']").click(submit)
        form.find("[name='cancel']").unbind("click")
        form.find("[name='cancel']").click(clickEvent[form.fadeOut(1000);true])
    }
    
    def buildList() {
        $("#milestones-button .dropdown-menu .item").remove
        $("#milestones-button .dropdown-menu").append(ms, [m| listItem(m)])
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
            val prop = new MilestoneValue => [
                setTitle(form.find("[name='title']").gqVal)
                setDescription(form.find("[name='description']").gqVal)
            ]
            val targetNumber = if (form.attr("target").equals("0")) {0} else Integer::valueOf(form.attr("target"))
            val um = ms.findFirst([it.number == targetNumber])
            api.saveMilestone(repo, um, prop, callback[m|
                if ($("#Issues .milestones ." + m.cssClass).isEmpty) {
                    $("#Issues .milestones").append(new MilestoneUI(m).elm)
                } else {
                    $("#Issues .milestones ." + m.cssClass + " h2").text(m.title)
                }
                ms.remove(um)
                ms.add(m)
                buildList
                iUIs.forEach([iUI|iUI.addMilestone(um, m)])
                form.fadeOut(1000)
            ])
            true
        ]
    }
}