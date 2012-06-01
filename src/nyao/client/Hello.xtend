package nyao.client

import static com.google.gwt.query.client.GQuery.*
import static nyao.client.F.*
import static nyao.client.SimpleAsyncCallback.*

import com.google.gwt.core.client.EntryPoint
import com.github.nyao.gwtgithub.client.GitHubApi
import com.github.nyao.gwtgithub.client.models.Repository
import com.github.nyao.gwtgithub.client.models.Issue
import com.github.nyao.gwtgithub.client.models.GHUser
import com.google.gwt.core.client.JsArray
import com.google.gwt.query.client.GQuery
import com.google.gwt.core.client.JavaScriptObject
import com.github.nyao.gwtgithub.client.models.GHUsers

class Hello implements EntryPoint {
    val api = new GitHubApi();
    
    def getValue(GQuery gq) {
        gq.vals.get(0)
    }
    
    def each(JsArray<? extends JavaScriptObject> items, (JavaScriptObject) => void f) {
        var i = 0
        while (i < items.length) {
            val r = items.get(i)
            f.apply(r)
            i = i + 1
        }
    }
    
    override onModuleLoad() {
        $("#LoginSubmit").click(func[
            $("#Authorization").fadeOut(1000)
            $(".username").text($("#Login").value)
            $("#Repositories").fadeIn(1000)
            api.getRepositories($("#Login").value, onCallback[showRepositories(it.data, "Repos")])
            true
        ])
        
        $("#TokenSubmit").click(func[
            $("#Authorization").fadeOut(1000)
            $("#Repositories").fadeIn(1000)
            api.setAuthorization($("#Token").value)
            api.getUser(onCallback[$(".username").text(it.login)])
            api.getMyRepository(onCallback[showRepositories(it.data, "Repos")])
            api.getOrganizations(onCallback[showOrgs(it)])
            true
        ])
        
        $("#Repositories").hide
        $("#Issues").hide
        $("#User").click(func[$("#Authorization").fadeIn(1000);true])
    }
    
    def showOrgs(GHUsers orgs) {
        $("#Repositories .Orgs table").remove
        orgs.data.each[
            val org = it as GHUser
            api.getRepositories(org.login, onCallback[showOrgRepositories(org, it.data)])
        ]
    }
    
    def showOrgRepositories(GHUser org, JsArray<Repository> rs) {
        $("#Repositories .Orgs")
            .append($("<table>").addClass("table table-bordered table-striped " + org.login)
                .append($("<thead>").append($("<tr>").append($("<th>").text(org.login))))
                .append($("<tbody>"))
        )
        showRepositories(rs, org.login)
    }
    
    def showRepositories(JsArray<Repository> rs, String kind) {
        $(".nav ." + kind).remove
        $(".nav")
            .append($("<li>").addClass("dropdown " + kind)
                .append($("<a>").addClass("dropdown-toggle")
                                .attr("data-toggle", "dropdown")
                                .attr("href", "#")
                                .text(kind)
                                .append($("<b>").addClass("caret")))
                .append($("<ul>").addClass("dropdown-menu " + kind)))
        
        $("#Repositories ." + kind + " tbody tr").remove
        rs.each([addRepository(it as Repository, kind)])
    }
    
    def openIssuesAnchor(Repository r) {
        $("<a>").text(r.name + "(" + String::valueOf(r.openIssues) + ")")
                .attr("href", "#")
                .click(func [
                    api.getIssues(r, onCallback[showIssues(r, it.data)])
                    true
                ])
    }
    
    def addRepository(Repository r, String kind) {
        $(".nav ." + kind + " ul").append($("<li>").append(openIssuesAnchor(r)))
        $("#Repositories ." + kind + " tbody").append($("<tr>").append($("<td>").append(openIssuesAnchor(r))))
    }
    
    def void showIssues(Repository r, JsArray<Issue> issues) {
    	$(".nav .active").remove
        $("#Repositories").fadeOut(1000)
        $("#Issues tbody tr").remove
        
        $("#Issues").fadeIn(1000)
        $(".nav").append($("<li>").addClass("active").append($("<a>").attr("href", "#").text(r.name)))
        issues.each([addIssue(it as Issue)])
    }
    
    def addIssue(Issue issue) {
        $("#Issues tbody")
            .append($("<tr>")
                .append($("<td>")
                    .append($("<a>").attr("href",   issue.htmlUrl)
                                    .attr("target", "_blank")
                                    .text("#" + String::valueOf(issue.number))))
                .append($("<td>").text(issue.title)))
    }
}
