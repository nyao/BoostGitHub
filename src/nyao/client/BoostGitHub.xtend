package nyao.client

import com.github.nyao.gwtgithub.client.GitHubApi
import com.github.nyao.gwtgithub.client.api.AUser
import com.github.nyao.gwtgithub.client.api.Labels
import com.github.nyao.gwtgithub.client.api.Milestones
import com.github.nyao.gwtgithub.client.api.Users
import com.github.nyao.gwtgithub.client.models.GHUser
import com.github.nyao.gwtgithub.client.models.Repo
import com.github.nyao.gwtgithub.client.values.RepoValue
import com.google.gwt.core.client.EntryPoint
import java.util.ArrayList
import java.util.List
import nyao.client.ui.IssueUI
import nyao.client.ui.LabelForm
import nyao.client.ui.MilestoneForm
import nyao.client.ui.MilestoneUI
import nyao.client.ui.NewIssueForm
import com.github.nyao.gwtgithub.client.api.Issues
import com.github.nyao.gwtgithub.client.api.Repos
import com.google.gwt.user.client.Window

import static com.google.gwt.query.client.GQuery.*
import static nyao.util.SimpleAsyncCallback.*
import static nyao.util.XtendFunction.*

import static extension nyao.util.ConversionJavaToXtend.*
import static extension nyao.util.XtendGQuery.*
import static extension nyao.util.XtendGitHubAPI.*

class BoostGitHub implements EntryPoint {
    var GitHubApi api;
    
    override onModuleLoad() {
        $("#LoginSubmit").click(clickLogin)
        $("#TokenSubmit").click(clickToken)
        fulllInitial
        $("#Auth .close").click(clickEvent[$("#Auth").fadeOut(1000);true])
        $("#User").click(clickEvent[$("#Auth").fadeIn(1000);true])
    }
    
    def fulllInitial() {
        initialView
        $(".navbar .nav").children.remove
    }
    
    def initialView() {
        $("#Repos").hide
        $("#Issues").hide
        $("#setting").hide
        $("#new-issue-form").hide
        $("#milestone-form").hide
        $("#label-form").hide
        
        $("#Repos tbody tr").remove
        $("#Issues .Backlog tbody tr").remove
        $("#Issues .milestones").children.remove
    }
    
    def clickLogin() {
        clickEvent[
            fulllInitial
            $("#Token").gqVal("")
            $("#Auth").fadeOut(1000)
            $("#Repos").fadeIn(1000)
            val user = $("#Login").gqVal
            api = new GitHubApi()
            api.getUser(user, setUsername)
            api.getRepos(user, callback[showRepos(it, "Repos")])
            api.getOrgs(user, callback[showOrgs(it)])
            true
        ]
    }
    
    def clickToken() {
        clickEvent[
            fulllInitial
            $("#Login").gqVal("")
            $("#Auth").fadeOut(1000)
            $("#Repos").fadeIn(1000)
            api = new GitHubApi()
            api.setAccessToken($("#Token").gqVal)
            api.getUser(setUsername)
            api.getRepos(callback[showRepos(it, "Repos")])
            api.getOrgs(callback[showOrgs(it)])
            true
        ]
    }
    
    def setUsername() {
        callback[AUser user|
            $(".navbar .username").text(user.data.login)
            $(".navbar .avatar").attr("src", user.data.avatarUrl)
        ]
    }
    
    def showOrgs(Users orgs) {
        $("#Repos .Orgs table").remove
        orgs.data.each[org|
            api.getRepos(org.login, 
                         callback[showOrgRepos(org, it)])
        ]
    }
    
    def showOrgRepos(GHUser org, Repos rs) {
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
    
    def showRepos(Repos rs, String kind) {
        $(".navbar .nav").append(aOrgMenu(rs, kind))
        
        $("#Repos ." + kind + " tbody")
            .append(rs.data, [r|
                val elm =
                    $("<tr>")
                    .append($("<td>")
                        .append($("<img>").attr("src", r.owner.avatarUrl)
                                          .attr("height", "18px")
                                          .attr("width", "18px"))
                        .append($("<span>").text(r.getName).css("padding", "5px")))
                    .append($("<td>").text(r.openIssuesString))
                    .append($("<td>").text(r.getWatchersS))
                    .append($("<td>").text(r.getForksS))
                    .append($("<td>").text(r.getLanguage))
                if (r.hasIssues) {
                    elm.click(clickEvent[clickRepoOpen(r)]).css("cursor", "pointer")
                } else {
                    elm.click(clickEvent[clickDisableRepo(r);true]).css("opacity", "0.5")
                }
            ])
    }
    
    def aOrgMenu(Repos rs, String kind) {
        $("<li>").addClass("dropdown " + kind)
            .append($("<a>").addClass("dropdown-toggle")
                            .attr("data-toggle", "dropdown")
                            .attr("href", "#")
                            .text(kind)
                            .append($("<b>").addClass("caret")))
            .append($("<ul>").addClass("dropdown-menu " + kind)
                .append(rs.data, [$("<li>").append(aOpenIssues(it))]))
    }
    
    def aOpenIssues(Repo r) {
        $("<a>").text(r.getName + "(" + r.openIssuesString + ")")
                .attr("href", "#")
                .click(clickEvent[clickRepoOpen(r)])
    }
    
    def clickRepoOpen(Repo r) {
        $("#Repos").fadeOut(1000)
        initialView
        $(".navbar .nav .active").remove
        api.getIssues(r, callback[showRepo(r, it)])
        true
    }
    
    def clickDisableRepo(Repo r) {
        if (!api.authorized) {
            Window::alert("the repository issues is disable now.")
        } else if (Window::confirm("enable issues?")) {
            val prop = new RepoValue => [
                setName(r.name)
                setHasIssues(true)
            ]
            api.saveRepo(r, prop, callback[
                clickRepoOpen(r)
            ])
        }
    }
    
    def activeRepositoryName(Repo r) {
        $("<li>").addClass("active")
                 .append($("<a>").attr("href", "#").text(r.getName))
    }
    
    def showRepo(Repo r, Issues is) {
        $(".navbar .nav").append(activeRepositoryName(r))
        $("#Issues").fadeIn(1000)
        
        api.getMilestones(r, callback[ms|showMilestones(r, is, ms)])
    }
    
    def showMilestones(Repo r, Issues is, Milestones ms) {
        val mUIs = new ArrayList<MilestoneUI>
        ms.data.each([m|
            if ($("#Issues ." + m.cssClass).isEmpty) {
                val mUI = new MilestoneUI(m)
                mUIs.add(mUI)
                $("#Issues .milestones").append(mUI.elm)
            }
        ])
        mUIs.add(new MilestoneUI(null)) // Backlog
        
        api.getLabels(r, callback[ls| showIssuesWIthLabel(r, is, ms, mUIs, ls)])
    }
    
    def showIssuesWIthLabel(Repo r, Issues is, Milestones ms, List<MilestoneUI> mUIs, Labels ls) {
        val iUIs = new ArrayList<IssueUI>
        is.data.each([i|
            val iUI = new IssueUI(i, r, ls.data.toList, ms.data.toList, api)
            iUIs.add(iUI)
            mUIs.findFirst([
                it.m.cssClass == i.milestone.cssClass
            ]).append(iUI)
        ])
        
        if (api.authorized) {
            "#Issues table".callTableDnD // drag and drop 
            
            $("#setting").fadeIn(1000)
            new NewIssueForm(api, r, ls, ms, iUIs)
            new MilestoneForm(api, r, ms.data.toList, iUIs)
            new LabelForm(api, r, ls.data.toList, iUIs)
        }
    }
}
