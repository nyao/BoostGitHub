package nyao.client

import static com.google.gwt.query.client.GQuery.*
import static nyao.client.F.*

import com.google.gwt.core.client.EntryPoint

class Hello implements EntryPoint {
	override onModuleLoad() {
		$("#Button").click(func[
			$("#Label").text("hello! " + $("#Name").vals.get(0))
			true
		])
	}
}
