package nyao.client.ui

import com.github.nyao.gwtgithub.client.GitHubApi
import com.github.nyao.gwtgithub.client.api.Labels
import com.github.nyao.gwtgithub.client.api.Milestones
import com.github.nyao.gwtgithub.client.models.Repo
import com.github.nyao.gwtgithub.client.values.IssueValue
import java.util.List

import static com.google.gwt.query.client.GQuery.*
import static nyao.util.SimpleAsyncCallback.*
import static nyao.util.XtendFunction.*

import static extension nyao.util.ConversionJavaToXtend.*
import static extension nyao.util.XtendGQuery.*

class NewIssueForm {
    val GitHubApi api
    val List<IssueUI> iUIs
    val Labels ls
    val Milestones ms
    val Repo repo
    val form = $("#new-issue-form")
    
    new(GitHubApi api, Repo r, Labels ls, Milestones ms, List<IssueUI> iUIs) {
        this.api = api
        this.repo = r
        this.iUIs = iUIs
        this.ls = ls
        this.ms = ms
        
        $("#new-issue-button").unbind("click")
        $("#new-issue-button").click(clickEvent[
            form.find("[name='title']").gqVal("")
            form.find("[name='body']").gqVal("")
            form.fadeIn(1000)
            true
        ])
        
        form.find("[name='submit']").unbind("click")
        form.find("[name='submit']").click(submit)
        
        form.find("[name='cancel']").unbind("click")
        form.find("[name='cancel']").click(clickEvent[form.fadeOut(1000);true])
    }
    
    def submit() {
        clickEvent[
            val prop = new IssueValue => [
                setTitle(form.find("[name='title']").gqVal)
                setBody(form.find("[name='body']").gqVal)
            ]
            api.createIssue(repo, prop, callback[i|
                form.fadeOut(1000)
                val iUI = new IssueUI(i, repo, ls.data.toList, ms.data.toList, api)
                iUIs.add(iUI)
                $("#Issues .Backlog tbody").append(iUI.elm)
                ("#Issues .Backlog table").calltableDnDUpdate // drag and drop
            ])
            true
        ]
    }
}
