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

class Hello implements EntryPoint {
    val api = new GitHubApi();
    
	override onModuleLoad() {
		$("#LoginSubmit").click(func[
            api.getRepositories($("#Login").vals.get(0), callback[
            	onSuccessDo[addRepositories(it.data)]
            	onFailureDo[GWT::log("error", it)]
            ])
			true
		])
		
		$("#TokenSubmit").click(func[
			api.setAuthorization($("#Token").vals.get(0))
            api.getMyRepository(callback[
            	onSuccessDo[addRepositories(it.data)]
            	onFailureDo[GWT::log("error", it)]
            ])
			true
		])
	}
	
	def void addRepositories(JsArray<Repository> rs) {
		$("#Repositories tbody tr").remove
		var i = 0
        while (i < rs.length) {
			val r = rs.get(i)
			addRepository(r)
			i = i + 1
        }
	}
	
	def addRepository(Repository r) {
        $("#Repositories tbody")
        	.append($("<tr>")
    		 	.append($("<td>").text(r.name)
                    .append($("<a>").attr("href",   r.htmlUrl)
                                    .attr("target", "_blank")
                                    .text("(_)")))
                .append($("<td>")
                	.append($("<a>").text(String::valueOf(r.openIssues))
                                    .click(func [
                                        api.getIssues(r, callback[
                                        	onSuccessDo[addIssues(it.data)]
            								onFailureDo[GWT::log("error", it)]
                                        ])
                                        true
                                    ]))))
        
	}
	
	def void addIssues(JsArray<Issue> issues) {
		$("#Issues tbody tr").remove
		var i = 0
        while (i < issues.length) {
			val issue = issues.get(i)
			addIssue(issue)
			i = i + 1
        }
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
