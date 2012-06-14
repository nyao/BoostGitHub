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
import nyao.client.ui.LabelForm

import static com.google.gwt.query.client.GQuery.*
import static nyao.util.SimpleAsyncCallback.*
import static nyao.util.XtendFunction.*

import static extension nyao.util.ConversionJavaToXtend.*
import static extension nyao.util.XtendGQuery.*
import static extension nyao.util.XtendGitHubAPI.*
import com.github.nyao.gwtgithub.client.api.Labels

class BoostGitHub implements EntryPoint {
    val api = new GitHubApi();
    
    override onModuleLoad() {
        $("#LoginSubmit").click(clickEvent[
            initialView
            $("#Auth").fadeOut(1000)
            val user = $("#Login").gqVal
            $("#Repos").fadeIn(1000)
            api.getUser(user, callback[
                $(".navbar .username").text(it.data.login)
                $(".navbar .avatar").attr("src", it.data.avatarUrl)
            ])
            api.getRepos(user, callback[showRepos(it.getData, "Repos")])
            api.getOrgs(user, callback[showOrgs(it)])
            true
        ])
        
        $("#TokenSubmit").click(clickEvent[
            initialView
            $("#Auth").fadeOut(1000)
            $("#Repos").fadeIn(1000)
            api.setAccessToken($("#Token").gqVal)
            api.getUser(callback[
                $(".navbar .username").text(it.data.login)
                $(".navbar .avatar").attr("src", it.data.avatarUrl)
            ])
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
            .append(rs, [r|$("<tr>")
                            .append($("<td>").click(openIssueClick(r))
                                             .css("cursor", "pointer")
                                .append($("<img>").attr("src", r.owner.avatarUrl)
                                                  .attr("height", "18px")
                                                  .attr("width", "18px"))
                                .append($("<span>").text(r.getName).css("padding", "5px")))
                            .append($("<td>").text(r.openIssuesString))
                            .append($("<td>").text(r.getWatchersS))
                            .append($("<td>").text(r.getForksS))
                            .append($("<td>").text(r.getLanguage))
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
    
    def showIssues(Repo r, JsArray<Issue> is) {
    	$(".navbar .nav .active").remove
        $(".navbar .nav").append(activeRepositoryName(r))
        
        $("#Issues Backlog tbody tr").remove
        $("#Issues .milestones").children.remove
        $("#Issues").fadeIn(1000)
        
        api.getMilestones(r, callback[ms|
            val mUIs = new ArrayList<MilestoneUI>
            ms.data.each([m|
                if ($("#Issues ." + m.cssClass).isEmpty) {
                    val mUI = new MilestoneUI(m)
                    mUIs.add(mUI)
                    $("#Issues .milestones").append(mUI.elm)
                }
            ])
            mUIs.add(new MilestoneUI(null)) // Backlog
            
            api.getLabels(r, callback[ls|
                val iUIs = new ArrayList<IssueUI>
                is.each([i|
                    val iUI = new IssueUI(i, r, ls.data.toList, ms.data.toList, api)
                    iUIs.add(iUI)
                    mUIs.findFirst([
                        it.m.cssClass.equals(i.milestone.cssClass)
                    ]).append(iUI)
                ])
                
                if (api.authorized) {
                    "#Issues table".callTableDnD // drag and drop 
                    
                    $("#new-issue-button").click(clickNewIssue(r, ls, ms, iUIs))
                    $("#setting").fadeIn(1000)
                    new MilestoneForm(api, r, ms.data, iUIs)
                    new LabelForm(api, r, ls.data, iUIs)
                }
            ])
        ])
    }
    
    def clickNewIssue(Repo r, Labels ls, Milestones ms, List<IssueUI> iUIs) {
        clickEvent[
            val form = $("#new-issue-form") 
            form.fadeIn(1000)
            $("#new-issue-form [name='submit']").click(clickEvent[
                    val prop = new IssueForSave => [
                        setTitle(form.find("[name='title']").gqVal)
                        setBody(form.find("[name='body']").gqVal)
                    ]
                    api.createIssue(r, prop, callback[i|
                        form.fadeOut(1000)
                        val iUI = new IssueUI(i, r, ls.data.toList, ms.data.toList, api)
                        iUIs.add(iUI)
                        $("#Issues .Backlog tbody").append(iUI.elm)
                        ("#Issues .Backlog table").calltableDnDUpdate // drag and drop
                    ])
                    true
            ])
            form.find("[name='cancel']").click(clickEvent[
                form.fadeOut(1000)
                true
            ])
            true
        ]
    }
}
