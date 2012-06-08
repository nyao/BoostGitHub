package nyao.client

import com.github.nyao.gwtgithub.client.GitHubApi
import com.github.nyao.gwtgithub.client.api.Users
import com.github.nyao.gwtgithub.client.models.GHUser
import com.github.nyao.gwtgithub.client.models.Issue
import com.github.nyao.gwtgithub.client.models.Repository
import com.google.gwt.core.client.EntryPoint
import com.google.gwt.core.client.JsArray
import com.github.nyao.gwtgithub.client.models.Milestone

import static com.google.gwt.query.client.GQuery.*
import static nyao.util.SimpleAsyncCallback.*
import static nyao.util.XtendFunction.*

import static extension nyao.util.ConversionJavaToXtend.*
import static extension nyao.util.XtendGQuery.*
import nyao.client.ui.IssueUI

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
            api.getUser(callback[$(".username").text(it.data.login)])
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
        $(".navbar .nav ." + kind).remove
        $(".navbar .nav").append(aDropdownMenu(rs, kind))
        
        $("#Repositories ." + kind + " tbody tr").remove
        $("#Repositories ." + kind + " tbody")
            .append(rs, [$("<tr>").append($("<td>").append(aOpenIssues(it)))])
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
        $("<a>").text(r.name + "(" + String::valueOf(r.openIssues) + ")")
                .attr("href", "#")
                .click(clickEvent [
                    $("#Repositories").fadeOut(1000)
                    api.getIssues(r, callback[showIssues(r, it.data)])
                    true
                ])
    }
    
    def classForMilestone(Milestone m) {
        if (m == null || m.title.equals("Backlog")) "Backlog"
        else "milestone-" + m.number
    }
    
    def showIssues(Repository r, JsArray<Issue> issues) {
    	$(".navbar .nav .active").remove
        $("#Issues tbody tr").remove
        $("#Issues .milestones").children.remove
        
        $("#Issues").fadeIn(1000)
        $(".navbar .nav")
            .append($("<li>").addClass("active")
                .append($("<a>").attr("href", "#").text(r.name)))
        
        issues.map([it.milestone]).filterNull.forEach([
            if ($("#Issues ." + classForMilestone(it)).isEmpty) {
                $("#Issues .milestones").append(aMilestone(it))
            }
        ])
        
        issues.each([i|
            $("#Issues ." + classForMilestone(i.milestone) + " tbody").append(new IssueUI(i, r, api).elm)
        ])
        
        "#Issues table".callTableDnD // drag and drop
        
    }
    
    def aMilestone(Milestone m) {
        $("<div>").addClass(classForMilestone(m))
            .append($("<h2>").text(m.title))
            .append($("<table>").addClass("table table-bordered table-striped")
                .append($("<tbody>")))
    }
}
