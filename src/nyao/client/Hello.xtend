package nyao.client

import static com.google.gwt.query.client.GQuery.*
import static nyao.client.F.*
import static nyao.client.ConfigurableAsyncCallback.*

import com.google.gwt.core.client.EntryPoint
import com.google.gwt.core.client.GWT
import com.github.nyao.gwtgithub.client.GitHubApi
import com.github.nyao.gwtgithub.client.models.Repository
import com.github.nyao.gwtgithub.client.models.Issue
import com.google.gwt.core.client.JsArray
import com.google.gwt.query.client.GQuery
import com.google.gwt.core.client.JavaScriptObject

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
            api.getRepositories($("#Login").value, callback[
                onSuccessDo[addRepositories(it.data)]
                onFailureDo[GWT::log("error", it)]
            ])
            true
        ])
        
        $("#TokenSubmit").click(func[
            api.setAuthorization($("#Token").value)
            api.getMyRepository(callback[
                onSuccessDo[addRepositories(it.data)]
                onFailureDo[GWT::log("error", it)]
            ])
            true
        ])
        
        $("#toggleRepositories").click(func[$("#Repositories").fadeToggle(1000);true])
    }
    
    def void addRepositories(JsArray<Repository> rs) {
        $("#Repositories .Mine tbody tr").remove
        rs.each([addRepository(it as Repository)])
    }
    
    def addRepository(Repository r) {
    	$("#Mine")
    		.append($("<li>"))
    			.append($("<a>").text(r.name + "(" + String::valueOf(r.openIssues) + ")")
    							.attr("href", "#")
    							.click(func [
                                        api.getIssues(r, callback[
                                            onSuccessDo[$("#CurrentRepositoryName").text(r.name);addIssues(it.data)]
                                            onFailureDo[GWT::log("error", it)]
                                        ])
                                        true
                                    ]))
    	
        $("#Repositories .Mine tbody")
            .append($("<tr>")
                .append($("<td>")
                    .append($("<a>").text(r.name + "(" + String::valueOf(r.openIssues) + ")")))
                    				.attr("href", "#")
                                    .click(func [
                                        api.getIssues(r, callback[
                                            onSuccessDo[$("#CurrentRepositoryName").text(r.name);addIssues(it.data)]
                                            onFailureDo[GWT::log("error", it)]
                                        ])
                                        true
                                    ]))
    }
    
    def void addIssues(JsArray<Issue> issues) {
    	$("#Repositories").fadeOut(1000)
        $("#Issues tbody tr").remove
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
