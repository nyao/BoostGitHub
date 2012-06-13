package nyao.client.ui

import com.github.nyao.gwtgithub.client.GitHubApi
import com.github.nyao.gwtgithub.client.models.Comment
import com.github.nyao.gwtgithub.client.models.Issue
import com.github.nyao.gwtgithub.client.models.Label
import com.github.nyao.gwtgithub.client.models.Milestone
import com.github.nyao.gwtgithub.client.values.IssueForSave
import com.google.gwt.query.client.GQuery
import java.util.ArrayList
import org.eclipse.xtend.lib.Property
import com.github.nyao.gwtgithub.client.values.CommentForSave
import com.github.nyao.gwtgithub.client.models.Repo
import java.util.List

import static com.google.gwt.query.client.GQuery.*
import static nyao.util.SimpleAsyncCallback.*
import static nyao.util.XtendFunction.*

import static extension nyao.util.ConversionJavaToXtend.*
import static extension nyao.util.XtendGQuery.*
import static extension nyao.util.XtendGitHubAPI.*

class IssueUI {
    var Issue issue
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
        ms.filter([issue.milestone?.number != it.number]).forEach([ms|
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
    
    def addMilestone(Milestone ms) {
        this.ms.add(ms)
        resetReady(ms.cssClass)
    }
    
    def addLabel(Label l) {
        this.ls.add(l)
    }
    
    def clickReady(Integer number, String cssClass) {
        clickEvent[
            val prop = new IssueForSave => [setMilestone(number)]
            api.editIssue(repo, issue, prop, callback[
                issue = it
                $("#Issues ." + cssClass + " tbody").append(elm)
                resetReady(cssClass)
            ])
            true
        ]
    }
    
    def makeEditForm() {
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
                        .click(clickEvent[elm.find(".edit").fadeOut(1000);true])
                    )
                )
            )
    }
    
    def submitEdit() {
        clickEvent[
            val prop = new IssueForSave => [
                setTitle(elm.find(".edit-title").gqVal)
                setBody(elm.find(".edit-body").gqVal)
                setLabels(elm.find(".label-selected").mapByAttr("name"))
            ]
            api.editIssue(repo, issue, prop, callback[
                elm.find(".edit").fadeOut(1000)
                elm.find(".title").text(it.title)
                issue = it
                makeIssueUI
            ])
            true
        ]
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
                api.getComments(repo, issue, callback[
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
    
    def makeComment(Comment c) {
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
            val prop = new CommentForSave => [setBody(cadd.find("textarea").gqVal)]
            api.createComment(repo, issue, prop, callback([
                makeComment(it).insertBefore(cadd)
                cadd.find("textarea").gqVal("")
            ]))
            false
        ]
    }
}
