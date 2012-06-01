package nyao.client

import static com.google.gwt.query.client.GQuery.*
import static nyao.client.F.*
import static nyao.client.ConfigurableAsyncCallback.*

import com.google.gwt.core.client.EntryPoint
import com.google.gwt.core.client.GWT
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
            $("#Repositories").fadeIn(1000)
            api.getRepositories($("#Login").value, callback[
                onSuccessDo[addRepositories(it.data, "Repos")]
                onFailureDo[GWT::log("error", it)]
            ])
            true
        ])
        
        $("#TokenSubmit").click(func[
            $("#Repositories").fadeIn(1000)
            api.setAuthorization($("#Token").value)
            api.getMyRepository(callback[
                onSuccessDo[addRepositories(it.data, "Repos")]
                onFailureDo[GWT::log("error", it)]
            ])
            api.getOrganizations(callback[
                onSuccessDo[addOrgs(it)]
            ])
            true
        ])
        
        $("#toggleRepositories").click(func[$("#Repositories").fadeToggle(1000);true])
    }
    
    def addOrgs(GHUsers orgs) {
        $("#Repositories .Orgs table").remove
        orgs.data.each[
            val org = it as GHUser
            api.getRepositories(org.login, callback[
                onSuccessDo[addOrgRepositories(org, it.data)]
            ])
        ]
    }
    
    def addOrgRepositories(GHUser org, JsArray<Repository> rs) {
        $("#Repositories .Orgs")
            .append($("<table>").addClass("table table-bordered table-striped " + org.login)
                .append($("<thead>").append($("<tr>").append($("<th>").text(org.login))))
                .append($("<tbody>"))
        )
        addRepositories(rs, org.login)
    }
    
    def addRepositories(JsArray<Repository> rs, String kind) {
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
    
    def openIssues(Repository r) {
    	$("<a>").text(r.name + "(" + String::valueOf(r.openIssues) + ")")
                .attr("href", "#")
                .click(func [
                    api.getIssues(r, callback[
                        onSuccessDo[addIssues(r, it.data)]
                        onFailureDo[GWT::log("error", it)]
                    ])
                    true
                ])
    }
    
    def addRepository(Repository r, String kind) {
        $(".nav ." + kind + " ul").append($("<li>").append(openIssues(r)))
        $("#Repositories ." + kind + " tbody").append($("<tr>").append($("<td>").append(openIssues(r))))
    }
    
    def void addIssues(Repository r, JsArray<Issue> issues) {
    	$(".nav .active").remove
        $("#Repositories").fadeOut(1000)
        $("#Issues tbody tr").remove
        
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
