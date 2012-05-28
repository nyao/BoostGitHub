package nyao.client

import static com.google.gwt.query.client.GQuery.*
import static nyao.client.FunctionF.*

import com.google.gwt.core.client.EntryPoint
import com.google.gwt.user.client.ui.RootPanel
import com.google.gwt.user.client.ui.Label

class Hello implements EntryPoint {
	override onModuleLoad() {
		$("Button").click(func[
			RootPanel::get("Label").add(new Label("hello"))
			return true
		])
	}
}
