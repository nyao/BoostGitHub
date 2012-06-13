package nyao.client.ui

import com.github.nyao.gwtgithub.client.GitHubApi
import com.github.nyao.gwtgithub.client.models.Label
import com.github.nyao.gwtgithub.client.models.Repo
import com.github.nyao.gwtgithub.client.values.LabelForSave
import com.google.gwt.core.client.JsArray
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
    val form = $("#label-form")
    
    new(GitHubApi api, Repo r, JsArray<Label> ls, List<IssueUI> iUIs) {
        this.api = api
        this.repo = r
        this.iUIs = iUIs
        
        $("#labels-button .dropdown-menu").append(ls, [l| listItem(l)])
        $("#labels-button [name='new']").click(clickItem(null))
        form.find("[name='submit']").click(submit)
        form.find("[name='cancel']").click(clickEvent[form.fadeOut(1000);true])
    }
    
    def listItem(Label l) {
        $("<li>").append($("<a>")
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
            val prop = new LabelForSave => [
                setName(form.find("[name='name']").gqVal)
                setColor(form.find("[name='color']").gqVal)
            ]
            val targetNumber = if (form.attr("target").nullOrEmpty) {null} else form.attr("target")
            api.saveLabel(repo, targetNumber, prop, callback[l|
                iUIs.forEach([issueUI|issueUI.addLabel(l)])
                form.fadeOut(1000)
            ])
            true
        ]
    }
}