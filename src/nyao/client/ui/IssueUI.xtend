package nyao.client.ui

import com.github.nyao.gwtgithub.client.GitHubApi
import com.github.nyao.gwtgithub.client.models.issues.Issue
import com.github.nyao.gwtgithub.client.models.issues.Label
import com.github.nyao.gwtgithub.client.models.issues.Milestone
import com.github.nyao.gwtgithub.client.values.issues.IssueValue
import com.github.nyao.gwtgithub.client.values.issues.IssueCommentValue
import com.google.gwt.query.client.GQuery
import java.util.ArrayList
import org.eclipse.xtend.lib.Property
import com.github.nyao.gwtgithub.client.models.Repo
import java.util.List
import com.github.nyao.gwtgithub.client.models.issues.IssueComment

import static com.google.gwt.query.client.GQuery.*
import static nyao.util.SimpleAsyncCallback.*
import static nyao.util.XtendFunction.*

import static extension nyao.util.ConversionJavaToXtend.*
import static extension nyao.util.XtendGQuery.*
import static extension nyao.util.XtendGitHubAPI.*

class IssueUI {
    @Property Issue issue
    val Repo repo
    val List<Label> ls
    val List<Milestone> ms
    val GitHubApi api
    @Property GQuery elm
    
    new(Issue issue, Repo repo,List<Label> ls, List<Milestone> ms, GitHubApi api) {
        this.issue = issue
        this.repo = repo
        this.ls = ls
        this.ms = ms
        this.api = api
        
        makeIssueUI
    }
    
    def makeIssueUI() {
        if (elm != null) {
            elm.children.remove
        } else {
            elm = $("<tr>").id("issue-" + issue.number)
        }
        elm.append($("<td>").addClass("span1")
                .append($("<a>").attr("href",   issue.htmlUrl)
                                .attr("target", "_blank")
                                .text("#" + String::valueOf(issue.number))))
            .append($("<td>").addClass("issue-item")
                .append(makeAvatar)
                .append(makeTitle)
                .append(issue.labels, [makeLabel(it)])
                .appendIf(makeEditButton, [|api.authorized])
                .appendIf(makeEditForm.hide, [|api.authorized])
                .appendIf(makeReadyButton, [|api.authorized])
                .append(makeDetailPanel.hide))
            .append($("<td>").addClass("open-detail")
                             .css("align", "right")
                             .css("cursor", "pointer")
                             .css("width", "16px")
                             .css("padding", "8px 12px")
                             .click(clickDetail)
                .append($("<i>").addClass("icon-chevron-down")))
    }
    
    def makeAvatar() {
        $("<img>").attr("src", issue.user.avatarUrl)
                  .attr("height", "18px")
                  .attr("width", "18px")
    }
    
    def makeTitle() {
        $("<span>").addClass("title")
                   .text(issue.title)
                   .css("padding", "5px")
    }
    
    def makeLabel(Label l) {
        $("<span>").addClass("label")
                   .css("background-color", "#" + l.color)
                   .text(l.name)
    }
    
    def makeEditButton() {
        $("<span>").addClass("btn btn-mini editButton")
                   .text("Edit")
                   .click(clickEvent[elm.find(".edit").fadeIn(1000);true])
    }
    
    def makeReadyButton() {
        $("<span>").css("float", "right").addClass("btn-group ready")
            .append($("<a>").addClass("btn btn-mini dropdown-toggle")
                            .attr("data-toggle", "dropdown")
                            .attr("href", "#")
                            .text("ready"))
            .append($("<ul>").addClass("dropdown-menu")
                .append(appendReadyList))
    }
    
    def appendReadyList() {
        val result = new ArrayList<GQuery>
        ms.filter([issue.milestone?.number.compareTo(it.number) != 0]).forEach([ms|
                     result.add(
                     $("<li>")
                         .append($("<a>").attr("href", "#").text(ms.title)
                         .click(clickReady(ms.number, ms.cssClass))
                     ))
                 ])
        if (issue.milestone != null) {
            result.add(($("<li>")
                .append($("<a>").attr("href", "#")
                                .attr("name", "Backlog")
                                .text("Backlog")
                                .click(clickReady(null, "Backlog")))))
        }
        result
    }
    
    def resetReady(String cssClass) {
        elm.find(".dropdown-menu").children.remove
        elm.find(".dropdown-menu").append(appendReadyList)
        ("#Issues ." + cssClass + " table").calltableDnDUpdate // drag and drop
    }
    
    def addMilestone(Milestone oldm, Milestone newm) {
        this.ms.remove(oldm)
        this.ms.add(newm)
        makeIssueUI
    }
    
    def addLabel(Label oldl, Label newl) {
        this.ls.remove(oldl)
        this.ls.add(newl)
        makeIssueUI
    }
    
    def clickReady(Integer number, String cssClass) {
        clickEvent[
            val prop = new IssueValue => [setMilestone(number)]
            api.editIssue(repo, issue, prop, callback[
                issue = it
                $("#Issues ." + cssClass + " tbody").append(elm)
                resetReady(cssClass)
            ])
            true
        ]
    }
    
    def makeEditForm() {
        new EditIssueForm(api, repo, issue, ls, this).elm
    }
    
    def makeDetailPanel() {
        $("<tr>").addClass("detail")
            .append($("<td colspan='2'>")
                .append($("<div>")
                    .append($("<pre>")))
                .append($("<div>").addClass("comments")
                                  .css("max-height", "250px")
                                  .css("overflow", "auto")))
    }
    
    def clickDetail() {
        clickEvent[
            val dt = $(it.eventTarget)
            val detail = elm.find(".detail")
            if (!detail.isVisible) {
                detail.find("pre").text(issue.body)
                api.getIssueComments(repo, issue, callback[
                    val panel = detail.find(".comments")
                    panel.children.remove
                    panel.append(it.data, [makeComment(it)])
                    panel.appendIf(makeCommentAdd, [|api.authorized])
                ])
                dt.find("i")
                  .removeClass("icon-chevron-down")
                  .addClass("icon-chevron-up")
            } else {
                dt.find("i")
                  .removeClass("icon-chevron-up")
                  .addClass("icon-chevron-down")
            }
            detail.fadeToggle(1000)
            true
        ]
    }
    
    def makeComment(IssueComment c) {
        $("<div>").addClass("comment")
            .append($("<img>").attr("src", c.user.avatarUrl)
                              .attr("height", "48px")
                              .attr("width", "48px"))
            .append($("<pre>").text(c.body))
    }
    
    def makeCommentAdd() {
        $("<div>").addClass("add-comment")
            .append($("<textarea>").addClass("input-xlarge")
                                   .attr("rows", "4")
                                   .click(clickEvent[false]))
            .append($("<a>").addClass("btn submit")
                            .text("add comment")
                            .click(postComment))
    }
    
    def postComment() {
        clickEvent[
            val cadd = $(it.eventTarget).parent
            val prop = new IssueCommentValue => [setBody(cadd.find("textarea").gqVal)]
            api.createIssueComment(repo, issue, prop, callback([
                makeComment(it).insertBefore(cadd)
                cadd.find("textarea").gqVal("")
            ]))
            false
        ]
    }
}
