package nyao.client

import com.github.nyao.gwtgithub.client.GitHubApi
import com.github.nyao.gwtgithub.client.api.Users
import com.github.nyao.gwtgithub.client.models.GHUser
import com.github.nyao.gwtgithub.client.models.Issue
import com.github.nyao.gwtgithub.client.models.Repository
import com.google.gwt.core.client.EntryPoint
import com.google.gwt.core.client.JsArray
import com.google.gwt.query.client.GQuery

import static com.google.gwt.query.client.GQuery.*
import static nyao.util.SimpleAsyncCallback.*
import static nyao.util.XtendFunction.*

import static extension nyao.util.ConversionJavaToXtend.*
import static extension nyao.util.XtendGQuery.*
import com.github.nyao.gwtgithub.client.models.Milestone

class BoostGitHub implements EntryPoint {
    val api = new GitHubApi();
    
    override onModuleLoad() {
        $("#LoginSubmit").click(clickEvent[
            $("#Authorization").fadeOut(1000)
            val user = $("#Login").gqVal
            $(".username").text(user)
            $("#Repositories").fadeIn(1000)
            api.getRepositories(user, callback[showRepositories(it.data, "Repos")])
            api.getOrganizations(user, callback[showOrgs(it)])
            true
        ])
        
        $("#TokenSubmit").click(clickEvent[
            $("#Authorization").fadeOut(1000)
            $("#Repositories").fadeIn(1000)
            api.setAuthorization($("#Token").gqVal)
            api.getUser(callback[$(".username").text(it.login)])
            api.getMyRepository(callback[showRepositories(it.data, "Repos")])
            api.getOrganizations(callback[showOrgs(it)])
            true
        ])
        
        $("#Repositories").hide
        $("#Issues").hide
        $("#Authorization .close").click(clickEvent[$("#Authorization").fadeOut(1000);true])
        $("#User").click(clickEvent[$("#Authorization").fadeIn(1000);true])
    }
    
    def showOrgs(Users orgs) {
        $("#Repositories .Orgs table").remove
        orgs.data.each[org|
            api.getRepositories(org.login, callback[showOrgRepositories(org, it.data)])
        ]
    }
    
    def showOrgRepositories(GHUser org, JsArray<Repository> rs) {
        $("#Repositories .Orgs")
            .append($("<table>").addClass("table table-bordered table-striped " + org.login)
                .append($("<thead>")
                    .append($("<tr>")
                        .append($("<th>").text(org.login))))
                .append($("<tbody>")))
        showRepositories(rs, org.login)
    }
    
    def showRepositories(JsArray<Repository> rs, String kind) {
        $(".nav ." + kind).remove
        $(".nav").append(aDropdownMenu(kind))
        
        $("#Repositories ." + kind + " tbody tr").remove
        rs.each([r|
            $(".nav ." + kind + " ul")
                .append($("<li>").append(aOpenIssues(r)))
            $("#Repositories ." + kind + " tbody")
                .append($("<tr>")
                    .append($("<td>").append(aOpenIssues(r))))
        ])
    }
    
    def aDropdownMenu(String kind) {
        $("<li>").addClass("dropdown " + kind)
            .append($("<a>").addClass("dropdown-toggle")
                            .attr("data-toggle", "dropdown")
                            .attr("href", "#")
                            .text(kind)
                            .append($("<b>").addClass("caret")))
            .append($("<ul>").addClass("dropdown-menu " + kind))
    }
    
    def aOpenIssues(Repository r) {
        $("<a>").text(r.name + "(" + String::valueOf(r.openIssues) + ")")
                .attr("href", "#")
                .click(clickEvent [
                    api.getIssues(r, callback[showIssues(r, it.data)])
                    true
                ])
    }
    
    def classForMilestone(Milestone m) {
        if (m == null || m.title.equals("Backlog")) "Backlog"
        else "milestone-" + m.number
    }
    
    def showIssues(Repository r, JsArray<Issue> issues) {
    	$(".nav .active").remove
        $("#Repositories").fadeOut(1000)
        $("#Issues tbody tr").remove
        $("#Issues .milestones").children.remove
        
        $("#Issues").fadeIn(1000)
        $(".nav")
            .append($("<li>").addClass("active")
                .append($("<a>").attr("href", "#").text(r.name)))
        
        issues.map([it.milestone]).filterNull.forEach([
            if ($("#Issues ." + classForMilestone(it)).isEmpty) {
                $("#Issues .milestones").append(aMilestone(it))
            }
        ])
        
        issues.each([i|
            val ms = classForMilestone(i.milestone)
            val aIssue = aIssue(i)
            val aDetail = aIssueDetail(i).hide
            aIssue.click(showIssueDetail(aDetail, i, r))
            $("#Issues ." + ms + " tbody").append(aIssue)
            $("#Issues ." + ms + " tbody").append(aDetail)
        ])
    }
    
    def showIssueDetail(GQuery detail, Issue i, Repository r) {
        clickEvent[
            if (!detail.isVisible) {
                api.getComment(r, i, callback[
                    val panel = detail.find(".comments")
                    panel.children.remove
                    it.data.each([
                        panel.append($("<div>").addClass("comment")
                             .append($("<img>").attr("src", it.user.avatarUrl)
                                               .attr("height", "48")
                                               .attr("width", "48"))
                             .append($("<pre>").text(it.body)))
                    ])
                ])
            }
            detail.fadeToggle(1000)
            true
        ]
    }
    
    def aIssue(Issue issue) {
        $("<tr>")
            .append($("<td>").addClass("span1")
                .append($("<a>").attr("href",   issue.htmlUrl)
                                .attr("target", "_blank")
                                .text("#" + String::valueOf(issue.number))))
            .append($("<td>").text(issue.title)
                .append($("<img>").attr("src", issue.user.avatarUrl)
                                  .attr("height", "18")
                                  .attr("width", "18")))
    }
    
    def aIssueDetail(Issue issue) {
        $("<tr>")
            .append($("<td colspan='2'>")
                .append($("<div>").addClass("detail")
                    .append($("<pre>").text(issue.body)))
                .append($("<div>").addClass("comments")
                                  .css("max-height", "250px")
                                  .css("overflow", "auto")))
    }
    
    def aMilestone(Milestone m) {
        $("<div>").addClass(classForMilestone(m))
            .append($("<h2>").text(m.title))
            .append($("<table>").addClass("table table-bordered table-striped")
                .append($("<tbody>")))
    }
}
