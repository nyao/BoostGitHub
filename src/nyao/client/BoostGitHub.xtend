package nyao.client

import com.github.nyao.gwtgithub.client.GitHubApi
import com.github.nyao.gwtgithub.client.api.Users
import com.github.nyao.gwtgithub.client.models.GHUser
import com.github.nyao.gwtgithub.client.models.Issue
import com.google.gwt.core.client.EntryPoint
import com.google.gwt.core.client.JsArray
import com.github.nyao.gwtgithub.client.models.Milestone
import nyao.client.ui.IssueUI
import com.github.nyao.gwtgithub.client.values.IssueForSave
import com.github.nyao.gwtgithub.client.api.Milestones
import com.github.nyao.gwtgithub.client.models.Repo

import static com.google.gwt.query.client.GQuery.*
import static nyao.util.SimpleAsyncCallback.*
import static nyao.util.XtendFunction.*

import static extension nyao.util.ConversionJavaToXtend.*
import static extension nyao.util.XtendGQuery.*
import static extension nyao.util.XtendGitHubAPI.*
import com.github.nyao.gwtgithub.client.values.MilestoneForSave

class BoostGitHub implements EntryPoint {
    val api = new GitHubApi();
    
    override onModuleLoad() {
        $("#LoginSubmit").click(clickEvent[
            $("#Auth").fadeOut(1000)
            val user = $("#Login").gqVal
            $(".navbar .username").text(user)
            $("#Repos").fadeIn(1000)
            api.getRepos(user, callback[showRepos(it.getData, "Repos")])
            api.getOrgs(user, callback[showOrgs(it)])
            true
        ])
        
        $("#TokenSubmit").click(clickEvent[
            $("#Auth").fadeOut(1000)
            $("#Repos").fadeIn(1000)
            api.setAccessToken($("#Token").gqVal)
            api.getUser(callback[$(".navbar .username").text(it.data.login)])
            api.getRepos(callback[showRepos(it.getData, "Repos")])
            api.getOrgs(callback[showOrgs(it)])
            true
        ])
        
        $("#Repos").hide
        $("#Issues").hide
        $("#setting").hide
        $("#new-issue-form").hide
        $("#milestone-form").hide
        $("#label-form").hide
        $("#Auth .close").click(clickEvent[$("#Auth").fadeOut(1000);true])
        $("#User").click(clickEvent[$("#Auth").fadeIn(1000);true])
    }
    
    def showOrgs(Users orgs) {
        $("#Repos .Orgs table").remove
        orgs.data.each[org|
            api.getRepos(org.login, 
                                callback[showOrgRepos(org, it.getData)])
        ]
    }
    
    def showOrgRepos(GHUser org, JsArray<Repo> rs) {
        $("#Repos .Orgs")
            .append($("<table>").addClass("table table-bordered table-striped " + org.login)
                .append($("<thead>")
                    .append($("<tr>")
                        .append($("<th>").text(org.login))
                        .append($("<th>").text("issues"))
                        .append($("<th>").text("wathers"))
                        .append($("<th>").text("forks"))
                        .append($("<th>").text("lang"))))
                .append($("<tbody>")))
        showRepos(rs, org.login)
    }
    
    def showRepos(JsArray<Repo> rs, String kind) {
        $(".navbar .nav ." + kind).remove
        $(".navbar .nav").append(aDropdownMenu(rs, kind))
        
        $("#Repos ." + kind + " tbody tr").remove
        $("#Repos ." + kind + " tbody")
            .append(rs, [$("<tr>")
                            .append($("<td>").text(it.getName))
                                             .click(openIssueClick(it))
                                             .css("cursor", "pointer")
                            .append($("<td>").text(it.openIssuesString))
                            .append($("<td>").text(it.getWatchersS))
                            .append($("<td>").text(it.getForksS))
                            .append($("<td>").text(it.getLanguage))
            ])
    }
    
    def aDropdownMenu(JsArray<Repo> rs, String kind) {
        $("<li>").addClass("dropdown " + kind)
            .append($("<a>").addClass("dropdown-toggle")
                            .attr("data-toggle", "dropdown")
                            .attr("href", "#")
                            .text(kind)
                            .append($("<b>").addClass("caret")))
            .append($("<ul>").addClass("dropdown-menu " + kind)
                .append(rs, [$("<li>").append(aOpenIssues(it))]))
    }
    
    def aOpenIssues(Repo r) {
        $("<a>").text(r.getName + "(" + r.openIssuesString + ")")
                .attr("href", "#")
                .click(openIssueClick(r))
    }
    
    def openIssueClick(Repo r) {
        clickEvent [
            $("#Repos").fadeOut(1000)
            api.getIssues(r, callback[showIssues(r, it.data)])
            true
        ]
    }
    
    def activeRepositoryName(Repo r) {
        $("<li>").addClass("active")
                .append($("<a>").attr("href", "#").text(r.getName))
    }
    
    def showIssues(Repo r, JsArray<Issue> issues) {
    	$(".navbar .nav .active").remove
        $(".navbar .nav").append(activeRepositoryName(r))
        
        $("#Issues Backlog tbody tr").remove
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
            
            if (api.authorized) {
                "#Issues table".callTableDnD // drag and drop 
                
                $("#new-issue-button").click(newIssueClick(r, mss))
                $("#setting").fadeIn(1000)
                $("#milestones-button [name='new']").click(milestoneClick(r))
                $("#labels-button [name='new']").click(newLabelClick)
            }
        ])
    }
    
    def aMilestone(Milestone m) {
        $("<div>").addClass(m.cssClass)
            .append($("<h2>").text(m.title))
            .append($("<table>").addClass("table table-bordered table-striped")
                .append($("<tbody>")))
    }
    
    def newIssueClick(Repo r, Milestones mss) {
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
    
    def milestoneClick(Repo r) {
        clickEvent[
            val form = $("#milestone-form")
            form.find("[name='title']").gqVal("")
            form.find("[name='description']").gqVal("")
            form.fadeIn(1000)
            form.find("[name='submit']").click(clickEvent[
                val prop = new MilestoneForSave => [
                    setTitle(form.find("[name='title']").gqVal)
                    setDescription(form.find("[name='description']").gqVal)
                ]
                api.createMilestone(r, prop, callback[ms|
                    $("#Issues .milestones").append(aMilestone(ms))
                    form.fadeOut(1000)
                ])
                true
            ])
            form.find("[name='cancel']").click(clickEvent[
                form.fadeOut(1000)
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
