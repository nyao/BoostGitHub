package nyao.client.ui

import com.github.nyao.gwtgithub.client.models.Issue
import com.google.gwt.query.client.GQuery
import com.github.nyao.gwtgithub.client.models.Repository
import com.github.nyao.gwtgithub.client.GitHubApi
import com.github.nyao.gwtgithub.client.models.Comment
import com.github.nyao.gwtgithub.client.models.Label

import static com.google.gwt.query.client.GQuery.*
import static nyao.util.SimpleAsyncCallback.*
import static nyao.util.XtendFunction.*

import static extension nyao.util.ConversionJavaToXtend.*
import static extension nyao.util.XtendGQuery.*

class IssueUI {
    val Issue issue
    val Repository repository
    val GitHubApi api
    @Property GQuery elm
    
    new(Issue issue, Repository repository, GitHubApi api) {
        this.issue = issue
        this.repository = repository
        this.api = api
        
        elm = 
        $("<tr>").id("issue-" + issue.number)
            .append($("<td>").addClass("span1")
                .append($("<a>").attr("href",   issue.htmlUrl)
                                .attr("target", "_blank")
                                .text("#" + String::valueOf(issue.number))))
            .append($("<td>").addClass("issue-item")
                .append(makeAvatar)
                .append(makeTitle)
                .append(issue.labels, [makeLabel(it)])
                .append(makeDetail.hide))
            .append($("<td>").addClass("open-detail")
                             .css("align", "right")
                             .css("cursor", "pointer")
                             .click(showDetail)
                .append($("<i>").addClass("icon-chevron-down")))
    }
    
    def makeAvatar() {
        $("<img>").attr("src", issue.user.avatarUrl)
                  .attr("height", "18px")
                  .attr("width", "18px")
    }
    
    def makeTitle() {
        $("<span>").text(issue.title)
                   .css("padding", "5px")
    }
    
    def makeLabel(Label l) {
        $("<span>").addClass("label")
                   .css("background-color", "#" + l.color)
                   .text(l.name)
    }
    
    def makeDetail() {
        $("<tr>").addClass("detail")
            .append($("<td colspan='2'>")
                .append($("<div>")
                    .append($("<pre>").text(issue.body)))
                .append($("<div>").addClass("comments")
                                  .css("max-height", "250px")
                                  .css("overflow", "auto")))
    }
    
    def showDetail() {
        clickEvent[
            val dt = $(it.eventTarget)
            val detail = elm.find(".detail")
            if (!detail.isVisible) {
                api.getComments(repository, issue, callback[
                    val panel = detail.find(".comments")
                    panel.children.remove
                    panel.append(it.data, [makeComment(it)])
                    panel.append(makeCommentAdd)
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
            api.createComment(repository, issue, cadd.find("textarea").gqVal, callback([
                makeComment(it).insertBefore(cadd)
                cadd.find("textarea").gqVal("")
            ]))
            false
        ]
    }
}