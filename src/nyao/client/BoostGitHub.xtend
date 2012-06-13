package nyao.client

import com.github.nyao.gwtgithub.client.GitHubApi
import com.github.nyao.gwtgithub.client.api.Milestones
import com.github.nyao.gwtgithub.client.api.Users
import com.github.nyao.gwtgithub.client.models.GHUser
import com.github.nyao.gwtgithub.client.models.Issue
import com.github.nyao.gwtgithub.client.models.Repo
import com.github.nyao.gwtgithub.client.values.IssueForSave
import com.google.gwt.core.client.EntryPoint
import com.google.gwt.core.client.JsArray
import java.util.ArrayList
import java.util.List
import nyao.client.ui.IssueUI
import nyao.client.ui.MilestoneForm
import nyao.client.ui.MilestoneUI

import static com.google.gwt.query.client.GQuery.*
import static nyao.util.SimpleAsyncCallback.*
import static nyao.util.XtendFunction.*

import static extension nyao.util.ConversionJavaToXtend.*
import static extension nyao.util.XtendGQuery.*
import static extension nyao.util.XtendGitHubAPI.*
import nyao.client.ui.LabelForm

class BoostGitHub implements EntryPoint {
    val api = new GitHubApi();
    
    override onModuleLoad() {
        $("#LoginSubmit").click(clickEvent[
            initialView
            $("#Auth").fadeOut(1000)
            val user = $("#Login").gqVal
            $(".navbar .username").text(user)
            $("#Repos").fadeIn(1000)
            api.getRepos(user, callback[showRepos(it.getData, "Repos")])
            api.getOrgs(user, callback[showOrgs(it)])
            true
        ])
        
        $("#TokenSubmit").click(clickEvent[
            initialView
            $("#Auth").fadeOut(1000)
            $("#Repos").fadeIn(1000)
            api.setAccessToken($("#Token").gqVal)
            api.getUser(callback[$(".navbar .username").text(it.data.login)])
            api.getRepos(callback[showRepos(it.getData, "Repos")])
            api.getOrgs(callback[showOrgs(it)])
            true
        ])
        initialView
        $("#Auth .close").click(clickEvent[$("#Auth").fadeOut(1000);true])
        $("#User").click(clickEvent[$("#Auth").fadeIn(1000);true])
    }
    
    def initialView() {
        $("#Repos").hide
        $("#Issues").hide
        $("#setting").hide
        $("#new-issue-form").hide
        $("#milestone-form").hide
        $("#label-form").hide
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
            val milestoneList = new ArrayList<MilestoneUI>
            mss.data.each([ms|
                if ($("#Issues ." + ms.cssClass).isEmpty) {
                    val mUI = new MilestoneUI(ms)
                    milestoneList.add(mUI)
                    $("#Issues .milestones").append(mUI.elm)
                }
            ])
            milestoneList.add(new MilestoneUI(null)) // Backlog
            
            api.getLabels(r, callback[ls|
                val issueList = new ArrayList<IssueUI>
                issues.each([i|
                    val issue = new IssueUI(i, r, mss.data.toList, api)
                    issueList.add(issue)
                    milestoneList.findFirst([
                        it.milestone.cssClass.equals(i.milestone.cssClass)
                    ]).append(issue)
                ])
                
                if (api.authorized) {
                    "#Issues table".callTableDnD // drag and drop 
                    
                    $("#new-issue-button").click(clickNewIssue(r, mss, issueList))
                    $("#setting").fadeIn(1000)
                    new MilestoneForm(api, r, mss.data, issueList)
                    new LabelForm(api, r, ls.data, issueList)
                }
            ])
        ])
    }
    
    def clickNewIssue(Repo r, Milestones mss, List<IssueUI> issueList) {
        clickEvent[
            $("#new-issue-form").fadeIn(1000)
            $("#new-issue-form [name='submit']").click(clickEvent[
                    val prop = new IssueForSave => [
                        setTitle($("#new-issue-form [name='title']").gqVal)
                        setBody($("#new-issue-form [name='body']").gqVal)
                    ]
                    api.createIssue(r, prop, callback[
                        $("#new-issue-form").fadeOut(1000)
                        val issue = new IssueUI(it, r, mss.data.toList, api)
                        issueList.add(issue)
                        $("#Issues .Backlog tbody").append(issue.elm)
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
}
