package nyao.client

import com.github.nyao.gwtgithub.client.GitHubApi
import com.github.nyao.gwtgithub.client.api.Users
import com.github.nyao.gwtgithub.client.models.GHUser
import com.github.nyao.gwtgithub.client.models.Issue
import com.github.nyao.gwtgithub.client.models.Repository
import com.google.gwt.core.client.EntryPoint
import com.google.gwt.core.client.JsArray
import com.github.nyao.gwtgithub.client.models.Milestone
import nyao.client.ui.IssueUI
import com.github.nyao.gwtgithub.client.values.IssueForSave
import com.github.nyao.gwtgithub.client.api.Milestones

import static com.google.gwt.query.client.GQuery.*
import static nyao.util.SimpleAsyncCallback.*
import static nyao.util.XtendFunction.*

import static extension nyao.util.ConversionJavaToXtend.*
import static extension nyao.util.XtendGQuery.*
import static extension nyao.util.XtendGitHubAPI.*

class BoostGitHub implements EntryPoint {
    val api = new GitHubApi();
    
    override onModuleLoad() {
        $("#LoginSubmit").click(clickEvent[
            $("#Auth").fadeOut(1000)
            val user = $("#Login").gqVal
            $(".navbar .username").text(user)
            $("#Repositories").fadeIn(1000)
            api.getRepos(user, callback[showRepositories(it.data, "Repos")])
            api.getOrgs(user, callback[showOrgs(it)])
            true
        ])
        
        $("#TokenSubmit").click(clickEvent[
            $("#Auth").fadeOut(1000)
            $("#Repositories").fadeIn(1000)
            api.setAccessToken($("#Token").gqVal)
            api.getUser(callback[$(".navbar .username").text(it.data.login)])
            api.getRepos(callback[showRepositories(it.data, "Repos")])
            api.getOrgs(callback[showOrgs(it)])
            true
        ])
        
        $("#Repositories").hide
        $("#Issues").hide
        $("#setting").hide
        $("#new-issue-form").hide
        $("#milestone-form").hide
        $("#label-form").hide
        $("#Auth .close").click(clickEvent[$("#Auth").fadeOut(1000);true])
        $("#User").click(clickEvent[$("#Auth").fadeIn(1000);true])
    }
    
    def showOrgs(Users orgs) {
        $("#Repositories .Orgs table").remove
        orgs.data.each[org|
            api.getRepos(org.login, 
                                callback[showOrgRepositories(org, it.data)])
        ]
    }
    
    def showOrgRepositories(GHUser org, JsArray<Repository> rs) {
        $("#Repositories .Orgs")
            .append($("<table>").addClass("table table-bordered table-striped " + org.login)
                .append($("<thead>")
                    .append($("<tr>")
                        .append($("<th>").text(org.login))
                        .append($("<th>").text("issues"))
                        .append($("<th>").text("wathers"))
                        .append($("<th>").text("forks"))
                        .append($("<th>").text("lang"))))
                .append($("<tbody>")))
        showRepositories(rs, org.login)
    }
    
    def showRepositories(JsArray<Repository> rs, String kind) {
        $(".navbar .nav ." + kind).remove
        $(".navbar .nav").append(aDropdownMenu(rs, kind))
        
        $("#Repositories ." + kind + " tbody tr").remove
        $("#Repositories ." + kind + " tbody")
            .append(rs, [$("<tr>")
                            .append($("<td>").text(it.name))
                                             .click(openIssueEvent(it))
                                             .css("cursor", "pointer")
                            .append($("<td>").text(it.openIssuesString))
                            .append($("<td>").text(it.watchersS))
                            .append($("<td>").text(it.forksS))
                            .append($("<td>").text(it.language))
            ])
    }
    
    def aDropdownMenu(JsArray<Repository> rs, String kind) {
        $("<li>").addClass("dropdown " + kind)
            .append($("<a>").addClass("dropdown-toggle")
                            .attr("data-toggle", "dropdown")
                            .attr("href", "#")
                            .text(kind)
                            .append($("<b>").addClass("caret")))
            .append($("<ul>").addClass("dropdown-menu " + kind)
                .append(rs, [$("<li>").append(aOpenIssues(it))]))
    }
    
    def aOpenIssues(Repository r) {
        $("<a>").text(r.name + "(" + r.openIssuesString + ")")
                .attr("href", "#")
                .click(openIssueEvent(r))
    }
    
    def openIssueEvent(Repository r) {
        clickEvent [
            $("#Repositories").fadeOut(1000)
            api.getIssues(r, callback[showIssues(r, it.data)])
            true
        ]
    }
    
    def activeRepositoryName(Repository r) {
        $("<li>").addClass("active")
                .append($("<a>").attr("href", "#").text(r.name))
    }
    
    def showIssues(Repository r, JsArray<Issue> issues) {
    	$(".navbar .nav .active").remove
        $(".navbar .nav").append(activeRepositoryName(r))
        
        $("#Issues Backlog tbody tr").remove
        $("#Issues .milestones tbody tr").remove
        $("#Issues .milestones").children.remove
        $("#Issues").fadeIn(1000)
        
        api.getMilestones(r, callback[mss|
            mss.data.each([ms|
                if ($("#Issues ." + ms.cssClass).isEmpty) {
                    $("#Issues .milestones").append(aMilestone(ms))
                }
            ])
            
            issues.each([i|
                $("#Issues ." + i.milestone.cssClass + " tbody")
                    .append(new IssueUI(i, r, mss.data, api).elm)
            ])
        
            "#Issues table".callTableDnD // drag and drop 
            
            $("#new-issue-button").click(newIssueClick(r, mss))
            $("#setting").fadeIn(1000)
            $("#milestones-button [name='new']").click(newMilestoneClick)
            $("#labels-button [name='new']").click(newLabelClick)
        ])
    }
    
    def aMilestone(Milestone m) {
        $("<div>").addClass(m.cssClass)
            .append($("<h2>").text(m.title))
            .append($("<table>").addClass("table table-bordered table-striped")
                .append($("<tbody>")))
    }
    
    def newIssueClick(Repository r, Milestones mss) {
        clickEvent[
            $("#new-issue-form").fadeIn(1000)
            $("#new-issue-form [name='submit']").click(clickEvent[
                    val prop = new IssueForSave => [
                        setTitle($("#new-issue-form [name='title']").gqVal)
                        setBody($("#new-issue-form [name='body']").gqVal)
                    ]
                    api.createIssue(r, prop, callback[
                        $("#new-issue-form").fadeOut(1000)
                        $("#Issues .Backlog tbody").append(new IssueUI(it, r, mss.data, api).elm)
                        ("#Issues .Backlog table").calltableDnDUpdate // drag and drop
                    ])
                    true
            ])
            $("#new-issue-form [name='cancel']").click(clickEvent[
                $("#new-issue-form").fadeOut(1000)
                true
            ])
            true
        ]
    }
    
    def newMilestoneClick() {
        clickEvent[
            $("#milestone-form").fadeIn(1000)
            $("#milestone-form [name='submit']").click(clickEvent[
                $("#milestone-form").fadeOut(1000)
                true
            ])
            $("#milestone-form [name='cancel']").click(clickEvent[
                $("#milestone-form").fadeOut(1000)
                true
            ])
            true;
        ]
    }
    
    def newLabelClick() {
        clickEvent[
            $("#label-form").fadeIn(1000)
            $("#label-form [name='cancel']").click(clickEvent[
                $("#label-form").fadeOut(1000)
                true
            ])
            true
        ]
    }
}
