package nyao.client.ui

import com.github.nyao.gwtgithub.client.GitHubApi
import com.github.nyao.gwtgithub.client.models.Label
import com.github.nyao.gwtgithub.client.models.Repo
import com.github.nyao.gwtgithub.client.values.LabelValue
import java.util.List

import static com.google.gwt.query.client.GQuery.*
import static nyao.util.SimpleAsyncCallback.*
import static nyao.util.XtendFunction.*

import static extension nyao.util.ConversionJavaToXtend.*
import static extension nyao.util.XtendGQuery.*

class LabelForm {
    val GitHubApi api
    val List<IssueUI> iUIs
    val Repo repo
    val List<Label> ls
    val form = $("#label-form")
    
    new(GitHubApi api, Repo r, List<Label> ls, List<IssueUI> iUIs) {
        this.api = api
        this.repo = r
        this.ls = ls
        this.iUIs = iUIs
        
        buildList
        $("#labels-button [name='new']").unbind("click")
        $("#labels-button [name='new']").click(clickItem(null))
        form.find("[name='submit']").unbind("click")
        form.find("[name='submit']").click(submit)
        form.find("[name='cancel']").unbind("click")
        form.find("[name='cancel']").click(clickEvent[form.fadeOut(1000);true])
    }
    
    def buildList() {
        $("#labels-button .dropdown-menu .item").remove
        $("#labels-button .dropdown-menu").append(ls, [l| listItem(l)])
    }
    
    def listItem(Label l) {
        $("<li>").append($("<a>")
                 .addClass("item")
                 .text(l.name)
                 .attr("name", l.name)
                 .attr("href", "#")
                 .click(clickItem(l)))
    }
    
    def clickItem(Label l) {
        clickEvent[
            form.find("[name='name']").gqVal(l?.name)
            form.find("[name='color']").gqVal(l?.color)
            form.attr("target", l?.name)
            form.fadeIn(1000)
            true;
        ]
    }
    
    def submit() {
        clickEvent[ev|
            val prop = new LabelValue => [
                setName(form.find("[name='name']").gqVal)
                setColor(form.find("[name='color']").gqVal)
            ]
            val targetName = if (form.attr("target").nullOrEmpty) {null} else form.attr("target")
            val ul = ls.findFirst([it.name == targetName])
            api.saveLabel(repo, ul, prop, callback[l|
                ls.remove(ul)
                ls.add(l)
                buildList
                iUIs.forEach([issueUI|issueUI.addLabel(ul, l)])
                form.fadeOut(1000)
            ])
            true
        ]
    }
}